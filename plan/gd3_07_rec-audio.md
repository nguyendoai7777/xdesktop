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

## 0. Bàn giao từ gd3_04 (30/10/2026)

<!-- handoff: gd3_04 -->

- **Đã có sẵn để dùng**: `Encoder::write_audio(&mut self, pcm: &[i16], pts: i64)`: PCM 48 kHz, 16-bit, stereo xen kẽ, `pts` 100 ns cùng đồng hồ với `Pacer`. Bộ thu phải tự đổi về đúng định dạng này. AAC 128 kbps.
- **Không phải lấp im lặng**: loopback không có gói khi máy im là bình thường. `Encoder` tự lấp khi âm trễ > 200 ms và khi `finish`; khoảng trống giữa hai gói cũng tự chèn.
- **Mốc lệch dưới 5 ms coi như liền mạch**, không bù. Trên 5 ms: chèn im lặng hoặc bỏ phần trùng, có thể nghe tiếng tách ⇒ tính `pts` từ đồng hồ thiết bị chuẩn, đừng từ giờ nhận gói có độ giật lớn.
- **`write_audio` cần `&mut Encoder`, cùng luồng với `write`**: thu âm đẩy gói qua kênh, vòng quay (gd3_06) rút hết gói trước mỗi `write`.
- **Bẫy đã gặp**: stream âm không có mẫu làm `WriteSample` của video bị chặn ~1 s / khung. Đã xử lý trong `Encoder`, đừng đi đường khác vòng qua nó (gd3_04 mục 9).
- **Soát lại khi làm**: `Options.audio = true`, rồi `mp4_verify <tệp>` in track `mp4a`, `audio_rms`, `track_gap_s`. Sóng sin thử sẵn trong `examples/pattern.rs`.

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
