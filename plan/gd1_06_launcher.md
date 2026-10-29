# gd1_06 — Launcher kiểu Raycast

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd1_01 · materiant-gd1_02 (`.drag_region()`), gd1_03 (`Kbd`), gd1_04 (ô tìm), gd1_06 (danh sách) |
| Quyết định áp dụng | F-2, F-4 |
| Phụ thuộc mới | `unicode-normalization` (MIT / Apache-2.0) — đã dùng ở spike để bỏ dấu |
| File đụng tới | `crates/ui/src/launcher/mod.rs` MỚI · `crates/ui/src/launcher/filter.rs` MỚI · `crates/ui/src/launcher/view.rs` MỚI · `crates/ui/src/commands.rs` SỬA · `crates/core/src/config.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- `open_launcher` (Alt+Space mặc định, bấm icon khay) ⇒ cửa sổ không viền 760 × 492 logic, giữa màn có con trỏ (lần
  đầu) hoặc vị trí đã nhớ.
- Ô tìm + danh sách mọi lệnh (`Command::ALL` trừ chính nó): tên i18n, mô tả ngắn, chip phím tắt hiện tại (`Kbd`), lệnh
  chưa gán phím thì không chip.
- Lọc không dấu, không phân biệt hoa thường ("thuoc" ⇒ "Thước căn"), xếp: khớp đầu từ > khớp giữa; khớp cả tên tiếng Anh
  của lệnh.
- ↑ ↓ chọn, Enter chạy (ẩn launcher rồi chạy lệnh), Esc ẩn — bắt ở **pha capture** (ô nhập nuốt phím, bẫy đã gặp).
- Mất focus ⇒ ẩn. Kéo bằng thanh trên (ô nhập `occlude` để đặt con trỏ chữ, không kéo). Nhớ vị trí kéo tới.
- **Dựng sẵn ẩn** khi UI khởi động (`Window::set_visible`) ⇒ mở lại tức thì khi UI đang ấm.
- `filter.rs`: bỏ dấu + chấm điểm — hàm thuần, test đơn vị.

## 2. Không làm trong task này

- Ctrl+K gán phím: gd1_07. Lịch sử ảnh / lệnh gần đây.

## 3. Kiểu dữ liệu · IPC · cấu hình

`config.json` thêm `launcher: { position: { monitorId, x, y } | null }` — toạ độ logic trên màn `monitorId`; màn không
còn ⇒ về giữa màn có con trỏ.

## 4. Code

Mẫu đã chạy: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` — `Launcher`, `fold`, `kbd`, `launcher_options`,
`window_control_area(Drag)` + `occlude`. Chuyển sang component `materiant` thay `div` tự dựng.

## 5. Đo

Alt+Space → khung đầu: UI nguội / ấm (spike: launcher 15,7 MB Task Manager). RAM khi launcher hiện.

## 6. Nghiệm thu

- Gõ "chup", "mau", "ruler" ra đúng lệnh; ↑ ↓ Enter Esc chạy cả khi con trỏ chữ đang trong ô nhập.
- Bấm ra ngoài ⇒ ẩn; mở lại ⇒ ô tìm rỗng, mục đầu được chọn.
- Kéo sang màn khác, đóng UI, mở lại ⇒ đúng chỗ cũ.
- `[owner-qa]`: gõ tiếng Việt bằng Unikey / EVKey (Telex) trong ô tìm; sáng / tối; vi / en.

## 7. Ghi chú UI

```
┌──────────────────────────────────────────────┐  ← thanh trên kéo được
│ 🔍  Tìm lệnh…                                 │
├──────────────────────────────────────────────┤
│ ▣ Chụp vùng          Chọn vùng màn hình  ⌃⇧1 │  ← mục chọn: nền nhấn nhạt
│ ▣ Thước căn          Đo khoảng cách px   ⌃⇧2 │
│ …                                            │
├──────────────────────────────────────────────┤
│ ↵ Chạy    ⌃K Hành động                   Esc │  ← chân
└──────────────────────────────────────────────┘
```

Khoá i18n: `launcher.search`, `launcher.run`, `launcher.actions`, `command_desc.<id>` cho mỗi lệnh.

## 8. Nợ chuyển task khác

- Ctrl+K: gd1_07.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
