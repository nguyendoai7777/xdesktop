# gd3_02 — engine OCR trong `crates/ocr`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~800 dòng, phần lớn chuyển từ spike |
| Phụ thuộc | gd3_01, gd0_05 |
| Quyết định áp dụng | F-6, D-2, F-4 |
| Phụ thuộc mới | `ort` =2.0.0-rc.15 `load-dynamic` (MIT / Apache-2.0), `ndarray`, `sha2`, `toml` — bản ghim theo `fastcast/spikes/ocr/Cargo.toml` sau gd0_05 |
| File đụng tới | MỚI `crates/ocr/src/engine/{det,rec,paddle,imgops,manifest,pipeline}.rs`, `crates/ocr/examples/ocr_bench.rs`; SỬA `crates/ocr/src/engine/mod.rs`, `crates/ocr/Cargo.toml`, `Cargo.lock` |

## 0. Bàn giao từ gd0_05 (30/10/2026)

<!-- handoff: gd0_05 -->

- **Đã có sẵn để dùng**: mã `fastcast/spikes/ocr/src/*` (42 test, chuyển theo được C1, C2), bộ ảnh `spikes/ocr/tools/gen-bench.ps1` (sinh lại giống từng byte), model `spikes/ocr/tools/quantize.py <models> <đích> mix` (Docker, giống từng byte, sha256 ở `spikes/ocr/results/manifest.int8-mix.toml`). Số so sánh: `docs/spikes/ocr.md`, thô ở `spikes/ocr/results/final/`.
- **Đổi so với spec — quan trọng**: cấu hình chốt là **lai**, nên **GIỮ `paddle.rs`** và nhánh `Hybrid` + `looks_like_code` (`pipeline.rs`); thêm `paddle.rs` vào tệp của task này. Bỏ được: `LineReader::VietOcr` / `Paddle` đứng riêng, preset `scene`, cờ đảo màu bộ dò, `Order::Scene`, cờ arena, `split_points` nhánh khe ≥ 0,2.
- **Tham số chốt**: det `PP-OCRv6_small_det` int8 · Paddle `PP-OCRv6_small_rec` **fp32** · VietOCR `vietocr-vgg_transformer-vn8a30` int8 · `with_arena_allocator(false)` + `with_memory_pattern(false)` · 4 luồng · batch 16 · không thu ảnh · đảo màu từng dòng chỉ ở bộ đọc · phóng ×2 khi trung vị hộp < 15 px và vùng ≤ 1 megapixel · cắt dòng dài ở khe rộng nhất · thứ tự `Rows`. Đừng int8 bộ đọc Paddle: WER `code` 8,30 ⇒ 15,24.
- **Mốc so trong `ocr_bench`**: CER 2,45 % (26 ảnh) · 0,86 % (12 ca khó). **Thời gian** spike đo lúc máy bận (nhiễu 2–5 lần): dùng số 11,0 s / 1,2 s làm trần thô, đừng coi đỏ nếu chỉ thời gian lệch mà máy đang bận; đo lại khi rảnh rồi mới kết luận.
- **Bẫy**: nạp đúng `onnxruntime.dll` bằng đường dẫn tuyệt đối (`ort::init_from`), không theo `PATH`, Windows có bản cũ ở System32. Giữ `with_telemetry(false)`: bản ONNX Runtime chính thức có thu thập dữ liệu. `Store::open` soát sha256 của đúng model đang nạp (~400 ms) ngay cả ở bản phát hành. Build `load-dynamic` không tải gì lúc build, test engine thật cần dll + model nên để `#[ignore]` hoặc ở `ocr_bench`.
- **Soát lại khi làm**: `cargo deny check licenses` sau khi thêm `ort`; `ocr_bench <bench> --bench <bench>/truth.tsv` và `<bench>/hard`; log không có chữ đọc được.

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `crates/ocr/src/lib.rs` (`Recognizer`, re-export `RgbaImage`, `OcrError`), stub `engine/mod.rs` (`Engine::load`, `impl Recognizer`). `image` 0.25 đã khai trong `crates/ocr/Cargo.toml`, không codec: spike cần `png` / `jpeg` thì bật feature khi thêm `ort`.
- **Đổi so với spec**: `crates/ocr` có `[lib] fastcast_ocr` + `[[bin]] fastcast-ocr`.
- **Soát lại khi làm**: `cargo clippy -p fastcast-ocr --all-targets -- -D warnings`, `cargo test -p fastcast-ocr`, `cargo deny check licenses`. Chi tiết: `plan/gd3_01_contracts.md` mục 9.

## 1. Làm gì

- Chuyển `spikes/ocr/src/{det,rec,paddle,imgops,manifest,pipeline}.rs` sang `engine/`, bỏ nhánh chỉ phục vụ đo (cờ đảo màu bộ dò, preset `scene`), chỉ giữ preset `screen` + cấu hình lai theo kết luận `docs/spikes/ocr.md`.
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
