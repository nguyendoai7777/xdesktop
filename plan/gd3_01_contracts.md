# gd3_01 — chốt hợp đồng + khung tệp cho các làn GĐ3

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
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

## 10. Đề xuất cải tiến
