# gd1_08 — Thước căn trên màn đóng băng

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd1_02 · gd1_05 (chép chữ) |
| Quyết định áp dụng | F-1, F-3 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/ruler.rs` MỚI · `crates/ui/src/overlay/mod.rs` SỬA · `crates/ui/src/commands.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- `ruler` ⇒ đóng băng + overlay (dùng lại gd1_02, chế độ `Ruler`): hai trục x / y mảnh đi qua con trỏ, kéo hết màn
  đang chứa con trỏ; nhãn toạ độ con trỏ (pixel vật lý, cục bộ của màn).
- Nhấn – kéo – nhả ⇒ hình chữ nhật từ điểm đầu tới điểm cuối, nhãn `W × H px` (pixel vật lý). Kéo lại ⇒ đo mới.
- Ctrl/Cmd+C chép `W×H` (vd `320×48`) qua daemon; Esc thoát.
- Shift khi kéo ⇒ khoá một trục (đo thuần ngang / dọc).

## 2. Không làm trong task này

- Đo nhiều hình cùng lúc, tự bắt cạnh phần tử (snap to edges) — ghi đề xuất nếu thấy đáng.

## 4. Code

Dùng `selection.rs` của gd1_02 (cùng máy trạng thái kéo) nhưng không có tay nắm / thanh công cụ. Nhãn `px` là pixel
**vật lý** — dev FE cần cả CSS px ⇒ hiện thêm `(@1.5x: 213×32)` khi màn có scale ≠ 1.

## 6. Nghiệm thu

- Kéo 100 px logic trên màn 150 % ⇒ nhãn 150 px vật lý + `@1.5x: 100`.
- Trục vẽ trên đúng màn chứa con trỏ khi con trỏ đi qua màn khác.
- `[owner-qa]`: đo một nút trên trang web đã biết cỡ CSS ⇒ khớp.

## 7. Ghi chú UI

Trục 1 px logic màu nhấn, nhãn nền tối chữ sáng. Khoá i18n: `ruler.copy_hint`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
