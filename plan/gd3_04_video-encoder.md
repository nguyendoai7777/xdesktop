# gd3_04 — mã hoá MP4 H.264 + AAC

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd3_01 |
| Quyết định áp dụng | F-7, D-2 (cấm x264 / GPL) |
| Phụ thuộc mới | — (đã khai ở gd3_01) |
| File đụng tới | SỬA `crates/video/src/{size,pacer,encoder}.rs`; MỚI `crates/video/tests/encoder.rs`, `crates/video/examples/{pattern,mp4_verify}.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đổi so với spec**: `target_size` đã là mã thật ở `fastcast_core::worker` (cùng test), `video/src/size.rs` chỉ re-export, vì UI (gd3_10) cũng cần mà không phụ thuộc `fastcast-video`. Task này chỉ còn `default_bitrate` + `Pacer`.
- **Đã có sẵn để dùng**: `source::{D3d, create_device, create_bgra}` là mã thật (`crates/video/src/source/mod.rs`) để chạy hoạ tiết, không phải chờ gd3_05. Stub `encoder::{Options, Encoder}`, `Options` đã bỏ `Samples` (mẫu GPU), thêm `audio: bool`.
- **Đã chốt**: API `Encoder` trả `Result<_, RecError>`, HRESULT log và đổi mã ngay trong `encoder.rs` (< 34 px ⇒ `RegionTooSmall`). Đổi chữ ký thì ghi mục 9 cho gd3_06.
- **Soát lại khi làm**: `-p fastcast-video`; không sửa `Cargo.toml`, feature `windows` đã đủ theo spike + audio. Thiếu thì commit nhỏ riêng theo luật làn.

## 1. Làm gì

- `target_size`, `default_bitrate`, `Pacer`: chép từ `spikes/video/src/plan.rs` cùng test.
- `Encoder`: Video Processor (BGRA → NV12, co bằng GPU) + Sink Writer, mẫu GPU, BT.709, chuyển từ `spikes/video/src/encoder.rs`.
- **Ép container MPEG-4** bằng `MF_TRANSCODE_CONTAINERTYPE`: tệp có đuôi `.part`, Sink Writer không suy được từ đuôi.
- `describe()`: tên bộ mã hoá + có phải phần cứng không, để báo khi rơi về phần mềm (RAM ~×4, CPU ~×10).
- `write_audio`: thêm stream AAC, PCM 16-bit, mốc thời gian dùng chung đồng hồ với video.
- Chạy không cần màn thật: `examples/pattern.rs` vẽ hoạ tiết mã vạch (`pattern.rs` của spike) vào texture rồi mã hoá; `mp4_verify` giải mã lại đọc đủ khung.

## 2. Không làm trong task này

Nguồn khung (gd3_05), vòng quay (gd3_06), thu âm (gd3_07). Vòng texture + `IMFTrackedSample`. Fragmented MP4 (đề xuất 6 của gd0_06, cần QuickTime).

## 2b–5

Viết lúc bắt đầu task. Toàn `[opus]` (FFI). Soát bằng `-p fastcast-video`. **Đo**: 720p30 60 s từ hoạ tiết, CPU theo chu kỳ (`QueryProcessCycleTime`, không `GetProcessTimes`), RAM, cỡ tệp; so `docs/spikes/video.md` mục 2.

## 6. Nghiệm thu

- Test hàm thuần chép từ spike (C1, C3 gd0_06) xanh.
- `[opus-run]` `pattern` 720p30 + sóng sin ra MP4; `mp4_verify` đủ khung, có track AAC, thời lượng hai track lệch ≤ 1 khung.
- Vùng < 146 × 100 rơi về phần mềm ⇒ `describe` báo đúng; < 34 px ⇒ lỗi rõ, không panic.
- Không chụp màn người dùng trong mọi bước.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

QuickTime (C11 gd0_06): gd3_13 đưa vào danh sách kiểm tay.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
