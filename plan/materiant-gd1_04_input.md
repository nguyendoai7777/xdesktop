# materiant-gd1_04 — Ô nhập: field-shell, ô chữ, ô số

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | materiant-gd1_02 · **song song** với gd1_03, gd1_05, gd1_06 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/field/mod.rs` · `src/field/shell.rs` · `src/field/input.rs` · `src/field/number.rs` SỬA · `examples/gallery/pages/input.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10 (nghiệm thu) + fastcast `gd1_06` (launcher dùng
ô tìm kiếm) qua mục 9.

## 1. Làm gì

- `FieldShell`: khung nhãn, gợi ý, lỗi, icon đầu / cuối, trạng thái thường / hover / focus / lỗi / disabled theo token
  ô nhập của gd1_02 (`radius-field` 10 px).
- `TextField` trên `gpui_base::Input`: placeholder, chọn chữ, undo / redo, dán, xoá nhanh (icon `x`), `on_change` /
  `on_submit`. Phím Esc / Enter **không** bị nuốt — app bắt ở pha capture được (bẫy đã gặp ở spike launcher).
- `NumberField` với mask số: min / max / bước, ↑ ↓ tăng giảm, gõ chữ sai bị chặn, dán chuỗi lẫn chữ ⇒ lọc số (FPS
  1–60, cỡ chữ của fastcast).

## 2. Không làm trong task này

- Ô nhiều dòng, ô mật khẩu, ô mã (`code-field`) — GĐ2 nếu cần. Không sửa `style.rs` / `icon.rs`.

## 3. Interface

`TextField::new(id, cx)` (Entity, giữ trạng thái gõ) `.placeholder()` `.label()` `.hint()` `.error(Option<…>)`
`.leading_icon(IconName)` `.clearable(bool)`; `NumberField::new(id, cx).range(1..=60).step(1)`; logic mask
`numeric_mask::apply(input, cfg) -> String` là hàm thuần.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\form\` — `ui/src/lib/field-shell/`, `ui/src/lib/input/`,
  `headless/src/lib/numeric-mask.ts` (+ `numeric-mask.spec.ts` làm nguồn ca), `headless/src/lib/field-state.ts`.
- Mẫu ô nhập không nuốt Esc: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` (launcher).

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` `numeric_mask` theo các ca của `numeric-mask.spec.ts` (âm, thập phân, dán lẫn chữ, vượt min / max).
- C2 `[opus-run]` gallery: gõ, chọn chữ, Ctrl+Z / Ctrl+Y, dán, nút xoá; NumberField ↑ ↓ dừng ở biên.
- C3 `[opus-run]` Esc trong ô nhập đến được listener capture của trang gallery.
- C4 `[owner-qa]` gõ Unikey / EVKey (Telex) + IME tiếng Việt của Windows: "Tiếng Việt có dấu" không mất / nhân đôi ký tự.

## 7. Ghi chú UI

Trang `input`: ô thường, có nhãn + gợi ý, đang lỗi, disabled, có icon search + xoá, NumberField.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
