# gd3_10 — bảng thiết lập quay trên overlay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd3_08 |
| Quyết định áp dụng | F-3, F-7, F-8, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/record_panel.rs`; MỚI `crates/ui/tests/record_setup.rs` |

## 0. Bàn giao từ gd3_08 (30/10/2026)

<!-- handoff: gd3_08 -->

- **Đã có sẵn để dùng**: `overlay/record_panel.rs` đã nối, chỉ điền tệp này. `Tool::Record` có tay nắm, không có thanh. Module con đọc được `session.record`, `session.selection`, `session.close(cx)`. `commands::dispatch` vẫn gọi `record::stop_if_recording || dev_hook` trước khi mở overlay.
- **Đổi so với spec**: `render(visible, widgets, host, window, cx)`, không còn `at`: `view` đã đặt chỗ, `occlude`, chặn chuột. `window` để tạo `NumberField`; entity để trong `Widgets`, sống tới khi đóng overlay, cả lúc panel ẩn khi kéo chỉnh. Thêm móc `state`, `size`. Gỡ `#[allow(dead_code)]` trên `OverlaySession::record`, `PanelHost` khi dùng tới.
- **Bẫy**: `PanelState` sao ở `cx.observe` nên đổi `session.record` phải `cx.notify()`. Không có móc "mở": đọc `config.record` lúc `selection_changed` đầu tiên. Vùng chuyển màn thì cửa sổ màn kia có `Widgets` mới, giá trị phải nằm ở `session.record`.
- **Phím**: `on_key` chạy trước mọi phím kể cả Esc. Enter lúc focus ở ô nhập / nút không tới `on_key` ⇒ Enter trong ô FPS phải bắt từ sự kiện của ô. Mũi tên chỉ dời vùng khi focus ở gốc cửa sổ, focus ở widget thì mũi tên là của widget.
- **Soát lại khi làm**: `fake_record_has_no_toolbar_and_no_drawing_keys` (bài này gửi Esc hai lần: Esc của panel không được nuốt). Máy bận thì chạy `--test-threads=1` trước khi kết luận đỏ.

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đổi so với spec**: `target_size` gọi từ `fastcast_core::worker` (UI không phụ thuộc `fastcast-video`). Có sẵn `MIN_RECORD_EDGE`, `RECORD_FPS`, `RECORD_RES` cùng chỗ, `config.record` (`RecordPrefs`, mặc định 720 / 30 / none / true).
- **Đã có sẵn để dùng**: `record::start` stub ghi log `record: start <x>,<y> <w>x<h> res <n> fps <n> audio <None|System|Mic> cursor <bool>`, không ghi đường dẫn: test so dòng này.

## 1. Làm gì

- Panel cạnh vùng: độ nét 480 / 720, FPS (`NumberField` 1–60), âm thanh (`Select`), con trỏ (`Switch`), nút bắt đầu. Hiện cỡ ra thật theo `target_size`.
- Đọc / nhớ `config.record` (ghi lúc bắt đầu quay, không ghi mỗi lần đổi).
- FPS ngoài 1–60 ⇒ báo, không kẹp lặng lẽ. Cạnh < `MIN_RECORD_EDGE` ⇒ khoá nút + `record.too_small`.
- Enter hoặc nút ⇒ tính đích tạm trong `save.videoDir` theo tên giờ, thư mục không ghi được ⇒ báo trên overlay, giữ vùng.
- **Đóng overlay rồi mới `record::start`**, chờ cửa sổ đã gỡ + 2 khung; không thì khung đầu của video dính overlay. Ảnh đóng băng nhả trước khi quay.

## 2. Không làm trong task này

Khung viền, nút dừng (gd3_11). Hộp thoại lưu (gd3_12). Cài đặt độ nét trong Settings (GĐ4).

## 2b. Phân vai

`[opus]` thứ tự đóng overlay → start. `[sonnet]` ghép panel từ `materiant`, test theo case.

## 3–5

Viết lúc bắt đầu task. Dùng `record::start` stub của gd3_01, ghi log `record: start` để test.

## 6. Nghiệm thu

- `tests/record_setup.rs` trên màn giả: đổi tuỳ chọn bằng phím, Enter gọi start đúng tham số, FPS sai không start, vùng nhỏ khoá nút, cấu hình nhớ qua lần mở sau.
- Dùng hết bằng bàn phím (Tab / mũi tên / Enter). Sáng / tối, vi / en.

## 7. Ghi chú UI

```
┌ quay vùng ───────────────────────┐
│ độ nét   [480] [720]   1280 × 720│
│ fps      [ 30 ]  1–60            │
│ âm thanh [không ▾]               │
│ con trỏ  (•)                     │
│                    [bắt đầu  ⏎]  │
└──────────────────────────────────┘
```

Nền `cx.floating_surface()`. Khoá `record.*` có sẵn từ gd3_01.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
