# gd2_05 — chọn màu cho mọi công cụ

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ |
| Repo | fastcast |
| Cỡ | S — ~250 dòng |
| Phụ thuộc | gd2_04, materiant-gd2_01 |
| Quyết định áp dụng | D-9, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/annotate/{options,model}.rs`, `overlay/{mod,view,toolbar}.rs`, `crates/core/src/config.rs`, `i18n/{vi,en}.toml` |

## 0. Bàn giao từ materiant-gd2_01 (30/10/2026)

<!-- handoff: materiant-gd2_01 -->

- **Đã có sẵn để dùng**: `materiant::color_picker::{ColorPicker, ColorPickerEvent, ColorPickerLabels, Rgb}` — mẫu gọi ở
  `plan/materiant-gd2_01_color-picker.md` mục 9, trang gallery `color_picker`. Đã gộp `master` của materiant.
- `ColorPicker::new(id, [u8; 3], window, cx)` nhận thẳng `Color = [u8; 3]` của `annotate/model.rs`; `Rgb` đổi về bằng
  `let c: [u8; 3] = rgb.into()`. Sự kiện `ColorPickerEvent::Change(Rgb)` chỉ phát khi mã RGB đổi.
- Đặt thẳng trên overlay: `.floating(true)` (nền `floating_surface` D-10, đệm, bóng, `occlude`; rộng 264 px). Component
  không tự mở / đóng — view của overlay giữ `Entity<ColorPicker>` và cờ hiện, phím `c` chỉ bật cờ.
- Đổi từ ngoài (đổi công cụ, nạp config): `set_value(color, window, cx)` — không phát sự kiện nên không lặp vòng.
- Hàng màu mẫu: `.swatches([...])` nhận `[[u8; 3]; N]`. Nhãn đọc màn hình: `ColorPickerLabels { area, hue, hex }` qua
  catalog i18n — component không có chữ hiển thị nào khác.
- **Bẫy — phím tắt**: phím gõ trong ô hex vẫn nổi lên `on_key` của overlay (không chặn được, chặn là mất ký tự), `a`–`f`
  còn là chữ hex. `on_key` phải soát `picker.read(cx).hex_focused(window, cx)` đầu hàm rồi `return`; cả Enter / Esc: Enter
  trong ô hex là chốt màu, đừng để nó xác nhận vùng.
- **Bẫy — chuột**: panel đã `occlude`, nhưng listener cấp cửa sổ của overlay vẫn thấy chuột lúc kéo ra ngoài bảng — soát
  `picker.read(cx).dragging()` trước khi coi đó là nét vẽ / đổi vùng.
- **Bẫy — mũi tên**: ô màu / thanh sắc độ đang focus nhận mũi tên qua keymap context `ColorPickerSlider` (thắng phím của
  cha), mũi tên dời vùng của overlay sẽ không chạy lúc đó. Đóng bảng thì trả focus về view overlay.
- **Soát lại khi làm**: fastcast build thấy đúng `materiant` đã gộp (có module `color_picker`); so diện mạo ở trang gallery `color_picker` (`pwsh materiant/tools/gallery-run.ps1 -Page color_picker`).

## 0. Bàn giao từ gd2_04 (30/10/2026)

<!-- handoff: gd2_04 -->

- **Đã có sẵn để dùng**: `OverlaySession::change_font`, `relayout_text`; `Ink.style` (`InkStyle { color, width, font: TextFont }`) là kiểu hiện tại, ô đang soạn đọc `style` lúc vẽ nên đổi màu áp ngay; `options::Labels`.
- **Bẫy đã gặp**: khi có ô soạn, `on_key` để phím thường rơi tới input handler. Ô hex của bảng màu có focus riêng, phải kiểm phím tắt công cụ không chạy. `Shape::Text` lưu màu lúc chốt, `TextEditing` thì chưa có màu.

## 1. Làm gì

- Nút màu trên bảng tuỳ chọn mở `materiant::color_picker`, đổi màu áp cho nét sau, cho cả ô chữ đang soạn. Phím `c` mở / đóng.
- Hàng màu mẫu; nhớ màu + độ dày + cỡ chữ gần nhất (`config.annotate`, có `#[serde(default)]`, ghi lúc đóng overlay).
- Gõ hex trong bảng không kích hoạt phím tắt công cụ.
- **Thêm (chủ dự án, 30/10/2026)**: con lăn đổi cỡ công cụ đang bật. Độ dày 1–32 (vẽ tự do 1–48), bước 1, mặc định 3; chữ 10–96, bước 2, mặc định 20. Áp ngay trên nét đang vẽ và ô chữ đang soạn, không thêm mục undo; touchpad cộng dồn; mỗi công cụ nhớ cỡ riêng; nhãn `3 px` gần con trỏ 1 giây.

## 2. Không làm trong task này

Lấy màu từ ảnh đóng băng ngay trong bảng.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

Đổi màu xong vẽ ra đúng màu, ảnh xuất đúng mã màu.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

Gộp `master` ở `3dee9ef`.

- Có: `InkStyle { color, widths: [u16; 5], font }`, `size_range(tool)` (mọi min / max / bước ở `model.rs`), `WheelSteps`, `Ink::nudge_stroke`, `OverlaySession::{wheel, toggle_color, set_color}`; `OverlayView::{on_wheel, sync_color_panel}`; `config.annotate` (`color`, `lineWidth`, `arrowWidth`, `rectangleWidth`, `ellipseWidth`, `penWidth`, `fontSize`), kẹp khi đọc, ghi lúc đóng overlay; bước kịch bản `wheel`, `wheelpx`.
- Bảng tuỳ chọn: ô màu, các nấc 2 / 3 / 5 / 8, thêm số hiện tại; giá trị giữa các nấc thì không nấc nào sáng. `[` `]` đi theo nấc, đang ở giữa thì về nấc gần theo chiều đó.
- `Visible.style` chỉ có ở màn có thanh công cụ: lăn trên màn 0 không vẽ lại màn 1 (`fake_wheel_on_one_monitor_does_not_repaint_the_other`).
- Bảng màu chỉ dựng lúc mở, đóng là nhả. Nhấn ra ngoài bảng thì đóng bảng và nhấn vẫn có tác dụng. Esc đóng bảng trước.
- Kiểm: unit `model`, `shape`, `options`; `fake_wheel_*`, `fake_color_*`, `fake_ink_style_*`; ảnh màn giả (bảng màu, nét 12 px đổi giữa chừng, nhãn `12 px`).
- **Chưa kiểm**: con lăn + touchpad thật, kéo thật trên bảng màu, RAM khi mở bảng màu.
- Không có cộng dồn nhiều nấc trong một sự kiện dòng: Windows gộp hai nấc lăn cực nhanh thành một sự kiện thì chỉ đổi một bước.

## 10. Đề xuất cải tiến
