# gd3_07 — thu âm hệ thống / micro

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026), chờ kiểm tay C6 |
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

## 2b. Phân vai

Toàn `[opus]` (FFI theo OS, đa luồng). **Riêng tư**: `[opus-run]` chỉ thu loopback 2 s rồi xoá tệp ngay, KHÔNG mở micro trên máy chủ dự án.

## 3. Kiểu dữ liệu

Chữ ký stub giữ nguyên: `audio::start(source, sink) -> Result<AudioCapture, RecError>`, `AudioPacket { pcm, pts }`. Thêm ngữ nghĩa: `pts` = 0 là lúc `start` trả về, `AudioSource::None` không mở thiết bị.

## 4. Code

Phần thuần (đa nền, có test): `InputFormat`, `Resampler`, `Converter`, `PacketClock`. Phần WASAPI: `mod imp` trong `audio.rs`, luồng `audio-capture`, polling 10 ms.

## 5. Đo

`audio_probe --secs 2 --tone 1000`: mục 9. CPU / RAM cả tiến trình đo ở gd3_13.

## 6. Nghiệm thu

- C1 `[opus-unit]` Cho 8–192 kHz, 10 s chia gói 10 ms. Khi đổi mẫu. Thì đủ 480 000 khung (sai số ≤ một khung vào), giữ tần số 440 Hz; tone trên Nyquist ở 192 kHz bị giảm. ✅
- C2 `[opus-unit]` Cho float 32, int 16 / 24 / 32, mono, 5.1. Thì ra đúng stereo, kênh giữa trộn vào hai bên. ✅
- C3 `[opus-unit]` Cho máy im 3 s không có gói. Khi gói kế tới. Thì `pts` nhảy tới mốc thật, `Encoder` lấp im lặng phần giữa. ✅ (phần lấp: test của gd3_04)
- C4 `[opus-unit]` Cho 1 giờ gói 10 ms ở 44,1 / 48 / 96 kHz. Thì `pts` đúng tuyệt đối, không lấy lại mốc. Cho đồng hồ thiết bị lệch ±100 ppm. Thì `pts` luôn trong 20 ms so với giờ thật. ✅
- C5 `[opus-run]` Loopback 2 s ra MP4 có track AAC đúng thời lượng; tệp đã xoá. ✅
- C6 `[owner-qa]` Micro + âm hệ thống 60 s cùng video: tiếng khớp hình; rút tai nghe giữa chừng không treo; đổi thiết bị mặc định giữa chừng thì tiếng theo sang; micro bị tắt trong Privacy ⇒ `AudioUnavailable` hoặc im lặng (ghi lại ca nào).

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

- gd3_06: gọi `audio::start` ngay trước khi lấy mốc đếm giờ (sau `Encoder::new`, sau khi chờ khung đầu). Đã báo session gd3_06.
- Làn gộp sau cùng trong gd3_06 / gd3_07: `unsupported` ở `lib.rs` còn được `session.rs` dùng trên Windows. `session.rs` hết dùng thì thành mã chết, clippy đỏ ⇒ đặt `#[cfg(not(windows))]` cho hàm đó.

## 9. Bàn giao thực tế

- **Soát** (30/10/2026, nhánh `claude/gd3_07`): `cargo clippy -p fastcast-video --all-targets -- -D warnings` xanh; `cargo test -p fastcast-video` 33 + 15 test xanh; `cargo deny check licenses` ok. Theo luật làn, không build GPUI. Không có target khác Windows trên máy ⇒ nhánh `#[cfg(not(windows))]` chưa biên dịch.
- **Chạy thật, loopback 2 s, không phát gì (máy im)**: `packets=0`, track `soun` 2,005 s, `audio_rms=0`, lệch track 5 ms ⇒ im lặng do `Encoder` lấp, đúng thời lượng.
- **Chạy thật, `--tone 1000` (sóng −46 dB từ giây 0,5 tới 1,5)**: `packets=140`, `first_pts_ms=540` (tone bắt đầu 500 ms + ~40 ms mở stream), `peak=163` (đúng 0,005 × 32 767), `audio_rms=81`, `audio_hz=523` trên cả 2 s (≈ 1 kHz trong ~1 s), track `soun` 2,005 s, lệch track 5 ms, `stop_ms=6`. Tệp thử đã xoá sau mỗi lần. Máy chạy 48 kHz nên nhánh đổi tần số chỉ được phủ bằng unit test, chưa chạy với thiết bị thật khác 48 kHz.
- **Chưa chạy thật**: micro (cấm trên máy chủ dự án), mất thiết bị, đổi thiết bị mặc định, micro bị chặn ⇒ C6.
- **Khoảng rớt khung của probe** (58–59 / 60 khung, `max_jump=2`): bản debug vẽ hoạ tiết chậm, không phải việc của thu âm.
- **Opus chọn 30/10/2026**:
  - `pts` đếm theo số mẫu, neo vào `qpcPosition`, lệch > 20 ms thì neo lại — vì: giờ nhận gói bị giật, `devicePosition` không chắc chạy lúc loopback im, đồng hồ thiết bị thuần thì trôi so với video (QPC). Giá: lệch 100 ppm thì mỗi ~200 s có một bước 20 ms.
  - Giữ chữ ký stub, mốc 0 = lúc `start` trả về — vì: gd3_06 đang làm theo chữ ký đó, session chỉ phải gọi đúng chỗ.
  - Polling 10 ms, không event — vì: loopback + event từng không ổn trên Windows cũ, polling không kém gì với bộ đệm 500 ms.
  - Tự viết đổi mẫu tuyến tính + trung bình, không dùng `AUTOCONVERTPCM` — vì: cờ đó không đáng tin với loopback (nhớ từ `miniaudio`, chưa thử lại), không thêm crate (luật làn cấm sửa `Cargo.toml`).
  - Quá 2 kênh: lấy trái, phải + kênh giữa, bỏ kênh sau và LFE — vì: đủ lời thoại phim 5.1, không cần ma trận trộn đầy đủ.
  - Mất thiết bị giữa chừng: thử mở lại mỗi 500 ms, không báo lỗi — vì: bỏ cả cuộc quay vì rút tai nghe tệ hơn mất tiếng một đoạn.
- **Đề xuất đã làm**: theo thiết bị mặc định mới (mục 10, dòng 1).
- **Chờ kiểm tay**: C6.

## 10. Đề xuất cải tiến

1. `[ux]` Đổi thiết bị mặc định giữa cuộc quay ⇒ thiết bị cũ không báo lỗi, loopback im tới hết — `Stream::drain` không có lỗi nào để bắt — so id thiết bị mỗi giây rồi mở lại — tiếng không mất khi cắm tai nghe — S — P1. **Đã làm.**
2. `[ux]` Mất thiết bị giữa chừng chỉ có log, người dùng không biết đoạn sau im — `imp::run` — thêm `RecEvent` báo UI — biết sớm để dừng quay — M — P2. Cần thông điệp mới trong `worker.rs` (tệp chung, cấm trong làn) ⇒ `plan/_backlog.md`.
3. `[pro]` "Cả hai" (micro + hệ thống, trộn và bù lệch đồng hồ): hợp huy hiệu Pro cho người quay hướng dẫn. Đã có trong Q-1, chỉ đặt chỗ.
- `[bảo mật]` Log chỉ có HRESULT + định dạng, không có tên thiết bị / nội dung âm; micro chỉ mở khi `source == Mic`. `[ram]` Không áp cho daemon: `fastcast-rec` bật khi quay, thêm một `Vec` mỗi 10 ms, bộ đệm WASAPI 500 ms.
