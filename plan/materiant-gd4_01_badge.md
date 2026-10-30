# materiant-gd4_01 — huy hiệu `Badge`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | S — ~80 dòng |
| Phụ thuộc | — (song song với gd4_01, khác repo) |
| Quyết định áp dụng | D-4, D-6, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `src/badge.rs`, `examples/gallery/pages/badge.rs`; SỬA `src/lib.rs`, `examples/gallery/{main,pages/mod}.rs`, `CLAUDE.md` (bảng module) |

## 1. Làm gì

- `materiant::badge::Badge::new(label)`: chip chữ nhỏ, `.tone(Accent)` (mặc định `Primary`), `.outline()`. Không state, `RenderOnce`, không chứa chữ cố định.
- Trang gallery sáng / tối, đủ tông màu. Tương phản chữ / nền ≥ 4,5 : 1 ở cả hai tông (test thuần trên token).

## 2. Không làm trong task này

Huy hiệu số thông báo, chấm trạng thái. `IconSource` của F-12 (D-4 chỉ đặt chỗ). Dọn nợ GĐ1 của materiant.

## 2b. Phân vai

Toàn bộ `[opus]` (cỡ S, không có phần tách được cho Sonnet).

## 4. Code

Dùng `Accent::tokens` (`tonal*`), `text_caption`, số đo lấy từ gói `chip` / `badge` ở `E:\codex\xbds\materiant\projects`. Mẫu chip: `kbd.rs`.

## 6. Nghiệm thu

- C1 `[opus-unit]` Cho `Badge::new("Pro")` / Thì `Primary`, tonal; `.tone(..).outline()` đổi đúng trường. ✅
- C2 `[opus-unit]` Cho `ink` đã đủ tương phản / Thì giữ nguyên, nền đúng `tonal`, kiểu outline nền trong suốt. ✅
- C3 `[opus-unit]` Cho mọi `Accent` × hai kiểu × sáng / tối × theme mặc định + 3 preset / Thì chữ / nền ≥ 4,5 : 1. ✅
- C4 `[opus-run]` Khi `gallery-run.ps1 -Page badge`, Ctrl+T / Thì ảnh sáng + tối đúng, `foreground_unchanged=True`. ✅
- C5 Bốn lệnh soát xanh; `cargo tree -i gpui-component` báo không có. ✅

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

- **Cho fastcast (gd4_05)**: `use materiant::badge::Badge; Badge::new(label)` (`.tone(Accent)`, `.outline()`), nhãn do app truyền qua i18n. Không cần `id`, không bấm được. Tương phản chỉ được bảo đảm trên `c.surface` đục ⇒ đặt dòng khoá trên `surface`; đặt trên nền khác thì soát lại.
- Opus chọn 30/10/2026: plan trỏ gói `chip` / `badge` ở `xbds/materiant/projects` nhưng không có gói này ⇒ số đo theo `kbd.rs` (cao 20, bo 4), đệm ngang 6 — vì đó là mẫu chip plan cũng nêu.
- Opus chọn 30/10/2026: `badge_colors` trộn dần `ink` về màu chữ khi chưa đạt 4,5 : 1, không đổi `AccentTokens` — vì `style.rs` còn dùng cho nút.
- Kiểu tonal có viền trong suốt để cùng cỡ với outline. Gallery: trang `badge` cuối sidebar.
- Soát trên nhánh, `master` không đổi tới lúc gộp: build, clippy `-D warnings`, test (126 unit materiant + ui-tests), deny `licenses ok`, `gpui-component` không có. Chạy thử màn phụ (x = -1518): RAM 13,9 MB, `foreground_unchanged=True`. Ảnh đã xoá.
- `src/overlay/popover.rs` ở checkout chính của materiant đang bẩn sẵn (đổi định dạng, không phải của task này) — để nguyên.

## 10. Đề xuất cải tiến

Bảo mật: không áp. UX: không có phát hiện (không tương tác). RAM: không phụ thuộc mới, không state. Pro: chỗ đặt huy hiệu thuộc `gd4_05`. Không có đề xuất.
