# gd4_19 — macOS: âm thanh khi quay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Máy | Viết + `cargo check --target` được trên máy nhà; ✅ cuối cần chạy trên Mac |
| Repo | fastcast |
| Cỡ | M — ~420 dòng |
| Phụ thuộc | gd4_12 |
| Quyết định áp dụng | D-3, F-7 |
| Phụ thuộc mới | — (`objc2-*` đã có ở khối macOS của `crates/video/Cargo.toml`) |
| File đụng tới | SỬA `crates/video/src/audio.rs` (chỉ nhánh `cfg`), `crates/video/src/macos/{mod,writer,portable}.rs` |

## 0. Bàn giao từ gd4_12 (30/10/2026)

<!-- handoff: gd4_12 -->

- **Đã có sẵn để dùng**: `macos/writer.rs::Writer` (mới có input video), `macos/capture.rs` (mẫu `define_class!` cho `SCStreamOutput`, `Handoff` chuyển giá trị ObjC qua kênh, `check_permission`), `macos/portable.rs` (hàm thuần, test chạy được trên Windows: nên đặt hàm đổi định dạng âm và căn `pts` ở đây).
- **Sửa khi làm**: bỏ nhánh `AudioUnavailable` đầu `macos::run`; test `audio_is_reported_unavailable_until_gd4_19` trong `tests/macos.rs`. `audio.rs` còn nhánh `not(windows)` chung với Linux: đổi `cfg` như đã làm ở `session.rs`.
- **Bẫy**: `objc2-*` cần bật feature tường minh khi phương thức biến mất lúc biên dịch (`objc2-core-media` của `objc2-av-foundation`). `cargo fmt -p fastcast-video` đụng `audio.rs` nhánh Windows: soát `git status`. Vòng quay chạy không có `NSApplication`, callback đi trên hàng đợi riêng, mọi chỗ gọi ObjC ở luồng quay cần `autoreleasepool`.
- **Soát lại khi làm**: `AVCaptureSession` có dùng đồng hồ host hay không phải kiểm trên Mac (`pts` âm dựa vào đó). `plan/gd4_12_macos-video.md` mục 9.

Tách từ gd4_12 ngày 30/10/2026, trước khi code: gd4_12 ước lượng lại ~1.210 dòng, vượt trần 900. Cắt ra ~420 dòng âm thanh, gd4_12 còn ~790 dòng.

## 1. Làm gì

- `audio::start` nhánh macOS, đúng hợp đồng `AudioPacket` (PCM 48 kHz, 16-bit, stereo; `pts` 0 = lúc gọi `start`), dùng lại `Converter` + `PacketClock` của `audio.rs`.
- `AudioSource::System`: `SCStream` riêng, chỉ âm (`capturesAudio`, 48 kHz, 2 kênh). `AudioSource::Mic`: `AVCaptureDevice` + `AVCaptureAudioDataOutput`, có hộp thoại xin quyền; đọc định dạng thật từ `CMAudioFormatDescription`.
- `writer.rs`: thêm `AVAssetWriterInput` AAC 128 kbps + `write_audio` (dựng `CMSampleBuffer` từ PCM, chèn im lặng khi âm trễ > 200 ms như `encoder.rs` trên Windows).
- `macos/mod.rs`: bỏ nhánh trả `AudioUnavailable` trong `run`, thêm `AudioFeed` + `rebase_audio` như `session.rs`.

## 2. Không làm trong task này

Sửa nhánh Windows. Trộn âm hệ thống với micro (F-7 chỉ chọn một nguồn).

## 6. Nghiệm thu

- [ ] `cargo check --locked --target aarch64-apple-darwin -p fastcast-video` + `cargo test -p fastcast-video` trên Windows.
- [ ] Trên Mac: quay kèm âm hệ thống, kèm micro: tiếng khớp hình, từ chối quyền micro ra `AudioUnavailable`.
- Chưa chạy được trên Mac ⇒ ghi `✅ mã — chờ chạy trên Mac`, gạch `_backlog.md`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
