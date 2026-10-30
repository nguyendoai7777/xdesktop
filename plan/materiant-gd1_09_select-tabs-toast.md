# materiant-gd1_09 — Dropdown (select), Tabs, Toast

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~800 dòng |
| Phụ thuộc | materiant-gd1_03 (nút đóng của toast) · **song song** với gd1_07 / gd1_08 (và gd1_04–06 nếu chưa xong) |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/select.rs` · `src/tabs.rs` · `src/toast.rs` SỬA · `examples/gallery/pages/{select,tabs,toast}.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10. Nếu lúc làm gd1_06 (cuộn) đã xong thì danh
sách của dropdown dùng `ScrollArea`; chưa xong thì dùng thanh cuộn mặc định của gpui-base + ghi mục 8.

## 0. Bàn giao từ materiant-gd1_03 (30/10/2026)

<!-- handoff: materiant-gd1_03 -->

- **Đã có sẵn để dùng**: nút đóng toast = `materiant::button::IconButton::new(id, IconName::CloseThin).size(Size::Sm)
  .accessibility_label(…)` (dáng `text`, màu mặc định `primary`; trên toast nhiều màu thì `.color(ink_của_toast)` hoặc
  `.base()`); bo tròn `.rounded_full()`. `Size::{Lg, Md, Sm}.height()` = 38 / 32 / 24 px — dùng cho chiều cao Select
  để đứng thẳng hàng với nút.
- Màu theo loại toast: `Accent::{Primary, Success, Warning, Danger}.tokens(cx)` + bảng thuần
  `ButtonPaint::resolve(Variant::Tonal, …)` nếu muốn toast nền nhạt cùng bậc thang với nút `tonal`.
- Nút có ripple + vòng focus bàn phím sẵn; nút trong toast `loading` / `disabled` tự bỏ khỏi Tab.
- **Bẫy**: chữ trong khung `line_height = 1` (trigger của Select, nhãn Tab) trông thấp ~2 px — xem `button::optical_lift`
  (pub(crate), dời lên `style.rs` ở gd1_10); `TextSystem::descent` của DirectWrite là số âm. GPUI sinh click bàn phím ở
  KeyUp ⇒ UI test gửi cả KeyDown + KeyUp (`press()` trong `ui-tests/tests/button.rs`); `--keys` của gallery chỉ KeyDown.
- **Bẫy build**: worktree dùng chung `CARGO_TARGET_DIR` đè rlib `materiant` của nhau khi build cùng lúc ⇒ target riêng
  khi có làn khác đang build.
- **Soát lại khi làm**: trang gallery `button`; `plan/materiant-gd1_03_button-kbd.md` mục 9 (API đầy đủ).

## 0. Bàn giao từ materiant-gd1_06 (30/10/2026)

<!-- handoff: materiant-gd1_06 -->

- **Đã có sẵn để dùng**: danh sách thả của `Select` dài ⇒ `materiant::list::scroll_top_for_index(…, Align::Nearest)` /
  `VirtualListHandle::scroll_to(ix, Align::Nearest)` để mục đang trỏ luôn lọt khung; `ListNav::apply` (↑ ↓ PageUp PageDown
  Home End, KHÔNG vòng, kẹp, `count = 0` ⇒ `None`). Bọc danh sách ngắn bằng `ScrollArea::new(id).vertical().max_h(…)`;
  `Scrollbar` tự dựng ⇒ `materiant::scroll::scrollbar_styles(cx.scrollbar_tokens())`.
- **Khác cần chú ý**: `ListNav` không vòng (đúng danh sách / launcher); typeahead chưa có ở `list.rs` — viết trong
  `select.rs`.
- **Bẫy đã gặp**: GPUI chạy action của key binding TRƯỚC `on_key_down` ⇒ ↑ ↓ / Enter của Select phải là action trong
  `key_context` riêng (sâu hơn cha nên thắng ↑ ↓ đổi trang của gallery); mẫu `materiant::list::bind_keys` + test
  `keys_move_selection_and_keep_it_visible` (`ui-tests/tests/scroll.rs`) gán ↓ ở view cha để soát.
- **Bẫy đã gặp**: build ở `CARGO_TARGET_DIR=materiant/target/<task>` riêng; `gallery-run.ps1 -Exe … -Out …` riêng.

## 1. Làm gì

- `Select` trên `gpui_base::Select`: đóng / mở bằng Enter / Space / ↓, ↑ ↓ chọn, typeahead (gõ chữ nhảy tới mục),
  disabled, có `FieldShell`-like nhãn (dùng lại style của gd1_04 chỉ khi đã gộp — không thì tự vẽ khung, ghi nợ).
- `Tabs`: ngang + dọc (sidebar Settings của fastcast), vạch chỉ báo (`tab-ink`) trượt, ← → / ↑ ↓ đổi tab, Home / End.
- `Toast`: hàng đợi chồng nhiều cái ở góc cửa sổ, tự ẩn sau thời gian (dừng đếm khi rê chuột), nút đóng
  (`IconButton`), loại `info` / `success` / `warning` / `danger`, animate vào / ra. App gọi `Toast::push(window, cx, …)`.

## 2. Không làm trong task này

- Tabs nhớ trạng thái theo URL (`query-memory`) — đặc thù web, bỏ. Select nhiều lựa chọn / có ô tìm — GĐ2 nếu cần.
- Không sửa `style.rs` / `icon.rs`.

## 3. Interface

`Select::new(id, cx).items(…).selected(ix).on_change(…)`; `Tabs::new(id).vertical().tab(…).selected(ix)
.on_change(…)`; `Toast::push(window, cx, ToastSpec { kind, message, duration })`; bộ đếm giờ toast là hàm thuần
(`ToastTimer` tạm dừng / tiếp).

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\` — `form/ui/src/lib/dropdown/` (+ `dropdown-field`); `tabs/src/lib/`
  (`tab-group.ts`, `tab-nav.ts`, `tab-ink.ts`, `tabs.util.ts` + spec, `tabs.css`, `tab-bar/`); `toast/src/lib/`
  (`toast.service.ts`, `toast-timer.ts` + spec, `toast-ref.ts` + spec, `toast-viewport.ts`, `toast*.css`,
  `toast-item/`, `toast-message/`).

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` typeahead chọn mục đầu khớp tiền tố (không phân biệt hoa thường, gõ lại cùng chữ đi mục kế).
- C2 `[opus-unit]` `ToastTimer`: tạm dừng khi rê, tiếp đúng phần còn lại — theo `toast-timer.spec.ts`.
- C3 `[opus-unit]` điều hướng tabs (bỏ tab disabled, Home / End) theo `tabs.util.spec.ts`.
- C4 `[opus-run]` gallery: đẩy 5 toast liên tiếp chồng đúng thứ tự, tự ẩn; tabs dọc + ngang đổi bằng phím.
- C5 `[owner-qa]` so ba trang với tài liệu materiant web ở sáng / tối.

## 7. Ghi chú UI

Trang `select`: vài dropdown (thường, disabled, 50 mục). Trang `tabs`: tabs ngang trên, tabs dọc trái. Trang `toast`:
bốn nút đẩy bốn loại toast.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
