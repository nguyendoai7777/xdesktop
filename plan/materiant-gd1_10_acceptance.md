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

## 0. Bàn giao từ materiant-gd1_04 (30/10/2026)

<!-- handoff: materiant-gd1_04 -->

- **Đã có sẵn để dùng** (launcher): `materiant::field::TextField` — `cx.new(|cx| TextField::new("search", window, cx)
  .placeholder(…).leading_icon(IconName::Search).clearable(true).on_change(…).on_submit(…))`; focus bằng
  `window.focus(&field.focus_handle(cx), cx)` (`impl Focusable`). Esc, Enter, ↑ ↓ đều đi tiếp tới `on_key_down` /
  `capture_key_down` của launcher (test C3) ⇒ ẩn bằng Esc, chọn bằng ↑ ↓ như mẫu gd1_06 ở dưới. Hoặc
  `cx.subscribe(&field, |…, e: &FieldEvent, …|)` (`Change` / `Submit`).
- **Đổi so với spec**: `new(id, window, cx)` (có `window`); placeholder / giá trị ban đầu áp ở khung vẽ đầu ⇒ đọc
  `value(cx)` sau một khung. `set_value` không phát `Change`. Ô lớn `lg` (38 px) chưa có — launcher cần chữ to thì đặt
  `.text_size()` ở phần tử cha hoặc thêm `FieldSize` (mục 10 gd1_04).
- **Nợ chuyển sang đây** (mục 8 gd1_04): dời `FIELD_HEIGHT` / `FIELD_PADDING_X` / `FIELD_ICON_SIZE` (`field/shell.rs`)
  lên `style.rs`. Kiểm tay C4 gd1_04 (Unikey / EVKey / IME tiếng Việt, ô FPS `99` → rời ô ⇒ `60`, bấm nhãn ⇒ focus) —
  gom vào lượt kiểm tay GĐ1.
- **Bẫy đã gặp**: GPUI chỉ phát focus / blur cho cửa sổ ĐANG active ⇒ gallery `--background` không kiểm được blur;
  test UI cần `window.activate_window()` (mẫu `ui-tests/tests/field.rs` `focus_field`). Enter ở ô một dòng làm
  `InputState` phát `Change` dù chữ không đổi — `TextField` đã lọc, ô tự viết trên `gpui_base::Input` thì nhớ lọc.
  Không thử Ctrl+V trên máy thật (đọc clipboard của chủ dự án) — dán kiểm bằng clipboard giả của test.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test field` (5 ca); trang gallery `input` RAM 16,3 MB lúc mở.
  Chi tiết: `plan/materiant-gd1_04_input.md` mục 9.

## 0. Bàn giao từ materiant-gd1_06 (30/10/2026)

<!-- handoff: materiant-gd1_06 -->

- **Đã có sẵn để dùng** (launcher): `materiant::list::{VirtualList, VirtualListHandle, ListKey, Align}`. Ô tìm giữ focus
  ⇒ `on_key_down` của launcher: `ListKey::from_key(&e.keystroke.key)` → `this.selected = this.list.navigate(key,
  this.selected, n)`; lọc xong `this.list.scroll_to(0, Align::Start)`; Enter ⇒ chạy mục chọn. `TextField` của gd1_04 để
  ↑ ↓ đi tiếp lên cha (`plan/confirm.md`) nên cách này chạy được. Mẫu đủ: trang `examples/gallery/pages/scroll.rs`.
- **Nợ chuyển sang đây** (mục 8 của gd1_06): gọi `materiant::list::bind_keys(cx)` trong `materiant::init` (hiện gán lười
  ở lần vẽ danh sách đầu); đồng bộ `ScrollbarMotion` vào theme `gpui_base` ở `theme/` — `with_idle(1 s)`,
  `with_enter / with_exit(160 ms)` cho đúng web (hiện: ẩn sau 2 s, không fade); dời `ROW_RADIUS` / `LIST_RADIUS`
  (`list.rs`), hằng thanh cuộn (`scroll.rs`) lên `style.rs` nếu component khác cần.
- **Việc treo gom**: C4 gd1_06 `[owner-qa]` — cuộn touchpad + bánh xe trên màn 144 Hz ở trang `scroll`.
- **Bẫy đã gặp**: GPUI chạy action của key binding TRƯỚC `on_key_down` ⇒ phím của component phải là action trong
  `key_context` riêng (sâu hơn cha nên thắng), `on_key_down` không chặn được binding của view cha. Worktree chung
  `CARGO_TARGET_DIR` ghi đè rlib của nhau ⇒ build ở `materiant/target/<task>`; `gallery-run.ps1` truyền `-Exe` / `-Out`
  riêng.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test scroll` (7 ca); RAM trang `scroll` 18,1 MB lúc mở /
  18,5 MB sau End — số so khi gộp mọi trang. Chi tiết: `plan/materiant-gd1_06_scroll-list.md` mục 9.

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
