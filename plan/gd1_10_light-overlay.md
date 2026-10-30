# gd1_10 — Overlay nhẹ cho máy không GPU / phiên RDP

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay RDP thật |
| Repo | fastcast (có thể chạm `materiant/spikes/ui-foundation` để thử nhanh) |
| Cỡ | M — gồm đo + một hướng sửa |
| Phụ thuộc | gd1_02, gd1_03 |
| Quyết định áp dụng | F-3, D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/render_mode.rs` MỚI · `crates/ui/src/overlay/view.rs` SỬA · `crates/capture/src/lib.rs` SỬA (nếu cần ảnh thu nhỏ) |

## 1. Làm gì

- Phát hiện khi GPUI vẽ bằng **WARP** (adapter "Microsoft Basic Render Driver") hoặc đang trong **phiên RDP**
  (`GetSystemMetrics(SM_REMOTESESSION)`) ⇒ bật chế độ nhẹ.
- Tái hiện trước khi sửa: spike đo overlay trên WARP ngốn ~9 nhân CPU khi kéo (23–29 s CPU cho 1,75 s kéo — báo cáo
  `materiant/docs/spikes/ui-foundation.md` mục 4b); ép WARP bằng bản vá `materiant/spikes/ui-foundation/vendor/gpui-pre-windows`
  (`GPUI_FORCE_WARP=1`).
- Thử theo thứ tự rẻ → đắt, dừng ở cách đầu tiên đạt mục 5: (a) chỉ vẽ lại khi vùng chọn đổi, gộp mouse-move theo khung;
  (b) lớp tối + ảnh nền vẽ một lần thành texture, mỗi khung chỉ vẽ viền + nhãn; (c) giảm độ phân giải ảnh nền trong khi
  kéo, vẽ lại nét khi nhả.
- Ghi số đo từng cách vào mục 9.

## 2. Không làm trong task này

- Renderer CPU riêng ngoài GPUI — nếu (a)–(c) không đạt thì dừng, ghi đề xuất, hỏi chủ dự án.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| Đo tách lớp, sửa vẽ lại chéo màn, `render_mode.rs`, nối vào `view.rs`, test | `[opus]` (vòng vẽ + FFI, không tách Sonnet) |
| RDP thật, nhìn bằng mắt độ mượt | `[owner-qa]` |

## 5. Đo

CPU (tổng thời gian CPU của tiến trình) khi kéo 2 s trên WARP và trên RDP thật: mục tiêu ≤ 1 nhân trung bình; GPU thật
không tệ hơn gd1_02.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ | Kết quả |
| --- | --- | --- | --- |
| C1 | Hai màn; kéo chỉ trên màn 0 ⇒ màn 1 không vẽ lại | `[opus-unit]` test `fake_overlay_drag_on_one_monitor_does_not_repaint_the_other` | Xanh |
| C2 | WARP ép, hai cửa sổ đủ 1080p; kéo 120 lần di ⇒ CPU ≤ 1 nhân trung bình, kéo không chậm đi | `[opus-run]` `measure_fullscreen_drag_cpu` | Đạt sát ngưỡng: TB 0,90 nhân (0,60–1,09), xem mục 9 |
| C3 | Chế độ nhẹ ép ⇒ chọn, tay nắm, phím, thanh công cụ như chế độ đầy đủ | `[opus-unit]` test `fake_overlay_light_mode_behaves_the_same` | Xanh |
| C4 | Nhận diện: adapter phần mềm / phiên RDP / biến ép | `[opus-unit]` `software_adapter_or_remote_session_picks_light`; `[opus-run]` log `render mode Light (adapter Microsoft Basic Render Driver…)` | Xanh; nhánh RDP chỉ phủ bằng hàm thuần |
| C5 | GPU thật không tệ hơn gd1_02 | `[opus-run]` | Đạt: 141–234 ms CPU / 3,3 s (gd1_02: 141–359 ms) |
| C6 | Ảnh chế độ nhẹ: vùng sáng 1:1, viền ngoài vùng, khung cuối đúng sau khi nhả | `[opus-run]` PrintWindow màn giả, đã xem + xoá | Đạt; nền tối hơi mềm (nửa độ phân giải) |
| C7 | RDP vào máy nhà từ máy khác, chụp vùng dùng được, kéo không giật quá mức | `[owner-qa]` | Chờ — `plan/_backlog.md` |

## 8. Nợ chuyển task khác

- gd1_11 gom bước kiểm tay RDP (C7) vào báo cáo nghiệm thu.

## 9. Bàn giao thực tế

- **Nguyên nhân tìm được**: (1) `session.read(cx)` trong `render` làm GPUI vẽ lại MỌI cửa sổ mỗi lần phiên đổi — phép so
  `Visible` của gd1_02 không có tác dụng, kể cả trên GPU thật. (2) Trên WARP, quad lớn đắt hơn hẳn sprite: chỉ ảnh 2,9–4,9 s,
  thêm các dải tối 14,6–15,8 s, thêm nền đen ~25 s.
- **Số đo từng cách** (release, i5-10400F, hai cửa sổ 1080p nằm ngoài màn, 120 lần di, mỗi dòng 3 vòng; "mốc" chạy lúc máy
  bận hơn nên khoảng thời gian rộng):

  | Cách | CPU khi kéo | Thời gian kéo | Nhân |
  | --- | --- | --- | --- |
  | Mốc WARP (tái hiện vấn đề) | 29,2–30,8 s | 4,9–18,2 s | 1,6–6,2 |
  | (a) `render` không đọc phiên, chỉ vẽ màn đổi | 24,8–27,0 s | 5,4–9,5 s | 2,8–4,6 |
  | (b) sprite ảnh tối + ảnh gốc cắt theo vùng, viền bốn thanh, 30 fps | 3,6–4,4 s | 3,3–3,4 s | 1,09–1,30 |
  | (b) + 25 fps — **đang dùng** (9 vòng) | 2,75–3,84 s | 3,2–5,1 s | **0,60–1,09, TB 0,90** |
  | GPU thật, chế độ đầy đủ, sau (a) | 141–234 ms | 3,3–3,5 s | 0,04–0,07 |

  (c) không thử: (b) đã đạt, và giảm độ phân giải ảnh không giảm số pixel phải tô mỗi khung.
- **RAM** (Task Manager, 2 màn 1080p, cửa sổ thu nhỏ): overlay mở trên WARP: đầy đủ 59,8–68,5 MB, nhẹ 52,5–69,4 MB; trên GPU:
  đầy đủ 48,8–54,6 MB, nhẹ ép 41,1–65,6 MB. Sau khi nhả GPU, 6 vòng WARP chững ở 28–32 MB (không rò; chế độ đầy đủ trên WARP
  cũng 25–31 MB); GPU chế độ đầy đủ 12–13 MB (gd1_02 ghi 9,1–9,6 MB — chưa truy nguyên). Khung đầu từ UI ấm còn GPU, WARP:
  nhẹ 64–88 ms, đầy đủ 69–79 ms.
- **Giới hạn của số đo**: script chỉ di ~35 lần/s; cửa sổ ngoài màn nên DWM không ghép, CPU DWM không tính; WARP ép ≠ RDP
  thật; các session khác đang build cùng lúc. **1440p / 4K chưa đo được**: lần thử 4K tạm cho 0,30–0,36 nhân nhưng không tin
  được vì OS có thể kẹp cỡ cửa sổ theo màn thật, nên nhịp khung theo diện tích là suy luận, chưa kiểm.
- **Opus chọn 30/10/2026** (`plan/confirm.md`): nền tối nửa độ phân giải; 25 fps ở 1080p, giãn tới 10 fps; RDP có GPU thật
  cũng vào chế độ nhẹ (đúng spec mục 1).
- **File ngoài danh sách**: `crates/ui/src/platform.rs` (`remote_session`), `overlay/dev.rs` (`=1080p-offscreen`),
  `overlay/mod.rs`, `tests/overlay.rs`, `CLAUDE.md`, `ROADMAP.md`. `crates/capture` không phải sửa. Viền bốn thanh áp cho cả
  hai chế độ. `FASTCAST_OVERLAY_RENDER=light|full` ép chế độ; mỗi cửa sổ log thêm chế độ + số lần vẽ.
- **Lệnh soát** (nhánh đã gộp master có gd1_04, gd0_06; worktree, target riêng): `cargo build`, `cargo clippy --all-targets
  -- -D warnings`, `cargo test` (ui: 107 unit + 5 ipc + 12 overlay), `cargo deny check licenses` — xanh. Xung đột gộp ở
  `CLAUDE.md`, `platform.rs`, `overlay/mod.rs`: giữ cả hai phía.
- **Sự cố khi chạy thử**: lúc chụp PrintWindow, bản debug mở cửa sổ console, `foreground_unchanged=False` ⇒ hai lần giành
  focus thoáng qua trên máy thật. Lần sau chụp bằng bản release. Không phím / chuột thật; ảnh đã xoá.
- **Đề xuất đã làm**: nhịp khung giãn theo diện tích màn (`light_interval`, có test).
- **Chờ kiểm tay** (C7, `plan/_backlog.md`).

## 10. Đề xuất cải tiến

- [ram] WARP giữ 25–32 MB sau khi đóng tới lúc UI thoát (giữ ấm 300 s) — số đo mục 9 — rút giờ giữ ấm khi adapter là phần mềm
  — bớt ~25 MB, đổi lại lần mở sau nguội — S — P3. **Không làm**: đánh đổi chưa rõ lợi, cần số đo trên máy không GPU thật.
- [ram] Chế độ đầy đủ trên GPU sau khi nhả 12–13 MB so với 9,1–9,6 MB ở gd1_02 — mục 9 — so với bản gd1_02 để truy nguyên, có
  thể do các task sau — M — P3. Để gd1_11 đo lại lúc máy rảnh.
- [ux] Nền tối nửa độ phân giải hơi mềm — ảnh C6 — dùng đủ độ phân giải, tốn thêm ~6 MB mỗi màn 1080p — S — P3. Chờ chủ dự án
  nhìn (`plan/confirm.md`).
- [bảo mật] Không áp: bản tối chỉ ở RAM, nhả cùng cửa sổ; log chỉ có tên adapter.
- [pro] Không áp.
