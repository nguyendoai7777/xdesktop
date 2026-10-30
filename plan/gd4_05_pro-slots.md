# gd4_05 — chỗ cho Pro

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~120 dòng |
| Phụ thuộc | gd4_01, materiant-gd4_01 |
| Quyết định áp dụng | D-4, F-12 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/{page_pro,row}.rs`; MỚI `crates/ui/tests/settings_pro.rs` |

## 1. Làm gì

- Trang Pro: một câu giới thiệu + `locked_row` cho mọi `ProFeature::ALL`: tên, mô tả, huy hiệu `Badge`, không bấm được.
- `row::locked_row` điền thân thật (gd4_01 để stub): trình đọc màn hình đọc được "pro", Tab bỏ qua.
- `Entitlement::current()` là nguồn duy nhất: `Pro` ⇒ dòng hiện không khoá (chỉ để test hàm thuần, không có đường bật lúc chạy).

## 2. Không làm trong task này

Tính năng Pro nào, nút mua, trang giá, kiểm giấy phép, gọi mạng. Không thêm dòng khoá vào launcher, overlay, thanh công cụ: giữ đường nóng sạch. Làm thật `customIcons` / theme tuỳ biến: để lúc có thanh toán (D-4).

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh.
- [ ] Soát mã: không có biến môi trường, khoá config, tham số dòng lệnh nào bật Pro (test `Entitlement::current() == Free` trong bản release).
- [ ] `settings-run.ps1 -Page pro` chụp vi / en × sáng / tối: mười dòng, cuộn được, cỡ chữ 20 không vỡ. Chỉ màn DELL.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
