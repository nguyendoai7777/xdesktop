# materiant-gd5_04 — VirtualGrid

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (02/11/2026) |
| Repo | materiant |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/virtual_grid.rs`, `examples/gallery/pages/virtual_grid.rs`; MỚI `ui-tests/tests/virtual_grid.rs` |

## 1. Làm gì
- `materiant::virtual_grid::VirtualGrid`: ô cùng cỡ, số cột tự tính theo bề ngang + cỡ ô tối thiểu + `gap`, chỉ dựng hàng trong khung. Dựa trên `uniform_list` như `src/list.rs` (mỗi hàng ảo là một dòng), dùng lại scrollbar `scrollbar_styles`.
- Đổi cỡ cửa sổ thì tính lại số cột, giữ ô đang chọn trong khung.
- Bàn phím: ← → ↑ ↓, PageUp / PageDown, Home / End; Enter / nhấp đúp ⇒ `on_activate`. Handle `scroll_to(index, Align)`.
- Trang gallery `virtual_grid`: 10.000 ô có ảnh giữ chỗ. Đo RAM và khung hình khi cuộn so với 100 ô, ghi ở mục 5: RAM không được tăng theo số ô.
- Ảnh bìa: tìm hiểu cache `img()` của GPUI có nhả ảnh ra khỏi khung không; ghi kết quả + cách app nên dùng ở mục 9 (groove có lưới album lớn).
- Test logic thuần (số cột, ô → hàng, điều hướng ở biên) trong module; test bàn phím trong `ui-tests/`.

## 2. Không làm trong task này
- Ô khác cỡ (masonry), kéo thả. Không sửa `src/list.rs` trừ khi dùng lại được mà không đổi API.

## 2b. Phân vai
Opus làm toàn bộ: phần lớn là hình học + bố cục + phần tử tự viết, không có phần ghép UI đáng giao.

## 5. Đo
Bản release `-p materiant`, cửa sổ 1116×759 ở màn phụ, 5 cột, màn 144 Hz; RAM là cột Memory (private working set); cuộn bằng `GALLERY_GRID_AUTOSCROLL` (`GALLERY_FRAME_STATS=1`, 15–25 s).

| Kịch bản | RAM | Khung TB / tối đa |
|---|---|---|
| 100 ô, nghỉ | 14,7 MB | — |
| 10.000 ô, nghỉ | 14,7 MB | — |
| 100 ô, cuộn 40 px/khung | 15,4 MB | 6,95 / 21,2 ms |
| 10.000 ô, cuộn 40 px/khung | 15,5 MB | 6,94 / 11,5 ms |
| 1.500 ảnh PNG 300×300, `img(path)` trần | 541 MB | 6,94 / 14,7 ms |
| Như trên, bọc `image_cache(retain_all)` | 1.066 MB | 6,93 / 15,3 ms |
| Như trên, `img(path).image_cache(&LruImageCache 128)` | 67 MB | 6,95 / 30,1 ms |

RAM không tăng theo số ô: 100 và 10.000 ô chênh 0,1 MB khi cuộn, đạt yêu cầu. Lúc đo trước bản sửa cao hàng, một lần LRU đạt 245 MB (khung tối đa 218 ms) và một ảnh chụp thiếu hàng dưới cùng; sau đó 30 ảnh chụp + các lần đo khác không lặp lại, chưa rõ nguyên nhân.

## 6. Nghiệm thu — Case test
- C1 `[opus-unit]` số cột, bề ngang ô, ô → hàng, ca biên: xanh.
- C2 `[opus-unit]` `GridNav` ở biên, hàng cuối ngắn, lưới rỗng, chưa chọn, sau khi lọc ngắn lại: xanh.
- C3 `[opus]` số cột có ngay khung đầu, một khung chỉ dựng ≤ 24 / 1.000 ô: xanh (`ui-tests/tests/virtual_grid.rs`).
- C4 ← → ↑ ↓ PageUp PageDown Home End, ô chọn lọt khung, ↓ của view cha không chạy, Enter kích hoạt: xanh.
- C5 `scroll_to` bốn kiểu căn, gọi trước khung đầu vẫn áp, cao hàng lẻ vẫn tới đáy: xanh.
- C6 đổi bề ngang: tính lại số cột, ô chọn vẫn trong khung (đơn vị + UI): xanh.
- C7 nhấp chọn đúng cột, nhấp đúp kích hoạt, bánh xe không đổi ô chọn: xanh.
- C8 `LruImageCache` giữ đúng `capacity`: xanh.
- C9 `[opus-run]` gallery thật: `SELECT 0 → 1 → 6 → 16`, `ACTIVATE 16`, End ⇒ `SELECT 9999` thấy trọn hàng cuối; không giành focus: xanh.
- C10 `[owner-qa]` kéo đổi cỡ cửa sổ thật (không giả lập được), nhiều màn khác DPI, nền sáng: `pwsh start.ps1 docs virtual_grid`, kéo hẹp / rộng cửa sổ, số cột đổi, ô chọn không mất. Chờ kiểm tay.

## 9. Bàn giao thực tế
**API**: `materiant::virtual_grid::{VirtualGrid, VirtualGridHandle, GridNav, GridKey, LruImageCache, Align}`; `VirtualGrid::new(id, count, min_cell_width, cell_height, render_cell)` + `.height_per_width(ratio)` · `.gap` · `.selected` · `.on_select` · `.on_activate` · `.track` · `.track_focus` · `.scrollbar_visibility`; handle: `scroll_to(ix, Align)`, `navigate`, `columns`, `page_rows`, `scroll_top`.

**Cho groove — ảnh bìa, kết luận từ mã `gpui-pre` 0.3.10 + số đo mục 5**:
- `img(path)` trần KHÔNG nhả ảnh ra khỏi khung: ảnh nằm trong cache toàn cục tới hết đời app (`remove_asset` cũng không gỡ khỏi atlas).
- `image_cache(retain_all(id))` / `RetainAllImageCache` cũng giữ hết (comment "LRU" của GPUI sai). Bọc ngoài lưới còn tệ hơn: nạp hai lần, vì `ImageCacheElement` chỉ đặt cache lúc request_layout và paint, còn hàng của `uniform_list` dựng lúc prepaint.
- **Dùng**: một `Entity<LruImageCache>` cho cả màn, gắn thẳng `img(path).image_cache(&covers)`. `capacity` phải lớn hơn số ảnh tối đa trong một khung, nên gấp 2–3 lần: nhỏ hơn thì ảnh đang hiện bị đẩy ra rồi nạp lại không ngừng (test đã treo vì thế). Lưu ý màn lớn + ô nhỏ có thể hơn 500 ảnh một khung.
- Tốn RAM theo cỡ ảnh gốc (300×300 ≈ 360 KB, 1000×1000 ≈ 4 MB), GPUI không tự thu nhỏ ⇒ groove nên tạo thumbnail đúng cỡ ô trước khi nạp.
- `img(String)` KHÔNG phải tệp: chuỗi là URI hoặc asset nhúng. Tệp trên đĩa phải truyền `PathBuf` / `Path`.

**Quyết định (Opus chọn 02/11/2026)**:
- Đo bề ngang trong prepaint bằng phần tử nội bộ `Measured` thay vì đọc bounds khung trước — vì khỏi lệch một khung lúc mở và đổi cỡ.
- ← → đi theo thứ tự ô, hết hàng sang hàng kế — vì giống Explorer; ↑ ↓ PageUp PageDown giữ cột.
- Đổi cỡ: ô chọn đã cuộn đi xa thì không kéo về, chỉ giữ khi đang trong khung — vì không giật khỏi chỗ người dùng đang xem.
- Thêm `.height_per_width` và `LruImageCache` (ngoài chữ của task) — vì album cần bìa vuông khi ô giãn, và số đo cho thấy không có LRU thì lưới album ngốn hết RAM.
- Chừa dải 9 px bên phải cho thanh cuộn ⇒ lưới lệch nhẹ về trái — vì thumb không đè ô cột cuối.

**Lỗi đã sửa lúc làm**: cao hàng lẻ (215,46 px) bị GPUI làm tròn theo pixel thiết bị, sai số cộng dồn làm End thiếu 137 px ở 1.500 ô. Bám lưới pixel, có test. Test không thấy vì dùng số chẵn; lộ ra khi xem ảnh chụp.

**Soát**: `cargo build`, `clippy -D warnings`, `cargo test`, `cargo deny check licenses` xanh; `gpui-component` không có trong cây. Không phụ thuộc mới. `src/list.rs` không đổi.

**Giới hạn**: khe sau hàng cuối vẫn tính vào chiều cao nội dung (dư `gap` ở đáy). Chờ kiểm tay: C10.

## 10. Đề xuất cải tiến
- Bảo mật: không áp (không đọc tệp ngoài đường dẫn app truyền).
- [ux] `LruImageCache` với `capacity` quá nhỏ nạp lại không ngừng — test treo khi 6 ảnh / capacity 4 — bảo vệ ảnh dùng trong khung hiện tại bằng đếm khung (`on_next_frame`) — tránh lỗi khó thấy khi màn rất lớn — S — P2. Chưa làm vì cửa sổ test không chạy callback khung nên không kiểm tự động được; đã ghi `plan/_backlog.md`.
- [pro] không có chỗ phù hợp.