#!/usr/bin/env node
// Build, mở app, rồi theo dõi mã nguồn: lưu tệp (hay session khác gộp vào master) ⇒ build lại ⇒ đóng app cũ, mở app mới.
// start.* gọi thay cho `cargo build` + chạy exe (mặc định bật, tắt bằng --no-watch / XDESKTOP_NO_WATCH=1):
//   node tools/watch-run.mjs --watch groove/crates --watch materiant/src --exe groove/target/start/debug/groove \
//     [--arg <đối số app>]… -- --manifest-path groove/Cargo.toml -p groove-app
// Sau `--` là đối số của `cargo build`, build qua tools/cargo-prune.mjs (dọn bản build cũ). Build lỗi lần đầu ⇒ thoát;
// build lỗi khi đang chạy ⇒ giữ app cũ, in lỗi, chờ lần lưu sau. Exe không đổi (sửa tệp không ảnh hưởng mã) ⇒ không mở lại.
// Đóng cửa sổ app (app tự thoát) ⇒ lệnh này thoát theo; Ctrl+C ⇒ đóng app rồi thoát.
// `--scope <desktop id>` (Linux có systemd): app chạy trong scope riêng `app-xdesktop-<id>-<số>.scope` như GNOME mở app, để
// trình theo dõi tài nguyên (Mission Center…) hiện app thành dòng riêng thay vì gộp vào terminal đã gọi lệnh.
// Không có hot reload thật: mở lại là tiến trình mới, mất trạng thái đang mở (trang, hộp thoại); vị trí cửa sổ app tự nhớ.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const prune = path.join(path.dirname(fileURLToPath(import.meta.url)), 'cargo-prune.mjs');
const argv = process.argv.slice(2);
const split = argv.indexOf('--');
const own = split < 0 ? argv : argv.slice(0, split);
const buildArgs = split < 0 ? [] : argv.slice(split + 1);
const watchDirs = [];
const appArgs = [];
let exe;
let scope;
for (let i = 0; i < own.length; i += 2) {
  const [flag, value] = [own[i], own[i + 1]];
  if (flag === '--watch') watchDirs.push(value);
  else if (flag === '--exe') exe = value;
  else if (flag === '--arg') appArgs.push(value);
  else if (flag === '--scope') scope = value;
  else fail(`đối số lạ: ${flag}`);
}
if (!exe || !watchDirs.length) fail('cần --exe và ít nhất một --watch');

// Thư mục sinh ra / không phải mã của ta: đổi trong đó không build lại (và không gắn inotify vào hàng nghìn thư mục build).
const ignored = /(^|[\\/])(target|\.git|node_modules|dist|release|spikes)([\\/]|$)|(~|\.swp|\.swx|\.tmp|4913)$/;

let app = null;
let quitting = false;
let building = false;
let again = false;
let timer = null;

function fail(message) {
  console.error(`watch-run: ${message}`);
  process.exit(2);
}

function build() {
  return new Promise((resolve) => {
    const child = spawn(process.execPath, [prune, 'build', ...buildArgs], { stdio: 'inherit' });
    child.on('close', (code) => resolve(code === 0));
  });
}

function mtime() {
  return fs.statSync(exe, { throwIfNoEntry: false })?.mtimeMs ?? 0;
}

// `systemd-run --scope` tạo scope rồi exec đúng exe ⇒ pid con vẫn là app, kill như thường.
const useScope = scope && process.platform === 'linux' && hasSystemdRun();
function hasSystemdRun() {
  return (process.env.PATH ?? '').split(path.delimiter).some((d) => fs.existsSync(path.join(d, 'systemd-run')));
}

let launches = 0;
function launch() {
  const [cmd, args] = useScope
    ? ['systemd-run', ['--user', '--scope', '--quiet', `--unit=app-xdesktop-${scope}-${process.pid}${launches++}`, '--', exe, ...appArgs]]
    : [exe, appArgs];
  const child = spawn(cmd, args, { stdio: 'inherit' });
  app = child;
  child.on('exit', (code, signal) => {
    if (app !== child) return; // bị thay bằng bản mới
    app = null;
    if (!quitting) {
      console.error(`watch-run: app đã đóng (${signal ?? code}), thoát.`);
      cleanup();
      process.exit(code ?? 0);
    }
  });
}

function stop(child) {
  return new Promise((resolve) => {
    if (!child || child.exitCode !== null || child.signalCode !== null) return resolve();
    const force = setTimeout(() => child.kill('SIGKILL'), 3000);
    child.once('exit', () => {
      clearTimeout(force);
      resolve();
    });
    child.kill('SIGTERM');
  });
}

async function rebuild() {
  if (building) {
    again = true;
    return;
  }
  building = true;
  do {
    again = false;
    const before = mtime();
    console.error('watch-run: mã đổi, build lại…');
    const ok = await build();
    if (!ok) console.error('watch-run: build lỗi, giữ app đang chạy; sửa rồi lưu lại.');
    else if (mtime() === before) console.error('watch-run: exe không đổi, không mở lại.');
    else {
      const old = app;
      app = null;
      await stop(old);
      if (quitting) break;
      launch();
      console.error('watch-run: đã mở bản mới.');
    }
  } while (again && !quitting);
  building = false;
}

const watchers = [];
function cleanup() {
  for (const w of watchers) w.close();
  clearTimeout(timer);
}

async function quit() {
  quitting = true;
  cleanup();
  await stop(app);
  process.exit(130);
}
process.on('SIGINT', quit);
process.on('SIGTERM', quit);

if (!(await build())) process.exit(1);
launch();
for (const dir of watchDirs) {
  if (!fs.existsSync(dir)) continue;
  const recursive = fs.statSync(dir).isDirectory();
  watchers.push(
    fs.watch(dir, { recursive }, (_, name) => {
      if (name && ignored.test(String(name))) return;
      clearTimeout(timer);
      timer = setTimeout(rebuild, 400);
    }),
  );
}
console.error(`watch-run: theo dõi ${watchDirs.join(', ')} — lưu tệp là mở lại app; Ctrl+C để thoát.`);
