# gd3_12 — lưu video sau khi dừng (tách với ảnh)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay ở gd3_13 |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd3_01 |
| Quyết định áp dụng | F-8 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/record/finish.rs`; MỚI `crates/ui/tests/record_save.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: stub `record/finish.rs`: `Finished { path, secs, bytes }`, `show`. Lệnh `record_region` + `FASTCAST_OVERLAY_FAKE` + `FASTCAST_RECORD_FINISHED=<tệp>` gọi `show` (giả 42 s, `bytes` theo tệp). `save.rs`: `Target`, `Target::dir`, `Failure` (kèm trường), `ask_path`, `dialog_target`, `report_failure` đã `pub(crate)`.
- **Bẫy**: `dialog_target` cố định đuôi `png`, `report_failure` cần `Entity<OverlaySession>` mà bảng này không có ⇒ bản video viết trong `finish.rs`, dùng `notice::show` khi không có overlay. `show` chạy thẳng từ `dispatch`, mở cửa sổ phải tự bọc `app::with_gpu`.
- **Đã có khoá**: `record.finish_title`, `save`, `save_as`, `discard`, `discard_confirm`, `saved` (`{name}`). Không có khoá báo lỗi lưu riêng: `save.failed` dùng được (`{dir}`).

## 1. Làm gì

Tệp đã nằm trong `save.videoDir` lúc quay xong; bảng này quyết định số phận của nó:

- Ctrl/⌘+S, Enter: giữ nguyên, `notice::show_saved` bấm mở thư mục.
- Ctrl/⌘+Shift+S: hộp thoại của OS, đầu vào `save.lastVideoDialogDir`, nhớ lại sau khi chọn, tách khỏi ảnh. Cùng ổ thì đổi tên, khác ổ thì chép ở luồng nền rồi xoá bản cũ, hỏng thì giữ bản cũ và báo.
- Bỏ: `Dialog` xác nhận rồi xoá.
- Đóng bảng không chọn: coi như giữ. Không tự xoá video của người dùng.
- Hiện thời lượng + cỡ tệp. Tên trùng ⇒ `_2`, `_3` như ảnh. Đuôi khác `.mp4` ⇒ nối thêm.
- Log không ghi đường dẫn / tên tệp. Dùng lại phần `pub(crate)` của `save.rs`, không sửa tệp đó; `file_name_now`, `remember_dialog_dir` của ảnh cố định `.png` / khoá ảnh ⇒ viết bản video trong `finish.rs` bằng `fastcast_core::naming`.

## 2. Không làm trong task này

Chỉnh `save.videoDir` trong Settings (GĐ4). Xem lại video trong app.

## 2b. Phân vai

`[opus]` toàn bộ: chép / đổi tên an toàn + bảng + test. Dự kiến giao Sonnet phần bảng + test, nhưng hai phần chung một tệp, cỡ S, Opus đã nạp đủ ngữ cảnh nên không tách.

## 3–5

Không có kiểu, IPC, khoá config mới: dùng `Finished`, `save.videoDir`, `save.lastVideoDialogDir` của gd3_01. Không đo: bảng là cửa sổ ngắn hạn, số đo RAM chung ở gd3_13. Chạy thử: `FASTCAST_CONFIG_FILE=<tệp tạm>` + `FASTCAST_OVERLAY_SAVE_AS=<đường dẫn>|cancel`; `FASTCAST_RECORD_FINISHED=<tệp mẫu>` gọi `finish::show` thẳng; phím: `FASTCAST_RECORD_FINISH_KEYS`.

## 6. Nghiệm thu

- ✅ `tests/record_save.rs`: lưu nhanh (Ctrl+S, Enter, Esc), Lưu thành… cùng ổ, huỷ hộp thoại quay lại bảng, nhớ thư mục, trùng tên, thư mục không ghi được ⇒ giữ bản cũ + báo, Bỏ cần xác nhận (Esc, huỷ, đồng ý), Enter trên nút đang focus.
- ✅ Ảnh và video nhớ thư mục riêng (test đọc `config.json`, cả hai chiều).
- ✅ Chép sang ổ khác thật, E: sang C: (`real_second_drive_when_there_is_one`, khẳng định đi đường chép), hỏng giữa chừng giữ bản cũ, không sót tệp tạm.
- `[owner-qa]` Trong gd3_13: hộp thoại nổi đúng, chép sang ổ khác.

## 7. Ghi chú UI

```
┌ đã quay xong ─────────────────────────┐
│ 00:42 · 16,8 MB                       │
│ [lưu ⌃S] [lưu thành… ⌃⇧S] [bỏ]        │
└───────────────────────────────────────┘
```

Cửa sổ riêng ở đáy màn có con trỏ, nền đặc. Khoá `record.*` có sẵn.

## 8. Nợ chuyển task khác

Không còn. Hai khoá i18n thiếu (`record.discard_keep`, `record.discard_failed`) đã thêm bằng commit riêng sau khi làn gộp, đúng luật làn.

## 9. Bàn giao thực tế

- **Đã làm**: `crates/ui/src/record/finish.rs` (bảng + `relocate`), `crates/ui/tests/record_save.rs`. Fastcast: `c87a7ce`, `605d0f3`.
- **Soát**: `build`, `clippy -D warnings`, `deny` xanh; `cargo test` toàn workspace xanh, trừ `tests/overlay.rs` đỏ 9 ca trong lượt chạy chung (hết hạn 5 s chờ thoát lúc nhiều làn build), chạy lại riêng `--test-threads=2` thì 32/32 xanh. Sau commit i18n chỉ chạy lại `record_save`, `i18n`, `clippy`. Cùng lý do, `record_save` chờ thoát theo `TIMEOUT` thay vì 5 s.
- **Soi giao diện**: chụp `PrintWindow` trên màn giả, bảng vi và hộp xác nhận en (bản trước khi đổi nút huỷ thành `discard_keep`) vừa cửa sổ. Popup thật chưa chụp, chờ gd3_13.
- **Opus chọn 30/10/2026** (đủ ở `plan/confirm.md`): Esc giữ + báo như Ctrl+S; gợi ý tên hiện có của tệp, không sinh `file_name_now`; chọn đúng tệp đang có ⇒ không làm gì; chép xong mà không xoá được bản cũ ⇒ thành công, chỉ log; bảng cách đáy 120 px; loại khỏi ảnh chụp.
- **Lỗi bắt được nhờ test ổ thật**: `sync_all` trên handle chỉ đọc là Access Denied trên Windows.
- **Bẫy**: `window.dispatch_keystroke` chỉ gửi nhấn, không nhả, mà `Button` bấm bằng phím lúc nhả ⇒ kịch bản phím gửi cả `KeyUp` qua `dispatch_event`.
- **Chờ kiểm tay**: mục 6, trong gd3_13. `record/mod.rs` (gd3_11) gọi `finish::show` khi nhận `RecEvent::Finished`, tệp phải nằm trong `save.videoDir`.

## 10. Đề xuất cải tiến

Bảo mật: log chỉ ghi `kind`, có test soát; tệp tạm tự xoá khi lỗi. RAM: bảng đóng là GPU được nhả như mọi cửa sổ. Pro: không áp.

- [ux] Chép sang ổ khác chỉ có vòng quay, không có tiến độ — `move_onto` dùng `fs::copy` — đổi sang vòng chép có báo tiến độ — giá trị với video lớn trên ổ mạng — M — P3. Chưa làm: chưa có số đo cho thấy chờ lâu, xét lại sau gd3_13.
- [bảo mật] Tiến trình bị giết giữa lúc chép để lại `.fastcast-<pid>-<seq>.tmp` cạnh đích — `temp_path` — quét dọn lúc khởi động — S — P3. Không làm: phải quét thư mục của người dùng, được ít hơn mất; hiếm và nằm trong thư mục người dùng tự chọn.
