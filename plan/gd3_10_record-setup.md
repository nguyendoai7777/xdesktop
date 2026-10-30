# gd3_10 — bảng thiết lập quay trên overlay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay ở gd3_13 |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd3_08 |
| Quyết định áp dụng | F-3, F-7, F-8, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/record_panel.rs`, `overlay/mod.rs` (gỡ `allow(dead_code)` của `record`, bàn giao gd3_08 cho phép); MỚI `crates/ui/tests/record_setup.rs` |

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

`[opus]` thứ tự đóng overlay → start, ghép panel từ `materiant`, test theo case (không giao Sonnet: cùng một tệp, mục 9). `[owner-qa]` nhìn khung đầu video trên màn thật.

## 3. Kiểu dữ liệu · IPC · cấu hình

Không thêm khoá, không thêm thông điệp. `RecordState { loaded, prefs, fps: Option<f64> }` ở phiên; `prefs.fps` chốt lúc bắt đầu. Đọc `config.record`, ghi lúc bắt đầu quay (đọc lại tệp, chỉ đổi khoá này).

## 4. Code

`overlay/record_panel.rs`: `submit` → thử ghi thư mục ở luồng nền (`exporting` chặn phím, chuột) → `launch` → `session.close` → chờ cửa sổ + phiên nhả (trần 1 s) → 2 khung màn chậm nhất → `record::start`.

## 5. Đo

Không đo số (số chính thức ở gd3_13). Log `record setup: overlay released true after <n> ms` cho thời gian chờ.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ |
|---|---|---|
| C1 | Có vùng, Enter ở gốc ⇒ `record::start` đúng vùng + `config.record` | `enter_starts_with_config_after_the_overlay_is_gone` |
| C2 | Bắt đầu ⇒ thứ tự: `overlay: closed` → cả hai view nhả → `released true` → `record: start` | cùng bài |
| C3 | Chỉ phím: Tab / mũi tên / gõ / Enter / Space đổi đủ 4 tuỳ chọn, Enter trên nút ⇒ đúng tham số; lần mở sau nhớ, không ghi lại | `keyboard_only_changes_every_option_and_is_remembered` |
| C4 | Enter trong ô FPS, Enter ở nhóm radio ⇒ bắt đầu | `enter_inside_fps_field_and_radio_group_starts` |
| C5 | FPS 61, 0, rời ô rồi quay lại ⇒ không start, không kẹp; sửa 60 ⇒ start | `bad_fps_blocks_without_clamping_then_a_fix_starts` |
| C6 | Cạnh < 34 ⇒ không start; nới bằng phím ⇒ start. Nút khoá: xem ảnh | `small_region_blocks_until_grown`, `[opus-run]` |
| C7 | Thư mục không ghi được ⇒ báo, vùng + phím còn, Esc chạy; log không lộ đường dẫn | `unwritable_video_dir_keeps_the_overlay_and_the_region` |
| C8 | Esc từ ô FPS, từ danh sách âm thanh ⇒ đúng thứ tự, không nuốt | `escape_from_widgets_cancels_in_order` |
| C9 | Chọn lại vùng trên màn kia ⇒ giữ số vừa gõ | `options_survive_moving_the_panel_to_the_other_monitor` |
| C10 | Sáng / tối, vi / en: đọc được, vừa panel | `[opus-run]` ảnh `PrintWindow` màn giả |
| C11 | Khung đầu video không dính overlay trên màn thật | `[owner-qa]` gd3_13 |

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

- gd3_13: C11 vào danh sách kiểm tay.
- `tests/picker.rs` phụ thuộc con trỏ thật: `plan/_backlog.md`.

## 9. Bàn giao thực tế

- **Kết quả**: `overlay/record_panel.rs` đủ mục 1; `tests/record_setup.rs` 8 bài + 6 unit xanh. `cargo build`, `clippy -D warnings`, `cargo deny check licenses` xanh.
- **Đỏ không thuộc làn**: `fake_picker_copies_the_pixel_retries_and_remembers_the_format` đỏ 4/4 lần trên nhánh. `picker.rs` không đổi so với `master`; chuột thật của máy đứng ở 1119,626, nếu màn chính 1920×1080 thì đó là chỗ cửa sổ giả (test đọc `rgb(136 24 160)` thay vì giữa màn). Suy từ toạ độ, chưa chạy lại với chuột ở chỗ khác vì không đụng chuột thật. Mọi bài khác của repo xanh.
- **Opus chọn 30/10/2026**: tự làm cả phần `[sonnet]`, vì panel và thứ tự đóng cùng một tệp, lời giao dài bằng code.
- **Opus chọn**: không đặt `range` cho `NumberField`: bản kẹp của nó chạy khi rời ô, trái "không kẹp lặng lẽ". Hệ quả: ↑ ↓ vượt 60 hiện lỗi thay vì dừng, ô cho gõ dấu âm rồi báo lỗi. Số sai cũng khoá nút.
- **Opus chọn**: độ nét dùng `RadioGroup` thay hai nút ở bản vẽ mục 7: mũi tên chọn sẵn, một điểm dừng Tab. Enter ở nhóm là bắt đầu; Enter ở `Select` / `Switch` vẫn là của widget, Tab tới nút rồi Enter.
- **Opus chọn**: lỗi thư mục dùng `record.error_output`, không dùng `save::report_failure` (chữ của nó gợi "Lưu thành…"). Thử ghi bằng tệp `.fastcast-probe-<pid>.tmp` rồi xoá, không giữ chỗ `.part` cho worker.
- **Kiểm chạy**: chỉ màn giả, foreground không đổi. Ảnh `PrintWindow` sáng / tối, vi / en, lỗi FPS, vùng nhỏ, danh sách mở: vừa panel, đã xoá. Chưa kiểm: mắt thường trên màn thật, chờ gd3_13.
- **Soi cải tiến**: bảo mật: log không có đường dẫn (C7), tệp thử được xoá (unit). RAM: phiên nhả trước khi quay (C2), không phụ thuộc mới. UI/UX: mục 10. Pro: "độ nét trên 720p" đã có ở lộ trình GĐ4, không thêm.

## 10. Đề xuất cải tiến

- [ux] Bấm lại phím quay trong ~100 ms giữa lúc đóng overlay và `record::start` mở overlay mới, video dính overlay đó — đọc `launch` + `commands::dispatch`, chưa tái hiện — cờ "đang chuyển sang quay" để `stop_if_recording` nuốt lệnh — giá trị thấp, cửa sổ rất hẹp — S — P3. Không làm: chạm `commands.rs`, `record/mod.rs` của làn khác.
