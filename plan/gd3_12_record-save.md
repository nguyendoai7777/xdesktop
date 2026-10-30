# gd3_12 — lưu video sau khi dừng (tách với ảnh)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | 🔄 |
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

`[opus]` chép / đổi tên an toàn. `[sonnet]` bảng + test.

## 3–5

Viết lúc bắt đầu task. Chạy thử: `FASTCAST_CONFIG_FILE=<tệp tạm>` + `FASTCAST_OVERLAY_SAVE_AS=<đường dẫn>|cancel`; `FASTCAST_RECORD_FINISHED=<tệp mẫu>` gọi `finish::show` thẳng.

## 6. Nghiệm thu

- `tests/record_save.rs`: lưu nhanh, Lưu thành… cùng ổ, huỷ hộp thoại quay lại bảng, nhớ thư mục, trùng tên, thư mục không ghi được ⇒ giữ bản cũ + báo, Bỏ cần xác nhận.
- Ảnh và video nhớ thư mục riêng (test đọc `config.json`).
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

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
