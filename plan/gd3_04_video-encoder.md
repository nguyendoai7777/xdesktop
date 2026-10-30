# gd3_04 — mã hoá MP4 H.264 + AAC

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd3_01 |
| Quyết định áp dụng | F-7, D-2 (cấm x264 / GPL) |
| Phụ thuộc mới | — (đã khai ở gd3_01) |
| File đụng tới | SỬA `crates/video/src/{size,pacer,encoder}.rs`; MỚI `crates/video/tests/encoder.rs`, `crates/video/examples/{pattern,mp4_verify}.rs`, `crates/video/examples/common/mod.rs` |

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

## 2b. Phân vai

Toàn `[opus]` (FFI). Soát bằng `-p fastcast-video` + `cargo deny`.

## 3–4. Kiểu dữ liệu + code

Giữ nguyên chữ ký stub của gd3_01. Mới: `encoder::MIN_EDGE = 34`. Hoạ tiết, soi MP4, giải mã lại nằm ở `examples/common/mod.rs`, dùng chung cho hai example và `tests/encoder.rs`.

## 5. Đo

720p30 60 s từ hoạ tiết, CPU theo chu kỳ (`QueryProcessCycleTime`, không `GetProcessTimes`), RAM, cỡ tệp; so `docs/spikes/video.md` mục 2. Kết quả ở mục 9.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ |
|---|---|---|
| C1 | `default_bitrate`, `Pacer`: test chép từ spike (C1, C3 gd0_06). `target_size`: test ở `core` | `[opus-unit]` ✅ |
| C2 | `pattern` 720p30 + sóng sin ⇒ `mp4_verify` đủ khung, có track AAC, hai track lệch ≤ 1 khung | `[opus-run]` ✅ lệch 10,7 ms |
| C3 | Vùng < 146 × 100 ⇒ rơi về phần mềm, `describe` báo đúng (100 × 400: phần mềm; 146 × 100: NVENC) | `[opus-unit]` + `[opus-run]` ✅ |
| C4 | Cạnh < 34 px ⇒ `RegionTooSmall`, không panic, không tạo tệp; 34 × 34 vẫn mã hoá được | `[opus-unit]` ✅ |
| C5 | Đuôi `.part` ⇒ vẫn ra container MP4 (`mp42`, `moov`) | `[opus-unit]` ✅ |
| C6 | Thư mục đích không có ⇒ `OutputUnwritable`; HRESULT ⇒ mã lỗi đúng | `[opus-unit]` ✅ |
| C7 | Stream âm không có mẫu / ngắt giữa chừng ⇒ video không bị chặn, hai track bằng nhau, âm sau khoảng trống đúng chỗ (thêm khi làm) | `[opus-unit]` ✅ |
| C8 | Dừng trước khung đầu ⇒ `Internal`, không panic; bỏ `Encoder` không `finish` ⇒ nhả tệp ngay; FPS 1 có âm không bị chặn (thêm khi làm) | `[opus-unit]` ✅ |
| C9 | Không chụp màn người dùng trong mọi bước: chỉ hoạ tiết vào texture | ✅ |

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

QuickTime (C11 gd0_06): gd3_13 đưa vào danh sách kiểm tay.

## 9. Bàn giao thực tế

**Lệnh soát** (nhánh sau khi gộp `master` có gd3_05): `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test` với `-p fastcast-video` (22 + 15 test xanh), `cargo deny check licenses` ok. Theo luật làn, không build GPUI.

**Số đo** (bản release, GTX 1650, NVENC, máy bận 92–100 % vì các làn khác build, mỗi cấu hình một lượt; CPU đã trừ phần vẽ hoạ tiết, RAM gồm ảnh hoạ tiết 3,7 MB ở 720p, 8,3 MB ở 1080p; không phải số chính thức, chính thức ở gd3_13):

| Cấu hình | CPU | RAM Task Manager | Cỡ tệp | Rớt | Mã vạch | Lệch hai track | Spike |
|---|---|---|---|---|---|---|---|
| 720p30 60 s + AAC | 5,5 % | 44,7 MB (giây 30) | 25,9 MB | 0 / 1800 | 1800 / 1800 | 10,7 ms | — |
| 720p30 60 s, không âm | 3,8 % | 43,7 MB (giây 30) | 25,0 MB | 0 / 1800 | 1800 / 1800 | — | 4,1 %, 29,6 MB, 24,1 MB |
| 1080 → 720p30 20 s + AAC | 5,7 % | 65,9 MB (giây 10) | 8,7 MB | 0 / 600 | 600 / 600 | 10,7 ms | 5,0 %, 35,3 MB (không âm, 60 s) |
| 720p60 20 s + AAC | 9,2 % | 48,4 MB (giây 10) | 17,0 MB | 0 / 1200 | 1200 / 1200 | 10,6 ms | 8,2 %, 31,2 MB (không âm, 60 s) |
| Phần mềm 720p30 10 s + AAC | 36,4 % | 200,2 MB (giây 5) | 4,2 MB | 0 / 300 | 300 / 300 | 5,3 ms | ≥ 44 % |

- **CPU, cỡ tệp, số khung khớp spike. RAM cao hơn spike ~14 MB và chưa rõ vì sao**: không do AAC (có âm 44,7, không âm 43,7). Khác biệt đo: máy bận 100 %, spike lấy mẫu giữa lượt khi máy bận 68 %. gd3_13 đo lại lúc không làn nào chạy; vẫn trên 35 MB thì soi.
- **Không rò theo khung**: lượt 90 s lấy mẫu mỗi 10 s: 36,4 MB (10 s) → 52,0 (20 s) → 53,1 (80 s), tăng ~1,1 MB / phút sau khi ổn định. Phần tăng chậm chưa xác định nguồn (có thể là bảng chỉ mục MP4 nằm trong RAM tới lúc ghi `moov`); quay rất dài cần xem lại. Cùng lượt này giây 30 đọc 52,3 MB, khác 44,7 MB ở trên: một lượt không đủ làm mốc RAM.
- **Cỡ nhỏ**: 100 × 400 phần mềm (59,6 MB, 10 % CPU), 146 × 100 NVENC (25,2 MB, 5,9 %), đúng spike.

**Lỗi thật tìm thấy lúc làm, đã sửa**: Sink Writer xen kẽ các stream. Bật stream AAC mà không đưa mẫu ⇒ `WriteSample` của video bị chặn, lâu nhất 1,1 s, trung bình 0,84 s / khung (300 khung mất 252 s); tệp ra `mp4_verify` đọc lỗi `0xC00D36B3`. Âm hệ thống im thì WASAPI loopback không đưa gói nào nên ca này là ca thường. Sửa trong `Encoder`: `write` lấp im lặng khi âm trễ > 200 ms so với `pts`, `finish` lấp tới hết video, `write_audio` chèn im lặng vào khoảng trống và bỏ phần trùng; mốc âm tính từ số mẫu đã ghi.

**Opus chọn 30/10/2026** (đều ở `plan/confirm.md`):
- Lấp im lặng trong `Encoder`, không đẩy cho gd3_07 — phương án khác: `SendStreamTick` — vì: một chỗ, gd3_07 không phải biết bẫy này, track âm liên tục. Chưa thử `SendStreamTick`.
- AAC 128 kbps — vì: ~1 MB / phút, đủ cho âm hệ thống + giọng nói.
- Thêm tệp `examples/common/mod.rs` ngoài danh sách của task — vì: hai example + test cần chung hoạ tiết và bộ soát. Đúng trần 7 tệp.
- Dừng trước khung đầu ⇒ `Internal`, không tự ghi khung giả — vì: `Encoder` không biết nội dung khung, gd3_06 phải ghi ít nhất một khung.

**Cho gd3_06, gd3_07**: khối bàn giao trong hai task đó.

**Chưa kiểm**: QuickTime (gd3_13). Máy không GPU D3D11: ca cần GPU trong `tests/encoder.rs` tự bỏ qua, in lý do; chưa chạy trên máy như vậy.

**Đề xuất đã làm** (run-task mục 5): không có đề xuất P1 / P2 nào làm được trong phạm vi tệp của làn này ngoài lỗi đã sửa ở trên. Lăng kính bảo mật: log chỉ ghi HRESULT, không đường dẫn; test tự xoá tệp. UI/UX: không áp. Pro: không áp.

## 10. Đề xuất cải tiến

- [ux] Windows N (không Media Feature Pack) có thể không chạy nổi `fastcast-rec.exe` thay vì báo `NoEncoder`: exe nhập trực tiếp từ `mfplat.dll` — suy từ cách crate `windows` liên kết, chưa kiểm trên máy N — đề xuất: gd3_11 coi "bật exe lỗi" như `NoEncoder`, hoặc nạp trễ DLL — giá trị: báo được lý do và cách gỡ — M — P2. Máy này không phải bản N ⇒ `plan/_backlog.md`.
- [ram] RAM 720p30 cao hơn spike ~14 MB, chưa rõ nguồn (mục 9) — gd3_13 đo lại lúc máy rảnh, còn cao thì soi; vòng texture + `IMFTrackedSample` (đã loại khỏi task này) là chỗ đầu tiên để thử — S — P2. Cần máy rảnh ⇒ giao gd3_13.
- [ux] Vùng siêu dài: 8000 × 720 mã hoá xong nhưng Media Foundation không giải mã lại được (`0xC00D36B4`), 5120 × 720 thì được. Ngưỡng chưa dò, cũng chưa thử trình phát khác — hiếm, chỉ gặp khi vắt 3–4 màn với vùng thấp — S — P3 ⇒ `plan/_backlog.md`.
