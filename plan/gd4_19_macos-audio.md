# gd4_19 — macOS: âm thanh khi quay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ mã + phần không cần quyền chạy trên Mac (31/10/2026) — tiếng thật chờ chủ dự án (`_backlog.md`) |
| Máy | Viết + `cargo check --target` được trên máy nhà; ✅ cuối cần chạy trên Mac |
| Repo | fastcast |
| Cỡ | M — ~420 dòng |
| Phụ thuộc | gd4_12 |
| Quyết định áp dụng | D-3, F-7 |
| Phụ thuộc mới | `objc2-core-audio-types` (Zlib / Apache-2.0 / MIT, đã có trong lock) |
| File đụng tới | SỬA `crates/video/src/audio.rs` (chỉ nhánh `cfg`), `crates/video/src/macos/{mod,writer,portable,capture}.rs`, `crates/video/src/lib.rs` (`cfg` của `unsupported`), `crates/video/tests/macos.rs`, `CLAUDE.md`; MỚI `crates/video/src/macos/audio.rs` |

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

## 2b. Phân vai

| Phần | Vai |
|---|---|
| FFI, đồng hồ, `Writer`, vòng quay, test hàm thuần | [opus] |
| Chạy trên Mac | [owner-qa] |

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ | Kết quả |
|---|---|---|---|
| C1 | Máy Windows / soát / `cargo check --locked --target aarch64-apple-darwin -p fastcast-video`, clippy target đó, `cargo test -p fastcast-video` xanh | [opus-run] | ✅ |
| C2 | Định dạng PCM thật / đọc ASBD, xen kẽ, căn `pts`, lấp im lặng, trần RAM / đúng hợp đồng | [opus-unit] `portable.rs` | ✅ (chạy trên Windows) |
| C3 | Mac / `writer_muxes_aac_without_any_permission` / tệp có track `soun` | [opus-run] | ✅ 31/10/2026: AAC 48 kHz, 2 kênh, 1,0 s, video 1,0 s |
| C4 | Mac, có quyền / `records_system_audio`, `records_microphone` (`--ignored`) / `Finished`, có track âm | [owner-qa] | bị chặn: thiếu Screen Recording |
| C5 | Mac / quay kèm âm hệ thống, kèm micro, mở QuickTime / tiếng khớp hình | [owner-qa] | bị chặn: thiếu Screen Recording |
| C6 | Mac / từ chối quyền micro / `Failed { AudioUnavailable }`, không sót `.part` | [owner-qa] | bị chặn: `check_permission` của màn dừng trước khi tới micro |

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

**Chạy trên Mac 31/10/2026:** C3 xanh, tức `AVAssetWriterInput` nhận các khoá chuỗi `AV*Key` và `close_audio` lấp im lặng tới hết video (`afinfo`: AAC 48 kHz, 2 kênh, 1,0 s; `AVURLAsset`: `isPlayable` true, track `vide` + `soun`). Bitrate đo 36 kbps vì đoạn thử phần lớn im, không phải số của tiếng thật.

**Chưa kiểm, cần quyền:** `SCStream` 2 × 2 có giao âm không, đồng hồ `AVCaptureSession`, log `rec: audio clock`, khớp hình, từ chối micro. Bước chạy: `plan/_backlog.md`. Ca `records_*` nay soát cả độ dài `vide`, `soun`.


- `macos/audio.rs`: `System` = `SCStream` riêng (2 × 2, 1 fps, 48 kHz, stereo, bỏ âm của chính tiến trình); `Mic` = `AVCaptureSession`, định dạng đọc lại từ từng `CMSampleBuffer`. Đổi về `AudioPacket` bằng `Converter`, `PacketClock` có sẵn.
- `writer.rs`: track AAC 128 kbps; `write_audio` chỉ xếp hàng (`AudioQueue`), `pump_audio` đưa cho input khi còn chỗ, âm trễ > 200 ms thành im lặng, `close_audio` lấp tới hết video.
- Mất nguồn giữa lượt quay: khoảng thiếu thành im lặng; micro mở lại thiết bị mặc định như Windows (`AudioCapture::keep_alive`, soát mỗi 1 s). Từ chối quyền, không có thiết bị: `AudioUnavailable`.
- Opus chọn 30/10/2026: đồng hồ mic đổi qua `synchronizationClock` + `CMSyncConvertTime`, mốc lệch giờ nhận quá 2 s thì lấy giờ nhận, vì chưa kiểm được đồng hồ của `AVCaptureSession` trên Mac. Khoá `AV*Key` dùng chuỗi thay vì thêm `objc2-avf-audio`. Cả hai ở `plan/confirm.md`.
- Soát: `cargo check --locked --target aarch64-apple-darwin -p fastcast-video` xanh; clippy target đó `-D warnings` xanh; clippy Windows xanh; `cargo test -p fastcast-video` 59 + 15 + 10 ca xanh (`--test-threads=4`); `cargo deny check licenses` ok. Soát riêng `-p fastcast-video`, không build GPUI.
- Soi cải tiến: bảo mật — log chỉ có mã lỗi + định dạng, không nội dung âm, tệp thử xoá khi xong. RAM — hàng PCM có trần 5 s (~1,9 MB); đồng hồ nhảy không cấp phát theo độ dài khoảng trống. Pro — không áp.

**Sửa 31/10/2026 theo D-11** (mục 10 đã làm, không còn treo):

- Chờ hộp thoại quyền micro không còn chặn `Stop`: hỏi trước khi mở nguồn quay, `wait_answer` soát lệnh mỗi 50 ms. `Stop` ⇒ `AudioUnavailable`, `Abort` ⇒ thoát êm. Sửa ở `fastcast-rec`, không đụng UI. Chạy thật: chưa có quyền micro ⇒ `Failed { AudioUnavailable }`, tiến trình thoát cùng lúc dừng (3,04 s), không treo; chưa phân biệt được máy đang ở trạng thái chưa hỏi hay đã từ chối.
- Mở lại micro: đã biên dịch, clippy xanh, **chưa chạy thật** vì thiếu quyền micro và không rút được thiết bị. `startRunning` chặn luồng quay một lúc, chỉ khi vừa mất thiết bị. Bước kiểm: gạch gd4_19 ở `_backlog.md`.

## 10. Đề xuất cải tiến

Không còn.
