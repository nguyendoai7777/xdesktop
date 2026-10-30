# gd4_18 — nghiệm thu GĐ4

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (31/10/2026) — chờ kiểm tay, Mac, Ubuntu; GĐ4 chưa đóng |
| Repo | fastcast |
| Cỡ | S — ~100 dòng test + báo cáo |
| Phụ thuộc | gd4_02 → gd4_09 (phần Windows); gd4_10 → gd4_17 (phần macOS, Ubuntu, báo cáo ghi rõ phần chưa chạy) |
| Quyết định áp dụng | D-2, D-9, F-4 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `docs/gd4-report.md`; SỬA `crates/ui/tests/measure.rs`, `CLAUDE.md`, `ROADMAP.md` |

## 0. Bàn giao từ gd4_05 (31/10/2026)

<!-- handoff: gd4_05 -->

- **Đã có sẵn để dùng**: trang Pro + `row::locked_row` có `Badge`; `tests/settings_pro.rs` soát không có đường bật Pro (cả `--release`).
- **Soát lại khi làm**: `pwsh tools/settings-run.ps1 -Page pro`; `cargo test --release -p fastcast-ui --test settings_pro`. Danh sách kiểm tay thêm: Narrator trên dòng Pro (`plan/_backlog.md`).
- **Bẫy đã gặp**: `tests/overlay` đỏ ngẫu nhiên một test khác nhau lúc nhiều làn chạy, `plan/gd4_05_pro-slots.md` mục 9: chạy lúc máy rảnh rồi mới kết luận.
- **Nhìn lại ở báo cáo**: hai việc ux chưa làm (PageUp / PageDown, Shift+Tab ở ô số), `plan/gd4_05_pro-slots.md` mục 10.

## 0. Bàn giao từ gd4_03 (30/10/2026)

<!-- handoff: gd4_03 -->

- **Đã có sẵn**: trang Phím tắt, `hotkey_dialog.rs` dùng chung launcher; log `settings: hotkeys page in <ms>` để đo.
- **Soát lại**: đổi trang sang Phím tắt ở bản release, chuẩn dưới 30 ms (`FASTCAST_SETTINGS_PAGE=general`, `-Keys "wait@500 down"`); bản debug đo được 35,3 ms, chưa có số release.
- **Kiểm tay**: C9 của `gd4_03`, gán thật với `fst` thật, gạch ở `_backlog.md`.

## 0. Bàn giao từ gd4_04 (30/10/2026)

<!-- handoff: gd4_04 -->

- **Đã có sẵn**: trang Lưu và quay; `clipboard.excludeFromHistory` chặn cả Win+V lẫn clipboard đám mây trên Windows.
- **Nợ**: chưa có tiêu đề nhóm trên trang (thiếu khoá i18n, `gd4_04` mục 8).
- **Soát lại**: daemon đổi `clipboard.rs` không thêm phụ thuộc, tính vào lần đo RAM daemon cuối; kiểm tay Win+V ở `_backlog.md`.

## 0. Bàn giao từ gd4_02 (30/10/2026)

<!-- handoff: gd4_02 -->

- **Đã có sẵn để dùng**: log `settings: general applied in <ms>` để đo độ trễ đổi cài đặt, chạy `pwsh tools/settings-run.ps1 -Page general -Keys "wait@300 tab tab tab tab up up up up up up"`.
- **Số đo chính thức cần lấy**: trần 50 ms khi đổi cỡ chữ. Số ở `plan/gd4_02_settings-general.md` mục 9 đo trên bản debug lúc máy bận.
- **Kiểm tay thêm vào danh sách**: tắt / bật tự khởi động, khởi động lại máy, daemon lên sau đúng độ trễ; tệp cấu hình chỉ đọc ⇒ thấy toast `settings.save_failed`.
- **Soát**: sidebar Settings không theo cỡ chữ (mục 10 của gd4_02).
- **Nợ**: lỗi `autostart::apply` không tới UI, khoá `settings.autostart_failed` chưa dùng.

## 0. Bàn giao từ gd4_09 (31/10/2026)

<!-- handoff: gd4_09 -->

- **Đã có sẵn để dùng**: `pwsh tools/build-installer.ps1 -ModelsSource <model> [-Makensis <exe>]` ra `dist/fastcast-<version>-setup.exe`; `pwsh tools/installer-e2e.ps1 -Setup <setup> -Release <target>/release` cài + gỡ im lặng, `fst` là exe giả. Bản có sẵn cho kiểm tay: `fastcast/dist/` (gitignore).
- **Số đo lấy lại lúc máy rảnh**: cỡ `setup.exe` (lần gd4_09: 65,1 MB), thời gian cài (6,2 s), `Ready` + RAM đỉnh OCR từ bản cài.
- **Đưa vào danh sách kiểm tay**: C12 của `plan/gd4_09_windows-installer.md`, gồm `fst --version | Out-Host` và đường `fst quit` / `autostart off` thật (chưa từng chạy).
- **Bẫy**: bộ gỡ thật xoá tác vụ tự khởi động chung của máy; đừng chạy trên máy đang dùng bản khác.

## 1. Làm gì

- Số đo lúc không làn nào chạy: RAM cửa sổ Settings, UI giữ ấm sau khi đóng Settings ≥ 10 s, khung đầu, cỡ exe, cỡ `setup.exe`.
- RAM daemon thật: danh sách kiểm tay, vì máy nhà không tự bật `fst` thật khi chạy thử.
- `docs/gd4-report.md`: bảng theo từng OS: đạt / chưa chạy; **một** danh sách kiểm tay theo thứ tự chạy, gom `[owner-qa]` của gd4_02 → gd4_17, kèm mục tay còn treo của GĐ1, GĐ2, GĐ3.
- Soát nợ: nhãn thước với cỡ chữ lớn (`gd1_08` mục 10), các gạch backlog đã làm xong thì xoá.
- `ROADMAP.md`: mục "Bàn giao GĐ4", đóng câu hỏi mở về công cụ bản cài. `docs/decisions.md` chỉ ghi điều chủ dự án đã chốt.

## 2. Không làm trong task này

Tự ghi đạt cho phần macOS, Ubuntu chưa chạy. `close-phase`: chờ chủ dự án kiểm tay.

## 2b. Phân vai

Opus làm hết: số đo + báo cáo phải do người chạy viết, mã sửa ~60 dòng, không đáng giao. `[owner-qa]`: `docs/gd4-report.md` mục 4.

## 6. Nghiệm thu

- [x] Bốn lệnh soát xanh trên bản đã gộp (nhánh không có commit nào khác `master`); `cargo check --locked --target aarch64-apple-darwin -p fastcast-daemon -p fastcast-video -p fastcast-capture -p fastcast-ocr` xanh.
- [x] Bảng số có cách đo; thử Settings chỉ ở màn DELL (lúc đó là màn duy nhất).

## 9. Bàn giao thực tế

Commit fastcast: `808216a`, `3d60e3d`, `9d6bc81`, gộp `39baa90`; báo cáo `fastcast/docs/gd4-report.md`, bàn giao `fastcast/ROADMAP.md`.

**Soát trên `9d6bc81`, thấy xanh**: `cargo build`; clippy `-D warnings`; `cargo test --no-fail-fast -- --test-threads=4` 34 bộ, 644 passed, 0 failed; `cargo deny check licenses`; `cargo check --locked --target aarch64-apple-darwin` bốn crate.

**Test overlay `fake_wheel_needs_a_tool_and_adds_up_touchpad_deltas`**: đua trong test, không phải máy bận, không phải sản phẩm. Trước khi sửa, lúc rảnh: 6 / 10 đỏ chạy riêng, 2 / 4 đỏ cả bộ. Sau: 30 / 30, 5 / 5, cộng hai lượt cả workspace. Chi tiết: báo cáo mục 3.

**Chưa rõ gốc**: `real_ocr` đỏ 1 / 4 lần lúc rảnh, panic `common/mod.rs:103` (hết 20 s chờ log); bộ lọc của lượt đó làm mất tên dòng log. `_backlog.md`.

**Màn hình**: lúc chạy Windows chỉ báo một màn, DELL S2319H, thành màn chính, LG không có. Không rõ từ lúc nào, nên có thể từ đầu lượt. Lần `settings-run` đầu tiên bị script từ chối 15 lần vì "nằm trên màn chính": cửa sổ đã mở trên DELL rồi đóng ngay, đây là màn duy nhất. Sau đó thêm `-AllowOnlyScreen` và soát "đúng một màn, tên DELL" trước mỗi bài. Không chạy `fst` thật, `isolated`, bộ cài có giao diện.

**Sửa ngoài danh sách tệp**: `overlay/ruler.rs` (nợ nhãn thước), `settings/view.rs` (PageUp / PageDown), `tests/common`, `tests/overlay.rs`, `tests/settings_pro.rs`, `tools/settings-run.ps1`.

**Đề xuất đã làm**: `[gd4_05 · ux P2]` PageUp / PageDown; nhãn thước theo cỡ chữ. Bản cài mới nhất ở `fastcast/dist/` (gitignore), sha256 `5ea6f34c…`, e2e im lặng xanh.

**Chưa đo**: RAM daemon thật (W2); thời gian cài; `ocr_bench`.

**Soi cải tiến**: bảo mật không áp, chỉ thêm phím cuộn và test. UI/UX: mục 10. RAM: không thêm phụ thuộc; giữ ấm sau Settings 6,9–7,5 MB. Pro: không áp.

## 10. Đề xuất cải tiến

- [ux] Shift+Tab kẹt trong ô số — khả nghi `gpui-base` `input/base/state.rs:197` — chặn ở `materiant` `NumberField` — S — P2. Chưa làm: `materiant` đang có thay đổi chưa commit ở `src/overlay/popover.rs` (không phải của lượt này), và chặn ở Settings dễ đụng hộp thoại gán phím. Ở `_backlog.md`.
- [ram] Lấy màu mở lần hai 59 MB, lần đầu 50 MB — báo cáo mục 2.4 — soi phần giữ lại giữa hai lần — S — P3. Ở `_backlog.md`.
