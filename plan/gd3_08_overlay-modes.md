# gd3_08 — overlay có chế độ OCR / quay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
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

## 2b–5

Viết lúc bắt đầu task. Toàn `[opus]`: chạm luồng sự kiện + phiên. Chạy thử trên màn giả (`FASTCAST_OVERLAY_FAKE=1`). Không đưa thêm trường vào phiên ngoài phần cần cho panel.

## 6. Nghiệm thu

- `tests/overlay.rs`: `--command ocr_region` / `record_region` trên màn giả mở, kéo chọn gọi `selection_changed`, Esc đóng, lệnh lặp đưa cửa sổ lên, không mở chồng với `capture_region`.
- Test `fake_overlay_drag_on_one_monitor_does_not_repaint_the_other` vẫn xanh.
- Bốn lệnh soát xanh; `capture_region` không đổi hành vi (test GĐ1 + GĐ2 xanh).

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
