# gd1_03 — Chỉnh vùng chọn + thanh công cụ

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | gd1_02 · materiant-gd1_02 (ripple), gd1_03 (`IconButton`), gd1_07 (`Tooltip`) |
| Quyết định áp dụng | F-3, F-1 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/selection.rs` SỬA · `crates/ui/src/overlay/handles.rs` MỚI · `crates/ui/src/overlay/toolbar.rs` MỚI · `crates/ui/src/overlay/view.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- Sau khi nhả chuột: 8 tay nắm (4 góc + 4 cạnh) kéo đổi cỡ, kéo bên trong để dời, kéo ra ngoài vùng ⇒ chọn lại từ đầu.
- Phím: mũi tên dời 1 px vật lý, Shift + mũi tên 10 px, Alt + mũi tên đổi cỡ cạnh phải / dưới; Esc bỏ vùng chọn (lần
  hai đóng overlay); Enter = hành động mặc định (chép — gd1_05).
- Mọi phép chỉnh tính bằng toạ độ toàn cục vật lý, kẹp trong desktop ảo, cỡ tối thiểu 1 × 1.
- Thanh công cụ nổi cạnh vùng chọn (dưới, phải; không đủ chỗ thì lật lên / vào trong; luôn nằm trọn trên **một** màn):
  Lưu, Lưu thành…, Chép, Đóng — nút gắn hành động từ gd1_04 / gd1_05 (task này chỉ phát sự kiện).
- `handles.rs`: hit-test tay nắm + phép đổi cỡ thuần (kéo qua cạnh đối diện thì lật) — test đơn vị.

## 2. Không làm trong task này

- Công cụ chú thích (chữ nhật, mũi tên, chữ…): GĐ2 — chỉ chừa chỗ trên thanh công cụ.

## 3. Kiểu dữ liệu · IPC · cấu hình

`SelectionState::Selected { rect, grab: Option<Grab> }`, `Grab = Move | Resize(Handle)`;
`ToolbarAction = Save | SaveAs | Copy | Close`.

## 4. Code

Hit-test tay nắm theo pixel **logic** của cửa sổ đang chứa con trỏ (vùng bắt 8 px logic), rồi đổi về toàn cục vật lý
bằng `MonitorInfo::from_logical`. Vị trí thanh công cụ là hàm thuần (rect vùng chọn, layout, cỡ thanh) → (màn, toạ độ).

## 5. Đo

CPU khi kéo đổi cỡ liên tục 2 s trên 2 màn (so gd1_02).

## 6. Nghiệm thu

- Đổi cỡ bằng tay nắm khi vùng vắt hai màn khác scale ⇒ cạnh bám đúng con trỏ trên cả hai màn.
- Thanh công cụ không bao giờ bị cắt ở mép màn / nằm vắt hai màn (test hàm vị trí với layout giả lập 3 màn).
- Test đơn vị: lật khi kéo qua cạnh đối diện, kẹp mép desktop, nudge Shift.
- `[owner-qa]`: Tab / Enter / Space điều khiển được nút trên thanh công cụ; tooltip có phím tắt.

## 7. Ghi chú UI

```
┌───────────────── vùng chọn ─────────────────┐
■                                             ■   ■ = tay nắm 8 px logic
└─────────────────────────────────────────────┘
                     [💾] [💾…] [⧉] [✕]          IconButton sm, tonal; tooltip "Lưu  Ctrl+S"
```

Khoá i18n: `toolbar.save`, `toolbar.save_as`, `toolbar.copy`, `toolbar.close`.

## 8. Nợ chuyển task khác

- Hành động Lưu / Lưu thành: gd1_04. Chép: gd1_05.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
