# gd2_02 — đường thẳng, mũi tên, elip, độ dày

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ |
| Repo | fastcast |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | gd2_01 |
| Quyết định áp dụng | D-9, D-10, F-11 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/annotate/{model,shape,export,paint}.rs`, `overlay/{toolbar,view}.rs`, `assets.rs`, `i18n/{vi,en}.toml`; MỚI `overlay/annotate/options.rs`, icon `line.svg` (`design/fastcast-icons/` + `crates/ui/assets/icons/`) |


## 0. Bàn giao từ gd2_01 (30/10/2026)

<!-- handoff: gd2_01 -->

- **Đã có sẵn để dùng**: `annotate::shape::prims` là nguồn hình chung cho lớp vẽ + lớp xuất, thêm hình chỉ sửa ở đó; `tests/overlay.rs::saved_ink_image`.
- **Bẫy đã gặp**: `Visible` chỉ giữ `ink_rev` theo màn; đọc thẳng `Ink` lúc paint, đừng đọc `OverlaySession` trong `render`.

## 1. Làm gì

- Công cụ `line` (phím `l`), `arrow` (`a`), `ellipse` (`e`). Shift: thẳng theo bội 45°, chữ nhật thành vuông, elip thành tròn.
- Bảng tuỳ chọn cạnh thanh công cụ: 4 độ dày (phím `[` `]` đổi), đơn vị logic của màn đang vẽ ⇒ đổi ra pixel vật lý lúc bắt đầu nét.
- Đầu mũi tên co theo độ dày, mũi tên quá ngắn không vỡ hình. Ảnh xuất khớp hình trên màn.
- Tự vẽ icon `line` cùng hệ F-11.

## 2. Không làm trong task này

Vẽ tự do, chữ, bảng màu.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

Ảnh lưu đủ hình đúng vị trí, cả khi vùng vắt hai màn khác scale; độ dày đúng theo pixel vật lý.

## 7. Ghi chú UI

Bảng tuỳ chọn cùng nền khối nổi, đặt dưới thanh (lật lên khi sát đáy màn).

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

Gộp `master` ở `a379e5b`.

- Có: đường thẳng, mũi tên, elip; Shift khoá 45° / vuông; bốn độ dày 2 / 3 / 5 / 8 logic, phím `[` `]`; bảng tuỳ chọn `annotate/options.rs`.
- `lyon` thêm trực tiếp vào `crates/ui` (đã có trong cây qua GPUI).

## 10. Đề xuất cải tiến
