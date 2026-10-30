# gd1_05 — Chép ảnh / chữ qua daemon (Ctrl/Cmd+C)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | gd1_03 |
| Quyết định áp dụng | F-4 (clipboard ở daemon), D-2 |
| Phụ thuộc mới | `arboard` 3.7 (MIT / Apache-2.0) vào **daemon**, `tempfile` dev-dep của UI (đã có trong cây) — RAM trước / sau ở mục 9 |
| File đụng tới | `crates/core/src/ipc.rs` SỬA · `crates/daemon/src/clipboard.rs` MỚI · `crates/daemon/src/daemon.rs` SỬA · `crates/daemon/Cargo.toml` SỬA · `crates/ui/src/clipboard.rs` MỚI · `crates/ui/src/overlay/mod.rs` SỬA (spec ghi `view.rs` — phím đã nối ở gd1_03) · `crates/ui/src/notice.rs` MỚI · `crates/core/src/paths.rs`, `crates/daemon/src/{ipc_server,isolated}.rs`, `platform/*` · `crates/daemon/examples/clipboard_probe.rs`, `tools/measure-clipboard.ps1` MỚI |

## 1. Làm gì

- Ctrl/Cmd+C, Enter, nút Chép ở overlay ⇒ ảnh vùng chọn vào clipboard, đóng overlay, toast "Đã chép".
- Clipboard do **daemon** giữ (F-4): trên Linux bên giữ clipboard phải sống, UI thì tự thoát sau khi giữ ấm.
- Ảnh không đi qua JSON: UI ghi RGBA thô vào tệp tạm trong `<data_dir>/tmp/` (tên ngẫu nhiên), gửi đường dẫn + cỡ;
  daemon đọc, đặt clipboard, **xoá tệp ngay**.
- Daemon chỉ nhận đường dẫn nằm trong `<data_dir>/tmp/` của chính nó, cỡ khớp `w × h × 4`, trần 16 384 × 16 384 ⇒
  không đọc được tệp tuỳ ý dù pipe bị tiến trình khác của cùng người dùng gọi.
- Chép chữ (`ClipboardText`) cho thước (gd1_08) + lấy màu (gd1_09).
- Daemon khởi động thì dọn tệp sót trong `tmp/`.

## 2. Không làm trong task này

- Lịch sử clipboard. Chép nhiều định dạng (HTML…).

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| IPC, kiểm đường dẫn / cỡ, luồng clipboard, luồng UI → daemon, thông báo, i18n, test | `[opus]` (không giao Sonnet: i18n + `fake_daemon` ~20 dòng, dính interface đang chốt) |
| Dán vào Paint / Word / trình duyệt, nhìn thông báo | `[owner-qa]` |

## 3. Kiểu dữ liệu · IPC · cấu hình

```rust
Message::ClipboardImage { path: PathBuf, width: u32, height: u32 }   // UI → daemon; trả Ok | Error
Message::ClipboardText { text: String }                              // UI → daemon; trần 64 KiB
```

## 4. Code

`[opus]`: hai thông điệp + kiểm đường dẫn / cỡ (ca biên: `..`, symlink, đường dẫn tuyệt đối khác thư mục, cỡ lệch).
`arboard` đặt clipboard trên luồng riêng của daemon, không chặn vòng sự kiện.

## 5. Đo

RAM daemon lúc nghỉ trước / sau `arboard` (hiện 1,1 MB) và sau một lần chép ảnh 3840 × 1080 (bộ nhớ phải nhả về gần
mức nghỉ). Thời gian Ctrl+C → dán được.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ bởi | Kết quả |
| --- | --- | --- | --- |
| C1 | Tệp hợp lệ trong `tmp/` ⇒ tới clipboard, tệp bị xoá; clipboard hỏng vẫn xoá | `[opus-unit]` | ✅ |
| C2 | `..`, tương đối, tuyệt đối khác thư mục, thư mục con ⇒ `Error`, tệp không bị đụng | `[opus-unit]` | ✅ |
| C3 | Symlink trong `tmp/` ⇒ từ chối, đích không bị đụng | `[opus-unit]` | ✅ nhánh từ chối chỉ chạy khi OS cho tạo symlink, không thì test tự bỏ qua |
| C4 | Cỡ lệch, cạnh 0, cạnh > 16 384 ⇒ `Error`, tệp bị xoá; chữ > 64 KiB ⇒ `Error` | `[opus-unit]` | ✅ |
| C5 | Pipe thật + luồng clipboard thật, nơi đặt giả: ảnh + chữ + từ chối, thứ tự trả lời đúng | `[opus-unit]` | ✅ |
| C6 | Daemon khởi động dọn tệp sót; lúc chép dọn tệp > 10 phút, tệp mới giữ | `[opus-unit]` | ✅ |
| C7 | Màn giả, Ctrl+C: tệp đúng cỡ qua IPC; daemon lỗi ⇒ overlay còn, UI xoá tệp, chép lại được; `Ok` ⇒ overlay đóng, thông báo | tích hợp `tests/overlay.rs` | ✅ |
| C8 | Clipboard thật qua daemon `isolated`: ảnh đọc lại đúng từng byte + đúng cỡ 3840 × 1080, chữ đúng, nội dung cũ được trả lại | `[opus-run]` | ✅ |
| C9 | UI màn giả → daemon `isolated`, UI thoát rồi mới đọc clipboard: còn ảnh 3840 × 1080 | `[opus-run]` | ✅ |
| C10 | RAM daemon: nghỉ ≤ 5 MB, sau khi chép ảnh về gần mức nghỉ | `[opus-run]` | ✅ |
| C11 | Chép bằng Ctrl+C / Enter / nút, dán vào Paint / Word / trình duyệt: đúng ảnh, đúng cỡ vật lý; hết giữ ấm vẫn dán được; thông báo không lấy focus, đúng màn có con trỏ | `[owner-qa]` | chờ kiểm tay |

## 7. Ghi chú UI

Khoá i18n: `clipboard.copied`, `clipboard.failed`.

## 8. Nợ chuyển task khác

- Linux / macOS: kiểm lại sau gd0_07 và GĐ4. Linux đang dùng X11 của `arboard` (qua XWayland trên GNOME); chưa bật
  `wayland-data-control` vì không có máy thử — gạch ở `plan/_backlog.md`.
- gd1_08 thước, gd1_09 lấy màu: dùng `clipboard::copy_text` (khối bàn giao trong hai task đó).
- gd1_04: thông báo "Đã lưu" sau khi đóng overlay dùng được `notice::show`; bấm thông báo để mở thư mục thì phải thêm vào đó.

## 9. Bàn giao thực tế

**Luồng đã làm**: `ToolbarAction::Copy` (Ctrl/⌘+C, Enter, nút) ⇒ `overlay::open` subscribe ⇒ `clipboard::copy_selection`:
cắt vùng → ghi `<data_dir>/tmp/clip-<ngẫu nhiên>.rgba` ngoài vòng GPUI → `ClipboardImage` → daemon đọc, xoá, đặt trên luồng
`clipboard` (bật ở lần chép đầu) → `Ok` thì đóng overlay + thông báo. `Error` / mất daemon ⇒ UI xoá tệp, overlay giữ vùng chọn.

**Số đo** (Task Manager, bản release `isolated` — không đăng ký phím tắt thật, `tools/measure-clipboard.ps1`):

| | Trước `arboard` | Sau |
| --- | --- | --- |
| Daemon nghỉ | 1,11 MB | 1,06–1,09 MB |
| Ngay sau khi chép ảnh 3840 × 1080 | — | 1,14 MB (chưa sửa: 21,58 MB) |
| +10 s, sau một lần chép chữ | — | 1,15 MB |
| Đỉnh working set lúc chép ảnh | — | 44,8 MB, tạm thời |
| Cỡ `fst.exe` | 1,09 MB | 1,24 MB |

Thời gian: daemon đặt ảnh 3840 × 1080 hoạ tiết khó nén 105 ms; Ctrl+C → daemon trả lời trên ảnh màn giả cùng cỡ 58 ms; chữ 1–4 ms.

**Cách đo RAM an toàn**: daemon luôn đăng ký phím ⇒ thêm feature lúc biên dịch `isolated` (`crates/daemon/src/isolated.rs`):
đủ khay + cửa sổ ẩn + IPC, không phím, không autostart, không đọc / ghi `config.json`, endpoint + khoá riêng. Không phải biến
môi trường để bản phát hành không có đường tắt. Trong lúc đo có icon khay.

**Lỗi tìm được khi đo, đã sửa**: sau `SetClipboardData` user32 chỉ thả `HGLOBAL` ở lần mở clipboard kế tiếp ⇒ daemon giữ
thêm 20 MB tới lần chép sau, kể cả khi app khác đã thay clipboard. Sửa: `platform::release_clipboard_memory` mở + đóng
clipboard ngay sau khi đặt, thử lại tối đa 10 lần × 20 ms.

**Quyết định (Opus chọn 30/10/2026, cũng ghi `plan/confirm.md`)**:

- Overlay đóng sau khi daemon trả `Ok`, không đóng ngay — vì hỏng thì còn vùng chọn; đổi lại overlay còn thêm ~60–110 ms.
- Thông báo = cửa sổ popup riêng `notice.rs`, không dùng `materiant::toast` — vì toast cần cửa sổ có sẵn mà overlay đã đóng.
- `ClipboardText { text: PrivateText }` thay vì `String` như spec — trên dây vẫn là chuỗi JSON, `Debug` chỉ in độ dài.
- Tệp trong `tmp/` bị từ chối vì cỡ lệch cũng xoá; tệp ngoài `tmp/` không bao giờ đụng.
- Không giao Sonnet (phần `[sonnet]` quá nhỏ, dính interface đang chốt).

**Đề xuất đã làm** (mục 10): dọn tệp tạm > 10 phút lúc chép; ghi chỗ Pro vào `ROADMAP.md`.

**Lệnh soát** (cwd = worktree, `CARGO_TARGET_DIR` riêng): `cargo build`, `cargo clippy --all-targets -- -D warnings`,
`cargo test`, `cargo deny check licenses`. Số test và kết quả lần cuối trước khi gộp: báo cáo của session + commit merge.

**An toàn máy**: chỉ chạy màn giả; clipboard thật chỉ qua `clipboard_probe` (lưu rồi trả lại). Máy đang **bật lịch sử
clipboard Win+V** ⇒ các ảnh hoạ tiết và chữ `fastcast 320×48 #1E90FF` của lần thử còn trong lịch sử, chủ dự án xoá ở Win+V
nếu muốn. Lần đầu chạy, foreground có đổi một lần nhưng máy đang có `fastcast-ui` của session song song giữ foreground từ
trước ⇒ không kết luận được về `focus: false` của thông báo, để `[owner-qa]` C11.

**Chờ kiểm tay** (C11, cũng ở `plan/_backlog.md`): overlay thật, Ctrl+C, dán vào Paint / Word / trình duyệt; đợi UI thoát rồi
dán lại. Vùng chọn vắt khe giữa các màn: phần khe trong suốt, Paint có thể hiện đen.

**Cho gd1_08 / gd1_09**: API `clipboard::copy_text(String, &Requests) -> Result<(), String>`; thông điệp `Message::ClipboardText { text: PrivateText(..) }`.

## 10. Đề xuất cải tiến

- [bảo mật] UI chết giữa lúc ghi và gửi ⇒ ảnh nằm trên đĩa tới lần daemon khởi động sau, mà daemon sống rất lâu —
  `clipboard::sweep` chỉ chạy lúc khởi động — dọn thêm tệp > 10 phút mỗi lần chép ảnh — ảnh chụp không nằm lại — S — P2.
  **Đã làm.**
- [pro] Lịch sử ảnh đã chụp (dán lại ảnh cũ, lưu cục bộ) — mục 2 loại khỏi bản này — chỗ Pro — đã ghi `ROADMAP.md` GĐ4.
- [bảo mật] Ảnh chụp lọt vào lịch sử Win+V / đồng bộ đám mây của Windows — máy chủ dự án đang bật — tuỳ chọn "không lưu ảnh
  chụp vào lịch sử" bằng `exclude_from_history` của `arboard` — riêng tư — S — P3. Chờ màn Settings (GĐ4), `plan/_backlog.md`.
- [ux] Linux Wayland: `arboard` chỉ dùng X11 khi chưa bật `wayland-data-control` — D-3 nhắm GNOME Wayland — bật feature + thử —
  chép chạy khi không có XWayland — S — P2. Thiếu máy Ubuntu, `plan/_backlog.md`.
- [ram] Đỉnh 44,8 MB lúc chép ảnh 3840 × 1080 (RGBA đọc từ tệp + bản lật dọc + DIB + PNG của `arboard`) — tự viết phần Windows
  bỏ bản lật / bỏ PNG — chỉ giảm đỉnh tạm thời, phải tự viết FFI + mất PNG — M — P3. Không làm.
