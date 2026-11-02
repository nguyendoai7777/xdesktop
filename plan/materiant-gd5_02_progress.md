# materiant-gd5_02 — Progress

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (02/11/2026) |
| Repo | materiant |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/progress.rs`, `examples/gallery/pages/progress.rs` |

## 1. Làm gì
- `materiant::progress`: thanh ngang và vòng tròn, mỗi loại có xác định (`value`) và không xác định. Nguồn: `E:\codex\xbds\materiant\projects\progress\src\lib` (`progress.component.ts`, `progress-circular.component.ts`, `progress-indeterminate.component.ts`).
- `gpui_kit::base` `Progress` chỉ có dạng thanh; dạng tròn tự vẽ (`canvas` + path, hoặc SVG xoay nếu đủ đẹp) và ghi lý do chọn ở mục 9.
- Hoạt ảnh chỉ chạy khi component đang hiện; dừng thì không xin vẽ khung mới (đo bằng `FRAMES`).
- Trang gallery `progress`: đúng cả sáng / tối. Test logic thuần (kẹp giá trị, góc cung).

## 2. Không làm trong task này
- Biến thể iOS (`progress-ios`), nhãn phần trăm.

## 2b. Phân vai
Toàn bộ `[opus]`: một module + một trang, hình học và keyframe gắn chặt nhau, không tách cho Sonnet.

## 6. Nghiệm thu
- C1 — Cho giá trị ngoài 0..=1 hoặc NaN, khi gọi `.value`, thì kẹp về 0..=1, NaN về 0. `[opus-unit]` ✅
- C2 — Cho `scale` / `stroke_width` không hợp lệ, thì về mặc định. `[opus-unit]` ✅
- C3 — Cho vòng không xác định, thì cung nằm trong 10°–280°, lặp ở 26 660 ms không nhảy pha. `[opus-unit]` ✅
- C4 — Cho thanh không xác định, thì hai vạch luôn trong track và ra ngoài track ở đầu / cuối chu kỳ. `[opus-unit]` ✅
- C5 — Cho dạng xác định, bị cắt khỏi vùng nhìn, hoặc đã gỡ khỏi cây, thì không xin khung. `ui-tests/tests/progress.rs` ✅
- C6 — Trang `progress` đúng sáng / tối; bấm Hide thì `FRAMES` dừng. `[opus-run]` ✅
- C7 — Vòng và thanh nhìn mượt khi chạy liên tục (ảnh tĩnh không soát được chuyển động). `[owner-qa]`: `pwsh start.ps1 docs progress`.

## 9. Bàn giao thực tế
- API: `materiant::progress::{ProgressBar, ProgressCircular}`; `.value(0..=1)` (không gọi = không xác định), `.tone(Accent)`; thanh có `.stroke_width(px)`, `.rtl()`; vòng có `.scale(f)` trên cỡ gốc 64 px. Thanh rộng theo khung cha.
- Opus chọn 02/11/2026, dạng tròn: `canvas` + `PathBuilder::stroke` thay vì SVG xoay — vì xoay SVG không đổi được độ dài cung (10°–280° theo MDC); gộp hai clipper của web thành một cung `start = θ`, `sweep = 540° − 2θ`.
- Opus chọn 02/11/2026, dạng thanh cũng vẽ trong `canvas`: xin khung ở bước vẽ để biết `content_mask`; `with_animation` xin khung cả khi đã cuộn khỏi vùng nhìn.
- Opus chọn 02/11/2026, giá trị 0..=1 (web không có dạng xác định); nền track của dạng tròn xác định dùng 18 % như thanh.
- Giảm chuyển động: `cx.reduce_motion()` kéo dài chu kỳ như web (thanh ×2, vòng ×1,25).
- Đo (`--page progress`, bản release, màn 144 Hz): 144 fps, RAM 18,5 MB. Bấm Hide: `FRAMES` dừng sau khi ripple của nút tan, im suốt 3 s chờ. Dạng xác định không xin khung (test).
- Soát trên nhánh sau khi gộp `master`: build, clippy, test, `deny check licenses` xanh; `cargo tree -i gpui-component` không có gói.
- Thêm tệp ngoài bảng "File đụng tới": `ui-tests/tests/progress.rs` (đúng luật test UI của `materiant/CLAUDE.md`).
- Chờ kiểm tay: C7. Lăng kính run-task: bảo mật không áp; UI/UX, RAM đã xử lý như trên; bàn phím không áp (không tương tác).
- Không có task nào phụ thuộc task này ⇒ không có khối bàn giao.

## 10. Đề xuất cải tiến
- Không có.
