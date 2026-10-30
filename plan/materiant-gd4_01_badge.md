# materiant-gd4_01 — huy hiệu `Badge`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~80 dòng |
| Phụ thuộc | gd3_13 đã gộp `master` (chủ dự án chốt 30/10/2026); song song với gd4_01, khác repo |
| Quyết định áp dụng | D-4, D-6, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `src/badge.rs`, `examples/gallery/pages/badge.rs`; SỬA `src/lib.rs`, `examples/gallery/{main,pages/mod}.rs`, `CLAUDE.md` (bảng module) |

## 1. Làm gì

- `materiant::badge::Badge::new(label)`: chip chữ nhỏ, `.tone(Accent)` (mặc định `Primary`), `.outline()`. Không state, `RenderOnce`, không chứa chữ cố định.
- Trang gallery sáng / tối, đủ tông màu. Tương phản chữ / nền ≥ 4,5 : 1 ở cả hai tông (test thuần trên token).

## 2. Không làm trong task này

Huy hiệu số thông báo, chấm trạng thái. `IconSource` của F-12 (D-4 chỉ đặt chỗ). Dọn nợ GĐ1 của materiant.

## 4. Code

Dùng `Accent::tokens` (`tonal*`), `text_caption`, số đo lấy từ gói `chip` / `badge` ở `E:\codex\xbds\materiant\projects`. Mẫu chip: `kbd.rs`.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh; `cargo tree -i gpui-component` báo không có.
- [ ] `pwsh tools/gallery-run.ps1 -Page badge` chụp sáng + tối (mở ở màn phụ DELL, không giành focus).

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
