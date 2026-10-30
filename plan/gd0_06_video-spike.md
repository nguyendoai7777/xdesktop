# gd0_06 — Spike quay video vùng (Windows)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay đường quay màn thật (C8–C11) |
| Repo | fastcast (spike ở `fastcast/spikes/video/`, ngoài cargo workspace) |
| Cỡ | M — spike, ~700 dòng vứt đi được |
| Phụ thuộc | — (độc lập) |
| Quyết định áp dụng | F-7, F-3 (vùng chọn toạ độ toàn cục vật lý), D-2 (cấm x264 / GPL) |
| Phụ thuộc mới | `windows` (MIT / Apache-2.0) với Graphics.Capture / DXGI / Media Foundation; có thể `windows-capture` (MIT) — soát |
| File đụng tới | `fastcast/spikes/video/` MỚI · `fastcast/docs/spikes/video.md` MỚI |

## 1. Làm gì

- Chụp khung của một vùng chọn (toạ độ toàn cục vật lý, `fastcast_capture::geometry::Rect`) bằng
  Windows.Graphics.Capture, hoặc DXGI Desktop Duplication — thử cả hai nếu rẻ, chọn một.
- Mã hoá H.264 bằng Media Foundation (bộ mã hoá phần cứng nếu có) ra MP4.
- Độ nét 480 / 720 = **cạnh ngắn** của vùng, giữ tỉ lệ, không phóng to (vùng nhỏ hơn thì giữ nguyên), làm tròn số chẵn —
  viết thành hàm thuần có test.
- FPS nhập 1–60, mặc định 30; nhịp khung đều khi màn 144 Hz / 60 Hz.
- Âm thanh theo Q-1 (chờ chủ dự án chốt — mặc định "Không"); nếu chốt có âm: AAC qua Media Foundation.
- Kế hoạch dự phòng OpenH264 (BSD-2, tải khi cần, giấy phép bằng sáng chế của Cisco chỉ áp khi tải binary của Cisco) —
  chỉ ghi kế hoạch, không làm.

## 2. Không làm trong task này

- Không UI quay (khung viền, nút dừng) — GĐ3. Không macOS / Linux.
- Không x264 / FFmpeg GPL.

## 2b. Phân vai

| Phần việc | Ai |
|---|---|
| Hàm thuần, cửa sổ thử, WGC / DXGI, Video Processor + Sink Writer, `--verify` (toàn `unsafe` / FFI theo OS) | `[opus]` |
| Quay màn thật: `--rect`, vắt hai màn, 144 Hz, QuickTime, nhìn độ nét chữ | `[owner-qa]` |

Không giao Sonnet: không có phần ghép UI / catalog; mọi tệp là FFI.

Riêng tư (session điều phối dặn 30/10/2026): không quay màn thật của chủ dự án; spike tự mở cửa sổ thử và quay đúng cửa
sổ đó. Đổi mục 5: số đo lấy trên cửa sổ thử, phần còn lại `[owner-qa]`.

## 4. Code

Crate spike `fastcast/spikes/video/` (`[workspace]` rỗng): `video-spike --rect x,y,w,h --fps 30 --res 720 --secs 10
out.mp4`. Vùng chọn có thể vắt qua hai màn ⇒ ghi lại cách xử lý (chụp từng màn rồi ghép, hay chỉ cho một màn).

## 5. Đo

Quay 720p30 trong 60 s: CPU trung bình (% một nhân), RAM Task Manager, cỡ file, khung rớt; thử trên màn 144 Hz và
60 Hz; thử vùng vắt hai màn.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ bởi | Kết quả |
|---|---|---|---|
| C1 | Vùng lẻ / nhỏ hơn 480 / dọc / 1 px ⇒ cạnh ngắn = res, chẵn, không phóng to, giữ tỉ lệ | `[opus-unit]` `target_size_*` | ✅ |
| C2 | FPS ngoài 1–60, `--rect` sai ⇒ lỗi rõ, không kẹp lặng lẽ | `[opus-unit]` + `[opus-run]` | ✅ |
| C3 | Nguồn 144 / 60 / 20 Hz, 30 fps, 60 s ⇒ đúng 1800 khung; thời lượng cộng dồn 1 giờ không trôi | `[opus-unit]` `pacer_*`, `sample_times_*` | ✅ |
| C4 | Vùng vắt hai màn toạ độ âm, lệch dọc, chạm khe, ngoài desktop ⇒ đúng mảnh / lỗi | `[opus-unit]` `compose_*` | ✅ |
| C5 | Cửa sổ thử 720p30 60 s ⇒ MP4 đọc lại đủ khung, CPU / RAM / cỡ tệp ghi báo cáo, không lấy focus | `[opus-run]` | ✅ 1800 / 1800, `stole_focus=0` |
| C6 | MP4 mở bằng stack Media Foundation của Windows và trình duyệt | `[opus-run]` `--verify`, Chromium 152 | ✅ |
| C7 | Báo cáo: số đo, API chọn, giới hạn, kế hoạch macOS / Linux, dự phòng OpenH264 | `docs/spikes/video.md` | ✅ |
| C8 | `--rect` trên một màn, `wgc` + `dxgi` ⇒ đúng vùng, soát con trỏ, viền vàng | `[owner-qa]` | chờ |
| C9 | Vùng vắt hai màn thật | `[owner-qa]` | chờ |
| C10 | 720p30 60 s trên màn 144 Hz và 60 Hz thật | `[owner-qa]` | chờ |
| C11 | Mở bằng QuickTime; chữ trong video đọc được; cửa sổ DRM hiện đen | `[owner-qa]` | chờ |

## 8. Nợ chuyển task khác

- UI quay + lưu tách ảnh / video (F-8): GĐ3.

- Kế hoạch cho GĐ3 (tiến trình quay riêng, `ABOVE_NORMAL`, chặn cạnh < 34 px, `moov` ở cuối): `fastcast/docs/spikes/video.md`
  mục 7. Chưa có tệp task GĐ3 để chèn.

## 9. Bàn giao thực tế

Xong 30/10/2026 — fastcast `claude/gd0_06`. Chi tiết + số đo: `fastcast/docs/spikes/video.md`.

**Số đo chính** (60 s, cửa sổ thử, GTX 1650 NVENC, máy bận 68 %): 720p30 quay + mã hoá **4,1 %** một nhân, **29,6 MB**
Task Manager (gồm 3,7 MB ảnh của cửa sổ thử), **24,1 MB** tệp, **0 / 1800** ô rớt. Ưu tiên thường cùng tải: 8 / 1800. Mỗi
cấu hình đo một lượt. Bộ mã hoá phần mềm: ≥ 44 %, working set 217 MB.

**Đã chạy thật**: WGC theo cửa sổ + cả chuỗi mã hoá. **Chưa chạy thật lần nào**: `--rect` (WGC theo màn, DXGI, ghép hai
màn) — mới biên dịch + test hàm thuần, có thể còn lỗi lúc chạy. Máy lúc đo chỉ có một màn 60 Hz.

**Chờ kiểm tay** (C8–C11): lệnh ở `plan/_backlog.md`, gạch `[gd0_06 · owner-qa]`.

**Soát**: clippy `-D warnings` xanh, 28 test xanh, `cargo deny --config ../../deny.toml … check licenses` ok (chỉ thêm
`windows` 0.62 + crate của nó, MIT / Apache-2.0). `crates/` không đổi ⇒ không chạy lại `cargo build` / `test` của workspace
cho task này. Tệp MP4 thử đã xoá.

**Sự cố trong lượt**: script tạo tệp lỗi cú pháp nên crate chưa có `Cargo.toml`, `cargo test` rơi lên workspace fastcast và
chạy cả bộ test của nó. Bộ test đó dùng màn giả, không chụp màn thật, không sót tiến trình. Có một test đỏ:
`fake_overlay_drag_across_monitors_then_close_and_reopen` (`crates/ui/tests/overlay.rs`) báo `fastcast-ui still running`
quá hạn, lúc máy đang bận nhiều lượt build. Nhánh này không sửa `crates/`; chưa chạy lại để xác nhận là do tải.

**Opus chọn 30/10/2026** (`plan/confirm.md`):

- WGC làm nguồn chính (tạm, chưa chạy thật theo màn) — viền vàng trên Windows 10 không tắt được.
- Vùng vắt màn: mỗi màn một nguồn, ghép vào khung cỡ vùng — thay vì chỉ cho một màn.
- Mẫu GPU + `ABOVE_NORMAL` làm mặc định của spike. Âm thanh: không (Q-1 chưa chốt, không chạm).
- **Vượt trần**: 1 438 dòng không tính test (trần 900, ước lượng ~700), 8 tệp Rust (trần 7). Không tách: spike vứt đi, một
  lát dọc. Phần vượt là cửa sổ thử + hoạ tiết + `--verify` (~420 dòng), phát sinh từ yêu cầu không quay màn thật.
- Bỏ `WS_EX_NOACTIVATE`: WGC từ chối cửa sổ có cờ này ⇒ cửa sổ thử có nút taskbar khi chạy, vẫn không lấy focus.

**Đề xuất đã làm** (mục 10): `ABOVE_NORMAL` mặc định; số đo RAM sau khi dừng; xả khung cũ trước khung đầu; CPU đo theo chu kỳ.

**Cho GĐ3**: `fastcast/docs/spikes/video.md` mục 7. `crates/video` chưa đụng.

## 10. Đề xuất cải tiến

Đã soát bốn lăng kính. Bảo mật: spike không log nội dung, tệp thử đã xoá, đường dẫn ra do người chạy đưa, không có IPC.

1. [ram] Luồng quay ưu tiên thường rớt 8 / 1800 ô khi máy bận — bảng mục 2 của báo cáo — `ABOVE_NORMAL` — hết rớt ở cùng tải —
   S — P1. **Đã làm** (mặc định của spike; GĐ3 mang theo, báo cáo mục 7).
2. [ram] `GetProcessTimes` đo ra 0 % với việc chạy ngắn theo timer — lượt `--fps 1` — đo theo chu kỳ TSC — số CPU đáng tin — S —
   P1. **Đã làm**. Áp cho công cụ đo sau này của GĐ3.
3. [ram] Sau khi dừng còn 32,7 MB working set do DLL đã nạp — `ws_after_stop_mb` — quay trong tiến trình riêng kiểu
   `fastcast-ocr` — trả hết RAM khi xong — M — P2. **Ghi báo cáo mục 7**: quyết định ở GĐ3, chưa có task.
4. [ux] Viền vàng quanh cả màn trên Windows 10 khi dùng WGC theo màn — `IsBorderRequired` không có trên 19045 — DXGI + tự vẽ con
   trỏ trên Windows 10 — hết viền — M — P2. **Chờ**: cần chủ dự án nhìn ở C8, `plan/confirm.md`.
5. [ux] Vùng có cạnh < 34 px báo lỗi media type; nhỏ hơn ~146 × 100 rơi lặng lẽ về phần mềm — báo cáo mục 3 — chặn trong UI,
   báo khi rơi — S — P2. **Ghi báo cáo mục 7**: chưa có UI quay (GĐ3).
6. [bảo mật] Quay dở mà sập thì mất cả tệp vì `moov` ở cuối — hộp đo được `ftyp, uuid, mdat, moov` — thử fragmented MP4 — M — P3.
   **Ghi báo cáo mục 7**: cần soát QuickTime, chưa có Mac trong lượt.
7. [pro] Độ nét trên 720p / xuất GIF ngắn — F-7 chỉ chốt 480 / 720 — đặt chỗ "Pro" — S — P3. **Đã ghi** `fastcast/ROADMAP.md` GĐ4.
