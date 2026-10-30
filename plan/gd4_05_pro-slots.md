# gd4_05 — chỗ cho Pro

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (31/10/2026) |
| Repo | fastcast |
| Cỡ | S — ~120 dòng |
| Phụ thuộc | gd4_01, materiant-gd4_01 |
| Quyết định áp dụng | D-4, F-12 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/{page_pro,row}.rs`; MỚI `crates/ui/tests/settings_pro.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Trang Pro: một câu giới thiệu + `locked_row` cho mọi `ProFeature::ALL`: tên, mô tả, huy hiệu `Badge`, không bấm được.
- `row::locked_row` điền thân thật (gd4_01 để stub): trình đọc màn hình đọc được "pro", Tab bỏ qua.
- `Entitlement::current()` là nguồn duy nhất: `Pro` ⇒ dòng hiện không khoá (chỉ để test hàm thuần, không có đường bật lúc chạy).

## 2. Không làm trong task này

Tính năng Pro nào, nút mua, trang giá, kiểm giấy phép, gọi mạng. Không thêm dòng khoá vào launcher, overlay, thanh công cụ: giữ đường nóng sạch. Làm thật `customIcons` / theme tuỳ biến: để lúc có thanh toán (D-4).

## 2b. Phân vai

Opus làm hết: ~60 dòng, không đáng tách. `[owner-qa]`: nghe bằng trình đọc màn hình thật.

## 6. Nghiệm thu

- C1 `[opus-unit]` Cho bản debug và `--release`, khi gọi `Entitlement::current()` ⇒ `Free`, `ProFeature::ALL` có 10 mục (`tests/settings_pro.rs`).
- C2 `[opus-unit]` Cho mã nguồn, khi quét ⇒ `entitlement.rs` không đọc env / args / config / tệp / `cfg`; ngoài nó không mã chạy thật nào có `Entitlement::Pro`.
- C3 `[opus-unit]` Cho `FASTCAST_PRO=1`, `FASTCAST_ENTITLEMENT=pro`, config có `pro: true`, khi mở trang Pro ⇒ log `10 rows, entitlement Free`; Tab rồi ↓ vẫn đổi trang (dòng khoá không giữ focus).
- C4 `[opus-unit]` Cho `Free` ⇒ có huy hiệu `pro`, tên đọc là `<tên>, pro`; cho `Pro` ⇒ không huy hiệu, cả vi / en (`row::tests`).
- C5 `[opus-run]` `settings-run.ps1 -Page pro` vi / en × sáng / tối: đủ dòng, đúng màn DELL, không giành foreground; cuộn tới dòng cuối; cỡ chữ 20 không vỡ.
- C6 `[owner-qa]` Trình đọc màn hình đọc được "pro" trên từng dòng: `plan/_backlog.md`.
- C7 Bốn lệnh soát xanh.

## 8. Nợ chuyển task khác

Không có. Hai việc ngoài cột sở hữu: `plan/_backlog.md`.

## 9. Bàn giao thực tế

- **Mã**: `row::locked_row` (`ProRowText` là hàm thuần, bọc `div().id().role(Group).aria_label("<tên>, pro")`), `page_pro.rs`, `tests/settings_pro.rs`. Chữ giới thiệu dùng khoá có sẵn `settings.pro_note`. Dòng khoá ở trang Chung, Lưu và quay tự có huy hiệu mới.
- **Case**: C1–C5, C7 xanh. C1 + C2 chạy cả `--release`.
- **Chạy thật**: bốn tổ hợp + cỡ 20 trên màn DELL, 876 × 639, `foreground_unchanged=True`, RAM debug 16,6–17 MB. Khung nhìn thấy 8 dòng, 2 dòng cuối phải cuộn. Soát cuộn bằng bản vá tạm `dev.rs` đưa `ScrollEvent` vào GPUI, đã trả lại, không commit. Ảnh đã xoá.
- **`cargo test` đủ**: lần đầu đỏ `fake_ocr_toolbar_has_copy_and_close_and_no_drawing_keys`, lần chạy riêng `tests/overlay` đỏ `fake_wheel_needs_a_tool_and_adds_up_touchpad_deltas`, mỗi lần một test khác, lúc các làn khác đang chạy. Test đầu chạy riêng xanh 2 / 2; toàn bộ `--no-fail-fast --test-threads=4` xanh. Không test overlay nào đụng tệp của task này, nhưng chưa truy nguyên nhân: test thứ hai không chạy lại riêng.
- **Opus chọn 31/10/2026**: `Role::Group` + nhãn ghép; xem `plan/confirm.md`.
- **Chưa kiểm**: nhãn a11y chỉ đặt trong mã, chưa có trình đọc màn hình nào đọc thử (C6).

## 10. Đề xuất cải tiến

Bảo mật: không áp, trang không đọc ghi gì. RAM: không thêm phụ thuộc. Pro: mười dòng đã đặt.

- [ux] Hai dòng cuối trang Pro không tới được bằng bàn phím — trang không có điểm dừng Tab, ↑ ↓ thuộc sidebar — PageUp / PageDown ở `settings/view.rs` qua `ScrollArea::track_scroll` — dùng hết bằng phím — S — P2. Chưa làm: ngoài tệp sở hữu của làn, vào backlog.
- [ux] Shift+Tab không rời ô cỡ chữ — `tab ×4, shift-tab ×4, ↓` ở trang Chung đổi cỡ chữ thay vì đổi trang; `tab, shift-tab, ↓` từ ô ngôn ngữ thì đúng — soát `NumberField` — đi ngược bằng phím — S — P2. Chưa làm: chưa rõ nguyên nhân, ngoài tệp sở hữu, vào backlog.
