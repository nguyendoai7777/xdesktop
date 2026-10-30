# gd3_08 — overlay có chế độ OCR / quay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd3_01, gd2_05 (đã gộp `master`: gd2_04 / gd2_05 cùng sửa `overlay/{mod,view,toolbar}.rs`) |
| Quyết định áp dụng | F-3, D-9, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/{mod,view,toolbar}.rs`, `commands.rs`, `crates/ui/tests/overlay.rs`; MỚI (stub) `overlay/{ocr_panel,record_panel}.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `commands::dispatch` đầu hàm gọi `record::stop_if_recording(cx) || record::dev_hook(cx)` với `RecordRegion`: **giữ nguyên** khi nối overlay, gd3_11 và gd3_12 dựa vào. Tệp `overlay/` không bị gd3_01 đụng.
- **Đổi so với spec**: `crates/ui/tests/ipc.rs` đã dùng `open_settings`, hai lệnh OCR / quay không còn trong `tests/`. Test trong `commands.rs` vẫn dùng `Command::OcrRegion` ở ca "other features are independent": task này sửa.
- **Bẫy**: mở overlay cho hai lệnh đó ⇒ từ đây chúng chụp màn thật nếu thiếu `FASTCAST_OVERLAY_FAKE`, test của task phải luôn đặt biến.

## 1. Làm gì

Điểm nối duy nhất trong overlay. Xong task, gd3_09 và gd3_10 chỉ sửa một tệp panel của mình.

- `Tool::Ocr`, `Tool::Record`, cùng `OverlayView` + tay nắm + chỉnh vùng của `Tool::Region`.
- `commands.rs`: `ocr_region`, `record_region` mở overlay; `same_feature` tính cả hai là lệnh overlay; `freeze` chạy cho cả hai; sửa test "other features are independent".
- Thanh công cụ theo tool: `Region` như cũ; `Ocr` chỉ Chép + Đóng; `Record` không có thanh (panel thay thế). Công cụ vẽ + phím `InkTool` chỉ bật ở `Region`.
- Ba móc gọi sang panel theo tool, thân rỗng ở task này:

```rust
// overlay/ocr_panel.rs, overlay/record_panel.rs — cùng khuôn.
pub fn selection_changed(session: &mut OverlaySession, region: Rect, cx: &mut Context<OverlaySession>);
pub fn on_key(session: &mut OverlaySession, key: &Keystroke, cx: &mut Context<OverlaySession>) -> bool;   // true ⇒ đã xử lý
pub fn render(visible: &PanelState, at: (f32, f32), cx: &mut Context<OverlayView>) -> AnyElement;
```

- `PanelState`: bản sao trong `view`, cập nhật ở `cx.observe` (luật `render` không đọc phiên, `fastcast/CLAUDE.md`).
- Vị trí panel: dùng lại `toolbar::place`.

## 2. Không làm trong task này

Nội dung panel. Nút OCR trên thanh của `Tool::Region`.

## 2b. Phân vai

Toàn `[opus]`: chạm luồng sự kiện + phiên. Chạy thử trên màn giả (`FASTCAST_OVERLAY_FAKE=1`). Không đưa thêm trường vào phiên ngoài phần cần cho panel.

## 3. Kiểu dữ liệu

- `overlay::Tool` thêm `Ocr`, `Record`; `OverlaySession` thêm `tool`, `ocr: ocr_panel::OcrState`, `record: record_panel::RecordState`, `rem`.
- `overlay::PanelHost { session, root }`: thứ panel cần từ cửa sổ.
- `view::Floating { monitor, toolbar, panel }` + `view::floating_at`, thay `toolbar_at`.
- Mỗi tệp panel: `OcrState` / `RecordState`, `PanelState`, `Widgets`, `state`, `size`, `selection_changed`, `on_key`, `render`; riêng OCR có `copy`.

## 4. Code

- `commands.rs`: `is_overlay` dùng chung cho `same_feature` và `freeze`. Màn giả không kích hoạt cửa sổ khi lệnh lặp.
- `toolbar.rs`: `State.mode`, `size_for`, `stack_size`, `stack`. OCR xếp thanh trên, panel dưới, cùng mép phải, cả khối đi qua `place`.
- `view.rs`: enum `Panel` giữ bản sao + widget, chỉ sao ở cửa sổ có panel; bọc panel bằng `occlude` + chặn chuột.

## 5. Đo

— (không thêm tiến trình, không thêm ảnh; số đo chính thức ở gd3_13).

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ |
| --- | --- | --- |
| C1 | `ocr_region` / `record_region` trên màn giả / kéo chọn, mũi tên / móc `selection_changed` được gọi với vùng đúng | `[opus-unit]` `fake_{ocr,record}_region_opens_selects_and_escapes` |
| C2 | Có vùng / Esc hai lần / bỏ vùng rồi đóng | như C1 |
| C3 | Đang mở / lệnh lặp / đưa lên, không đóng băng lần hai | `fake_{ocr,record}_region_repeat_focuses_and_never_stacks_with_capture` |
| C4 | Một lệnh overlay đang mở / lệnh overlay khác / không mở chồng | như C3 + `fake_capture_open_blocks_ocr_and_record` |
| C5 | `Tool::Ocr` / phím vẽ, Ctrl+S, Ctrl+C, nút thanh / chỉ Chép + Đóng, phím của `Region` không chạy | `fake_ocr_toolbar_has_copy_and_close_and_no_drawing_keys` |
| C6 | `Tool::Record` / chọn vùng / không có thanh, có panel | `fake_record_has_no_toolbar_and_no_drawing_keys` |
| C7 | Kéo trên màn 0 / đếm lần vẽ màn 1 / dưới 10, cả ba công cụ | `fake_panel_tools_drag_does_not_repaint_the_other_monitor`, `fake_overlay_drag_on_one_monitor_does_not_repaint_the_other` |
| C8 | Vùng bất kỳ, kể cả kín màn / tính vị trí / thanh + panel trọn trong màn, không đè nhau | `each_tool_floats_its_own_blocks_beside_the_selection`, `stack_stays_on_screen_when_there_is_no_room_below`, `stack_shares_the_right_edge_with_the_toolbar_on_top` |
| C9 | `capture_region` / test GĐ1 + GĐ2 / không đổi hành vi; bốn lệnh soát xanh | `cargo test --workspace` |

## 7. Ghi chú UI

Panel chưa có nội dung nên chưa có gì để kiểm bằng mắt; `[owner-qa]` nằm ở gd3_09, gd3_10, gd3_13.

## 8. Nợ chuyển task khác

- gd3_09, gd3_10: mục 0 của hai task.

## 9. Bàn giao thực tế

- **Lệch spec, Opus chọn 30/10/2026** (đều trong `plan/confirm.md`):
  - `render` đổi thành `render(visible, widgets, host, window, cx)`: `NumberField`, `ColorPicker` cần `Window` lúc tạo và cần chỗ giữ entity theo cửa sổ. `at` bỏ, `view` tự đặt chỗ + chặn chuột.
  - Thêm móc `state`, `size`; OCR thêm `copy` cho nút Chép, vì gd3_09 không được sửa `mod.rs`.
  - `Enter` khi focus ở nút / ô nhập không tới `on_key`; mũi tên chỉ dời vùng khi focus ở gốc cửa sổ.
  - Lệnh lặp trên màn giả không gọi `activate_window`, để test không giành focus máy đang dùng.
- **Soát sau khi gộp `master` vào nhánh**: `cargo build`, `clippy -D warnings`, `deny licenses` xanh. `cargo test --workspace --test-threads=2` xanh (overlay 40 passed, picker 6, ipc 5, unit UI 207).
- **Chạy song song lúc máy 100% CPU** đỏ từng đợt 2–11 test, đều "fastcast-ui still running after 5s" ở bước thoát, cả test `picker` không đụng tới; chạy riêng thì lúc xanh lúc đỏ, chạy đơn luồng xanh hết. Nguyên nhân do tải, chưa chứng minh riêng: chưa đo lại trên `master` lúc máy rảnh. `master` đã nới `wait_exit` lên tối thiểu 30 s (commit `2908670`).
- **Chưa kiểm**: overlay thật (theo luật làn chỉ chạy màn giả); hình panel, vì stub vẽ rỗng.

## 10. Đề xuất cải tiến

- Bảo mật / riêng tư: không có phát hiện. Log thêm chỉ có toạ độ vùng, như dòng `overlay: selected`.
- UI/UX: không có phát hiện trong phạm vi stub. Panel ẩn lúc kéo chỉnh, giống thanh công cụ.
- RAM: không có phát hiện. Không thêm ảnh; widget panel chỉ tạo ở cửa sổ có panel.
- Pro: không áp.
