---
paths:
  - "fastcast/crates/ocr/**"
  - "fastcast/spikes/ocr/**"
  - "fastcast/tools/fetch-ocr-models.*"
  - ".claude/worktrees/fastcast-*/crates/ocr/**"
  - "export-ocr.*"
---

# OCR của Fastcast — tích hợp trên máy mới

Model OCR không nằm trong git (78 MB, D-2: chỉ phát hành bản cài). Máy mới, OS mới: lấy gói model từ máy đã có rồi chạy
**một lệnh** `init-ocr`. Không phải sửa mã.

## OCR gồm gì

| Phần | Là gì | Ở đâu trong mã |
| --- | --- | --- |
| `fastcast-ocr` | exe con, UI bật khi cần, nói stdio, rảnh 60 s thì tự thoát | `fastcast/crates/ocr` (`src/main.rs` tìm thư mục model, `src/worker.rs` vòng stdio, `src/engine/` bộ dò + hai bộ đọc) |
| Model ONNX | PP-OCRv6 small (dò + đọc), VietOCR (đọc tiếng Việt), int8 lẫn fp32 | sổ sha256 `fastcast/spikes/ocr/results/manifest.int8-mix.toml` (`[[model]]`) |
| ONNX Runtime 1.31.1 | thư viện theo OS: `onnxruntime.dll` / `libonnxruntime.dylib` / `libonnxruntime.so`, bản chính thức của Microsoft | sổ trên, mục `[[runtime]]` (sha256 tệp thư viện); sha256 tệp nén ghim trong `fastcast/tools/fetch-ocr-models.sh` / `.ps1` |

Thư mục model (tên cố định) có `manifest.toml` (= sổ), `onnx/…`, thư viện ONNX Runtime, `onnxruntime-licenses/`.
`fastcast-ocr` soát sha256 từng tệp theo sổ trước khi nạp, lệch là từ chối ⇒ **không ký lại / sửa thư viện ONNX**.

## Model nằm đâu

| Bản | Thư mục model |
| --- | --- |
| Dựng / phát hành (mọi OS) | `fastcast/target/release/models` — `init-ocr` dựng ở đây; `build.sh` / `build.ps1` lấy từ đây |
| Dev `start.sh fastcast` / `start.ps1 fastcast` | mượn `fastcast/target/release/models` qua biến `FASTCAST_OCR_MODELS` (script tự đặt; chỉ bản debug / `--features dev-env` đọc biến này) |
| Windows đã cài | `<thư mục cài>\models\` cạnh `fastcast-ocr.exe` |
| macOS `.app` | `Fastcast.app/Contents/Resources/models/` |
| Linux `.deb` | `/opt/fastcast/models/`; exe build tay không có `models/` cạnh nó thì cũng mượn chỗ này |

## Lấy model trên máy mới

1. Ở máy đã có model (`fastcast/target/release/models` đầy đủ):

   ```bash
   bash export-ocr.sh          # macOS / Linux
   ```

   ```bash
   pwsh ./export-ocr.ps1       # Windows
   ```

   Ra `release/fastcast/fastcast-ocr-models.tar.gz` + `.sha256` (chỉ model, không kèm ONNX Runtime vì theo OS).
2. Chép **cả hai tệp** sang máy mới, đặt vào `fastcast/spikes/ocr/` (`.gitignore` đã chặn, không lọt vào git).
3. Ở máy mới, tại gốc workspace:

   ```bash
   bash fastcast/spikes/ocr/init-ocr.sh        # macOS / Linux
   ```

   ```bash
   pwsh fastcast/spikes/ocr/init-ocr.ps1       # Windows (pwsh chạy được cả trên macOS / Linux)
   ```

   Lệnh hỏi nguồn: gói `.tar.gz` (chưa giải nén) hoặc thư mục đã giải nén; Enter = gói cạnh script, không có thì thư mục đích
   đã có. Truyền đường dẫn làm đối số thì không hỏi. Các bước: soát `.sha256` của gói (nếu có) → giải nén vào
   `fastcast/target/release/models` → soát sha256 từng model theo sổ → tải ONNX Runtime đúng OS / kiến trúc, soát sha256 →
   in lệnh tiếp theo. Chạy lại bao nhiêu lần cũng được.

ONNX Runtime mới ghim cho Windows x64, macOS arm64, Linux x64. Kiến trúc khác (Linux arm64, Mac Intel, Windows arm64): thêm
nhánh vào `fetch-ocr-models.sh` / `.ps1` + mục `[[runtime]]` của sổ (sha256 đo từ bản phát hành chính thức).

Không có máy nào có model: dựng lại từ model gốc vnocr bằng Docker —
`pwsh fastcast/tools/fetch-ocr-models.ps1 -Vnocr <vnocr>/models -Out fastcast/target/release/models`
(hoặc `bash fastcast/tools/fetch-ocr-models.sh --out … --vnocr …`).

## Sau khi tích hợp

- Bản dev: `bash start.sh fastcast` / `pwsh start.ps1 fastcast` — in `model OCR: …` khi đã mượn được model.
- Bản cài: `bash build.sh` / `pwsh ./build.ps1`, chọn Fastcast. Có model thì không còn hậu tố `_draft` vì thiếu model
  (macOS còn cần `cargo-about` + `pwsh` hoặc `python3` cho trang giấy phép). Đóng gói từng OS:
  `fastcast/tools/build-macos.sh`, `fastcast/tools/build-deb.sh`, `fastcast/tools/build-installer.ps1` (đều soát sổ khi chép model).

## Kiểm OCR chạy được

Không mở cửa sổ, không chụp màn — đo trên bộ ảnh tổng hợp:

```bash
cd fastcast
cargo build --release -p fastcast-ocr --example ocr_bench
python3 -I spikes/ocr/linux-bench/gen_bench.py spikes/ocr/tools/gen-bench.ps1 out/bench
cargo run --release --manifest-path spikes/ocr/linux-bench/Cargo.toml -- out/bench
target/release/examples/ocr_bench out/bench --bench out/bench/truth.tsv --models target/release/models
```

Dòng cuối `TỔNG CER …`: trên Mac M5 Pro ra 0,92 % / 20 ảnh, đọc trung vị 1,7 s (06/11/2026). Windows có sẵn bộ ảnh GDI+:
`pwsh spikes/ocr/tools/gen-bench.ps1 -Out out/bench` rồi `pwsh tools/ocr-e2e.ps1 -Exe target/release/fastcast-ocr.exe -Models target/release/models -Bench out/bench`.
`cargo run --release --manifest-path spikes/ocr/linux-bench/…` sửa `spikes/ocr/linux-bench/Cargo.lock` thì trả lại bằng
`git -C fastcast checkout spikes/ocr/linux-bench/Cargo.lock`.

Qua UI thật: mở bản dev, gọi lệnh "Lấy chữ trong vùng" (`ocr_region`), kéo vùng có chữ.

## Bẫy

- Phiên ORT phải chỉ CPU (`with_auto_device(AutoDevicePolicy::PreferCPU)` trong `crates/ocr/src/engine/pipeline.rs`): crate `ort`
  mặc định chọn EP tự động, trên macOS gắn CoreML ⇒ ảnh 1080p ngốn ~7 GB RAM.
- Đổi bản ONNX Runtime: sửa cả sha tệp nén trong `fetch-ocr-models.*` lẫn sha thư viện trong `[[runtime]]` của sổ;
  `[[runtime]]` đứng trước `[[model]]`.
- macOS: không ký lại `libonnxruntime.dylib` (đổi tệp ⇒ lệch sổ). Khi có Developer ID phải ký với hardened runtime rồi cập nhật sha.
