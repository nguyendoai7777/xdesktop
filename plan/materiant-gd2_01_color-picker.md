# materiant-gd2_01 — bảng chọn màu

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | M — ước ~450 dòng, thật ~640 dòng mã + ~180 dòng test thuần trong `src/color_picker.rs` (vẫn dưới trần 900) |
| Phụ thuộc | materiant GĐ1 |
| Quyết định áp dụng | D-6, D-9, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `src/color_picker.rs`, `examples/gallery/pages/color_picker.rs`, `ui-tests/tests/color_picker.rs`; SỬA `src/lib.rs`, `src/field/input.rs`, `examples/gallery/{main,pages/mod}.rs`, `examples/common/dev.rs`, `tools/gallery-run.ps1`, `CLAUDE.md`, `ROADMAP.md` |

## 1. Làm gì

- `ColorPicker` có state: ô bão hoà / độ sáng (HSV), thanh sắc độ, ô hex, hàng màu mẫu do app truyền, phát `ColorPickerEvent::Change`.
- Kéo ra ngoài ô vẫn bám; bàn phím: mũi tên chỉnh ô đang focus; không chữ cố định (app truyền nhãn).
- Đổi HSV ↔ RGB ↔ hex là hàm thuần có test. Trang gallery, sáng / tối.

## 2. Không làm trong task này

Kênh alpha, OKLCH, lưu bảng màu.

## 2b. Phân vai

Làm hết ở `[opus]`: API chốt sớm cho fastcast gd2_05, các phần dính nhau trong một tệp nên không tách `[sonnet]`.
`[owner-qa]`: C10.

## 3. Kiểu dữ liệu

`materiant::color_picker`: `Rgb { r, g, b }` (u8; `From<[u8; 3]>` hai chiều, `to_hex`, `parse_hex`, `to_hsv`), `Hsv`,
`ColorPicker`, `ColorPickerEvent::Change(Rgb)`, `ColorPickerLabels { area, hue, hex }`. Không config, không IPC.

## 4. Code

`src/color_picker.rs`; kéo = `canvas` đăng ký `window.on_mouse_event` (pha capture); gradient ô màu = hai lớp phủ trên màu
thuần; thanh sắc độ = 6 đoạn gradient hai điểm dừng.

## 5. Đo

RAM gallery trang này 14,3–15,0 MB (hiển thị trên trang, `gallery-run` đo 15 MB) — thư viện, không vào tiến trình nền.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ |
|---|---|---|
| C1 | Mọi mã RGB (lưới bước 5 + góc) ⇒ HSV ⇒ RGB về đúng byte; màu chuẩn đúng; hex nhận / từ chối đúng | `[opus-unit]` ✅ |
| C2 | Xám / đen giữ sắc độ, đen giữ bão hoà; khớp mã thì HSV không nhảy; mũi tên kẹp ở biên | `[opus-unit]` ✅ |
| C3 | Ô màu focus, cha gán `up`: ↑ chỉnh ô màu, cha không nhận; ← bớt bão hoà; Shift = bước 10 % | `[opus-unit]` ✅ |
| C4 | Thanh sắc độ: Shift+→ = +10°, ← giảm | `[opus-unit]` ✅ |
| C5 | Kéo ra xa ngoài ô: kẹp đúng góc; nhả thì thôi; di chuyển không giữ nút ⇒ thôi kéo | `[opus-unit]` ✅ |
| C6 | Ô hex: 6 chữ số áp ngay, không đè chữ đang gõ; Enter nhận 3 chữ số + chuẩn hoá; rời ô với chữ sai ⇒ về màu hiện tại | `[opus-unit]` ✅ |
| C7 | Màu mẫu: Tab + Space / Enter áp; bấm lại cùng màu không phát; đen đổi sắc độ không phát, `set_value` không phát | `[opus-unit]` ✅ |
| C8 | `cargo build`, `clippy -D warnings`, `cargo test`, `deny check licenses` xanh; `tree -i gpui-component` báo không có | `[opus-run]` ✅ |
| C9 | Gallery bằng `gallery-run`: đúng sáng / tối, nền nổi 0,75, kéo ra ngoài cửa sổ `#FF0E00` đúng, ↑ không đổi trang, vòng focus hiện, `foreground_unchanged=True` | `[opus-run]` ✅ |
| C10 | Kéo chuột thật ra ngoài cửa sổ, nhả ngoài cửa sổ | `[owner-qa]` chờ kiểm tay: `pwsh start.ps1 docs color_picker` |

## 7. Ghi chú UI

```
┌ 240 ───────────┐
│ ô màu 240×150  │   Tab: ô màu → sắc độ → hex → từng màu mẫu
│ sắc độ 240×12  │   mũi tên 1 % / 1°, Shift + mũi tên 10 % / 10°
│ [■] [#RRGGBB ] │
│ ● ● ● ● ● ● ●  │   màu mẫu 20 px, 8 màu một hàng; đang chọn có vòng
└────────────────┘
```

`.floating(true)`: thêm đệm 12 px (bề ngang 264), `floating_surface` (D-10), bóng, `occlude`.

## 8. Nợ chuyển task khác

- `gd2_05_color` (fastcast): dùng API ở mục 9, chặn phím tắt khi `hex_focused`.

## 9. Bàn giao thực tế

**Cho fastcast — API thật**:

```rust
use materiant::color_picker::{ColorPicker, ColorPickerEvent, ColorPickerLabels, Rgb};
let picker = cx.new(|cx| {
    ColorPicker::new("annotate-color", style.color /* [u8; 3] */, window, cx)
        .floating(true)
        .swatches(PRESETS /* [[u8; 3]; N] */)
        .labels(ColorPickerLabels { area, hue, hex }, cx)
});
cx.subscribe(&picker, |this, _, ColorPickerEvent::Change(rgb), cx| { let c: [u8; 3] = (*rgb).into(); … });
```

Thêm: `.on_change(|rgb, window, cx|)`, `value()`, `set_value(rgb, window, cx)` (không phát sự kiện), `set_swatches`,
`set_labels`, `hex_focused(window, cx)`, `hex_field()`, `dragging()`, `Focusable` (trỏ ô màu).
`materiant::init` đã gán phím; `ColorPicker::new` cũng tự gán nếu app chưa gọi.

**Opus chọn 30/10/2026** (đã ghi `plan/confirm.md`): kiểu màu `Rgb` u8 đổi được `[u8; 3]`; component không tự mở popover;
hex `#RRGGBB` chữ hoa; 6 chữ số áp ngay, 3 chữ số chỉ áp khi Enter / rời ô; sắc độ kẹp 0–360, không xoay vòng.

**Ngoài danh sách tệp ban đầu**: `TextField::set_accessibility_label` (ô hex cần tên đọc màn hình mà không hiện nhãn);
verb `drag@x,y` cho `--keys` (`move@` gửi `pressed_button: None` nên không giả lập được kéo); `ui-tests/tests/color_picker.rs`.

**Bẫy**: `track_focus(&handle)` KHÔNG lấy `.tab_stop()` / `.tab_index()` của phần tử — handle tự mang
`cx.focus_handle().tab_stop(true)` thì Tab mới tới. Test phím Tab phải bọc cửa sổ trong `Root`.

**Soát**: `cargo build`, `clippy --all-targets -D warnings`, `cargo test` (9 test UI + 8 test thuần của module, toàn bộ
xanh), `cargo deny check licenses` ok. Chờ kiểm tay: C10.

**Mục 5 run-task**: bảo mật — không áp (không tệp, không IPC). UI/UX — bàn phím đủ, sáng / tối đạt; cỡ chữ lớn không ảnh
hưởng ô màu (px cố định có chủ ý). RAM — hai listener mỗi khung, không vẽ lại khi không kéo. Lỗi tìm thấy và đã sửa: Tab
không tới ô màu / thanh sắc độ (bẫy trên).

## 10. Đề xuất cải tiến

- [ux] Thanh sắc độ / ô màu chưa có Home / End — `src/color_picker.rs` `bind_keys` chỉ gán mũi tên — thêm khi có người cần — giá trị thấp — S — P3.
- [pro] Bảng màu riêng lưu theo người dùng, kênh alpha — mục 2 loại khỏi task — đặt chỗ huy hiệu Pro nếu làm (D-4) — M — P3.

Không có đề xuất P1 / P2 nên không làm thêm trong lượt.
