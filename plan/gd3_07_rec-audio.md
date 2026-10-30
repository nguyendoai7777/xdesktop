# gd3_07 — thu âm hệ thống / micro

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd3_04 |
| Quyết định áp dụng | F-7, Q-1 (Opus chọn ở gd3_01: Không / Hệ thống / Micro) |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/video/src/audio.rs`; MỚI `crates/video/examples/audio_probe.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: stub `crates/video/src/audio.rs` (`AudioPacket { pcm: Vec<i16>, pts: i64 }`, `AudioCapture`, `start`). Feature `Win32_Media_Audio`, `Win32_Media_KernelStreaming`, `Win32_Media_Multimedia`, `Win32_Devices_FunctionDiscovery`, `Win32_System_Com_StructuredStorage`, `Win32_System_Variant` đã khai, chưa dùng thử: thiếu thì commit nhỏ riêng.
- **Đã chốt**: `pts` đơn vị 100 ns, cùng `Encoder::write_audio`. `audio` là module đa nền ⇒ thân WASAPI bọc `#[cfg(windows)]`, OS khác trả `Unsupported`.

## 1. Làm gì

- `audio::start`: WASAPI, `System` = loopback thiết bị phát mặc định, `Mic` = thiết bị thu mặc định. Luồng riêng, gửi `AudioPacket { pcm, pts }` qua kênh.
- Đổi về 48 kHz, 16-bit, stereo trước khi đưa encoder. Im lặng ở loopback (không có khung âm) ⇒ tự chèn khoảng lặng để không lệch tiếng với hình.
- Micro bị OS chặn quyền, không có thiết bị ⇒ `AudioUnavailable`.
- `audio_probe`: thu N giây ra MP4 qua `Encoder`.

## 2. Không làm trong task này

"Cả hai" (trộn, bù lệch đồng hồ). Chọn thiết bị cụ thể. Sửa `session.rs` (gd3_06 đã gọi qua chữ ký stub).

## 2b–5

Viết lúc bắt đầu task. Toàn `[opus]`. **Riêng tư**: `[opus-run]` chỉ thu loopback 2 s rồi xoá tệp ngay, KHÔNG mở micro trên máy chủ dự án.

## 6. Nghiệm thu

- Test: đổi mẫu, chèn khoảng lặng, tính `pts` một giờ không trôi.
- `[opus-run]` Loopback 2 s ra MP4 có track AAC đúng thời lượng; tệp đã xoá.
- `[owner-qa]` Micro + âm hệ thống 60 s cùng video: tiếng khớp hình; rút tai nghe giữa chừng không treo.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
