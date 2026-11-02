# materiant-gd5_01 — Slider

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (02/11/2026) |
| Repo | materiant |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-10, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/slider.rs`, `examples/gallery/pages/slider.rs`; MỚI `ui-tests/tests/slider.rs` |

## 1. Làm gì
- `materiant::slider::Slider` dựng trên `gpui_kit::base` slider (`SliderState`, `Slider`, `SliderTrack`, `SliderIndicator`, `SliderThumb`), diện mạo lấy từ `E:\codex\xbds\materiant\projects\form\ui\src\lib\slider` (`slider.css`, `slider.const.ts`).
- Ngang và dọc (dọc cho 10 băng EQ của groove). `min` / `max` / `step`, `disabled`, `on_change` khi kéo, `on_commit` khi thả.
- Tua bài của groove: app đặt được giá trị từ ngoài lúc đang phát mà không cắt ngang thao tác kéo của người dùng.
- Bàn phím: mũi tên, PageUp / PageDown, Home / End. Nhấp vào track nhảy tới vị trí đó.
- Trang gallery `slider`: đúng cả sáng / tối. Test logic thuần (làm tròn step, kẹp biên), test bàn phím trong `ui-tests/`.
- Phím mặc định tự gán ở lần vẽ đầu (`bind_keys`, như `list.rs`); không sửa `lib.rs`.

## 2. Không làm trong task này
- Hai thumb (khoảng giá trị), nhãn giá trị nổi. Không viết UI của groove.

## 2b. Phân vai
| Phần việc | Ai |
|---|---|
| `src/slider.rs`, trang gallery, `ui-tests/tests/slider.rs` | [opus] — cỡ nhỏ, chung một interface, không tách Sonnet |
| Thanh trượt bằng chuột thật + trình đọc màn hình | [owner-qa] |

## 6. Nghiệm thu — Case test
- C1 Cho slider có focus, khi ← → ↑ ↓ / PageUp / PageDown / Home / End, thì đi 1 nấc / 10 nấc / về hai đầu, kẹp biên. [opus-unit + ui-tests]
- C2 Cha gán ↓, khi slider có focus, thì phím của slider thắng. [ui-tests]
- C3 Khi nhấp track, thì nhảy tới vị trí, change lúc nhấn, commit lúc thả, focus vào slider. [ui-tests]
- C4 Khi kéo, thì change theo nấc không lặp, ra ngoài bị kẹp, commit một lần. [ui-tests]
- C5 Khi kéo từ thumb, thì chạy và có focus. [ui-tests]
- C6 Đang kéo, khi app đẩy `.value`, thì thumb theo tay; thả xong `.value` có hiệu lực. [ui-tests + opus-run]
- C7 Dọc: min ở đáy, max ở đỉnh, step 0,5 thang âm. [ui-tests]
- C8 Disabled: chuột, phím, Tab không tác dụng. [ui-tests]
- C9 Max lệch nấc vẫn với tới; đổi thang lúc chạy. [opus-unit + ui-tests]
- C10 Khoá giữa lượt kéo không kẹt. [ui-tests]
- C11 Trang gallery đúng sáng / tối. [opus-run]
- C12 Trình đọc màn hình tăng / giảm được giá trị. [owner-qa]

## 9. Bàn giao thực tế
- `materiant::slider::Slider` giá trị do app giữ (`.value`), như `Switch`; không có `SliderState` lộ ra app. Tua bài: app cứ đẩy `.value(position)`, đang kéo slider tự bỏ qua; lưu vị trí mới ở `on_commit`.
- Opus chọn 02/11/2026: tính lại nấc từ tỉ lệ vị trí thay vì dùng giá trị `gpui-base` — vì bản base đếm nấc từ 0 và không kẹp `max` (`min = 5, step = 10` sai; `max = 10, step = 4` ra 12). Giữ trang gallery đúng bố cục mục 1.
- Opus chọn 02/11/2026: hover đổi tức thì, không animate rail / halo như web 160 ms — theo luật `materiant/CLAUDE.md`.
- Hằng diện mạo nằm cục bộ trong `slider.rs` (`style.rs` thuộc làn khác) — xem mục 8.
- Chạy thật: thanh tua nhãn 34 s trong khi thumb ở ~139 s lúc kéo, thả `COMMIT seek 139.5`; RAM gallery bản debug ~16 MB; cửa sổ không giành focus.
- Bẫy: `gallery-run.ps1` mặc định ghi chung `%TEMP%\materiant-gallery` ⇒ nhiều session song song đè stdout + ảnh của nhau; truyền `-Out` riêng. Lần `drag@` đầu chỉ khởi động lượt kéo của GPUI, cần lần thứ hai giá trị mới đổi.
- Chờ kiểm tay: C12 (action a11y của `gpui-base` không giả lập được trong test; `Control::on_base_notify` chưa được chạy qua) và kéo bằng chuột thật.

## 8. Nợ chuyển task khác
- Dời hằng `SLIDER_*` lên `style::tokens` khi không còn làn song song đụng `style.rs`.
