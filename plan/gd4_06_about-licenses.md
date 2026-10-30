# gd4_06 — trang giấy phép bên thứ ba + Giới thiệu

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | D-2 |
| Phụ thuộc mới | Công cụ dev `cargo-about` (MIT / Apache-2.0), không vào exe |
| File đụng tới | MỚI `about.toml`, `tools/licenses/{template.hbs,extra.toml}`, `tools/gen-licenses.ps1`, `crates/ui/tests/settings_about.rs`; SỬA `crates/ui/src/settings/page_about.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- `tools/gen-licenses.ps1 -Out <thư mục>` sinh `third-party.html`: cả cây phụ thuộc của 6 target phát hành (cùng danh sách `deny.toml`), gộp theo giấy phép, đủ văn bản.
- `extra.toml`: thứ cargo không thấy: ONNX Runtime + `ThirdPartyNotices.txt` (gd3_03), model PP-OCRv6 + VietOCR (sổ `manifest.toml`), bộ icon, Lucide (ISC), GPUI + `gpui-kit`.
- Trang Giới thiệu: phiên bản, nút mở trang giấy phép (`licenses/third-party.html` cạnh exe, thiếu ⇒ `about_licenses_missing`), mở thư mục dữ liệu, mở thư mục log.
- Script dừng nếu `cargo deny check licenses` đỏ.

## 2. Không làm trong task này

Đọc giấy phép dữ liệu huấn luyện model (`_backlog.md`, việc của chủ dự án; trang ghi đúng nhãn hiện có). Sửa nhãn `+int8-all` của sổ: gd4_09. Chép tệp vào bản cài: gd4_09.

## 4. Code

Không nhúng HTML vào exe (RAM + cỡ). Mở bằng trình duyệt mặc định: `cx.open_url`, khi chạy thử thì chỉ ghi log `about: open <loại>`, không mở cửa sổ ngoài (trình duyệt sẽ bật ở màn chính).

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh; `gen-licenses.ps1` chạy được hai lần ra cùng nội dung.
- [ ] Soát tệp sinh ra: có `gpui-pre`, `xcap`, `ort`, `windows`, `objc2`; không có GPL / AGPL.
- [ ] Nút mở khi chạy thử chỉ ghi log. `settings-run.ps1 -Page about` chụp sáng / tối. Chỉ màn DELL.

## 7. Ghi chú UI

Không in đường dẫn đầy đủ của người dùng ra log.

## 8. Nợ chuyển task khác

gd4_09, gd4_13, gd4_17: chép `third-party.html` vào `licenses/` cạnh `fastcast-ui` (khối bàn giao ở từng task).

## 9. Bàn giao thực tế

- **Có**: `tools/gen-licenses.ps1 -Out <thư mục>` ra `third-party.html` 910 KB, 582 crate, nhãn 0BSD, Apache-2.0, BSD-2/3, BSL-1.0, CC0-1.0, ISC, MIT, MPL-2.0, Unicode-3.0, Zlib; không GPL / AGPL. Script tự dừng nếu: `cargo deny` đỏ (đã thử bằng cách bỏ MIT khỏi `deny.toml`), target lệch `deny.toml`, nhãn GPL, thiếu `gpui-pre`, `gpui-kit`, `xcap`, `ort`, `windows`, `objc2`.
- **Soát**: chạy hai lần cùng sha256. Đối chiếu `cargo tree` của 6 target (`-e normal,build`): không thiếu crate nào ngoài crate nội bộ; trang có thêm 21 crate vì `cargo about` tính rộng hơn.
- **Bốn lệnh soát xanh**. `settings-run.ps1 -Page about` sáng / tối: đúng màn DELL, không giành foreground, 17,7 MB. Test `settings_about` phủ: nút chỉ ghi log, log không lộ đường dẫn, thiếu tệp thì báo.
- **Opus chọn 30/10/2026**:
  - `cx.open_with_system(path)` thay `cx.open_url`: khỏi mã hoá `file://` cho `C:\Program Files`.
  - Chép `LICENSE` + `ThirdPartyNotices.txt` của ONNX Runtime 1.31.1 vào `tools/licenses/texts/onnxruntime/` (344 KB): script không cần mạng hay thư mục model.
  - `cargo about --frozen`: không gọi ClearlyDefined, kết quả không đổi theo mạng.
  - Model đọc từ sổ `manifest.int8-mix.toml`: gd4_09 sửa nhãn `+int8-all` là trang đổi theo.
  - Icon F-11 không vào trang: dự án tự vẽ, không phải bên thứ ba (tra `design/fastcast-icons` không thấy nguồn ngoài). GPUI, `gpui-kit` nằm ở phần crate, không ở `extra.toml`.
  - Ba nút thành hàng, không dùng nhãn + nút: không thêm khoá i18n.
  - Biến thử `FASTCAST_ABOUT_LICENSES` chỉ đọc khi `is_test_run`.
- **Chờ kiểm tay** `[owner-qa]`: bản cài bấm ba nút mở đúng trình duyệt / Explorer; máy nhà không được mở trong làn. Ghi ở `_backlog.md`.
- **Chưa chạy** trên Mac, Ubuntu: `licenses/` cạnh exe mới chỉ soát bằng unit test.

## 10. Đề xuất cải tiến

Soi bốn lăng kính, không có đề xuất mới. Bảo mật: chỉ mở đường dẫn cố định, log không ghi đường dẫn. UX: dùng hết bằng phím, sáng / tối đã xem. RAM: HTML không nhúng vào exe, trang không giữ dữ liệu. Pro: không áp.
