# gd3_06 — tiến trình `fastcast-rec`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | gd3_04, gd3_05 |
| Quyết định áp dụng | F-4, F-7, F-8 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/video/src/session.rs`, `crates/video/src/bin/fastcast-rec.rs`; MỚI `crates/video/tests/session.rs` |

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

## 2b–5

Viết lúc bắt đầu task. Toàn `[opus]`. **Đo** trên cửa sổ thử, 720p30 60 s: CPU, RAM Task Manager, ô rớt, so spike (4,1 %, ~26 MB, 0 / 1800).

## 6. Nghiệm thu

- Test: `Stop`, stdin đóng, `Abort`, tệp đích đã có (không ghi đè), vùng quá nhỏ.
- `[opus-run]` Quay cửa sổ thử bằng biến dev của gd3_05, `mp4_verify` đủ khung; giết UI giả giữa chừng ⇒ tệp `.mp4` hợp lệ, không còn `.part`.
- Sau `Finished` tiến trình thoát, trả hết ~33 MB DLL.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
