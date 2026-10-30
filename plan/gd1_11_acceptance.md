# gd1_11 — Nghiệm thu GĐ1 (Windows)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay; GĐ1 CHƯA đóng |
| Repo | fastcast |
| Cỡ | S — đo + báo cáo, sửa lỗi nhỏ phát hiện được |
| Phụ thuộc | gd1_01 → gd1_10 |
| Quyết định áp dụng | F-1 → F-5, F-8, D-3 |
| Phụ thuộc mới | — |
| File đụng tới | `fastcast/docs/gd1-report.md` MỚI · `fastcast/ROADMAP.md` SỬA (mục bàn giao GĐ1) |

## 0. Bàn giao từ gd1_09 (30/10/2026)

<!-- handoff: gd1_09 -->

- **Đã có sẵn để dùng**: lấy màu ở `overlay/picker.rs`; log `picker: first frame on <n> monitor(s) in <ms>`, `picker: monitor <i>
  rendered <n> times`; `FASTCAST_OVERLAY_FAKE` + `FASTCAST_OVERLAY_SCRIPT` chạy được với `--command color_picker`.
- **Đổi so với lúc viết spec này**: `#1E90FF` = `oklch(0.652 0.19 253.2)`.
- **Nợ chuyển sang đây**: gom kiểm tay C14 (`plan/gd1_09_color-picker.md` mục 6) vào danh sách; thêm RAM + khung đầu của lấy màu vào
  bảng số đo (task chưa đo, bản debug không tính).
- **Bẫy đã gặp**: `color_picker` giờ mở overlay thật ⇒ test / lệnh thử không có `FASTCAST_OVERLAY_FAKE` là chụp màn thật.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test picker`.

## 0. Bàn giao từ gd1_10 (30/10/2026)

<!-- handoff: gd1_10 -->

- **Đã có sẵn để dùng**: `overlay/render_mode.rs`; log `overlay: render mode …` cho biết adapter + chế độ; `overlay: monitor <i>
  rendered <n> times` khi đóng; `FASTCAST_OVERLAY_RENDER=light|full`; `FASTCAST_OVERLAY_FAKE=1080p-offscreen`.
- **Đổi so với lúc viết spec này**: `OverlayView` không đọc phiên trong `render` (giữ `visible`); viền vùng chọn là bốn thanh
  cho cả hai chế độ. Chế độ nhẹ: nền tối nửa độ phân giải, 25 fps ở 1080p, tới 10 fps ở 4K.
- **Nợ chuyển sang đây**: gom kiểm tay RDP (`plan/gd1_10_light-overlay.md` C7) vào báo cáo; ghi số CPU 0,90 nhân là của WARP ép,
  chưa có RDP thật, chưa đo 1440p / 4K.
- **Bẫy đã gặp**: cửa sổ đủ cỡ lớn hơn màn thật có thể bị OS kẹp ⇒ số đo 4K giả không tin được. Chụp PrintWindow bằng bản
  release: bản debug mở console và giành focus.
- **Soát lại khi làm**: lệnh đo WARP ở `fastcast/CLAUDE.md`, trả lại `Cargo.lock` sau khi đo; đo lại lúc máy rảnh RAM sau khi nhả
  GPU trên GPU thật (12–13 MB so với 9,1–9,6 MB ở gd1_02, chưa truy nguyên).

## 1. Làm gì

- Chạy lại toàn bộ luồng GĐ1 trên bản release, máy nhà Windows 2 màn (DELL 60 Hz + LG 144 Hz), thêm một lượt đặt một
  màn scale 125 % hoặc 150 %.
- Bảng số đo: RAM daemon nghỉ, RAM UI giữ ấm không cửa sổ, RAM UI khi overlay mở / launcher mở; độ trễ phím tắt →
  overlay và Alt+Space → launcher (nguội / ấm); CPU khi kéo (GPU thật / WARP).
- Danh sách kiểm tay cho chủ dự án (`[owner-qa]`) gom từ mục 6 các task GĐ1, kèm bước làm.
- Kiểm `fst autostart on` + khởi động lại máy (GĐ0 T3 còn treo) cùng lượt này.

## 2. Không làm trong task này

- macOS / Ubuntu (GĐ4, sau gd0_07).

## 2b. Phân vai

| Phần việc | Vai |
| --- | --- |
| Đo trên bản release, màn giả + `fake_daemon`; truy RAM sau khi nhả GPU; viết báo cáo + danh sách | `[opus]` (không giao Sonnet: phần đo phụ thuộc đọc số liền tay) |
| Phím tắt thật, overlay thật, 2 màn khác Hz / scale, dán thật, autostart + khởi động lại, RDP, nền mờ | `[owner-qa]` |

## 5. Đo

Như mục 1 — so với spike (`materiant/docs/spikes/ui-foundation.md` mục 2) và với GĐ0 (daemon 1,1 MB).

## 6. Nghiệm thu — Case test

| Case | Cho / Khi / Thì | Phủ | Kết quả |
| --- | --- | --- | --- |
| C1 | Bản release, màn giả: RAM UI giữ ấm, overlay / launcher / thước / lấy màu mở; khung đầu nguội / ấm | `[opus-run]` `tests/measure.rs` | ✅ có số; độ trễ đo lúc máy bận |
| C2 | CPU khi kéo: GPU thật, WARP ép | `[opus-run]` `tests/overlay.rs` | ✅ 0,03–0,07 / 0,90–1,08 nhân |
| C3 | RAM daemon nghỉ, không đăng ký phím thật | `[opus-run]` bản `isolated` | ✅ 1,08–1,12 MB |
| C4 | Truy RAM sau khi nhả GPU 12–13 so với 9,1–9,6 MB | `[opus-run]` `measure_release_curve` | ✅ trả dần, ổn định 8,3–8,8 MB, không rò |
| C5 | Báo cáo `fastcast/docs/gd1-report.md`: bảng số đo, lỗi còn lại, danh sách kiểm tay một lượt | `[opus]` | ✅ |
| C6 | Độ trễ phím thật → overlay, Alt+Space → launcher (nguội / ấm) | `[owner-qa]` A3, A4, A11 | chờ kiểm tay |
| C7 | Không lỗi chặn ở luồng chụp → lưu / chép trên 2 màn khác Hz và khác scale | `[owner-qa]` lượt A + B | **chưa xác nhận** |
| C8 | `fst autostart on` + khởi động lại; RDP thật; nền mờ; dán thật | `[owner-qa]` lượt D, C, A14, A10 | chờ kiểm tay |

## 8. Nợ chuyển task khác

Chủ dự án kiểm xong danh sách ⇒ `close-phase` GĐ1 fastcast (session này KHÔNG gọi).

## 9. Bàn giao thực tế

Xong phần Claude làm được 30/10/2026 — fastcast `65c5b17` (nhánh `claude/gd1_11`, đã gộp, đã gỡ worktree, đã xoá thư mục build).

- **Đầu ra**: `fastcast/docs/gd1-report.md` (số đo, truy RAM, **danh sách kiểm tay mục 4**, lỗi còn lại); `fastcast/ROADMAP.md` mục "Bàn giao
  GĐ1"; `crates/ui/tests/measure.rs` (bài đo `--ignored`); `tests/common` thêm `FASTCAST_UI_EXE`, `ram_mb` / `cpu_ms` / `private_mb`,
  `wait_line_within`; `measure_overlay_ram_and_drag_cpu` đọc RAM sau khi nhả GPU ở +10 s; `CLAUDE.md` thêm lệnh + bẫy đọc RAM. Không đổi mã
  sản phẩm.
- **Số chính** (chi tiết báo cáo mục 2): daemon 1,08–1,12 MB; UI giữ ấm 5,7–5,8 MB chưa dùng, 8,3–8,9 MB sau khi dùng overlay; overlay mở 2 màn
  1080p 50–52 MB; thước, lấy màu cùng mức; launcher 14 MB; khung đầu overlay nguội 407–484 ms, ấm 52–70 ms, đã nhả GPU 205–330 ms (lượt
  đỡ bận nhất, chưa gồm chụp ~57 ms); CPU kéo 0,03–0,07 nhân GPU, 0,90–1,08 nhân WARP.
- **Truy RAM**: 9 / 12–13 MB không phải mức tăng. Bộ nhớ được trả dần tới 5–7 s sau `gpu released`, private bytes 56–141 → 17 MB; bài đo cũ đọc ở
  +0,5 s chạy lại cho 10,5–28,6 MB trên cùng code. `[gd1_06 · ram]` 7,3 MB cũng do đọc sớm: ổn định 5,6–5,9 MB. Thành phần trả trễ chưa xác
  định, không sửa.
- **Số đo KHÔNG sạch**: spike OCR + build session khác chạy xen kẽ (CPU 50–90 %). RAM ổn định giữa các lượt; độ trễ dao động rộng, báo cáo ghi
  cả "tốt nhất" và "mọi lượt". Số độ trễ cuối lấy từ kiểm tay. Đo trên `e5d3fe7`, đo lại overlay + launcher trên `e5dedbf` (icon F-11);
  nền khối nổi D-10 gộp sau, chưa đo.
- **Không chạy theo lệnh session điều phối**: overlay thật, `fst` thật, phím thật, autostart, đổi scale, RDP ⇒ danh sách mục 4 của báo cáo.
- **Soát** (worktree, target riêng, sau khi gộp master `bf1a991`): `cargo build`, `clippy --all-targets -D warnings`, `cargo test` (capture 11, core
  54, daemon 23, ui 130 + ipc 5 + overlay 14 + picker 6), `cargo deny check licenses`, `cargo fmt --check` — xanh. Một lượt trước đó 4 test
  `tests/picker.rs` đỏ lúc máy bận, chạy lại xanh (không gặp lại, chưa có bằng chứng là lỗi thật).
- **Lỗi nhỏ sửa**: không có lỗi sản phẩm. Bài đo tự viết từng trùng tên pipe giữa các vòng ⇒ tên theo vòng.
- **An toàn máy**: chỉ màn giả + `fake_daemon` + bản `isolated` (icon khay hiện trong lúc đo daemon, không đăng ký phím, không đụng cấu hình).
  Không chép ảnh vào clipboard thật, không đo lại `measure-clipboard`. `Cargo.lock` đã trả lại sau khi đo WARP. Bài đo mở cửa sổ màn giả nhỏ, không
  kích hoạt, ở góc màn chính (cả lúc chủ dự án có thể đang dùng máy), không kiểm tra `foreground_unchanged` riêng trong lượt này.
- **Opus chọn 30/10/2026** (`plan/confirm.md`): báo cáo GĐ1 đặt tiêu chí chính "chưa xác nhận"; đo bằng bài test `--ignored` chạy exe `--bin`.

## 10. Đề xuất cải tiến

- [ux] GPUI ghi mức ERROR `Invalid window handle. (0x80070578)` mỗi lần đóng overlay — 33 dòng trong một lượt đo, làm rối `ui.log` khi chủ dự án đọc
  log kiểm tay — khả nghi `gpui-pre-windows` `window.rs:627`, cần vá crate ngoài hoặc lọc log — sạch log — S — P3. **Chưa làm**: chưa kiểm gốc,
  không ảnh hưởng hành vi ⇒ `_backlog.md`.
- [ram] ~3 MB còn lại sau khi dùng overlay so với lúc chưa dùng — báo cáo mục 3 — đo sâu GPUI / DirectWrite — P3, M. Đã có trong `_backlog.md`
  (sửa lại số).
- [ux] Độ trễ phím → overlay chỉ đo được bằng log `first frame`, không tính phần phím → daemon; log daemon chỉ chính xác tới giây — đo đầu cuối
  thật cần ghi `ms` vào log — S — P3. **Chưa làm**: IPC đã đo 0,05–0,13 ms; chờ số kiểm tay xem có cần không.
- [bảo mật] Không áp: task không đổi mã sản phẩm. Soát: bài đo dùng cấu hình tạm (`tests/common`), không ghi ảnh ra ngoài thư mục tạm.
- [pro] Không thêm: task nghiệm thu, các chỗ Pro đã ghi ở `ROADMAP.md` GĐ4.
