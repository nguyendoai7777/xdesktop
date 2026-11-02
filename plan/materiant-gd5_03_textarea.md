# materiant-gd5_03 — TextArea

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (02/11/2026) — chờ kiểm tay bộ gõ tiếng Việt; dán 5.000 dòng chặn UI ~0,45–1,1 s (mục 5) |
| Repo | materiant |
| Cỡ | S — ~250 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/field/textarea.rs`, `src/field/mod.rs` (`pub use`), `examples/gallery/pages/input.rs`; MỚI `ui-tests/tests/textarea.rs` |

## 1. Làm gì
- `materiant::field::TextArea`: như `TextField` (`src/field/input.rs`), dùng lại `FieldShell`, cùng `FieldEvent`, trên `InputState` của gpui-base chế độ nhiều dòng (`rows`, `auto_grow(min, max)` — xem `state.rs` của `gpui-base` 0.8.1).
- Số dòng cố định hoặc tự giãn trong khoảng; cuộn khi vượt. Enter xuống dòng; Ctrl+Enter phát `FieldEvent` gửi.
- Dán lời bài hát dài (5.000 dòng) không đơ: đo và ghi ở mục 5.
- Gõ tiếng Việt qua bộ gõ: thêm vào danh sách `[owner-qa]`.
- Thêm phần `TextArea` vào trang gallery `input`, đúng cả sáng / tối. Test bàn phím / focus trong `ui-tests/`.

## 2. Không làm trong task này
- Tô màu cú pháp, đánh số dòng, trình soạn thảo của gpui-base (ROADMAP: không port editor).

## 2b. Phân vai
| Phần | Vai |
|---|---|
| `TextArea`, tuỳ chọn `multi_line` của `FieldShell`, trang gallery, test | `[opus]` |
| Bộ gõ tiếng Việt | `[owner-qa]` |

## 5. Đo
Bản release, `gallery.exe`, chèn bằng `TextareaState::insert` (cùng đường sửa chữ với `Paste`), bộ nhớ theo cột Memory.

| Nội dung | Chặn luồng UI |
|---|---|
| 5.000 dòng ngắn, không xuống dòng mềm (109 KB) | 448 ms |
| 5.000 dòng 54 ký tự, mỗi dòng ngắt mềm thành 2 (274 KB) | 1.132 ms (lần hai, tổng 548 KB: 1.206 ms) |
| Ước tính 100 dòng (bài thật), suy tuyến tính, chưa đo | ~9–23 ms |

Bộ nhớ: nghỉ ~15–16 MB, sau một lần dán dòng ngắn 17 MB, sau hai lần dán dòng dài 20,2 MB.

**Chưa đạt "không đơ" ở 5.000 dòng**: một lần chặn 0,45–1,1 s, không treo, gõ tiếp vẫn đúng. Nguyên nhân ở `gpui-base` 0.8.1: `text_wrapper.rs` (`update` → `measured_wrap_boundaries`) đo chữ từng dòng đồng bộ trên luồng UI. Không sửa được từ materiant nếu không vá thư viện đã ghim (D-6) hoặc chèn theo từng đợt (mất undo một bước).

## 6. Nghiệm thu
Mọi case `[opus-unit]` nằm ở `ui-tests/tests/textarea.rs`.

| Case | Cho / Khi / Thì | Phủ | Kết quả |
|---|---|---|---|
| C1 | Gõ, Enter, gõ ⇒ có dòng mới, không gửi | `[opus-unit]` | xanh |
| C2 | Ctrl+Enter ⇒ `on_submit` + `FieldEvent::Submit`, không chèn dòng, không `Change` | `[opus-unit]`, `[opus-run]` | xanh |
| C3 | Tab / Shift+Tab ⇒ rời ô, không sửa chữ | `[opus-unit]`, `[opus-run]` (Tab) | xanh |
| C4 | Esc tới cha | `[opus-unit]` | xanh |
| C5 | ↑ di chuyển caret giữa các dòng | `[opus-unit]` | xanh |
| C6 | `auto_grow(2, 4)`: cao theo dòng, vượt max thì giữ nguyên | `[opus-unit]`; `auto_grow(2, 6)` `[opus-run]` | xanh |
| C7 | `rows(3)`: chữ dài không làm ô cao thêm | `[opus-unit]` | xanh |
| C8 | Ctrl+V 5.000 dòng: đủ chữ, một `Change` | `[opus-unit]` | xanh |
| C9 | `set_value` không phát `Change`; disabled không gửi | `[opus-unit]` | xanh |
| C10 | Bấm chuột vào ô ⇒ focus, gõ được | `[opus-unit]` | xanh |
| C11 | Trang gallery `input` đúng sáng / tối (lỗi, disabled, focus, thanh cuộn) | `[opus-run]`, xem ảnh | xanh |
| C12 | Gõ tiếng Việt qua bộ gõ (Unikey / EVKey) trong ô `Fixed, 4 rows`: dấu đúng, không mất chữ | `[owner-qa]` | chờ kiểm tay |

## 9. Bàn giao thực tế
- `materiant::field::TextArea`: `rows`, `auto_grow`, `label`, `hint`, `placeholder`, `default_value`, `error`, `warning`, `disabled`, `on_change`, `on_submit`, `value`, `set_value`, `set_error`, `set_warning`, `set_disabled`, `set_accessibility_label`, `input_state`. Mặc định 3 dòng.
- Plan sai so với code: gpui-base 0.8.1 tách kiểu, nhiều dòng là `TextareaState` + `Textarea`, không phải `InputState`.
- Ngoài danh sách tệp: sửa thêm `src/field/shell.rs` (`FieldShell::multi_line`, `FIELD_PADDING_Y`) vì khung cũ cố định chiều cao. Ô một dòng không đổi.
- Opus chọn 02/11/2026: Tab / Shift+Tab chuyển focus, không chèn thụt lề — vì mặc định gpui-base thụt lề thì bàn phím kẹt trong ô. Ctrl+Enter bị chặn bằng `capture_action` vì gpui-base mặc định chèn dòng; không đi tiếp tới cha.
- Nút `Paste 5,000 lines` ở gallery in `PASTE insert=… frame=…`; `frame` lấy ở `on_next_frame`, chưa gồm thời gian vẽ khung đó. Số ở mục 5 là `insert`.
- Giới hạn của lần chạy thật: bấm chuột giả lập qua `--keys` không có tác dụng trên trang `input` (kể cả có `move@`, chưa rõ nguyên nhân), nên `[opus-run]` đi bằng Tab; bấm chuột chỉ phủ bằng C10. Cửa sổ và thứ tự trang được vá tạm để thấy phần dưới, đã gỡ, không commit. Theme sáng chỉ xem một ảnh; thanh cuộn dùng mặc định của gpui-base, chưa chỉnh theo `scrollbar_tokens`.
- Soát trên nhánh sau khi gộp `master`: `cargo fmt --check`, `clippy -D warnings`, `cargo test`, `deny licenses`, `cargo tree -i gpui-component` đều đạt. Task song song: `gallery-run.ps1` dùng chung `-Out` mặc định ⇒ log và ảnh lẫn nhau; truyền `-Out` riêng.
- Soi cải tiến: bảo mật không áp; RAM như mục 5; Pro không áp. UX: chỉ còn hai việc ghi ở mục 5 và dòng thanh cuộn trên.
- Không có task nào ghi task này ở dòng "Phụ thuộc" ⇒ không có khối bàn giao để chèn.
