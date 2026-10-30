# gd3_11 — đang quay: khung viền, đồng hồ, dừng

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd3_01 (`fake_rec`; KHÔNG cần overlay, không cần encoder) |
| Quyết định áp dụng | F-3, F-4, F-7, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/record/{mod,client,frame,controls}.rs`; MỚI `crates/ui/tests/record_control.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `crates/ui/examples/fake_rec.rs`: `--delay-ms`, `--fail <code>`, `--fail-after <giây>`, `--die-after <giây>` (chết không chốt tệp, thoát 3), `--software`, `--skipped <n>`; ghi `.part` rồi đổi tên thật. `worker::exe_path(REC_EXE_VAR, REC_EXE)`.
- **Đã nối**: lệnh `record_region` + `FASTCAST_OVERLAY_FAKE` + `FASTCAST_RECORD_REGION=x,y,w,h` gọi `record::start` qua `record::dev_hook` (`commands::dispatch`). Stub `start` có hai dòng log: giữ dòng `record: start …` (gd3_10 test), bỏ dòng `not implemented`. Field `output` đang `allow(dead_code)`: gỡ.
- **Bẫy**: bật con cần `CREATE_NO_WINDOW`. `dev_hook` chạy thẳng trong `dispatch`, chưa bọc `with_gpu`: mở cửa sổ phải tự bọc. `RecEvent::Finished` không có đường dẫn: lấy từ `RecordStart.output`.

## 1. Làm gì

- `record/client.rs`: bật `fastcast-rec` (`FASTCAST_REC_EXE` đè), gửi `Start`, đọc `RecEvent` ở luồng nền.
- `record/frame.rs`: viền quanh vùng, mỗi màn vùng chạm một cửa sổ `PopUp` không focus, xuyên chuột. Bật `WDA_EXCLUDEFROMCAPTURE` để viền không lọt vào video (như `notice`). Đổi toạ độ bằng scale của từng màn (F-3).
- `record/controls.rs`: thanh nhỏ ngoài vùng: chấm đỏ, thời gian, nút dừng. Không đủ chỗ ngoài vùng thì đặt góc màn. Rơi về phần mềm ⇒ hiện `record.software_encoder`; ô rớt tăng ⇒ `record.dropped`.
- Dừng: nút, hoặc phím `record_region` lần nữa (`stop_if_recording`, đã nối ở `commands::dispatch`).
- Giữ ấm: cửa sổ đang mở nên không tính giờ; nhả GPU: không đổi. Mở bằng `app::with_gpu`.
- `Failed` ⇒ `notice::show` đúng chữ báo, gỡ khung. `Finished` ⇒ gỡ khung, gọi `finish::show`.
- Đổi bố cục màn lúc quay ⇒ để worker báo `DisplayChanged`.

## 2. Không làm trong task này

Bảng thiết lập (gd3_10). Bảng sau khi dừng (gd3_12). Tạm dừng quay.

## 2b. Phân vai

`[opus]` client + frame + đa màn. `[sonnet]` ghép `controls.rs`.

## 3–5

Viết lúc bắt đầu task. **Chạy thử** bằng `FASTCAST_RECORD_REGION=x,y,w,h` (chỉ khi `FASTCAST_OVERLAY_FAKE`) gọi `record::start` thẳng, không qua overlay. **Đo**: RAM UI lúc đang quay, CPU khung viền ≈ 0 khi đứng yên.

## 6. Nghiệm thu

- `tests/record_control.rs` với `fake_rec`: khung + thanh mở, đồng hồ chạy, nút dừng / lệnh lặp gửi `Stop`, `Failed` từng mã, con chết giữa chừng ⇒ báo lỗi + gỡ khung, không cửa sổ mồ côi.
- UI thoát ⇒ worker nhận EOF.
- `[owner-qa]` Trong gd3_13: viền không lọt video, vùng vắt hai màn khác DPI, thanh không che vùng.

## 7. Ghi chú UI

```
● 00:42   [dừng]
```

Nền `cx.floating_surface()`; nút dừng vẽ ô vuông, không cần icon mới. Khoá `record.*` có sẵn.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
