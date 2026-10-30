# gd3_05 — nguồn khung theo vùng (WGC, DXGI, ghép nhiều màn)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
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

## 2b–5

Viết lúc bắt đầu task. Toàn `[opus]`. **Riêng tư**: không chạy `--rect` trên màn thật của chủ dự án (session gd0_06 đã dặn), đường theo màn là `[owner-qa]`.

## 6. Nghiệm thu

- Test `compose::plan` xanh trên bố cục giả, gồm hai màn khác scale (pixel vật lý, không co).
- `[opus-run]` `source_probe` WGC cửa sổ thử: mã vạch đọc đủ, không lấy focus.
- `[owner-qa]` Theo `plan/_backlog.md` gạch `[gd0_06 · owner-qa]` bước 2–4: đúng vùng, có con trỏ, viền vàng WGC so với DXGI, vắt hai màn, 144 Hz. Kết quả chốt backend mặc định.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

Chủ dự án không nhận viền vàng ⇒ đổi mặc định sang DXGI, một dòng ở `source::open`.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
