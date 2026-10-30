# gd1_04 — Lưu ảnh: Ctrl/Cmd+S và Ctrl/Cmd+Shift+S

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd1_03 · materiant-gd1_09 (`Toast` — chưa có thì log + bỏ toast, ghi nợ) |
| Quyết định áp dụng | F-8 |
| Phụ thuộc mới | `image` (MIT / Apache-2.0, chỉ PNG) — đã có trong cây qua xcap |
| File đụng tới | `crates/ui/src/save.rs` MỚI · `crates/core/src/naming.rs` MỚI · `crates/core/src/lib.rs` SỬA · `crates/core/src/paths.rs` SỬA (`FASTCAST_CONFIG_FILE`) · `crates/ui/src/notice.rs` SỬA (`show_saved`, `dismiss`) · `crates/ui/src/overlay/{mod,view,dev}.rs` SỬA · `crates/ui/src/{platform,app,main}.rs` SỬA · `crates/ui/tests/{overlay,common/mod}.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 0. Bàn giao từ gd1_03 (30/10/2026)

<!-- handoff: gd1_03 -->

- **Đã có sẵn để dùng**: phím + nút đã nối — `OverlaySession` là `EventEmitter<ToolbarAction>` (`overlay/toolbar.rs`:
  `Save | SaveAs | Copy | Close`); Ctrl/⌘+S ⇒ `Save`, Ctrl/⌘+Shift+S ⇒ `SaveAs`, nút trên thanh cũng vậy (log
  `overlay: action save`). Chỉ cần `cx.subscribe(&session, …)` trong `overlay::open` (cạnh `dev::run_script`) rồi gọi
  `save.rs` — **không** cần sửa `view.rs` cho phím nữa.
- Vùng: `session.selection.selected()` (đã chọn xong, kể cả lúc đang kéo chỉnh — `action` đã chặn khi `grabbing()`), cắt
  bằng `session.crop(rect)` (RGBA, ghép nhiều màn, khe trong suốt) — gỡ `#[cfg_attr(not(test), expect(dead_code))]` của
  `crop`. Đóng overlay: `session.close(cx)` (đã hoãn `defer`).
- **Đổi so với spec này**: phím đã ở `view.rs::on_key` qua `ToolbarAction::for_key`; dòng "File đụng tới" sửa
  `view.rs` có lẽ không cần — thêm `overlay/mod.rs` (subscribe) thay vào. Vùng chỉnh có thể nằm một phần trong khe giữa
  các màn (kẹp theo hình bao desktop) — PNG giữ phần đó trong suốt.
- **Huỷ hộp thoại ⇒ quay lại overlay**: overlay thật luôn-trên-cùng có thể đè hộp thoại hệ thống — soát `prompt_for_new_path`
  khi cửa sổ PopUp topmost đang mở (màn giả không lộ được lỗi này ⇒ [owner-qa]).
- **Bẫy đã gặp**: kịch bản dev `key` giờ phát cả key-up (nút GPUI chỉ bấm bằng Enter / Space lúc nhả phím) — test bấm nút
  bằng bàn phím: `key 0 tab` ×n rồi `key 0 enter`; Esc khi focus ở nút phải trả focus về gốc (đã sửa). Thanh công cụ
  chỉ dựng ở cửa sổ của màn chứa góc dưới phải vùng, log `overlay: toolbar on <màn> at x,y size WxH`.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test overlay` (5 test màn giả, mẫu `fake_overlay_edit_selection_and_toolbar`
  dùng `key 0 ctrl-s`); chi tiết `plan/gd1_03_selection-edit.md` mục 9.

## 1. Làm gì

- **Ctrl/Cmd+S** (và nút Lưu): cắt `Frozen::crop(vùng)` → PNG vào `save.imageDir` (mặc định Pictures của OS) tên
  `fastcast_YYYY-MM-DD_HH-mm-ss.png` giờ địa phương; trùng tên ⇒ `_2`, `_3`… (không bao giờ ghi đè). Đóng overlay.
- **Ctrl/Cmd+Shift+S** (và nút Lưu thành…): hộp thoại lưu của hệ thống (`cx.prompt_for_new_path`) mở ở
  `save.lastImageDialogDir` (chưa có ⇒ `imageDir`), nhớ thư mục vừa chọn. Huỷ hộp thoại ⇒ quay lại overlay.
- Mã hoá PNG + ghi file ngoài luồng UI; ghi qua file tạm cùng thư mục rồi đổi tên.
- Thư mục không còn / không ghi được ⇒ thông báo lỗi có đường dẫn, gợi ý Lưu thành…; không mất vùng chọn.
- Toast "Đã lưu <tên tệp>" (bấm ⇒ mở thư mục chứa).
- `naming.rs` (core): tên tệp theo giờ + tìm hậu tố không trùng — hàm thuần, video ở GĐ3 dùng lại.

## 2. Không làm trong task này

- Lưu video (GĐ3). Chọn định dạng khác PNG.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `naming.rs`, `save.rs` (ghi nguyên tử, không ghi đè), khoá phiên overlay, `notice.rs`, `exit_now` | `[opus]` |
| i18n, test theo case | `[opus]` — task nhỏ, cùng tệp với phần trên, không giao Sonnet |
| Hộp thoại thật trên overlay thật, bấm thông báo, DPI khác nhau | `[owner-qa]` |

## 3. Kiểu dữ liệu · IPC · cấu hình

Đọc `save.imageDir`, ghi `save.lastImageDialogDir`. **Ghi cấu hình**: đọc lại `config.json` ngay trước khi ghi rồi
chỉ đổi trường của mình (tránh đè thay đổi của `fst autostart` / Settings), ghi qua `config::save`.

## 4. Code

Phím Ctrl/Cmd: dùng `secondary` của GPUI (Cmd trên macOS, Ctrl nơi khác).

## 5. Đo

Thời gian từ Ctrl+S tới file nằm trên đĩa với vùng 3840 × 1080.

## 6. Nghiệm thu

- **C1** Cho vùng vắt hai màn giả có khe. Khi Ctrl+S. Thì PNG đúng từng pixel so với hoạ tiết tính độc lập, khe trong
  suốt, overlay đóng, thông báo hiện rồi tự đóng. `[opus-run]` `fake_save_writes_exact_pixels_across_monitors` ✅
- **C2** Log của C1 không chứa tên tệp / thư mục; thư mục lưu không còn tệp tạm. `[opus-run]` cùng test ✅
- **C3** Cho `imageDir` đã mất. Khi Ctrl+S. Thì báo lỗi có đường dẫn + gợi ý Lưu thành…, không tạo lại thư mục, vùng chọn
  còn (Esc còn "bỏ vùng"). `[opus-run]` `fake_save_to_missing_dir_keeps_the_selection` ✅; nhìn toast bằng `PrintWindow` ✅
- **C4** Khi huỷ hộp thoại. Thì về overlay, không ghi gì, Lưu thành… lại được. `[opus-run]` `fake_save_as_cancel_returns_to_the_overlay` ✅
- **C5** Khi Lưu thành… đường dẫn tiếng Việt thiếu đuôi. Thì tệp có `.png`, `lastImageDialogDir` nhớ qua lần khởi động sau,
  khoá khác của `config.json` còn nguyên. `[opus-run]` `fake_save_as_remembers_the_dir_across_restarts` ✅
- **C6** Lưu hai lần cùng tên ⇒ hai tệp, tệp đầu không đổi; 8 luồng cùng lúc ⇒ 8 tệp. `[opus-unit]` `saving_twice_never_overwrites`, `concurrent_saves_get_distinct_files` ✅
- **C7** `naming`: đổi ngày, hậu tố, tiếng Việt, đuôi. `[opus-unit]` ✅
- **C8** Overlay thật: hộp thoại Lưu thành… nổi trên overlay luôn-trên-cùng; huỷ thì về overlay, phím vẫn nhận. `[owner-qa]`
- **C9** Bấm thông báo mở Explorer đúng tệp; ✕ chỉ đóng; rê chuột dừng đếm giờ. `[owner-qa]`

## 7. Ghi chú UI

Khoá i18n: `save.saved`, `save.failed`, `save.open_folder`.

## 8. Nợ chuyển task khác

- gd1_05 đã ✅ trước khi task này xong nên không chèn khối bàn giao; hai bản `notice.rs` đã gộp (mục 9).
- gd1_10 (đang làm, đụng overlay): phiên có thêm cờ `exporting` / `copying`, gộp master rồi soát. gd1_11: C8, C9 ở trên.

## 9. Bàn giao thực tế

**Kết quả**: Ctrl/⌘+S và Ctrl/⌘+Shift+S chạy trọn luồng trên màn giả. Kiểm xanh sau khi gộp master: `cargo build`, `clippy
-D warnings`, `cargo test` (UI 101 đơn vị + 10 overlay + 5 ipc), `cargo deny check licenses`. Ảnh thử chỉ nằm trong thư mục
tạm của test; Pictures thật không có tệp `fastcast_*`.

**Đo** (release, `measure_save_3840x1080`, `measure_encode_busy_3840x1080`):

| Mục | Số đo |
| --- | --- |
| Ctrl+S → tệp trên đĩa, 3840 × 1080, hoạ tiết màn giả | ~32 ms (181 KB) — hoạ tiết nén quá tốt, không đại diện |
| Mã hoá ảnh nhiễu 3840 × 1080, `Fast` | 89 ms, 6 128 KB |
| Như trên, `Default` | 1 129 ms, 4 746 KB |
| RAM sau khi đóng, 8 vòng, hai màn 1080p giả | Lưu 34 → 43 MB rồi đứng; Esc 33 → 43 MB rồi đứng ⇒ không rò. Sau 6 s nghỉ: lưu 24, Esc 19 MB |

Chưa đo trên ảnh chụp màn hình thật (máy dùng thật, không chụp): số 89 ms là ảnh tổng hợp.

**Opus chọn 30/10/2026** (đều có gạch ở `plan/confirm.md`): nén `Fast`; overlay đóng SAU khi tệp xuống đĩa; thông báo là cửa
sổ riêng thay vì Toast; thêm `FASTCAST_CONFIG_FILE`; `TerminateProcess` sau `ui stopped`.

**Lỗi thật gặp và đã sửa**:

- Tiến trình UI ghi `ui stopped` rồi treo, nằm mãi không cửa sổ khi Quit tới ngay sau khi thông báo vừa mở (2/2 lần ở
  `measure_save`, 2/5 kịch bản ở lần thử khác). Chưa rõ gốc vì không lấy được stack; đã sửa bằng `platform::exit_now`, chạy
  lại 3 lần + ma trận 5 kịch bản không treo. Lỗi chập chờn nên đây là bằng chứng mạnh, không phải chứng minh tuyệt đối.
- `tests/common` trước đây để UI đọc cấu hình thật của máy ⇒ giờ luôn trỏ cấu hình tạm.

**Gộp với gd1_05** (gộp xong trước): cả hai cùng tạo `notice.rs`. Giữ `notice::show(kind, text, cx)` và vị trí đáy giữa của
gd1_05; thêm `show_saved`, `dismiss`, loại khỏi ảnh chụp, cửa sổ thường khi màn giả. Log đóng dùng `notice: closed`. Lưu và
chép khoá lẫn nhau.

**Còn lại**:

- Chờ kiểm tay C8, C9 (`plan/_backlog.md`).
- GPUI log `Invalid window handle` khi gỡ cửa sổ vừa mở (mở overlay ngay sau thông báo, Quit ngay): chỉ là log, chưa thấy
  hại gì, chưa tìm gốc.

**Đề xuất đã làm**: loại thông báo khỏi ảnh chụp kế; `measure_encode` để chọn mức nén; chỗ Pro ghi vào ROADMAP GĐ4.

## 10. Đề xuất cải tiến

- [pro] Mẫu tên tệp + JPEG / WebP — chỉ PNG tên theo giờ (`save.rs`) — gắn "Pro" — có người trả tiền — M — P3. Đã ghi `ROADMAP.md` GĐ4.
- [ux] Chưa chỉnh được `save.imageDir` trong app (chỉ sửa tay `config.json`) — dòng GĐ4 của `ROADMAP.md` chưa nêu — thêm vào Settings GĐ4 — F-8 ghi "chỉnh được" — S — P2. Đã ghi `plan/_backlog.md` vì Settings chưa có.
- [ram] Lưu làm RAM nghỉ cao hơn Esc ~5 MB sau 6 s (24 so với 19 MB) — số đo mục 9 — chưa rõ nguồn, nhiều khả năng allocator — theo dõi khi đo gd1_11 — S — P3. Không làm: chưa đủ chứng cứ là lỗi.
- [bảo mật] Không có việc mới: tệp tạm cùng thư mục, tự xoá khi lỗi (`TempFile`, test `failed_rename_removes_temp_and_reservation`); PNG không chứa metadata; log không có đường dẫn (C2).
