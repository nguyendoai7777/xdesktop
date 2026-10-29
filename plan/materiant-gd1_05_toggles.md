# materiant-gd1_05 — Checkbox, Radio, Switch

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~450 dòng |
| Phụ thuộc | materiant-gd1_02 · **song song** với gd1_03, gd1_04, gd1_06 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/checkbox.rs` · `src/radio.rs` · `src/switch.rs` SỬA · `examples/gallery/pages/toggles.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10.

## 1. Làm gì

- `Checkbox` trên primitive cùng tên của `gpui-base`: checked / unchecked / indeterminate (icon `minus`), nhãn bấm
  được, disabled, ripple tròn quanh ô.
- `Radio` + `RadioGroup`: ↑ ↓ / ← → đổi lựa chọn trong nhóm, Tab vào nhóm rơi vào mục đang chọn.
- `Switch`: thumb trượt có animate (`gpui_base::motion`), Space bật / tắt, tắt animate khi OS giảm chuyển động.
- Màu chọn = primary (hoặc màu nhấn khác), đúng sáng / tối.

## 2. Không làm trong task này

- Nhóm checkbox có "chọn tất cả" (GĐ2 nếu cần). Không sửa `style.rs` / `icon.rs`.

## 3. Interface

`Checkbox::new(id).checked(CheckState).label(…).on_change(…)`; `RadioGroup::new(id).items(…).selected(ix)
.on_change(…)`; `Switch::new(id).on(bool).on_change(…)`; `.accent(Accent)` chung.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\form\ui\src\lib\` — `checkbox/` (cả `checkbox-field`, `checkbox-group` để
  lấy số đo), `radio/`, `switch/`. README / API.md của `form`.

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` điều hướng nhóm radio: ↓ ở mục cuối quay về đầu, bỏ qua mục disabled.
- C2 `[opus-run]` gallery: Space bật / tắt checkbox + switch, indeterminate → checked khi bấm, disabled không đổi.
- C3 `[opus-run]` sáng / tối đúng màu; switch animate, tắt khi bật "Show animations = off" của Windows.
- C4 `[owner-qa]` so trang `toggles` với tài liệu materiant web.

## 7. Ghi chú UI

Trang `toggles`: ba cột (Checkbox · Radio · Switch), mỗi cột đủ trạng thái + disabled, một hàng đổi màu nhấn.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
