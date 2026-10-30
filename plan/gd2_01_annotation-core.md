# gd2_01 — mô hình chú thích, undo / redo, xuất ảnh + công cụ chữ nhật

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ |
| Repo | fastcast |
| Cỡ | M — ~850 dòng |
| Phụ thuộc | GĐ1 đã gộp `master` (gd1_03, gd1_04, gd1_05, gd1_10) |
| Quyết định áp dụng | D-2, D-9, D-10, F-3, F-11 |
| Phụ thuộc mới | `tiny-skia` 0.11 (BSD-3, đã có trong cây qua resvg của GPUI) |
| File đụng tới | MỚI `crates/ui/src/overlay/annotate/{mod,model,shape,export,paint}.rs`; SỬA `overlay/{mod,view,toolbar,dev}.rs`, `clipboard.rs`, `save.rs`, `i18n/{vi,en}.toml`, `tests/overlay.rs` |

## 1. Làm gì

- Lát dọc đầu tiên, chạy được từ nút tới pixel: chọn công cụ chữ nhật (nút + phím `r`), kéo trong vùng chọn ra hình, Ctrl+Z / Ctrl+Y, ảnh lưu + ảnh chép có hình.
- Chú thích là **vector, toạ độ toàn cục, pixel vật lý**; không chép ảnh mỗi nét. Dời / đổi cỡ vùng chọn không dời chú thích (chú thích gắn với ảnh đóng băng), vùng chọn chỉ cắt.
- Chỉ bắt đầu vẽ được trong vùng chọn, điểm kéo kẹp trong vùng, lúc vẽ + lúc xuất đều cắt theo vùng.
- Có công cụ đang bật: không còn tay nắm, nhấn ngoài vùng không chọn lại, Esc / chuột phải tắt công cụ trước rồi mới bỏ vùng.
- Hai cửa sổ vẽ cùng một mô hình; kéo trên màn A không vẽ lại màn B khi hình không chạm B.
- Chép chuyển phần cắt + ghép chú thích sang luồng nền (như lưu).

## 2. Không làm trong task này

Đường thẳng, mũi tên, elip, bảng độ dày (gd2_02); vẽ tự do (gd2_03); chữ (gd2_04); bảng màu (gd2_05). Sửa lại chú thích đã đặt, tẩy, làm mờ (`blur`).

## 3. Kiểu dữ liệu

`annotate::model`: `InkTool`, `Stroke { color: [u8; 4], width: f32 }`, `Shape`, `Annotation { id, shape }`, `Ink { items, undone, draft, revs per monitor, tool, style }`. Mọi cửa sổ giữ `Rc<RefCell<Ink>>` (không phải entity: `render` đọc thoải mái mà không bị GPUI ghi nhận), `Visible` chỉ giữ `ink_rev` của màn đó.

## 4. Code

`shape.rs`: hình → danh sách nét / đa giác thuần (dùng chung cho lớp vẽ + lớp xuất). `paint.rs`: `canvas` + `PathBuilder`, có cache tessellation theo màn. `export.rs`: `burn(&mut RgbaImage, region, &items, &layout)` bằng tiny-skia; khe giữa các màn vẫn trong suốt.

## 5. Đo

RAM overlay 2 màn 1080p + CPU kéo (GPU, WARP) so với `docs/gd1-report.md` mục 2. Mốc: 49,6–52,1 MB; 0,03–0,07 nhân; WARP 0,90–1,08 nhân.

## 6. Nghiệm thu

Viết case ở lúc bắt đầu task (run-task mục 3).

## 7. Ghi chú UI

Thanh: `[nút công cụ] | [undo redo] | [lưu, lưu thành, chép, đóng]`. Khoá i18n `toolbar.*`. Nền `cx.floating_surface()`, nhãn viết thường.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

Gộp `master` ở `f5771e9`.

- Có: `overlay/annotate/{model,shape,export,paint,options}.rs`, công cụ chữ nhật, undo / redo, `CropJob` ghép chú thích ở luồng nền (lưu + chép).
- Lệch spec: `Ink` giữ `Rc<RefCell<…>>` đúng spec; màu kiểu `[u8; 3]`, độ dày nằm trong `Pen`, không có `Stroke`.
- Kiểm: `fake_ink_*`, ảnh PrintWindow màn giả (`foreground_unchanged=True`).

## 10. Đề xuất cải tiến
