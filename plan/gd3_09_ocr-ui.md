# gd3_09 — OCR vùng chọn → Ctrl/Cmd+C

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | gd3_08 (`fake_ocr` có từ gd3_01; KHÔNG cần gd3_02, gd3_03) |
| Quyết định áp dụng | F-3, F-4, F-6, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/ocr/{mod,client}.rs`, `overlay/ocr_panel.rs`; MỚI `crates/ui/tests/ocr.rs` |

## 1. Làm gì

- `ocr/client.rs`: bật `fastcast-ocr` cạnh exe (`FASTCAST_OCR_EXE` đè), đọc stdout ở luồng nền, giữ tiến trình giữa các lần đọc. Con chết ⇒ bật lại một lần, vẫn hỏng thì báo lỗi.
- Ảnh đi bằng tệp RGBA trong `paths::ensure_tmp_dir()` như `ClipboardImage`; hỏng trước khi gửi ⇒ tự xoá.
- Nhả chuột / chỉnh vùng xong ⇒ đọc sau 150 ms không đổi nữa. Trả lời có `id` cũ thì bỏ.
- Panel cạnh vùng: đang đọc, chữ kết quả (cuộn được, `cx.floating_surface()` — D-10), không có chữ, lỗi có "thử lại".
- Ctrl/⌘+C, Enter: chép chữ qua `clipboard::copy_text` (async, cần `ipc::Requests`, mẫu ở `overlay/ruler.rs`), đóng overlay, `notice::show` "đã chép {count} ký tự". Bấm lúc đang đọc ⇒ đợi xong rồi chép. Không có chữ ⇒ không đóng.
- UI thoát hoặc giữ ấm hết hạn ⇒ `Shutdown`; không giữ worker quá 60 s rảnh.

## 2. Không làm trong task này

Sửa chữ trong panel, chép một phần. Nút OCR trên thanh chụp. Engine.

## 2b. Phân vai

`[opus]` `client.rs` + luồng hủy / chép chờ. `[sonnet]` phần vẽ panel theo mục 7, trên `PanelState` đã chốt.

## 3–5

Viết lúc bắt đầu task. **Đo**: RAM giữ ấm của UI không tăng (OCR ở tiến trình khác), độ trễ thả chuột → chữ khi có engine thật.

## 6. Nghiệm thu

- `tests/ocr.rs` (`FASTCAST_OVERLAY_FAKE=1` + `fake_ocr`): thành công, không chữ, `--fail` từng mã ra đúng chữ báo, trả lời cũ bị bỏ, Ctrl+C lúc đang đọc, con chết giữa chừng.
- Không còn tệp trong `tmp/` sau mọi ca; log không có chữ đọc được.
- `[owner-qa]` Trong gd3_13: engine thật, ảnh thật, tiếng Việt có dấu, nền tối, chữ 11–12 px, vùng vắt hai màn.

## 7. Ghi chú UI

```
┌ vùng chọn ─────────┐
│                    │
└────────────────────┘
┌ panel ─────────────┐
│ chữ đã đọc…        │  ScrollArea, tối đa 240 px cao
│ ctrl+c để chép     │  khoá `ocr.copy_hint`
└────────────────────┘
```

Khoá `ocr.*` có sẵn từ gd3_01. Sáng / tối, vi / en.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
