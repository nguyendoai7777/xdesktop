# Backlog — việc treo không làm được trong lượt

Mỗi gạch một việc + LÝ DO chưa làm được (thiếu máy, dịch vụ trả phí, chờ quyết định — D-8: đề xuất đã xác nhận thì làm
ngay, không vào đây). Có task thì trỏ tới tệp task, đừng chép lại. `run-task` mục 5, `close-phase` mục 3 ghi thêm.

## fastcast

- **[gd3_13 · owner-qa] Kiểm tay GĐ3 — một danh sách, `fastcast/docs/gd3-report.md` mục 4** (gồm gd3_06 C15, gd3_07 C6, gd3_05 DXGI, gd0_05 C8, gd0_06 C8–C11, gd3_09–12) — lý do: máy dùng thật, session không quay / chụp màn, không mở micro. Xong thì xoá các gạch `owner-qa` đó; `close-phase` GĐ3 khi GĐ1, GĐ2 cũng xong.
- **[gd4_18 · lỗi test] `real_ocr` (`tests/measure.rs`) đỏ 1 / 4 lần lúc máy rảnh** — panic `common/mod.rs:103` hết 20 s chờ log; tên dòng log mất vì bộ lọc của lượt đo. Bài `--ignored`, không nằm trong bốn lệnh soát. Lý do treo: 3 lần sau xanh, chưa tái hiện; lần sau đỏ giữ nguyên log.
- **[gd4_18 · ram] Lấy màu mở lần hai 59,3–59,7 MB, lần đầu 50,4 MB** — về 8,4–8,7 MB sau nhả GPU, không rò; P3, chưa truy.
- **[gd4_18 · owner-qa] Kiểm tay GĐ4 — MỘT danh sách, `fastcast/docs/gd4-report.md` mục 4** (W, V, T, X, rồi M, U trên máy tương ứng). Gom các gạch `owner-qa` gd4_02 → gd4_19 và trỏ tới danh sách GĐ1, GĐ2, GĐ3. Xong thì xoá các gạch đó; `close-phase` theo thứ tự GĐ1 → GĐ4. Chưa làm vì thiếu máy: `gd0_07`, `gd4_14`–`17`.
- **[gd3_13 · ux] Đọc cả màn đầy chữ 8–21 s**: thử giới hạn luồng / lô nhận dạng, báo tiến độ trên panel — lý do: phải đo lại CER lúc máy rảnh, GĐ4 đang chạy. `plan/gd3_13_acceptance.md` mục 10.
- **[gd3_13 · gd4_18 · ram] UI đang quay 3,4 ms CPU / s, không đồng hồ 1,5 ms / s lúc rảnh** (11–26 ms trước đây là số lúc bận): P3, không đáng soi tiếp trừ khi chủ dự án thấy cần.

- **[gd4_02 · owner-qa] Tự khởi động + toast lỗi** — lý do: máy nhà không chạy `fst` thật, không khởi động lại máy. Đổi trễ ở Cài đặt → Chung, bật tự khởi động, khởi động lại máy: daemon lên sau đúng độ trễ. Đặt `config.json` chỉ đọc, đổi cỡ chữ: thấy toast lỗi, ô trả về số cũ.
- **[gd4_13 · owner-qa] Icon khay ẩn khi mở `.app` qua `open` trên macOS 26** — lý do: mục của khay được tạo (x = 1012, 38 điểm) nhưng không lên màn; chạy thẳng `Contents/MacOS/fst` thì hiện đúng. Nghi cài đặt System Settings → Menu Bar → Allow in the Menu Bar đang tắt cho fastcast, chưa xác nhận. Đã có quyền ghi màn (31/10/2026): `cargo test -p fastcast-video --test macos -- --ignored --test-threads=1` đạt 3/3, phần nghe, xem file bằng QuickTime vẫn chờ tay.
- **[gd4_12 · owner-qa] Quay thật + OCR trên Mac** — lý do: thiếu quyền Screen Recording, Mac không có model. Đã chạy: writer, mọi test không cần quyền. Bước quay: Cài đặt hệ thống → Quyền riêng tư và bảo mật → Ghi màn hình, bật cho app chạy lệnh, mở lại app đó; `cargo test -p fastcast-video --test macos -- --ignored --test-threads=1`; quay thật, mở QuickTime; đo 720p30 (CPU, `footprint`, so với 3,9 % / 26,7 MB). Lúc chưa cấp quyền: xem có hộp thoại OS không (C6). Cần màn thứ hai: vùng vắt hai màn, rút màn giữa lúc quay (C5). Bước OCR: chép `onnx/` từ thư mục `-Out` trên máy Windows vào `fastcast/target/ocr-models/` (sha soát theo sổ), chép cả bộ ảnh `gen-bench` (chỉ sinh được trên Windows), rồi `FASTCAST_OCR_MODELS=<đích> cargo run -p fastcast-ocr --example ocr_bench -- <ảnh> --bench <ảnh>/truth.tsv` (C7). Case: `plan/gd4_12_macos-video.md`.
- **[gd4_05 · owner-qa] Trình đọc màn hình trên dòng Pro (C6)** — lý do: máy không chạy Narrator trong làn (phát tiếng, lấy focus). Bước: bật Narrator, Cài đặt → Pro, duyệt từng dòng; mong đợi đọc "<tên>, pro" + mô tả, Tab không dừng ở dòng nào.
- **[gd4_19 · owner-qa] Tiếng thật khi quay trên Mac** — lý do: thiếu quyền Screen Recording, Microphone. Đã chạy: track AAC của writer. Bước: cấp hai quyền như gạch gd4_12, `cargo test -p fastcast-video --test macos -- --ignored --test-threads=1` (`records_system_audio`, `records_microphone`); quay kèm âm hệ thống, kèm micro, mở QuickTime nghe khớp hình; từ chối micro ra `AudioUnavailable`, không sót `.part`. Rút micro giữa lúc quay: log `audio: device reopened`, cắm lại có tiếng tiếp. Hộp thoại quyền đang mở mà bấm dừng: kết thúc ngay. Soát thêm: `SCStream` 2 × 2 có giao âm, log `rec: audio clock`. Case C4–C6: `plan/gd4_19_macos-audio.md`.
- **[gd4_13 · owner-qa] Bản `.dmg` đủ và kiểm từ đầu tới cuối** — lý do: máy không có `pwsh`, `onnx/`. Bước: `brew install --cask powershell`; chép `onnx/` từ máy Windows vào `fastcast/target/ocr-models/`; `bash fastcast/tools/build-macos.sh --models target/ocr-models` (đường dẫn tính từ `fastcast`, chạy trong đó); mở `dist/macos-arm64/*.dmg`, kéo vào Applications, chuột phải → Open qua Gatekeeper; cấp quyền (tên fastcast phải hiện trong danh sách, hộp thoại micro đúng chữ vi / en); khay, phím tắt, chụp, quay, OCR, Giới thiệu → trang giấy phép; `autostart` + đăng nhập lại; kéo vào Thùng rác. Chữ ký ad-hoc đổi mỗi lần build nên có thể phải cấp lại quyền.
- **[gd4_13 · ký mã] Developer ID + notarize** — lý do: dịch vụ trả phí, chủ dự án quyết. Khi có: ký thêm `--options runtime`, ký lại dylib, cập nhật sha dylib trong sổ. Chưa có thì Gatekeeper chặn lần mở đầu.
- **[gd4_13] Bộ cài Windows sau khi sổ có mục Mac** — lý do: làm trên Mac. Chạy `tools/build-installer.ps1` ở máy nhà, xem bước soát sha vẫn qua.
- **[gd4_11 · owner-qa] Kiểm hai màn khác scale trên Mac thật** — lý do: máy chỉ có một màn; lỗi chồng màn đã sửa bằng `display_points::place`, test màn giả xanh. Cắm màn 1× cạnh Retina, chạy bản build: chụp vùng giữa Retina sát ranh và giữa màn 1× ⇒ ảnh chỉ có một màn; kéo vùng vắt ranh ⇒ khung bám con trỏ ở cả hai màn, ảnh ghép đúng hai mảnh; lấy màu bấm mũi tên trên màn 1× ⇒ con trỏ không nhảy màn; quay vùng trên màn 1× và vùng vắt ranh ⇒ video đúng vùng, viền đúng chỗ; đặt màn trái, trên, lệch dọc rồi lặp một lượt. Vùng vắt hai màn là hình chữ nhật theo pixel nên trên màn scale khác không ngang tầm mắt (như Windows): đúng F-3, không phải lỗi.
- **[gd4_11 · owner-qa] Kiểm tay UI Mac** — lý do: máy một màn đang dùng, chưa cấp Screen Recording. C5, C6, C7 của `plan/gd4_11_macos-ui.md`: thiếu quyền ⇒ thông báo + đúng trang Settings; có quyền ⇒ chụp thật, Cmd+C, Cmd+S, hộp thoại Lưu, overlay phủ menu + Dock, phủ khi app khác toàn màn, thông báo không lọt ảnh chụp (`NSWindowSharingNone` có thể không chặn ScreenCaptureKit từ macOS 15), mũi tên lấy màu dời con trỏ, chữ chú thích; hai màn cùng rồi khác scale.
- **[gd4_11] Bốn lệnh trên Windows chưa chạy sau gd4_11** — lý do: làm trên Mac. Chạy ở máy nhà: `crates/ui/tests` đổi `secondary-`, `capture/src/lib.rs` tách `xcap_sys`, thêm `capture/src/display_points.rs`, `platform::beyond_window` (Windows trả `None`, chưa biên dịch trên Windows).
- **[gd4_11 · ram] Sau overlay `fastcast-ui` còn ~40 MB trên Mac** (Windows 8,5): phần còn lại là Metal của gpui-pre (IOAccelerator + IOSurface ~28 MB), `request_windowing(Headless)` trên Mac không thả; không rò (ba lượt 63 → 66 → 66 MB), hết giờ giữ ấm tiến trình thoát. Lý do treo: phải vá gpui-pre. Bản 60 → 40 MB đã làm: daemon đặt `MallocLargeCache=0` cho UI.
- **[gd4_04 · owner-qa] Ảnh chép không vào Win+V** — lý do: phải chạy `fst` thật + chụp màn thật, máy nhà không làm trong làn. Bước: Cài đặt → Lưu và quay → bật "Không đưa vào lịch sử clipboard", chụp vùng, chép ảnh, mở Win+V: ảnh không có, Ctrl+V vẫn dán được; tắt tuỳ chọn, chép lại: ảnh có trong Win+V. Nút "Chọn…" mở hộp thoại thật, chọn được thư mục.
- **[gd4_10 · owner-qa] Kiểm tay daemon trên Mac** — lý do: cần mắt người + quyền Accessibility, session không tự cấp. Đã chạy được: `fst status`, `quit`, lần hai, không icon Dock, `autostart on` / `off`. Còn lại: `cargo build --release -p fastcast-daemon`, chạy `target/release/fst`, thấy icon khay, mở menu; bấm Alt+Space, Ctrl+Shift+1…5, mỗi phím có dòng `command: …` trong `~/Library/Application Support/fastcast/logs/daemon.log`; `fst autostart on`, đăng nhập lại, daemon lên sau ~12 s, `fst autostart off`, `fst quit`. Sau gd4_13: lặp autostart trong `.app`. Case C5b, C6b ở `plan/gd4_10_macos-daemon.md`.
- **[gd4_06 · owner-qa] Ba nút trang Giới thiệu (C4)** — lý do: chạy thử chỉ ghi log, máy nhà không mở trình duyệt trong làn. Bước: cài bản gd4_09, Cài đặt → Giới thiệu, bấm từng nút; mong đợi trang giấy phép mở ở trình duyệt mặc định, hai thư mục mở trong Explorer.
- **[gd4_09 · owner-qa] Cài thật bằng giao diện (C12)** — lý do: luật làn cấm mở bộ cài có giao diện, cấm chạy `fst` đã cài. `fastcast/dist/fastcast-0.1.0-setup.exe`: SmartScreen cảnh báo (chưa ký), cài, ô "chạy fastcast", khay, phím tắt, `fst --version | Out-Host` in phiên bản, khởi động lại máy, gỡ (tác vụ `fastcast-<user>` mất, `config.json` còn), cài đè bản cũ.
- **[gd4_09 · ký mã] Chứng chỉ ký Windows** — lý do: dịch vụ trả phí, chủ dự án quyết. Chưa ký thì SmartScreen cảnh báo.
- **[gd4_09] `build-installer.ps1 -Vendor`** — lý do: chỉ dùng lúc phát hành thật (D-6). Đã thử `cargo vendor` (769 thư mục), chưa build `--offline` từ đó.
- **[gd4_07 · owner-qa] Icon ở 100 %, 125 %, 150 % (C7)** — lý do: máy nhà không bật khay trong làn, icon khay nằm ở taskbar màn LG. Bước: cài / chạy `fst` thật ở mỗi tỉ lệ (đổi tỉ lệ rồi khởi động lại `fst`), xem icon khay nét, không ô nền, menu khay đúng cỡ; xem icon `fst.exe` trong Explorer và `fastcast-ui` ở Alt+Tab.
- **[gd4_07 · ux P3] Icon khay theo đổi tỉ lệ khi đang chạy** — lý do: không bật được khay trên máy nhà để thử. Bắt `WM_DPICHANGED`, gọi `set_icon` với cỡ mới.

- **[gd0_05 · owner-qa] Thử OCR trên ảnh chụp thật (C8)** — lý do: máy dùng thật, session không chụp màn; số CER trong `fastcast/docs/spikes/ocr.md` chỉ là ảnh tổng hợp. Khi `fastcast-ocr` chạy được (GĐ3): chụp vùng code, chat, web sáng / tối, chữ nhỏ, xem chữ ra; dòng tiếng Việt mất dấu = `looks_like_code` chọn nhầm.
- **[gd0_05] Đọc giấy phép dữ liệu huấn luyện của model trước khi bán** — lý do: spike chỉ tin nhãn Apache-2.0 trong sổ vnocr, không đọc giấy phép dữ liệu của `vgg_transformer` gốc + dữ liệu học thêm `vn8a30`; việc của chủ dự án, không chặn GĐ3.
- **[gd3_06 · owner-qa] Quay vùng thật bằng `fastcast-rec`** (`plan/gd3_06_rec-worker.md` C15): một màn, vắt hai màn khác DPI, tiếng khớp hình bằng tai — lý do: máy dùng thật, session chỉ quay cửa sổ thử. Gộp vào danh sách của gd3_13.
- **[gd3_06] Video chịu được sập giữa lượt**: `moov` ở cuối nên `.part` của tiến trình bị giết cứng không phát được; thử `MFTranscodeContainerType_FMPEG4` — lý do: đổi container phải soát lại QuickTime, cần máy Mac.
- **[gd3_07 · owner-qa] Kiểm tay âm thanh**: `plan/gd3_07_rec-audio.md` C6 (micro + hệ thống 60 s khớp hình, rút tai nghe, đổi thiết bị mặc định, micro bị chặn) — lý do: session không được mở micro trên máy chủ dự án, không rút được thiết bị. Gộp vào danh sách của gd3_13.

- **[gd2_06 · gd4_18] CPU WARP lúc vẽ nét vượt mục tiêu**: lúc rảnh 0,9–1,9 nhân, mục tiêu ≤ 1 (`fastcast/docs/gd4-report.md` mục 2.5); kéo tay nắm đã đạt 0,26–0,39. Lý do treo: chưa có RDP thật để biết có giật không, chờ C1–C2 của `gd1-report`. Thử trong chế độ nhẹ: giảm nhịp vẽ nét, hoặc giữ sẵn ảnh đã tô của các hình đã xong thay vì vẽ lại đường vector mỗi khung.
- **[gd2_06 · owner-qa] Kiểm tay GĐ2 — một danh sách, `fastcast/docs/gd2-report.md` mục 4** (gồm `gd2_04`, `gd2_05` ở dưới). Xong ⇒ `close-phase` GĐ2 khi GĐ1 cũng xong.

- **[gd2_05 · owner-qa] Con lăn + bảng màu**: `fst` thật, chụp vùng, chọn công cụ. Lăn con lăn có nấc + vuốt touchpad: mỗi nấc đổi một bước, nhãn `N px` gần con trỏ, không nhảy loạn; lăn giữa lúc kéo; lăn lúc đang gõ chữ có Unikey (con trỏ + IME không mất). Bảng màu (phím `c`): kéo ra ngoài ô vẫn bám, gõ hex không bật công cụ — lý do: máy dùng thật, session không chạy overlay thật, con lăn thật.

- **[gd2_04 · owner-qa] Gõ tiếng Việt vào ô chữ**: chạy `fst` thật, chụp vùng, phím `t`, click, gõ Telex + VNI qua Unikey / EVKey: không mất / nhân đôi chữ, ô ứng viên đúng chỗ; thử cả màn scale khác 100 % + vùng vắt hai màn khác scale (chữ không đổi cỡ vật lý, ảnh lưu khớp) — lý do: máy dùng thật, session không gõ phím thật; màn giả luôn theo scale màn chính.
- **[gd2_04] Font chữ chú thích trên macOS, Ubuntu**: chưa chạy thử, kiểm ảnh lưu có đúng chữ, đúng chỗ.

- **Kiểm tay GĐ1 — MỘT danh sách, theo thứ tự chạy: `fastcast/docs/gd1-report.md` mục 4** (gom mọi gạch `owner-qa` / "Kiểm tay" gd1_01 → gd1_10, T3 autostart, khác DPI, độ trễ phím thật, RDP, nền mờ, dán thật) — lý do: máy dùng thật, session không chạy overlay / phím thật. Tiêu chí 2 màn khác Hz, khác scale: **chưa xác nhận**. Xong ⇒ `close-phase` GĐ1, các gạch kiểm tay dưới đây xoá theo.
- **[gd1_11 · ux] GPUI ghi ERROR `Invalid window handle. (0x80070578)` mỗi lần đóng overlay**: làm rối `ui.log`, khả nghi `gpui-pre-windows` `window.rs:627` — lý do treo: chưa kiểm gốc, phải vá crate ngoài, không ảnh hưởng hành vi (P3). `plan/gd1_11_acceptance.md` mục 10.
- **Kiểm tay gd1_09 (C14 — `plan/gd1_09_color-picker.md` mục 6)**: trên màn HDR và màn scale 125 / 150 %, Ctrl+Shift+3 (hoặc launcher "Lấy màu"): kính lúp hiện cạnh con trỏ, mũi tên dời con trỏ thật đúng 1 px, kính lúp sang màn kia khi di chuột; Enter chép, dán ra so với màu thật — lý do: máy dùng thật không chạy overlay thật; màu HDR phụ thuộc cách `xcap` chụp, chưa kiểm.
- **`set_cursor_pos` Ubuntu (gd1_09)**: mũi tên chưa kéo con trỏ thật — lý do: chưa có máy, làm cùng GĐ4. macOS xong ở gd4_11, chờ kiểm tay.
- **[gd1_08 · owner-qa] Kiểm thước tay (C6)**: `fst` thật → Ctrl+Shift+2 → đo một nút trên trang web đã biết cỡ CSS ⇒ phần `@` khớp; có màn khác DPI: trục sang đúng màn, vắt hai màn thì không có `@`; Ctrl+C rồi dán ra `W×H` — lý do: máy dùng thật, chỉ chạy màn giả cùng scale. `plan/gd1_08_ruler.md`.
- **[gd1_08 · ux] Gợi ý trước lần đo đầu**: mục 10 (4) của gd1_08 — lý do: chờ chủ dự án xem tay. Mục (5) đã sửa ở gd4_18.
- **Kiểm tay gd1_10 (C7 — `plan/gd1_10_light-overlay.md` mục 6)**: RDP vào máy nhà từ máy khác, bấm chụp vùng; log có `overlay: render mode Light (… remote=true)`, kéo chọn dùng được, vùng sáng nét, lưu / chép đúng; xem thêm màn 1440p / 4K nếu có — lý do: không giả lập được RDP, cũng không đo được màn lớn hơn màn thật.

- **Kiểm tay gd1_05** (`plan/gd1_05_clipboard.md` C11): overlay thật, Ctrl+C / Enter / nút Chép → dán vào Paint / Word / trình
  duyệt (đúng ảnh, đúng cỡ); đợi UI thoát rồi dán lại; thông báo hiện ở màn có con trỏ, không lấy focus — lý do: máy dùng thật,
  session chỉ chạy màn giả.
- **Clipboard Linux Wayland** (gd1_05): bật `wayland-data-control` của `arboard` + thử trên GNOME, soát `cargo deny` — lý do:
  không có máy Ubuntu trong lượt.

### GĐ0 (T0–T4 xong 29/10/2026 — chi tiết `fastcast/ROADMAP.md` mục GĐ0)

- **[gd0_06 · owner-qa] Quay màn thật** — lý do: máy dùng thật, session không quay màn của chủ dự án; đường `--rect` mới
  biên dịch + test hàm thuần, chưa chạy lần nào. Các lệnh dưới **quay màn thật**, xem xong xoá tệp. Build
  (`cargo build --release --manifest-path fastcast/spikes/video/Cargo.toml`), exe ở `fastcast/spikes/video/target/release/`:
  1. `video-spike --monitors` — lấy toạ độ màn.
  2. `video-spike --rect 100,100,1280,720 --secs 10 a.mp4`, rồi `--backend dxgi` — đúng vùng? có con trỏ? viền vàng?
  3. Vùng vắt hai màn: `--rect <x cách ranh màn 640 px>,100,1280,720 --secs 10 b.mp4` trên DELL 60 Hz + LG 144 Hz.
  4. `--rect 100,100,1280,720 --secs 60 c.mp4` trên từng màn: dòng `MEASURE` (`skipped_slots`, CPU, RAM), `--verify c.mp4`.
  5. Mở tệp bằng Media Player, QuickTime (Mac), trình duyệt; chữ có đọc được không. Thử cửa sổ có DRM: hiện đen?
  Kết quả ghi `fastcast/docs/spikes/video.md` mục 6 + chọn WGC / DXGI ở `plan/confirm.md` trước GĐ3.
- **[gd3_05 · owner-qa] DXGI + con trỏ tự vẽ qua `source::open`** — lý do: máy dùng thật, session không quay màn của chủ dự án; `for_monitor` và `DxgiSource` mới biên dịch + test phần thuần, spike chưa có con trỏ DXGI nên bước trên không phủ. Sau gd3_06, quay màn thật bằng `fastcast-rec` với `FASTCAST_REC_BACKEND=dxgi`, xem xong xoá tệp: đúng vùng, con trỏ đúng chỗ + đúng cỡ trên từng màn, không để lại vết khi rê, chữ I-beam đảo màu, không viền vàng; log không có `dxgi unavailable`. Đổi độ phân giải giữa lúc quay ⇒ `DisplayChanged`. Không nhận viền vàng WGC ⇒ đổi mặc định ở `parse_backend`.
- **[gd4_08 · owner-qa] Pipe thật** — lý do: làn không được chạy `fst` thật. Cài vào `%LOCALAPPDATA%`, bật `fst`, `fst status | Out-Host` trả trạng thái, phím tắt mở được UI (`ui.log` có `ipc: connected`). Trên Mac / Ubuntu: `cargo test -p fastcast-core guarded_socket_is_private`.

- **Kiểm T3 thật**: `fst autostart on` → khởi động lại máy → daemon lên sau ~12 s, logon không chậm →
  `fst status | Out-Host`. Gộp vào gd1_11 nếu chưa làm trước.
- **Khác DPI chạy thật**: đặt một màn 125 % / 150 % → `cargo run -p fastcast-capture --example probe --release`
  (cùng lượt gd1_02).
- **Khay trên Linux**: `tray-icon` đang `default-features = false` ⇒ chưa có backend Linux. Chọn `ksni` (D-Bus thuần, soát
  giấy phép) hay `libappindicator` (GTK, LGPL — phải hỏi) — gd0_07.
- **Daemon macOS / Linux**: `crates/daemon/src/platform/other.rs` trả lỗi — vòng sự kiện macOS (NSApplication) + Linux
  (sau gd0_07). Autostart macOS (`SMAppService`) cùng bản cài GĐ4.
- **[gd1_01 · ux] Khởi động nguội UI ~300 ms**: đo từng bước khởi động GPUI, hoặc daemon bật sẵn UI headless (~4,2 MB)
  sau đăng nhập — chờ chủ dự án chọn đánh đổi RAM. `plan/gd1_01_ui-process.md` mục 10.
- **[gd1_01 · owner-qa] Kiểm UI cùng daemon thật**: `fst run capture_region` → `ui.log` có `run capture_region`; để
  yên > 10 s, Task Manager `fastcast-ui` ~4 MB; hết `keepWarmMins` tiến trình biến mất; `fst quit` ⇒ UI tắt theo.
- **[gd1_06 · ux] Launcher sau khi nhả GPU ~200 ms** (bản dựng sẵn 0,2 ms): giữ GPU / launcher ẩn lâu hơn khi launcher
  vừa dùng, hoặc tăng `GPU_IDLE_DEFAULT` — chờ chủ dự án chọn đánh đổi RAM giữ ấm 7,3 ⇒ 14,2 MB; gd1_02 (song song) cũng
  đo khung đầu overlay sau nhả GPU trên cùng hằng số. `plan/gd1_06_launcher.md` mục 10 (1). → gd1_02 đã tăng
  `GPU_IDLE_DEFAULT` 10 → 60 s (gạch `confirm.md`); gd1_06 thêm sàn riêng `launcher::HOLD_AFTER_USE` = 60 s (master
  `6503d28`). Còn treo chỉ khi chủ dự án muốn đánh đổi khác.
- **[gd1_06 · owner-qa] Kiểm launcher tay** (C7): Alt+Space thật, Telex, bấm ra ngoài, kéo sang màn khác + mở lại, sáng
  / tối, vi / en, không chớp nội dung cũ, Alt+Space không bật menu app đang dùng — bước ở `plan/gd1_06_launcher.md`
  mục 9; lỗi chớp / Alt thì làm đề xuất 4 / 2 của mục 10.
- **[gd1_11 · ram] UI giữ ấm sau khi dùng overlay 8,3–8,9 MB** (chưa dùng 5,7–5,8; launcher 5,6–5,9 — số 7,3 MB cũ của gd1_06 và 9–13 MB của gd1_02 / gd1_10 là đọc lúc bộ nhớ đang được trả, `fastcast/docs/gd1-report.md` mục 3): ~3 MB còn lại, cần đo sâu GPUI / DirectWrite; P3, chưa làm vì không tăng theo số lần mở.
- **[gd1_06 · ux] Dời launcher ẩn sang màn có con trỏ** bằng `SetWindowPos` thay vì dựng lại (~25 ms) — P3, làm khi có
  máy nhiều màn khác DPI để kiểm. Mục 10 (5).
- **[gd1_02 · owner-qa] Kiểm overlay tay** (C11, C12): `fst` thật, phím chụp vùng — kéo DELL 60 Hz ↔ LG 144 Hz, nhãn
  đúng cỡ vật lý, không màn đen / nháy; màn 125 % / 150 % nét 1:1 không lệch; Esc ở màn có con trỏ; Alt+F4 một màn đóng
  cả hai. Bước ở `plan/gd1_02_region-overlay.md` mục 9. Máy không có màn phụ lúc làm ⇒ chưa chạy overlay thật lần nào.
- **[gd1_03 · owner-qa] Kiểm chỉnh vùng tay** (C9): màn thật nhiều DPI — rê tay nắm thấy con trỏ đổi cỡ đúng hướng, kéo
  cạnh vắt hai màn khác scale bám con trỏ, Tab / Enter / Space trên thanh công cụ, tooltip có phím tắt, Alt + mũi tên
  không bật menu hệ thống, sáng / tối. Bước ở `plan/gd1_03_selection-edit.md` mục 9.
- **[gd1_03 · ux] Thân vùng chọn không có con trỏ "dời" trên Windows**: `gpui-pre-windows` (`util.rs`) map `OpenHand` /
  `ClosedHand` về `IDC_ARROW`, không có `IDC_SIZEALL` — lý do treo: phải vá crate ngoài (upstream) hoặc đặt con trỏ Win32
  riêng qua `platform` — M, P3.
- **[gd1_02 · ux] Spawn nguội → khung đầu overlay 496–674 ms** (> 400 ms của task): cùng hướng gạch gd1_01 "khởi động
  nguội" — daemon bật sẵn UI headless; trái F-4 ("bật khi dùng") ⇒ chờ chủ dự án chọn đánh đổi RAM.
  `plan/gd1_02_region-overlay.md` mục 10.
- **[gd1_02 · ux] Gắn lại GPU 150–405 ms** trên
  máy nhà (gd1_01 đo 17–26 ms) — đóng băng đã chồng lên lúc gắn; đo lại lúc máy rảnh / iGPU / máy công ty. Mục 10 của
  gd1_02.
- **[gd4_03 · owner-qa] Gán phím thật từ Settings (C9)**: bật `fst` thật, Cài đặt → Phím tắt, làm các bước C7 của `plan/gd1_07_hotkey-assign.md`. Máy nhà không chạy `fst` thật khi thử nên chưa kiểm.
- **[gd1_07 · owner-qa] Gán phím thật (C7)**: bật `fst` thật → Alt+Space → Chụp vùng → Ctrl+K → Gán phím tắt… →
  Ctrl+Shift+2 (của Thước căn; lúc ghi KHÔNG mở Thước căn) → Enter → "Lấy phím" ⇒ Ctrl+Shift+2 mở Chụp vùng; tổ hợp app
  khác giữ ⇒ báo + Quay lại; giết `fastcast-ui` lúc đang ghi ⇒ phím tắt chạy lại ngay. `plan/gd1_07_hotkey-assign.md` mục 9.
- **[gd1_07 · ux] PrintScreen không ghi được từ launcher trên Windows** (GPUI không báo `VK_SNAPSHOT`): subclass HWND
  launcher bắt `WM_KEYUP VK_SNAPSHOT` khi đang ghi — chưa làm vì cần bấm phím thật để kiểm (Win11 có thể giữ PrtSc cho
  Snipping). Mục 10 (1) của gd1_07.
- **Dọn dữ liệu thử**: `%APPDATA%\fastcast` + `%LOCALAPPDATA%\fastcast` thật trên máy nhà do lượt chạy Task Scheduler
  29/10/2026 tạo — giữ dùng tiếp, hoặc xoá bằng Explorer (session Claude chỉ thấy bản ảo hoá, memory
  `msix-appdata-virtualization`).

- **Kiểm tay gd1_04 (C8, C9 — `plan/gd1_04_save-image.md` mục 6)**: Lưu thành… trên overlay thật (hộp thoại phải nổi trên overlay, huỷ thì về overlay, phím vẫn nhận); bấm thông báo "Đã lưu" mở Explorer đúng tệp, ✕ chỉ đóng, rê chuột dừng đếm giờ — lý do: máy dùng thật, session không chạy overlay thật / không mở Explorer.

- **[gd3_04] Windows N**: có thể `fastcast-rec.exe` không bật nổi thay vì báo `NoEncoder` (exe nhập trực tiếp từ `mfplat.dll`; suy từ cách crate `windows` liên kết, chưa kiểm) — lý do: không có máy Windows N. Khi có máy: thử; nếu đúng thì gd3_11 coi "bật exe lỗi" như `NoEncoder`, hoặc nạp trễ DLL.
- **[gd3_04] Vùng siêu dài**: 8000 × 720 mã hoá xong nhưng Media Foundation không giải mã lại được (`0xC00D36B4`), 5120 × 720 thì được; ngưỡng chưa dò, chưa thử trình phát khác — lý do: P3, chỉ gặp khi vắt 3–4 màn với vùng thấp, ưu tiên sau các làn GĐ3.

## materiant

- Output style `terse` của quy trình xbds (D-5) — phần còn lại của T0b cũ (plan materiant trước khi tách tệp).

### GĐ1 — port component (đóng 30/10/2026, `completed/materiant/gd1/`)

- **Kiểm tay GĐ1 — một lượt** (lý do: nhìn bằng mắt / so web, hover + kéo cửa sổ thật của OS, bộ gõ Unikey / EVKey,
  touchpad + màn 144 Hz, nền mờ thật phía sau, FRAMES khi bật Animation effects — không giả lập được khi chạy thử nền):
  bảng 14 dòng có lệnh từng mục ở `materiant/docs/gd1-report.md` mục 6 (gom C4 / C5 của gd1_01 → gd1_09, C8 gd1_11, C1
  phần tay của gd1_10, phím Menu / Apps của gd1_08). Kết quả báo lại / ghi vào đây.
- **macOS / Ubuntu GĐ1** (gd1_10 C3 — lý do: máy này không có Mac / Ubuntu, không target darwin): gallery + launcher +
  `cargo test`, nhãn RAM `phys_footprint` / `RssAnon` chưa build lần nào — lệnh + chỗ dễ vỡ ở
  `materiant/docs/gd1-report.md` mục 5.
- **[gd1 nợ] `ToastViewport` thành `RootPlugin`; Dialog mở bằng code** (lý do: fastcast đặt `ToastViewport` trong view của overlay, thêm plugin thì vẽ hai lớp, bỏ thì đổi API fastcast đang dùng; Dialog khai báo đủ dùng, chưa có nơi gọi mở bằng code). `materiant/docs/gd1-report.md` mục 7.
- **[gd1_10 · ram] Trang gallery `button` 24,1 MB** (các trang khác 14–18) — đo phần nào tốn (bóng `elevated`, glyph)
  trước khi fastcast dùng nhiều bóng; lý do treo: không chặn, P3. Mục 10 (3).

## Workspace

- Agent riêng cho Rust (kiểu `be-builder` / `ui-builder` của xbds) — hiện run-task giao `general-purpose` + `model:
  sonnet`; viết agent khi thấy lời giao lặp lại.
- Hook `Stop` nhắc bàn giao (kiểu `tools/handoff-check.sh` của xbds) — chưa chuyển.
- Lịch sử clipboard trên macOS, Linux: cần máy thử (`watch_clipboard` đang là stub).
