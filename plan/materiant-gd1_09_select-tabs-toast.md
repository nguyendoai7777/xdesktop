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
