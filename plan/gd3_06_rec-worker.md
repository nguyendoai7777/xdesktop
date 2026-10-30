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
