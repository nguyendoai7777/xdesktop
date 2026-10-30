# gd3_05 — nguồn khung theo vùng (WGC, DXGI, ghép nhiều màn)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026, chờ kiểm tay C9) |
| Repo | fastcast |
| Cỡ | M — ~650 dòng |
| Phụ thuộc | gd3_01 |
| Quyết định áp dụng | F-3, F-7 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/video/src/source/{mod,wgc,dxgi,compose}.rs`; MỚI `crates/video/examples/source_probe.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `source/mod.rs` có `D3d`, `create_device`, `create_bgra` mã thật (giữ nguyên, gd3_04 dùng); stub `Source`, `open`, `monitors`, `wgc::WgcSource`, `dxgi::DxgiSource`, `compose::{Blit, plan}`.
- **Đổi so với spec**: `DxgiSource::new` thêm `cursor: bool` (tự vẽ con trỏ); `compose::plan` trả `Result<_, RecError>`, spike trả `String`. Vùng ngoài desktop: khuyên `DisplayChanged`, ghi mục 9.
- **Đã có**: `fastcast-capture` đã là phụ thuộc của `fastcast-video`, chỉ để dùng `geometry`; không gọi `xcap`.
- **Bẫy**: bỏ `println!` của spike (`wgc: viền vàng…`): stdout của `fastcast-rec` là giao thức ⇒ dùng `log`.

## 1. Làm gì

- `Source`, `WgcSource`, `DxgiSource`, `D3d`, `monitors()`: chuyển từ `spikes/video/src/capture.rs`.
- `compose::plan`: mỗi màn vùng chạm một nguồn, chép vào khung ghép cỡ vùng; khe để đen. Chuyển `compose_plan` cùng test (toạ độ âm, lệch dọc, chạm khe, ngoài desktop).
- `source::open(job, d3d)`: chọn backend. **Mặc định WGC** theo `plan/confirm.md` gạch gd0_06; `FASTCAST_REC_BACKEND=dxgi` đổi được để kiểm tay viền vàng Windows 10.
- DXGI: tự vẽ con trỏ (`GetCursorInfo` + hình con trỏ) khi `job.cursor`, dựng lại khi `DXGI_ERROR_ACCESS_LOST`.
- Đổi bố cục / độ phân giải màn giữa lúc quay ⇒ `RecError::DisplayChanged`, không dựng lại.
- `source_probe`: cửa sổ thử của spike (`testwin.rs`) + WGC theo cửa sổ, không quay màn người dùng.

## 2. Không làm trong task này

Encoder, vòng quay. Quay theo cửa sổ cho người dùng. macOS / Linux.

## 2b. Phân vai

Toàn `[opus]` (FFI, D3D, đa màn). `[owner-qa]`: đường theo màn. **Riêng tư**: không quay màn thật của chủ dự án (session gd0_06 đã dặn), không mở `for_monitor` / `DxgiSource` trên máy này.

## 3. Kiểu dữ liệu

- `Source::poll` giữ `windows::core::Result<bool>` như stub. Thêm `source::rec_error(&Error) -> RecError`: HRESULT riêng `DISPLAY_CHANGED` ⇒ `DisplayChanged`, còn lại ⇒ `CaptureLost`.
- `compose::plan`: vùng rỗng ⇒ `RegionTooSmall`, ngoài desktop ⇒ `DisplayChanged`.
- Biến môi trường: `FASTCAST_REC_BACKEND=wgc|dxgi`, `FASTCAST_REC_WINDOW=<hwnd>` (biến dev mà gd3_06, gd3_13 cần).

## 4. Code

`mod.rs`: `open`, `Watched` (soát bố cục mỗi 500 ms), `monitors`. `wgc.rs`, `dxgi.rs`: từ spike. `dxgi.rs` thêm `CursorLayer`: ảnh sạch + bản GDI-compatible, `DrawIconEx`. `examples/source_probe.rs`: cửa sổ thử + đọc mã vạch.

## 5. Đo

Không đo CPU / RAM (số chính thức ở gd3_13). Đọc khung: bảng C5.

## 6. Nghiệm thu

| Case | Cho | Khi | Thì | Phủ | KQ |
|---|---|---|---|---|---|
| C1 | Bố cục giả: một màn, toạ độ âm, lệch dọc, chạm khe, hai màn khác scale | `compose::plan` | Mảnh đúng pixel vật lý, không co, khe để trống | `[opus-unit]` | ✅ |
| C2 | Vùng ngoài desktop, vùng rỗng | `compose::plan` | `DisplayChanged`, `RegionTooSmall` | `[opus-unit]` | ✅ |
| C3 | `FASTCAST_REC_BACKEND` vắng, `wgc`, `dxgi`, giá trị lạ | `parse_backend` | Mặc định WGC, lạ cũng WGC | `[opus-unit]` | ✅ |
| C4 | Texture đen + mũi tên hệ thống, không chạm màn | `CursorLayer::present` | Vẽ đúng chỗ, con trỏ đổi mà ảnh không đổi thì xoá vết cũ, rời mảnh thì về ảnh sạch, không đổi thì `false` | `[opus-unit]` | ✅ |
| C5 | Cửa sổ thử 640 × 360 và 1280 × 720, 60 Hz | `source_probe` đi qua `source::open` | Mã vạch đọc đủ, không lùi, không lấy focus | `[opus-run]` | ✅ 174 / 180, 298 / 300, `bad=0`, `stole_focus=0` |
| C6 | Đang quay cửa sổ thử | `source_probe --resize` đổi cỡ | `DisplayChanged` | `[opus-run]` | ✅ sau ~50 ms |
| C7 | Bố cục khác lúc mở | `Watched::poll` | Chưa tới hạn soát: khung đi qua. Tới hạn: `DisplayChanged` | `[opus-unit]` | ✅ |
| C8 | `FASTCAST_REC_WINDOW` sai số, HWND không tồn tại | `open_window` | Lỗi, không rơi về quay màn | `[opus-unit]` | ✅ |
| C9 | Theo `plan/_backlog.md` gạch `[gd0_06 · owner-qa]` bước 2–4 và gạch `[gd3_05 · owner-qa]`: đúng vùng, có con trỏ, viền vàng WGC so với DXGI, vắt hai màn, 144 Hz | Chủ dự án quay màn thật | Kết quả chốt backend mặc định | `[owner-qa]` | chờ kiểm tay |

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

Chủ dự án không nhận viền vàng ⇒ đổi mặc định sang DXGI, một dòng ở `source::parse_backend`.

gd3_13: "`fastcast-rec` thật quay cửa sổ thử" dùng `FASTCAST_REC_WINDOW` + `source_probe --serve`, cách dùng ở `plan/gd3_06_rec-worker.md` mục 0.

## 9. Bàn giao thực tế

**Soát** (`-p fastcast-video`, cwd worktree): `clippy --all-targets -D warnings` xanh, `cargo test` 14 test xanh, `cargo deny check licenses` ok.

**Chạy thật** (`source_probe` bản release, chỉ cửa sổ thử, máy đang bận các làn khác): 640 × 360 trong 3 s `distinct=174 / rendered=180`; 1280 × 720 trong 5 s `distinct=298 / rendered=300`; `bad=0 backwards=0 stole_focus=0`. `--resize`: `DisplayChanged` ~50 ms sau khi đổi cỡ. WGC cửa sổ đưa khung ~140 lần / s dù cửa sổ vẽ 60 Hz ⇒ vòng quay không được coi `poll == true` là có ảnh mới.

**Chưa chạy lần nào, chỉ biên dịch + test phần thuần**: `WgcSource::for_monitor`, `DxgiSource` (acquire, dựng lại khi `ACCESS_LOST`), `Watched` khi rút màn thật. Đường theo màn là `[owner-qa]` (C9); phần vẽ con trỏ của DXGI đã phủ riêng bằng C4.

**Opus chọn 30/10/2026** (đều ở `plan/confirm.md`):

- Vùng ngoài desktop ⇒ `DisplayChanged`, theo khuyên của gd3_01.
- `poll` giữ kiểu `windows::Result`, thêm `rec_error`: không đổi hợp đồng gd3_01 mà gd3_06 đang chờ.
- DXGI không mở được một màn ⇒ màn đó dùng WGC.
- Thêm `FASTCAST_REC_WINDOW`, `source_probe --serve`: gd3_06 mục 6 ghi "biến dev của gd3_05", spec task này chưa nêu.
- Vẽ con trỏ bằng GDI, soát bố cục mỗi 500 ms.

**Giới hạn đã biết của con trỏ DXGI**: con trỏ động đứng ở khung đầu; trên màn DPI khác DPI hệ thống, cỡ con trỏ có thể lệch so với thật. Thêm hai texture cỡ vùng trên GPU, chỉ khi DXGI + bật con trỏ. Đo được khi kiểm tay.

**Đề xuất đã làm**: `open_window` báo lỗi rõ khi HWND sai, thay vì rơi về quay màn (C8). Siết `source_probe` từ "đã đọc" sang "khung khác nhau ≥ 90 % số vẽ".

**Chờ kiểm tay**: C9, ghi ở `plan/_backlog.md`.

## 10. Đề xuất cải tiến

- `[bảo mật]` `FASTCAST_REC_WINDOW` có hiệu lực ở bản release (`source/mod.rs`, `open`) — đề xuất: gd3_13 đo xong thì chỉ cho bản debug hoặc đi cùng biến chạy thử — giá trị: bớt một đường quay cửa sổ tuỳ ý, thấp vì kẻ đặt được biến môi trường đã chạy được mã — cỡ S — P3. Không làm trong lượt: gd3_06, gd3_13 cần nó ở bản release để đo; chung việc với đề xuất `exe_path` của gd3_01, đã ghi `plan/_backlog.md`.
- Lăng kính UI/UX, Pro: không áp, task không có giao diện. RAM: số đo thuộc gd3_13.
