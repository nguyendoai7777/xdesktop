# materiant-gd1_10 — Nghiệm thu GĐ1

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~300 dòng (example launcher) + báo cáo |
| Phụ thuộc | materiant-gd1_01 → gd1_09 |
| Quyết định áp dụng | D-3 (đa nền tảng), D-6 |
| Phụ thuộc mới | — (`unicode-normalization` chỉ nếu example cần bỏ dấu — ưu tiên không) |
| File đụng tới | `examples/launcher.rs` MỚI · `docs/gd1-report.md` MỚI · `ROADMAP.md` SỬA (bàn giao GĐ1) |

## 0. Bàn giao từ materiant-gd1_02 (29/10/2026)

<!-- handoff: materiant-gd1_02 -->

- **Đã có sẵn để dùng**: `.drag_region()` (`materiant::window::DragRegionExt`) — thanh trên của launcher; ô nhập bên
  trong bọc `.occlude()`. Cửa sổ mở với `is_movable: true`. Icon `Search` cho ô lọc.
- Việc treo của gd1_02 cần gom: kiểm tay C4 (kéo cửa sổ) + C5 (ripple so web, icon 150 % DPI) — `plan/_backlog.md`.
- Gom "dời lên `style.rs` / `icon.rs`" của gd1_03–06 (mục 8 của từng task); thêm icon = tệp `assets/icons/<tên>.svg` +
  một dòng `icons!` ở `src/icon.rs`.
- So ảnh sáng / tối: `gallery-run.ps1 -Keys "ctrl-t shot@light ctrl-t shot@dark"` cho mỗi trang.
- **Soát lại khi làm**: `cargo test` (25 unit + 4 theme UI + 5 ripple UI + 1 gallery); chạy thử chỉ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page <trang> -Keys "…"` — phím, chuột `down@x,y` / `up@` / `move@`, `wait@ms`,
  `shot@tên` (ảnh giữa chuỗi); toạ độ lấy từ ảnh trừ ~31 px thanh tiêu đề; ảnh xem xong xoá. Token + tên hàm đầy đủ:
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- Dựng lại launcher của spike bằng materiant (`TextField`, `VirtualList`, `Kbd`, `.drag_region()`, `Menu` cho Ctrl+K):
  Esc / bấm ra ngoài thì ẩn, kéo được bằng thanh trên (ô nhập không kéo), vị trí kéo tới được nhớ cho lần mở sau.
- Đo RAM so với spike (15,7 MB Task Manager), khung đầu.
- So ảnh gallery với trang tài liệu materiant ở cả sáng / tối — liệt kê chỗ lệch.
- Chạy gallery + launcher trên macOS và Ubuntu (D-3): ghi lỗi nền tảng.
- Gom việc treo của gd1_01–09 (mục 8 "dời token lên `style.rs`", icon thiếu…) thành một lượt dọn hoặc ghi `plan/_backlog.md`.
- Báo cáo `docs/gd1-report.md`; mục "Bàn giao GĐ1" trong `ROADMAP.md` cho fastcast.

## 2. Không làm trong task này

- Không thêm component mới; lỗi lớn ⇒ tách task sửa.

## 5. Đo

- RAM `launcher` example nghỉ + sau khi gõ lọc (Task Manager); cỡ exe; thời gian khung đầu (mẫu `bench.ps1`).

## 6. Nghiệm thu

- C1 `[opus-run]` launcher example chạy đủ hành vi mục 1 trên Windows; RAM ghi vào báo cáo.
- C2 `[opus-run]` soát xanh cả repo; gallery đủ mọi trang, không trang nào còn "chưa làm".
- C3 `[owner-qa]` chạy gallery + launcher trên macOS và Ubuntu (lệnh trong báo cáo), gửi lại ảnh / lỗi.
- C4 `[owner-qa]` duyệt bảng so ảnh sáng / tối.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
