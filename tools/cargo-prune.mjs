#!/usr/bin/env node
// Chạy `cargo <lệnh build…>` rồi dọn bản build cũ trong thư mục build vừa dùng. start.* / build.* gọi thay cho `cargo build`:
//   node tools/cargo-prune.mjs build --manifest-path materiant/Cargo.toml -p materiant --example gallery
// Cargo không tự xoá bản cũ: mỗi lần đổi feature / cờ / bản vá / toolchain lại thêm một bản `lib<crate>-<hash>` mới.
// Cách dọn: `--message-format=json` cho biết hash của mọi artifact lệnh này dùng; hash đó ghi vào sổ
// `<profile>/.prune-ledger.json` kèm ngày. Trong `.fingerprint/`, `deps/`, `build/`, `examples/`, bản nào cùng crate cùng loại
// (lib, build script, test…) với một hash trong sổ mà chính nó không có trong sổ thì là bản cũ ⇒ xoá. Loại không lộ hash
// (bin, example uplift) không bị xoá. `incremental/` của crate nào lâu hơn XDESKTOP_PRUNE_DAYS (mặc định 7) ngày chưa đụng
// thì xoá. Build lỗi thì không dọn. Thư mục build của worktree cố định (`target/w<N>`, D-18) chỉ build, không dọn: session
// đó còn cache clippy / test mà lệnh này không thấy. XDESKTOP_NO_PRUNE=1 ⇒ chỉ build.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const days = Number(process.env.XDESKTOP_PRUNE_DAYS ?? 7);
const keepMs = days * 24 * 3600 * 1000;
const hashRe = /-([0-9a-f]{16})(?=[.\\/]|$)/g;

const args = process.argv.slice(2);
const child = spawn('cargo', [...args, '--message-format=json-render-diagnostics'], {
  stdio: ['inherit', 'pipe', 'inherit'],
});
process.on('SIGINT', () => {}); // Ctrl+C tới cả cargo; đợi nó thoát rồi trả mã thoát của nó.

const used = new Set();
const profiles = new Set();
let pending = '';
child.stdout.on('data', (chunk) => {
  const lines = (pending + chunk).split('\n');
  pending = lines.pop();
  for (const line of lines) collect(line);
});

function collect(line) {
  if (!line.startsWith('{')) return;
  let msg;
  try { msg = JSON.parse(line); } catch { return; }
  const paths = [...(msg.filenames ?? []), msg.executable, msg.out_dir].filter(Boolean);
  for (const p of paths) {
    for (const m of p.matchAll(hashRe)) used.add(m[1]);
    // `<profile>/deps/…`, `<profile>/build/<pkg>-<hash>/…`, `<profile>/examples/…` ⇒ thư mục profile.
    const parts = path.resolve(p).split(path.sep);
    const i = parts.findLastIndex((s) => s === 'deps' || s === 'build' || s === 'examples');
    if (i > 0) profiles.add(parts.slice(0, i).join(path.sep));
  }
}

child.on('close', (code) => {
  collect(pending);
  if (code !== 0) process.exit(code ?? 1);
  if (process.env.XDESKTOP_NO_PRUNE !== '1') {
    for (const profile of profiles) {
      if (profile.split(path.sep).some((s) => /^w\d+$/.test(s))) continue;
      try { prune(profile); } catch (e) { console.error(`dọn ${profile}: ${e.message}`); }
    }
  }
  process.exit(0);
});

function prune(profile) {
  const now = Date.now();
  const ledgerFile = path.join(profile, '.prune-ledger.json');
  let ledger = {};
  try { ledger = JSON.parse(fs.readFileSync(ledgerFile, 'utf8')); } catch {}
  for (const h of used) ledger[h] = now;
  for (const [h, t] of Object.entries(ledger)) if (now - t > keepMs) delete ledger[h];
  fs.writeFileSync(ledgerFile, JSON.stringify(ledger));
  const kept = new Set(Object.keys(ledger));

  // Mỗi thư mục `.fingerprint/<pkg>-<hash>` chứa tệp loại (`lib-gpui`, `bin-x`, `test-lib-x`, `run-build-script-…`); một hash có
  // thể mang nhiều loại (bin + example không có metadata riêng). Hash cũ khi mọi loại nó mang đều có bản đang dùng khác.
  const fpDir = path.join(profile, '.fingerprint');
  const units = [];
  const live = new Set();
  for (const name of ls(fpDir)) {
    const m = /^(.+)-([0-9a-f]{16})$/.exec(name);
    if (!m) continue;
    const kinds = ls(path.join(fpDir, name))
      .filter((f) => !f.endsWith('.json') && !f.startsWith('dep-') && !f.startsWith('output-') && f !== 'invoked.timestamp')
      .map((k) => `${m[1]}|${k}`);
    units.push({ hash: m[2], kinds });
    if (kept.has(m[2])) kinds.forEach((k) => live.add(k));
  }
  const stale = new Set(
    units.filter((u) => !kept.has(u.hash) && u.kinds.length && u.kinds.every((k) => live.has(k))).map((u) => u.hash),
  );

  let freed = 0;
  let removed = 0;
  const rm = (p) => {
    const size = du(p);
    try { fs.rmSync(p, { recursive: true, force: true }); freed += size; removed++; } catch {} // tệp đang chạy (Windows) ⇒ để lần sau
  };
  for (const sub of ['.fingerprint', 'deps', 'build', 'examples']) {
    const dir = path.join(profile, sub);
    for (const name of ls(dir)) {
      const hashes = [...name.matchAll(hashRe)].map((m) => m[1]);
      if (hashes.length && hashes.every((h) => stale.has(h))) rm(path.join(dir, name));
    }
  }
  const incDir = path.join(profile, 'incremental');
  for (const name of ls(incDir)) {
    const p = path.join(incDir, name);
    if (now - fs.statSync(p).mtimeMs > keepMs) rm(p);
  }
  if (removed) console.error(`dọn ${profile}: xoá ${removed} mục cũ, nhẹ đi ${(freed / 2 ** 30).toFixed(2)} GB`);
}

function ls(dir) {
  try { return fs.readdirSync(dir); } catch { return []; }
}

function du(p) {
  const st = fs.lstatSync(p, { throwIfNoEntry: false });
  if (!st) return 0;
  if (!st.isDirectory()) return st.size;
  return ls(p).reduce((sum, name) => sum + du(path.join(p, name)), 0);
}
