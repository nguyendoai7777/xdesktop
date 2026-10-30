# gd3_01 — chốt hợp đồng + khung tệp cho các làn GĐ3

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~600 dòng, phần lớn là kiểu dữ liệu + stub (`todo` có kiểu, không logic) |
| Phụ thuộc | — (làm được ngay, song song với gd2_04 / gd2_05 vì không đụng `overlay/`) |
| Quyết định áp dụng | F-4, F-6, F-7, F-8, D-2, D-9; Q-1 (mục 3) |
| Phụ thuộc mới | `crates/video`: `windows` 0.62 (MIT / Apache-2.0, đã soát ở gd0_06) |
| File đụng tới | MỚI `crates/core/src/worker.rs`, `crates/video/src/{size,pacer,encoder,session,audio}.rs`, `crates/video/src/source/{mod,wgc,dxgi,compose}.rs`, `crates/video/src/bin/fastcast-rec.rs`, `crates/ocr/src/{lib,worker}.rs`, `crates/ocr/src/engine/mod.rs`, `crates/ui/src/ocr/{mod,client}.rs`, `crates/ui/src/record/{mod,client,frame,controls,finish}.rs`, `crates/ui/examples/{fake_ocr,fake_rec}.rs`; SỬA `crates/core/src/{lib,config}.rs`, `crates/ui/src/{main,commands,save}.rs`, `crates/ui/tests/ipc.rs`, `crates/video/Cargo.toml`, `crates/video/src/lib.rs`, `crates/ocr/src/main.rs`, `i18n/{vi,en}.toml`, `Cargo.lock`, `CLAUDE.md` |

## 1. Làm gì

Task này tồn tại để các task sau **không phải sửa chung tệp nào**. Xong task: mọi kiểu, thông điệp, khoá config, khoá i18n,
phụ thuộc, tệp stub của GĐ3 đã có và biên dịch được; mỗi làn chỉ điền phần thân tệp của mình.

- `fastcast_core::worker`: giao thức UI ↔ tiến trình con (mục 3), có test đọc / ghi JSON.
- Config: `record` (mục 3) có `#[serde(default)]`, test đọc file cũ.
- i18n: toàn bộ khoá GĐ3 (mục 7) trong `vi.toml` + `en.toml`.
- Stub biên dịch được cho mọi tệp ở dòng "File đụng tới", chữ ký đúng mục 3; hàm chưa làm trả lỗi `Unsupported` có log.
- `fake_ocr`, `fake_rec`: tiến trình giả nói đúng giao thức, trễ / lỗi chỉnh bằng tham số (`--delay-ms`, `--fail <code>`). Biến
  môi trường `FASTCAST_OCR_EXE`, `FASTCAST_REC_EXE` trỏ UI sang exe giả. Làn UI nhờ đó không cần engine thật.
- `record/mod.rs` nối sẵn hai biến chạy thử, chỉ có hiệu lực cùng `FASTCAST_OVERLAY_FAKE`: `FASTCAST_RECORD_REGION=x,y,w,h` gọi
  `record::start`, `FASTCAST_RECORD_FINISHED=<tệp mẫu>` gọi `finish::show`. gd3_11 và gd3_12 nhờ đó không cần overlay, không sửa `mod.rs` của nhau.
- **An toàn máy thật**: `tests/ipc.rs` + các lệnh ví dụ trong `CLAUDE.md` đổi từ `ocr_region` / `record_region` sang
  `open_settings`. Sau GĐ3 hai lệnh này mở overlay thật, chụp màn thật khi chạy test.
- `save.rs`: đổi `Target`, `Failure`, `ask_path`, `dialog_target`, `report_failure` thành `pub(crate)` (làn gd3_12 dùng lại), không đổi hành vi.
- `CLAUDE.md`: "ba tiến trình" ⇒ bốn (`fastcast-rec`), bảng crate, cách chạy `fake_ocr` / `fake_rec`, bẫy làn.

## 2. Không làm trong task này

Logic thật của bất kỳ làn nào. Không đụng `crates/ui/src/overlay/` (gd2_04 / gd2_05 đang sửa; gd3_08 đụng sau khi chúng gộp).
Không thêm `ort` (gd3_02 thêm, xem luật `Cargo.lock` ở `fastcast/ROADMAP.md` mục GĐ3).

## 2b. Phân vai

Toàn bộ `[opus]`: đây là interface giữa crate, sai ở đây thì mọi làn sai theo.

## 3. Kiểu dữ liệu · IPC · cấu hình

**Tiến trình con nói với UI qua stdin / stdout của chính nó** (JSON một dòng, mỗi lần một yêu cầu), không qua pipe của daemon:

- Daemon không đổi ⇒ không phải đo lại RAM daemon, không rộng thêm bề mặt của pipe (`_backlog.md`, gạch giả mạo pipe).
- UI chết ⇒ stdin đóng ⇒ con tự dọn. OCR thoát; quay thì **chốt tệp như `Stop`** rồi thoát, không mất video.
- `Role::Ocr` cũ trong `ipc.rs` giữ nguyên (luật "giữ biến thể cũ").

```rust
// crates/core/src/worker.rs — JSON camelCase, enum snake_case, cùng trần dòng `ipc::MAX_LINE`.
pub enum OcrRequest {
    /// `path`: RGBA thô `width × height × 4` trong `<data_dir>/tmp/`, cùng cách `ClipboardImage`. Bên nhận đọc xong xoá.
    Recognize { id: u64, path: PathBuf, width: u32, height: u32 },
    Shutdown,
}
pub enum OcrReply {
    Ready,
    Text { id: u64, text: PrivateText, ms: u32 },
    Failed { id: Option<u64>, code: OcrError },
}
pub enum OcrError { ModelMissing, ModelCorrupt, RuntimeMissing, ImageUnreadable, Internal }

pub enum RecRequest { Start(RecordJob), Stop, Abort }
pub struct RecordJob {
    pub region: RegionPx,        // toàn cục, pixel vật lý (F-3); core không phụ thuộc capture nên là struct trơn x, y, w, h
    pub output: PathBuf,         // tệp đích cuối cùng; worker ghi `<output>.part`, xong mới đổi tên
    pub res: u32,                // 480 | 720 — cạnh ngắn (F-7)
    pub fps: u32,                // 1..=60
    pub audio: AudioSource,
    pub cursor: bool,
}
pub enum RecEvent {
    Started { encoder: String, hardware: bool, width: u32, height: u32 },
    Progress { secs: u32, skipped: u32 },     // mỗi giây
    Finished { secs: u32, bytes: u64, skipped: u32 },
    Failed { code: RecError },
}
pub enum RecError {
    RegionTooSmall, NoEncoder, OutputUnwritable, DisplayChanged, CaptureLost, AudioUnavailable, Unsupported, Internal,
}
pub const MIN_RECORD_EDGE: u32 = 34;   // đo ở gd0_06: < 34 px ⇒ MF_E_INVALIDMEDIATYPE
```

```rust
// config.rs — khoá `record`, thiếu ⇒ mặc định.
pub struct RecordPrefs { pub res: u32 /* 720 */, pub fps: u32 /* 30 */, pub audio: AudioSource /* none */, pub cursor: bool /* true */ }
pub enum AudioSource { #[default] None, System, Mic }   // Q-1: xem dưới
```

Chữ ký stub làn nào cũng dựa vào:

```rust
// crates/ocr — lib + bin. Engine sau một trait để worker test được không cần model.
pub trait Recognizer { fn read(&mut self, image: &RgbaImage) -> Result<String, OcrError>; }
pub struct Engine;  impl Engine { pub fn load(models: &Path) -> Result<Engine, OcrError>; }  impl Recognizer for Engine {…}
pub fn worker::run<R: Recognizer>(load: impl FnOnce() -> Result<R, OcrError>, idle: Duration) -> ExitCode;

// crates/video
pub fn size::target_size(w: u32, h: u32, res: u32) -> (u32, u32);    // chép từ spike plan.rs
pub struct pacer::Pacer;                                             // chép từ spike plan.rs
pub trait source::Source { /* giữ nguyên trait của spike capture.rs:67 */ }
pub fn source::open(job: &RecordJob, d3d: &D3d) -> Result<Vec<Box<dyn Source>>, RecError>;
pub struct encoder::Encoder;  // new, write, write_audio(pcm: &[i16], pts: i64), describe, finish
pub fn audio::start(source: AudioSource, sink: Sender<AudioPacket>) -> Result<AudioCapture, RecError>;
pub fn session::run(job: RecordJob, control: Receiver<RecRequest>, events: impl FnMut(RecEvent)) -> Result<(), RecError>;

// crates/ui
pub fn ocr::recognize(job: CropJob, cx: &mut App, done: impl FnOnce(Result<String, OcrError>, &mut App) + 'static);
pub struct record::RecordStart { pub region: Rect, pub prefs: RecordPrefs, pub output: PathBuf }
pub fn record::start(req: RecordStart, cx: &mut App);
pub fn record::stop_if_recording(cx: &mut App) -> bool;              // `commands::dispatch` gọi đầu hàm với RecordRegion
pub fn record::finish::show(done: Finished, cx: &mut App);           // gd3_11 gọi, gd3_12 làm
```

**Opus chọn 30/10/2026 (Q-1)**: ba nguồn Không / Hệ thống / Micro, mặc định Không. "Cả hai" cần trộn + bù lệch đồng hồ giữa hai
thiết bị, để sau. Ghi `plan/confirm.md`, không ghi `docs/decisions.md`.

## 4. Code

- `crates/video/Cargo.toml`: khai đủ feature `windows` một lần (Graphics_Capture, Win32_Graphics_Direct3D11, Win32_Graphics_Dxgi,
  Win32_Media_MediaFoundation, Win32_Media_Audio, Win32_System_Com…) ⇒ gd3_04 → gd3_07 không phải sửa `Cargo.toml` / `Cargo.lock`.
- `crates/ui/Cargo.toml` không thêm `fastcast-video`, `fastcast-ocr`: UI chỉ biết exe + giao thức. Nhờ đó làn engine soát được bằng `-p`.
- Mã chỉ Windows đặt trong `#[cfg(windows)]`; OS khác trả `RecError::Unsupported` (macOS / Ubuntu ở GĐ4).

## 5. Đo

Không đổi `core` theo cách nặng thêm: `worker.rs` chỉ dùng serde có sẵn. Không cần đo lại RAM daemon nếu `cargo tree -p fastcast-daemon` không đổi.

## 6. Nghiệm thu

- **C1** `[opus-unit]` Mọi thông điệp `worker` đi vòng JSON; `Text` log ra chỉ thấy độ dài (`PrivateText`).
- **C2** `[opus-unit]` `config.json` cũ không có `record` đọc được, ra mặc định 720 / 30 / none / true.
- **C3** `[opus-unit]` Test i18n hai catalog cùng bộ khoá xanh.
- **C4** `[opus-run]` `fake_ocr`, `fake_rec` chạy từ stdin tay, trả đúng giao thức, `--fail` ra đúng mã.
- **C5** `[opus-run]` `cargo test -p fastcast-ui --test ipc` không mở overlay, không chụp màn (`grep` không còn `ocr_region` trong `tests/`).
- **C6** Soát đủ bốn lệnh; `cargo tree -p fastcast-ui` không có `fastcast-video`.

## 7. Ghi chú UI — khoá i18n (viết thường, memory `feedback-avoid-uppercase-ui`)

`[ocr]` `reading`, `result_title`, `empty`, `copied` ("đã chép {count} ký tự"), `copy_hint`, `error_model_missing`,
`error_model_corrupt`, `error_runtime_missing`, `error_failed`, `retry`.

`[record]` `setup_title`, `res`, `fps`, `fps_range`, `audio`, `audio_none`, `audio_system`, `audio_mic`, `cursor`, `start`,
`start_hint`, `too_small` ("vùng phải rộng và cao ít nhất {min} px"), `stop`, `elapsed`, `software_encoder`, `dropped`,
`finish_title`, `save`, `save_as`, `discard`, `discard_confirm`, `saved`, `error_no_encoder`, `error_output`,
`error_display_changed`, `error_capture_lost`, `error_audio`, `error_failed`.

## 8. Nợ chuyển task khác

Thân hàm: bảng làn ở `fastcast/ROADMAP.md` mục GĐ3.

## 9. Bàn giao thực tế

**Kết quả** (30/10/2026, Windows 10 máy nhà): C1, C2, C3, C5, C6 xanh. Soát sau khi gộp `master` (có gd2_04, gd2_05): `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test --no-fail-fast` (`core` 64, `ui` 189 + `ipc` 5 + `overlay` 32 + `picker` 6; phần bị bỏ qua là các bài đo `--ignored`), `cargo deny check licenses`. `cargo tree -p fastcast-ui` không có `fastcast-video`, `fastcast-ocr`.

- **C4** chạy tay qua stdin: `fake_ocr` đủ 5 mã `--fail`, sai cỡ ⇒ `image_unreadable`, tệp ảnh bị xoá, `--text ""`, `--die-after` thoát 3. `fake_rec` đủ 8 mã, `Stop`, stdin đóng ⇒ chốt tệp, đích đã có, `Abort` không còn `.part`, `--fail-after`, `--die-after`, vùng 33 px ⇒ `region_too_small`. Stub thật: `fastcast-ocr` ra `failed / internal`, `fastcast-rec` ra `failed / unsupported`, cùng thoát 2.
- **C5**: `grep` `ocr_region`, `record_region` trong `crates/ui/tests/` không còn dòng nào. Một test `record_dev_hooks_run_on_fake_overlay` đã viết và xanh (`FASTCAST_RECORD_REGION`, `FASTCAST_RECORD_FINISHED` trên màn giả) rồi **gỡ** để giữ đúng điều kiện này; biến chạy thử sẽ được `tests/record_control.rs`, `tests/record_save.rs` phủ lại.
- **Đo**: `cargo tree -p fastcast-daemon` giống hệt `master` (đã bỏ đường dẫn rồi so md5) ⇒ không đo lại RAM daemon.
- **Test đỏ một lần, lúc máy đang build song song**: `fake_save_writes_exact_pixels_across_monitors` (hết giờ chờ log; riêng 2 lần xanh), `fake_color_panel_picks_a_color_and_hex_typing_does_not_trigger_tools` của gd2_05 (hết giờ chờ thoát; riêng 3 lần xanh). Chạy lại cả tệp `overlay` đều xanh. Đúng loại đã ghi ở `ROADMAP.md`; `save.rs` chỉ đổi visibility.
- **Gộp `master`**: xung đột `crates/core/src/config.rs` (`record` cạnh `annotate` của gd2_05), giữ cả hai.
- **Chưa kiểm**: nhánh OS khác của `crates/video`, `crates/ocr` chưa biên dịch thử (máy không có target Linux / macOS). Không có việc kiểm tay.

**Khác spec, Opus chọn 30/10/2026 (D-9, đã ghi `plan/confirm.md`)**

- `target_size` là mã thật ở `fastcast_core::worker`, `video::size` re-export: spec tự mâu thuẫn, gd3_10 cần hàm này trong UI mà UI không được phụ thuộc `fastcast-video`.
- `source::{D3d, create_device, create_bgra}` là mã thật: gd3_04 chạy song song với gd3_05 cần device.
- `crates/ocr/Cargo.toml` phải sửa (dòng "File đụng tới" thiếu): thêm `[lib]`, `fastcast-core`, `image`, `log`. `crates/video` thêm `fastcast-capture` để dùng `geometry`.
- Thêm ngoài mục 3: `worker::{send, recv, parse_code, exe_path, target_size}`, hằng `OCR_EXE_VAR`, `REC_EXE_VAR`, `OCR_EXE`, `REC_EXE`, `RECORD_FPS`, `RECORD_RES`; `record::dev_hook`; `encoder::Options`; `audio::{AudioPacket, AudioCapture}`; `pacer::Tick`; `compose::Blit`; `finish::Finished`.
- Exe giả có thêm cờ cho ca của làn sau: `fake_ocr --text`, `--die-after`; `fake_rec --fail-after`, `--die-after`, `--software`, `--skipped`.
- Hai biến `FASTCAST_RECORD_*` kích hoạt qua lệnh `record_region` trong `commands::dispatch`, vì `app.rs` không thuộc tệp của task.
- `OcrError` không có `Unsupported` (đúng mục 3) ⇒ stub OCR trả `Internal`. Hàm không trả `Result` (`Pacer`, `default_bitrate`) dùng `todo!`, chưa ai gọi tới.
- Hai exe con đặt `windows_subsystem = "windows"` ở bản release như `fst`, `fastcast-ui`.

**Soi cải tiến**: bảo mật / riêng tư: `Text` chỉ log độ dài, log không ghi đường dẫn. UI/UX: không áp, chưa có giao diện; khoá i18n viết thường. RAM: daemon không đổi. Pro: không áp.

## 10. Đề xuất cải tiến

- `[bảo mật]` `worker::exe_path` nhận `FASTCAST_OCR_EXE` / `FASTCAST_REC_EXE` ở cả bản release (`crates/core/src/worker.rs`, hàm `exe_path`) — đề xuất: gd3_13 đo xong thì cân nhắc chỉ cho bản debug hoặc đi cùng `FASTCAST_OVERLAY_FAKE` — giá trị: bớt một đường chạy exe lạ, thấp vì kẻ đặt được biến môi trường đã chạy được mã — cỡ S — P3. Không làm trong lượt: làm bây giờ thì gd3_13 không đo được; đã ghi `plan/confirm.md`.
