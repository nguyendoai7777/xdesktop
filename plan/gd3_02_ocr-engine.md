# gd3_02 — engine OCR trong `crates/ocr`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~800 dòng, phần lớn chuyển từ spike |
| Phụ thuộc | gd3_01, gd0_05 |
| Quyết định áp dụng | F-6, D-2, F-4 |
| Phụ thuộc mới | `ort` =2.0.0-rc.15 `load-dynamic` (MIT / Apache-2.0), `ndarray`, `sha2`, `toml` — bản ghim theo `fastcast/spikes/ocr/Cargo.toml` sau gd0_05 |
| File đụng tới | MỚI `crates/ocr/src/engine/{det,rec,paddle,imgops,manifest,pipeline}.rs`, `crates/ocr/examples/ocr_bench.rs`; SỬA `crates/ocr/src/engine/mod.rs`, `crates/ocr/Cargo.toml`, `Cargo.lock` |

## 0. Bàn giao từ gd3_03 (30/10/2026)

<!-- handoff: gd3_03 -->

- **Đã có sẵn để dùng**: `crates/ocr/src/{main,worker}.rs` đã xong, `Engine` chỉ cần giữ chữ ký `load(&Path)` + `impl Recognizer`. Bộ model + dll dựng sẵn ở `C:/xdesktop-target/ocr-models`, đã khớp sổ, không cần Docker.
- **Đổi so với spike**: dll nạp từ `<models>/onnxruntime.dll`, không cạnh exe. Sổ là `<models>/manifest.toml`. `main.rs` đã soát thiếu manifest (`ModelMissing`) và thiếu dll (`RuntimeMissing`) trước khi gọi `Engine::load`; dll hỏng, sha256, giấy phép là phần của engine.
- **Nợ chuyển sang đây** (gd3_03 mục 6 C13, luật "làn gộp sau chạy"): sau khi gộp `master` vào nhánh, chạy
  `cargo build --release -p fastcast-ocr` rồi `pwsh tools/ocr-e2e.ps1 -Exe <target>/release/fastcast-ocr.exe -Models C:/xdesktop-target/ocr-models -Bench <thư mục>`, thêm một lượt `-IdleExit`. Ghi `Ready`, RAM đỉnh, thời gian từng ảnh vào mục 9 của `plan/gd3_03_ocr-worker.md` và của task này. Kỳ vọng ở mục 0 gd3_03.
- **Bẫy**: script mới thử với `fake_ocr`, lần đầu với engine thật có thể phải sửa. Ngưỡng 90 % là tỉ lệ từ, không phải CER; `-MinMatch` chỉnh được, đừng hạ để qua mà không ghi lý do.
- **Bẫy**: ảnh đã bị xoá trước `read`, và worker không đặt hạn đọc. Engine panic ⇒ tiến trình chết, UI thấy "worker died", nên lỗi đọc được thì trả `Err`, đừng `unwrap`.

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

## 2b. Phân vai

Toàn bộ `[opus]`: chuyển thuật toán + FFI nạp runtime, không có phần ghép UI để giao. Không `[owner-qa]`: ảnh chụp thật vẫn là C8 của gd0_05 (`plan/_backlog.md`).

## 3. Kiểu dữ liệu

`Engine::load(models)`: thư mục `models` chứa `manifest.toml`, `onnx/…` và `onnxruntime.dll` (`libonnxruntime.so` / `.dylib`). Ánh xạ lỗi:

| Tình huống | `OcrError` |
|---|---|
| Thiếu sổ / thiếu tệp model (thắng lỗi khác, vì chép lại là gỡ được) | `ModelMissing` |
| Sai sha256, giấy phép ngoài danh sách, sổ hỏng, sổ không có model cần | `ModelCorrupt` |
| Thiếu dll / dll không nạp được | `RuntimeMissing` |
| Ảnh rỗng (0 × n) | `ImageUnreadable` |
| Dựng phiên, chạy model lỗi sau khi đã qua soát | `Internal` |

## 4. Code

Chuyển từ spike, bỏ nhánh đo: `scene`, `det_invert`, `Order::Scene`, `LineReader::{VietOcr, Paddle}`, cờ arena, nhánh khe ≥ 0,2 của `split_points`, `conf`, `resize_area`, `is_dark_page`. Tham số thành hằng trong `pipeline.rs`. Thứ tự nạp: soát sổ ⇒ nạp dll ⇒ dựng phiên. Điểm số nằm trong `examples/ocr_bench.rs`, không vào crate phát hành. Codec `png` / `jpeg` chỉ ở `dev-dependencies`: worker nhận RGBA thô.

## 5. Đo

`ocr_bench` bản release, 26 ảnh + 12 ca khó của `gen-bench.ps1`, so `docs/spikes/ocr.md`. RAM + `Ready` nguội thuộc gd3_03, số chính thức thuộc gd3_13.

## 6. Nghiệm thu

Soát bằng `-p fastcast-ocr` (luật làn, `fastcast/ROADMAP.md`).

- **C1** `[opus-unit]` Cho sổ có model sai sha256 / thiếu tệp / giấy phép ngoài danh sách. Khi `Store::open` / `Engine::load`. Thì lỗi đúng mã ở mục 3, không nạp runtime.
- **C2** `[opus-unit]` Cho hàm thuần của spike (hình chữ nhật bao nhỏ nhất, resize kiểu PIL, cắt dòng rộng, Levenshtein, chọn đảo màu, thứ tự đọc). Thì đúng ca biên, chạy lại trong crate mới.
- **C3** `[opus-unit]` Cho ảnh rỗng, dll rác, thư mục không có dll. Khi nạp / đọc. Thì `ImageUnreadable` / `RuntimeMissing`, không panic (bản phát hành `panic = "abort"`).
- **C4** `[opus-run]` Cho 26 ảnh + 12 ca khó. Khi `ocr_bench <thư mục> --bench chuẩn.tsv`. Thì CER không tệ hơn 2,45 % / 0,86 % quá 1 điểm phần trăm, thời gian không tệ hơn 11,0 s / 1,2 s quá 10 % (máy bận ⇒ đo lại khi rảnh).
- **C5** `[opus-run]` `cargo deny check licenses` xanh sau khi thêm `ort`.
- **C6** `[opus-run]` Log của lượt C4 không có chữ đọc được, không có đường dẫn ảnh.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

`Cargo.lock`: gộp sau gd3_01; xung đột với làn khác ⇒ lấy bản `master` rồi `cargo build -p fastcast-ocr` sinh lại.

## 9. Bàn giao thực tế

- **Kết quả**: C1–C6 xanh. `cargo test -p fastcast-ocr`: 44 test engine + 6 test chấm điểm + 17 test worker. `cargo clippy -p fastcast-ocr --all-targets -- -D warnings`, `cargo deny check licenses` xanh. Soát theo luật làn engine, không build GPUI.
- **C4, `ocr_bench` bản release, vẫn có session khác chạy song song**: 26 ảnh CER 2,45 % · WER 2,86 % · trung vị 7,2 s (mốc 11,0 s). 12 ca khó CER 0,86 % · WER 2,81 % · trung vị 1,03 s (mốc 1,2 s). Chữ đọc được của 26 ảnh **trùng từng byte** với `spikes/ocr/results/final/full-mix-noarena.tsv`, tức mã chuyển sang không đổi kết quả. Thời gian đo được nhanh hơn mốc vì mốc đo lúc máy bận; số chính thức vẫn ở gd3_13. Nạp engine ~850 ms.
- **C6**: stderr lượt C4 rỗng, engine chỉ ghi log khi lỗi; log lỗi có đường dẫn model / dll, không có chữ, không có đường dẫn ảnh.
- **C13 của gd3_03, chạy lúc gộp sau `claude/gd3_03`** (`tools/ocr-e2e.ps1`, bản release, cả `-IdleExit`): xanh, script chạy được với engine thật không phải sửa. `Ready` 942 ms (lần đầu sau khi model chưa vào cache đĩa 5982 ms) · RAM đỉnh 343–365 MB · ba ảnh 4,9 / 8,5–8,7 / 8,0 s · khớp từ 91,6 / 100 / 99,6 % · thoát mã 0 sau 31 ms khi đóng stdin, sau 60034 ms khi rảnh · không sót tệp trong `tmp/`.
- **Thử thêm trên engine thật, không panic**: ảnh 1×1, 3×400, 400×3, 8000×20, 20×8000, 200×200, 5000×5000 (11,4 s), toàn đen, ~3000 cụm chữ nhỏ (17,1 s). Dll stub 2,8 KB của System32 ⇒ `RuntimeMissing`.
- **Đổi so với spec**: `paddle.rs` giữ lại theo gd0_05. Thêm `serde`, `serde_json` (đã có trong cây qua `core`), `toml` dùng bản 1 như `core` thay vì 0.9 của spike nên không thêm bản trùng. Vượt trần "≤ 2 crate": task đã liệt kê sẵn, đều là mã chuyển từ spike.
- **Opus chọn 30/10/2026** (`plan/confirm.md`):
  - Có tệp thiếu thì báo `ModelMissing` kể cả khi tệp khác sai: thiếu tệp gỡ được bằng cách chép lại.
  - Sổ không có model cần ⇒ `ModelCorrupt`; dựng phiên lỗi sau khi sha256 đã khớp ⇒ `Internal`.
  - Soát sổ trước khi nạp dll, ngược spike: task ghi "kiểm TRƯỚC khi nạp".
  - Codec ảnh chỉ ở `dev-dependencies`: exe phát hành nhận RGBA thô, không có mã giải mã PNG / JPEG.
- **Sửa khi soi**: `decode` của VietOCR đưa nguyên chuỗi `<pad>` / `<sos>` vào chữ cho người dùng khi model sinh mã đó, và trừ tràn nếu gặp mã 2 khi `eos` khác 2 ⇒ bỏ hai mã này, dùng `checked_sub`, thêm test. Bench không có ca nào chứa chúng nên số đo không đổi (12 ca khó đo lại vẫn 0,86 %).
- **Soi 4 lăng kính**: bảo mật — telemetry tắt, dll nạp đường dẫn tuyệt đối, sổ soát trước, không ghi chữ; dll không có sha256 trong sổ, xem mục 10. UI/UX — không áp, mã lỗi đã đủ để gd3_09 báo. RAM — phụ thuộc mới chỉ vào `fastcast-ocr`, `core` / `daemon` không đổi; số đỉnh ở trên. Pro — không áp cho engine.

## 10. Đề xuất cải tiến

- `[bảo mật]` `onnxruntime.dll` không có trong sổ sha256 — `engine/mod.rs` chỉ soát model — đưa dll vào `manifest.toml` khi GĐ4 đóng gói — chống dll bị tráo trong thư mục cài, nhưng ghi được vào đó thì đã thay được cả exe — S — P3. Chưa làm: sổ sinh bởi `quantize.py` + bản cài thuộc GĐ4, ghi `plan/_backlog.md`.
- `[ux]` Sổ `spikes/ocr/results/manifest.int8-mix.toml` ghi nhãn `+int8-all` và "(all)", Paddle trong đó thực ra fp32 — sha256 vẫn đúng — sửa nhãn khi GĐ4 làm trang giấy phép — tránh ghi sai lên trang giấy phép — S — P3. Chưa làm: ngoài tệp của làn, sửa sẽ lệch sổ `C:/xdesktop-target/ocr-models` đang dùng chung, ghi `plan/_backlog.md`.
