# gd3_06 — tiến trình `fastcast-rec`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026), đường theo màn thật chờ kiểm tay ở gd3_13 |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | gd3_04, gd3_05 |
| Quyết định áp dụng | F-4, F-7, F-8 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/video/src/session.rs`, `crates/video/src/bin/fastcast-rec.rs`, `crates/video/src/lib.rs` (hai dòng `cfg`, xem mục 9); MỚI `crates/video/tests/session.rs` |

## 0. Bàn giao từ gd3_04 (30/10/2026)

<!-- handoff: gd3_04 -->

- **Đã có sẵn để dùng**: `encoder::{Encoder, Options, MIN_EDGE}`, `pacer::{Pacer, Tick}`, `size::{target_size, default_bitrate}`. Chữ ký không đổi so với stub. `Encoder` tự gọi `MFStartup` / `MFShutdown`, session không phải lo.
- **Thứ tự mỗi ô, bắt buộc**: `write_audio` hết gói đang có, RỒI `write` khung video. Ngược lại, âm trễ > 200 ms so với `pts` bị lấp im lặng và gói về sau bị bỏ. FPS thấp dễ dính nhất.
- **Âm im không phải lo**: không có gói nào thì `Encoder` tự lấp, `finish` lấp tới hết video. Đừng tự ghi im lặng. Lý do: gd3_04 mục 9 (Sink Writer chặn ~1 s / khung).
- **Phải ghi ít nhất một khung trước `finish`**: không thì `Internal`. Dừng ngay sau `Start` ⇒ ghi khung ghép hiện tại một lần.
- **`Abort`**: bỏ `Encoder` không `finish` là nhả tệp ngay, xoá `.part` được (có test).
- **Mã lỗi**: `Encoder` đã log HRESULT và đổi mã. Đĩa đầy / hết quyền ⇒ `OutputUnwritable`, mất device ⇒ `CaptureLost`, không dựng được bộ mã hoá ⇒ `NoEncoder`, cạnh < 34 px ⇒ `RegionTooSmall`. Gọi `describe` ngay sau `new` để gửi `RecEvent::Started`.
- **Đừng đếm giờ trước `Encoder::new`**: mở bộ mã hoá mất 20–60 ms (spike mục 7).
- **Soát lại khi làm**: thử không cần màn thật bằng hoạ tiết như `examples/common/mod.rs` (`render`, `verify`); `mp4_verify <tệp>` đọc mã vạch nếu nguồn có mã vạch. Chi tiết: `plan/gd3_04_video-encoder.md` mục 9.

## 0. Bàn giao từ gd3_05 (30/10/2026)

<!-- handoff: gd3_05 -->

- **Đã có sẵn để dùng**: `source::open(&job, &d3d) -> Result<Vec<Box<dyn Source>>, RecError>`; `source::rec_error(&windows::core::Error) -> RecError` đổi lỗi của `poll` (bố cục đổi ⇒ `DisplayChanged`, còn lại ⇒ `CaptureLost`, có log sẵn); `source::{create_device, create_bgra, monitors}`.
- **Biến dev**: `FASTCAST_REC_WINDOW=<hwnd>` ⇒ `open` quay cửa sổ đó, cắt theo `job.region.w/h`, bỏ qua `x`, `y`. Lấy HWND: `source_probe --serve --size 1280x720` in `hwnd=<số>`, giữ cửa sổ tới khi stdin đóng; tiến trình riêng nên CPU của luồng vẽ không lẫn vào `fastcast-rec`. Mã vạch giống spike, `mp4_verify` đọc được.
- **Đổi so với spec**: `WgcSource::for_window` thêm tham số `canvas: (u32, u32)`. `source::open` tự khai DPI per-monitor, bin không cần khai.
- **Chưa làm phần `.part` / khung ghép**: canvas do vòng quay tạo bằng `create_bgra(region.w, region.h)`; khe giữa các màn dựa vào texture mới là đen (D3D11 chưa cam kết trên giấy, thực tế đúng).
- **Bẫy**: `poll == true` không có nghĩa ảnh mới: WGC cửa sổ đưa ~140 khung / s dù cửa sổ vẽ 60 Hz. Đừng đếm `stale_ticks` theo đó để suy ra rớt khung; rớt khung thật tính bằng `Pacer` + mã vạch.
- **Bẫy**: chờ khung đầu như spike (tối đa 2 s, thoát khi mọi nguồn có khung). DXGI bật con trỏ chỉ đưa lên khi đã có khung màn. `poll` trả `Ok(false)` khi mất quyền (UAC, khoá màn), không phải lỗi; rút màn thì `Watched` báo trong ≤ 500 ms.
- **Bẫy**: nguồn theo màn chưa chạy lần nào (`plan/gd3_05_video-source.md` mục 9). Session không quay màn thật ⇒ nếu thấy lỗi ở đường theo màn, đó là `[owner-qa]`, không tự thử trên màn chủ dự án.
- **Soát lại khi làm**: `source_probe` (đọc đủ), `source_probe --resize` (`DisplayChanged`), rồi `fastcast-rec` với `FASTCAST_REC_WINDOW` giết giữa chừng theo mục 6.

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `fastcast_core::worker::{RecRequest, RecordJob, RecEvent, RecError, MIN_RECORD_EDGE, RECORD_FPS, RECORD_RES, send, recv}`; `bin/fastcast-rec.rs` là khung tối thiểu, **chưa có luồng đọc stdin** cho `Stop` / `Abort` (mẫu: `crates/ui/examples/fake_rec.rs`, đứt kênh = `Stop`).
- **Đã chốt**: `Abort` không có sự kiện nào nữa; `Failed` là sự kiện cuối; đích đã có ⇒ `OutputUnwritable`.
- **Nợ chuyển sang đây**: `res`, `fps` ngoài `RECORD_RES` / `RECORD_FPS` (config sửa tay) ⇒ từ chối trước khi mở; `RecError` chưa có mã riêng nên dùng `Internal` + log.
- **Bẫy**: stdout chỉ để nói giao thức. `fake_rec` thoát 1 khi `Failed`, stub bin hiện thoát 2 ⇒ UI không được dựa vào mã thoát.

## 1. Làm gì

- Vòng quay một luồng kiểu kéo theo `docs/spikes/video.md` mục 4, luồng `ABOVE_NORMAL`, không MMCSS.
- Dựng encoder trước khi đếm giờ (mở mất 20–60 ms), xả khung cũ trước khung đầu.
- `Start` → `Started`, `Progress` mỗi giây, `Stop` hoặc **stdin đóng** ⇒ `finish`, đổi `.part` thành tệp đích, `Finished`. `Abort` ⇒ xoá `.part`.
- Chặn trước khi mở: cạnh < `MIN_RECORD_EDGE` ⇒ `RegionTooSmall`; không tạo được `.part` ⇒ `OutputUnwritable`.
- Gọi `audio::start` khi `job.audio != None`; `AudioUnavailable` ⇒ `Failed`, không quay im lặng ngoài ý người dùng.
- Log không có đường dẫn đích.

## 2. Không làm trong task này

Thu âm thật (gd3_07, stub đã có). UI (gd3_10 → gd3_12).

## 2b. Phân vai

Toàn `[opus]`: vòng quay, luồng stdin, chốt tệp, test. `[owner-qa]`: đường theo màn thật, trong gd3_13.

## 3–4. Kiểu dữ liệu, code

Không có kiểu, IPC, khoá config mới. `session::run` theo chữ ký stub; thân nằm trong `#[cfg(windows)] mod win`. Thứ tự: chặn → `.part` → nguồn → khung đầu → encoder → xả khung cũ → `audio::start` → `Started` → đếm giờ.

## 5. Đo

Release, cửa sổ thử 1280×720 (`source_probe --serve`, tiến trình riêng nên CPU của luồng vẽ không lẫn vào), máy đang bận ~61 % do các làn khác. Một lượt, xem như độ lớn:

| 720p30, 60 s | Spike | gd3_06 |
| --- | --- | --- |
| CPU, % một nhân (chu kỳ / 2,9 GHz) | 4,1 % | 3,9 % |
| RAM Task Manager | 29,6 MB, có ảnh cửa sổ 3,7 MB | 26,7 MB, không có ảnh cửa sổ |
| Ô rớt | 0 / 1800 | 0 |
| Mã vạch đọc được | 1800 / 1800 | 1826 / 1826 |
| Cỡ tệp | 24,1 MB / 60 s | 25,5 MB / 60,9 s |

`Stop` → thoát tiến trình: 68 ms. Exe release 388 KB (`xcap` không vào exe, trả lời ghi chú gd3_01 trong `confirm.md`).

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ | Kết quả |
| --- | --- | --- | --- |
| C1 | Đang quay / `Stop` / `Finished`, thoát 0, MP4 đủ mã vạch, không còn `.part` | `[opus-unit]` `tests/session.rs` | ✅ |
| C2 | Đang quay / stdin đóng / như C1 | `[opus-unit]` | ✅ |
| C3 | Đang quay / `Abort` / không có `Finished` hay `Failed`, không `.part`, không đích | `[opus-unit]` | ✅ |
| C4 | Đích đã có / `Start` / `OutputUnwritable`, đích giữ nguyên; đích xuất hiện giữa lượt cũng không bị đè | `[opus-unit]` | ✅ |
| C5 | Cạnh 33 px / `Start` / `RegionTooSmall`, chưa tạo `.part` | `[opus-unit]` | ✅ |
| C6 | Thư mục không có / `Start` / `OutputUnwritable`; `res`, `fps` ngoài hợp đồng ⇒ `Internal` | `[opus-unit]` | ✅ |
| C7 | `Stop` ngay sau `Start` / / vẫn có ≥ 1 khung, `Finished` | `[opus-unit]` | ✅ |
| C8 | FPS 1 / `Stop` / thoát dưới 900 ms, không chờ hết ô | `[opus-unit]` | ✅ |
| C9 | Nguồn đổi cỡ giữa lượt / / `Failed { DisplayChanged }`, MP4 hợp lệ giữ lại | `[opus-unit]` | ✅ |
| C10 | HWND không tồn tại / `Start` / `CaptureLost`, không `.part`, không chạm màn | `[opus-unit]` | ✅ |
| C11 | Cửa sổ thử 720p30 60 s / đo / mục 5, `mp4_verify` đủ khung | `[opus-run]` | ✅ |
| C12 | `pwsh` đóng vai UI giữ stdin, quay 6 s / `Stop-Process -Force` nó / rec thoát sau 259 ms, `.mp4` 159 khung đọc đủ, không `.part` | `[opus-run]` | ✅ |
| C13 | Sau `Finished` / / tiến trình thoát, trả hết DLL | `[opus-run]` | ✅ thoát 0 |
| C14 | Âm loopback + cửa sổ thử 3 s (`audio_probe --tone` phát sóng nhỏ) / `Stop` / track `avc1` + `mp4a`, lệch track 7 ms, `audio_rms=63`, tệp đã xoá. Chỉ soát track, chưa soát tiếng khớp hình (C15) | `[opus-run]` | ✅ |
| C15 | Vùng thật trên màn, vắt hai màn, tiếng khớp hình bằng tai | `[owner-qa]`, gd3_13 | chờ |

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

- **gd3_13**: C15; UI chưa nói video còn được giữ khi mất nguồn giữa chừng (mục 10).

## 9. Bàn giao thực tế

- **Đã làm**: `crates/video/src/session.rs`, `crates/video/src/bin/fastcast-rec.rs`, `crates/video/tests/session.rs`.
- **Soát xanh** (`-p fastcast-video` theo luật làn, trên nhánh đã gộp `master`): clippy `-D warnings`, 41 + 15 + 10 test, `cargo deny check licenses`. Số đo: mục 5, chính thức lấy lại ở gd3_13.
- **Opus chọn 30/10/2026** (cũng ghi `plan/confirm.md`):
  - Mất nguồn giữa chừng (`DisplayChanged`, `CaptureLost`) ⇒ vẫn chốt và đặt tệp đích, rồi `Failed`. Lý do: "UI chết không mất video" nên cũng áp cho rút màn; hợp đồng không đổi vì `Failed` vẫn là sự kiện cuối. Chưa có khung nào hoặc `finish` hỏng thì xoá `.part`.
  - Đổi tên hỏng (đích xuất hiện giữa lượt, tệp bị khoá sau 5 lần thử) ⇒ `OutputUnwritable`, **giữ** `.part`: video đã quay xong, xoá là mất.
  - Không ghi đè bằng `fs::hard_link` (báo `AlreadyExists`), ổ không có hard link mới soát rồi `fs::rename`: `fs::rename` của Windows đè đích. `MoveFileExW` cần thêm feature vào `Cargo.toml`, tệp chung.
  - Cả `.part` có sẵn từ lượt trước của cùng đích ⇒ ghi đè: `.part` là của worker, không phải dữ liệu người dùng.
  - `res`, `fps` lạ ⇒ `Internal` + log (nợ gd3_01). `Stop` lúc còn chờ khung đầu ⇒ ghi khung ghép hiện tại, vẫn `Started` rồi `Finished` để UI thấy chuỗi đúng.
- **Khác spec**:
  - Sửa `lib.rs` ngoài tệp sở hữu: gd3_07 gộp trước, `session.rs` bỏ stub nên `unsupported` thành `dead_code` trên Windows, clippy đỏ. Hai dòng `#[cfg(not(windows))]`.
  - Spec viết "gọi `audio::start`" không nói thứ tự: đặt sau khi xả khung, ngay trước `Started`. `pts` 0 = lúc GỌI hàm (gd3_07 chốt lại ở `8b762a5`), nên session lấy mốc trước khi gọi, trừ `offset` khỏi `pts`, phần `pts` âm bị cắt. `offset` đo được 106 ms; bản gộp đầu lấy mốc sau khi hàm trả về, gặp mốc mới của gd3_07 thì tiếng trễ hình cỡ đó, đã sửa bằng nhánh `claude/gd3_06_origin`.
- **Bẫy**: `cargo fmt -p fastcast-video` cũng format `audio.rs` của gd3_07 ⇒ soát `git status` trước khi commit. `cargo test --test session` một mình không build `source_probe` ⇒ dùng `cargo test -p fastcast-video`.
- **Riêng tư**: không quay màn thật; mọi tệp thử đã xoá; loopback chỉ 3 s, không mở micro.
- **Chờ kiểm tay**: C15, `plan/_backlog.md`.

## 10. Đề xuất cải tiến

Lăng kính: bảo mật có (dưới); UI/UX có (dưới); RAM không có gì mới (26,7 MB, thoát 68 ms sau `Stop`); Pro không thêm, "độ nét trên 720p / GIF" đã ở `ROADMAP.md` GĐ4.

- [ux] Mất nguồn giữa chừng, UI báo lỗi mà không nói video còn trong thư mục — `session.rs` nhánh `lost`, gd3_11 chỉ `notice::show` theo mã — thêm chữ "đã lưu phần đã quay" hoặc biến thể sự kiện — người dùng khỏi tưởng mất video — S — P2. **Chưa làm**: đụng `worker.rs`, `i18n` (tệp chung) và gd3_11 đang mở; đã ghi vào gd3_13 mục 0.
- [bảo mật] Rec bị giết cứng hoặc sập để lại `.mp4.part` không phát được (`moov` ở cuối) mà vẫn chứa hình màn — chưa đo tần suất, suy từ `Part` chỉ dọn khi còn chạy — UI dọn `*.mp4.part` cũ trong `save.videoDir` khi bắt đầu quay — S — P3. **Chưa làm**: `ui/src/record` của làn gd3_11 đang mở; đã ghi vào gd3_13 mục 0.
- [ux] Sập giữa lượt mất cả video — spike mục 7 — thử `MFTranscodeContainerType_FMPEG4` — M — P3. **Vào backlog**: phải soát lại QuickTime, cần Mac.
