---
name: groove
description: Khoanh session vào app groove trong workspace xdesktop (trình phát nhạc Groove X, đang viết lại từ Tauri + Vue sang Rust + GPUI + materiant) — nạp đúng ngữ cảnh của groove, không quét fastcast. Dùng khi chủ dự án gõ "/groove", "/groove <việc>", hoặc nói sẽ làm việc với groove.
argument-hint: "<việc cần làm, bỏ trống nếu chỉ nạp ngữ cảnh>"
---

Session này chỉ làm **groove**. fastcast không liên quan: hai app chỉ dùng chung materiant và luật workspace.

## Hiện trạng

`groove/` là repo git riêng (remote `nguyendoai7777/groove`), hiện vẫn là bản **Tauri + Vue, sắp bỏ**. G-1 đã chốt viết
lại bằng Rust + GPUI + materiant. Hệ quả:

- Không sửa lỗi riêng của bản Tauri, không thêm tính năng vào đó.
- Mã cũ chỉ dùng để tra hành vi cần giữ: `src/pages/` (`my-music`, `now-playing`, `playlists`), `src-tauri/src/`
  (`db.rs` SQLite, `tags.rs` đọc thẻ nhạc, `watcher.rs` theo dõi thư mục).
- Thư viện của bản cũ phải soát giấy phép lại nếu đem sang bản mới (D-2).

## Nạp ngay

1. `groove/CLAUDE.md`, `groove/ROADMAP.md` nếu đã có (lúc viết skill này chưa có; `groove/README.md` chỉ là mẫu Tauri,
   không cần đọc).
2. `docs/decisions.md`, mục `Chung cho workspace` và `groove` (G-*).
3. `groove/plan/_backlog.md`.

## Đọc khi việc cần

| Cần gì | Đọc |
| --- | --- |
| Component đang làm cho groove | `materiant/plan/completed/gd5/` (slider, progress, textarea, virtual grid) |
| Task của groove | `groove/plan/groove-gd<N>_*.md` nếu có, khung tệp ở `docs/tasking-convention.md` |
| Component UI | `materiant/src/<component>`, xem mục dưới |

## materiant

Bản viết lại dùng materiant làm UI. Chỉ mở đúng tệp của component đang dùng; đọc thêm `materiant/CLAUDE.md` khi sắp sửa
materiant. Sửa materiant là đụng cả app khác ⇒ giữ API chung, không nhét logic riêng của groove, và soát bằng lệnh của
materiant.

## Không đọc

- `fastcast/`, mục `fastcast` của `docs/decisions.md` (F-*), `fastcast/plan/`.
- `groove/node_modules/`, `groove/dist/`, `groove/release/`, `groove/src-tauri/target/`, `groove/src-tauri/gen/`.
- `materiant/spikes/` trừ khi tài liệu đang đọc trỏ tới.

Tìm kiếm luôn truyền `path` hẹp (`groove/src-tauri/src`, không phải gốc workspace): quét từ gốc đi qua thư mục build nên
dễ quá hạn.

## Sau khi nạp

Có việc trong tham số ⇒ làm luôn. Không có ⇒ báo một dòng "đã nạp ngữ cảnh groove" rồi chờ. Đừng tóm tắt lại những gì
vừa đọc. Việc chạm fastcast ⇒ nói rõ là ngoài phạm vi session này.
