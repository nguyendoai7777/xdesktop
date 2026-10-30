# gd3_02 — engine OCR trong `crates/ocr`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~800 dòng, phần lớn chuyển từ spike |
| Phụ thuộc | gd3_01, gd0_05 |
| Quyết định áp dụng | F-6, D-2, F-4 |
| Phụ thuộc mới | `ort` =2.0.0-rc.15 `load-dynamic` (MIT / Apache-2.0), `ndarray`, `sha2`, `toml` — bản ghim theo `fastcast/spikes/ocr/Cargo.toml` sau gd0_05 |
| File đụng tới | MỚI `crates/ocr/src/engine/{det,rec,imgops,manifest,pipeline}.rs`, `crates/ocr/examples/ocr_bench.rs`; SỬA `crates/ocr/src/engine/mod.rs`, `crates/ocr/Cargo.toml`, `Cargo.lock` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `crates/ocr/src/lib.rs` (`Recognizer`, re-export `RgbaImage`, `OcrError`), stub `engine/mod.rs` (`Engine::load`, `impl Recognizer`). `image` 0.25 đã khai trong `crates/ocr/Cargo.toml`, không codec: spike cần `png` / `jpeg` thì bật feature khi thêm `ort`.
- **Đổi so với spec**: `crates/ocr` có `[lib] fastcast_ocr` + `[[bin]] fastcast-ocr`.
- **Soát lại khi làm**: `cargo clippy -p fastcast-ocr --all-targets -- -D warnings`, `cargo test -p fastcast-ocr`, `cargo deny check licenses`. Chi tiết: `plan/gd3_01_contracts.md` mục 9.

## 1. Làm gì

- Chuyển `spikes/ocr/src/{det,rec,imgops,manifest,pipeline}.rs` sang `engine/`, bỏ nhánh chỉ phục vụ đo (`paddle`, cờ đảo màu bộ dò, preset `scene`), chỉ giữ preset `screen` + model fp32 / int8 theo kết luận `docs/spikes/ocr.md`.
- `Engine::load(models)`: đọc `manifest.toml`, kiểm sha256 + giấy phép TRƯỚC khi nạp, ánh xạ lỗi sang `OcrError`.
- `impl Recognizer for Engine`: nhận `RgbaImage`, trả chữ theo thứ tự đọc.
- `ocr_bench` thay cho CLI spike: `ocr_bench <thư mục> --bench chuẩn.tsv`, in CER + thời gian để so với báo cáo spike.

## 2. Không làm trong task này

Vòng stdin / stdout, thoát khi rảnh, tìm thư mục model (gd3_03). Không UI. Không huấn luyện model. Spike giữ nguyên trong `spikes/`.

## 2b–5

Viết lúc bắt đầu task. Soát bằng `-p fastcast-ocr` (luật làn, `fastcast/ROADMAP.md`).

## 6. Nghiệm thu

- Test đơn vị của spike (C1, C2 gd0_05) chạy lại xanh trong crate mới.
- `[opus-run]` `ocr_bench` trên bộ ảnh của spike: CER và thời gian không tệ hơn số trong `docs/spikes/ocr.md` quá 1 điểm phần trăm / 10 %.
- `cargo deny check licenses` xanh sau khi thêm `ort`.
- Log không có chữ đọc được, không có đường dẫn ảnh.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

`Cargo.lock`: gộp sau gd3_01; xung đột với làn khác ⇒ lấy bản `master` rồi `cargo build -p fastcast-ocr` sinh lại.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
