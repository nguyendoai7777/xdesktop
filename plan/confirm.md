# Chờ chủ dự án xác nhận

Việc **đã làm** trong lúc chủ dự án vắng (ngủ / bận) mà Claude không chắc chủ dự án đồng ý — đổi API, lệch bản web có
chủ ý, đánh đổi RAM / CPU, đổi luật, chọn phương án thay chủ dự án. Mỗi gạch: `- [<task>] <việc đã chọn> — <phương án
khác> — <vì sao chọn>`. Chủ dự án đọc: đồng ý ⇒ xoá gạch (quyết định lớn thì chép vào `docs/decisions.md`); không đồng
ý ⇒ ghi lại yêu cầu ngay dưới gạch để session sau làm lại.

Session thêm gạch bằng `Edit` chèn vào mục của task mình (không `Write` cả tệp — nhiều session cùng ghi).

## Điều phối (session cha, 30/10/2026)

- [điều phối] Session con không hỏi chủ dự án nữa (`AskUserQuestion`): tự chọn phương án khuyên dùng + tự chọn đề xuất
  cải tiến đáng làm rồi làm ngay (D-8) — phương án khác: dừng chờ tới sáng — vì sao: chủ dự án dặn "đừng để session nào
  bị block".
- [điều phối] Mỗi worktree một `CARGO_TARGET_DIR` riêng (`materiant/target/<task>`), sửa ở skill `run-task` mục 4 +
  `materiant/CLAUDE.md` — phương án khác: dùng chung để tiết kiệm build nguội / đĩa (~2 GB mỗi worktree) — vì sao: dùng
  chung làm cargo báo `Fresh` mà đưa ra exe của worktree khác (đã tái hiện: gallery gd1_03 ra trang stub của master).
- [điều phối] `start.ps1` / `start.sh`: master build ở `materiant/target/start`, worktree build ở thư mục của chính
  session đó (`target/<worktree>`) — phương án khác: thư mục riêng cho script (không bao giờ chờ khoá nhưng build nguội
  lại mỗi worktree) — vì sao: xem tay thường lúc session đã xong / rảnh, đỡ 2 GB + 5 phút mỗi lần.

- [điều phối] Xoá thư mục build chung cũ `materiant/target/{debug,release,tmp}` (~8,5 GB) — ổ E: còn 12 GB — phương án
  khác: giữ — vì sao: sau luật "mỗi worktree một target" không ai dùng nữa; session nào lỡ còn trỏ vào thì chỉ build
  nguội lại. Session mới build ở `C:/xdesktop-target/<task>` (C: còn ~450 GB) — chưa ghi vào skill, chờ bạn chọn ổ.
- [điều phối] Session fastcast gd1_01 mới để ở dạng thẻ đề xuất (app không cho tự mở session từ lượt do sự kiện nền);
  materiant gd1_07 / gd1_09 chờ gd1_03 (Button) gộp xong mới mở. Spike OCR (gd0_05) / quay video (gd0_06) KHÔNG mở khi
  vắng — cần chụp / quay màn hình thật của máy và tải ONNX Runtime lúc build.

## fastcast

- [rec-setup] Bảng thiết lập quay luôn ở giữa màn có vùng chọn, có thể che vùng; muốn chỉnh tay nắm phía dưới thì dùng phím mũi tên — phương án khác: giữa màn nhưng né vùng — vì sao: chủ dự án yêu cầu "luôn ở giữa". Vùng vắt hai màn: màn chứa góc dưới phải.
- [rec-setup] "Fps", "Hex", "Rgb" chỉ hoa chữ đầu — phương án khác: FPS, HEX — vì sao: theo đúng D-13, tránh toàn chữ hoa.

- [debt-notify] Lỗi tự khởi động đi bằng cặp thông điệp mới `AutostartStatusRequest` / `AutostartStatus`, không thêm trường vào `DaemonStatus` như lời khuyên — phương án khác: thêm trường `#[serde(default)]` — vì sao: `crates/ui/tests/settings_hotkeys.rs` dựng `DaemonStatus` bằng struct literal, thêm trường là test đó không biên dịch, mà tệp đang do session khác sửa, không được đụng. Daemon cũ trả `Error`, trang coi như không có gì để báo; `ReloadConfig` giữ nguyên nghĩa.
- [debt-notify] Trang Chung chỉ hỏi daemon sau khi vừa đổi tự khởi động (công tắc, độ trễ) — phương án khác: hỏi sau mọi lần ghi — vì sao: lỗi cũ còn nằm ở daemon tới lần áp sau, đổi cỡ chữ sẽ báo lại. Công tắc giữ ý người dùng, không trả về.
- [debt-notify] Mất âm báo bằng chữ trên thanh quay, không dùng thông báo nổi — phương án khác: `notice::show` — vì sao: chữ ở lại suốt đoạn mất tiếng, thông báo tắt sau 2,5 s. Có tiếng lại thì đổi chữ và giữ tới hết cuộc quay vì video đã có đoạn không tiếng.
- [debt-notify] Chỉ báo `AudioLost` khi mở lại thiết bị hỏng — phương án khác: báo mọi lần mất luồng — vì sao: rút tai nghe còn loa thì mở lại được ngay, báo là nhiễu. Thêm `AudioRestored` ngoài biến thể task nêu để thanh không báo mất mãi.

- [tray-menu] Chuột phải vào khay (Windows): daemon gửi `ShowTrayMenu`, `fastcast-ui` vẽ `materiant::menu`; menu của OS giữ làm dự phòng khi UI không bật được, rớt, báo lỗi hoặc im quá 3 s — phương án khác: bỏ hẳn menu OS, hoặc daemon tự vẽ menu bằng GDI — vì sao: Thoát phải chạy được cả khi UI hỏng, daemon không được mang UI (F-4), cũng không thêm phụ thuộc nào vào daemon.
- [tray-menu] macOS / Linux vẫn dùng menu của OS — phương án khác: bật menu tự vẽ cho macOS luôn — vì sao: chưa thử được trên hai máy đó; thanh AppIndicator của Linux không báo nhấp chuột nên không tự vẽ được.
- [tray-menu] Mục đầu ("Chụp vùng") được trỏ sẵn khi menu mở — phương án khác: thêm vào `materiant::menu` API mở menu không trỏ mục nào — vì sao: dùng API có sẵn (`OpenContextMenu`), không đụng repo materiant; đổi lại Enter / ↑ ↓ dùng được ngay. Nhấp chuột vẫn bình thường.
- [tray-menu] Cửa sổ popup lớn hơn khung menu một chút, phần dư trong suốt, nhấp vào đó coi như nhấp ra ngoài — phương án khác: đo chữ trước rồi mở vừa khít — vì sao: cỡ thật chỉ biết sau khung đầu mà gpui-pre không dời được cửa sổ đã mở.
- [tray-menu] Nền menu theo D-10 (đục 0,75), không acrylic nên trên desktop sặc sỡ có thể hơi khó đọc — phương án khác: nền đặc riêng cho menu khay — vì sao: giữ đúng D-10; chủ dự án thấy khó đọc khi dùng thật thì đổi.

- [gd4_18] Ghi ✅ task dù GĐ4 chưa đóng, Mac + Ubuntu chưa chạy, báo cáo ghi rõ — phương án khác: để 🔄 — vì sao: đúng mục 2 của task, `close-phase` mới chờ kiểm tay.
- [gd4_18] Thêm `settings-run.ps1 -AllowOnlyScreen` để đo khi máy chỉ còn DELL — phương án khác: chờ cắm lại LG — vì sao: chủ dự án vắng, LG không có trong danh sách màn; cờ vô tác dụng khi có từ hai màn, mỗi bài có soát trước đúng một màn tên DELL.
- [gd4_18] Làm PageUp / PageDown, nhãn thước theo cỡ chữ trong task nghiệm thu — phương án khác: chỉ ghi nhận — vì sao: P2 / nợ cỡ S, D-8; mã sản phẩm ~40 dòng.
- [gd4_18] Không đo lại `ocr_bench`, thời gian cài — phương án khác: đo đủ — vì sao: engine không đổi; cài chỉ đo được qua `installer-e2e`, không in số.
- [gd4_18] Thay `fastcast/dist/fastcast-0.1.0-setup.exe` (gitignore) bằng bản dựng từ `master` mới — phương án khác: giữ bản gd4_09 — vì sao: kiểm tay V6, V7 cần mã mới.
- [plan GĐ4] Pro chỉ là dòng khoá trên Settings, không làm thật theme tuỳ biến / `customIcons`, không có đường bật Pro — phương án khác: làm thật F-12 và theme tuỳ biến, khoá sau — vì sao: D-4 "chỉ đặt chỗ", không ai dùng được thì chưa đáng. Các mục Pro "chờ xác nhận" ở `ROADMAP.md` vẫn chờ.
- [plan GĐ4] Bản cài Windows dùng NSIS, cài theo người dùng — phương án khác: WiX / MSI, Inno Setup — vì sao: giấy phép Zlib nằm trong D-2, không cần admin, một tệp. Chưa ký mã: SmartScreen sẽ cảnh báo tới khi bạn mua chứng chỉ.
- [plan GĐ4] `gd4_10`, `gd4_12` viết trên máy nhà, soát bằng `cargo check --target`, ghi `✅ mã — chờ chạy trên Mac`; `gd4_11` phải làm trên Mac vì `fastcast-ui` không biên dịch chéo được — phương án khác: cả ba làm trên Mac — vì sao: nhanh hơn, nhưng mã FFI chưa chạy dễ phải sửa khi lên Mac thật. Đã cài thêm `rust-std` của `aarch64-apple-darwin`, `x86_64-unknown-linux-gnu` vào toolchain máy nhà.
- [plan GĐ4] Linux đóng gói `.deb` cho Ubuntu 26.04, không AppImage / Flatpak — phương án khác: AppImage — vì sao: D-3 chỉ nhắm GNOME Ubuntu, Flatpak đổi cách portal chạy.
- [plan GĐ4] Thêm `gd4_08` siết pipe + biến dev dù `ROADMAP.md` không nêu — phương án khác: phát hành như hiện tại — vì sao: bản cài là lần đầu tới máy người khác, pipe giả mạo được đang treo ở backlog.

- [gd0_05] Cấu hình OCR cho GĐ3 là lai (det + VietOCR int8, Paddle fp32, không arena) — phương án khác: VietOCR một mình như F-6 ghi (đơn giản hơn, nhưng CER 4,65 so với 2,45, WER `code` 35,7 so với 8,3), hoặc fp32 toàn phần (184 MB, CER ngang) — vì sao: code là ca dùng chính của app chụp vùng; F-6 không nhắc Paddle làm bộ đọc nên cần chủ dự án xem. Chưa ghi `docs/decisions.md`.
- [gd0_05] Model kèm bản cài (78 MB + dll 17 MB) — phương án khác: tải khi cần, cần máy chủ trả phí — vì sao: không tự bật dịch vụ tính tiền; đổi ý thì báo trước GĐ4.
- [gd0_05] Chỉ đo trên ảnh tổng hợp, không chụp màn thật — phương án khác: chờ chủ dự án có ảnh — vì sao: máy dùng thật, dặn không chụp; C8 ở backlog.
- [gd0_05] Số thời gian đo lúc máy bận ở `BelowNormal`, không đo lại khi máy rảnh — phương án khác: chờ các session GĐ2 / GĐ3 xong — vì sao: chỉ cần độ lớn để kết luận, số chính thức ở gd3_13.
- [gd2_06] Ghi ✅ dù WARP lúc vẽ nét 1,6–2,4 nhân, vượt mục tiêu ≤ 1 — phương án khác: tối ưu ngay trong GĐ2 — vì sao: chế độ nhẹ vẫn dùng được, số đo lúc máy bận, chưa có RDP thật để biết có giật không; đã gạch backlog.

- [gd2_05] Con lăn lên = tăng theo sự kiện dòng của OS (không đảo theo "natural scrolling") — phương án khác: đảo trên macOS — vì sao: chưa có máy Mac thử.
- [gd2_05] Một sự kiện dòng = một nấc, bất kể cài đặt số dòng của Windows; touchpad 30 px một nấc — phương án khác: chia theo 3 dòng — vì sao: cài đặt OS không làm đổi cảm giác; 30 px là ước lượng, chờ kiểm tay.
- [gd2_05] Mỗi công cụ nét nhớ độ dày riêng cả trong config; không nhớ đậm / nghiêng / gạch chân qua lần mở sau — phương án khác: nhớ cả ba — vì sao: yêu cầu chỉ nêu màu, độ dày, cỡ chữ; bật đậm lần trước dễ gây bất ngờ.
- [gd2_05] Giữ nấc 2 / 3 / 5 / 8 trên bảng + thêm số hiện tại; giá trị giữa nấc thì không nấc nào sáng — phương án khác: thay bằng thanh trượt — vì sao: ít đổi, vẫn một chạm.
- [gd2_05] Nhấn ra ngoài bảng màu: đóng bảng và nhấn vẫn vẽ được — phương án khác: lần nhấn đó chỉ đóng bảng — vì sao: khỏi tốn một lần nhấn.
- [gd2_05] Tám màu mẫu cố định (đỏ, cam, vàng, xanh lá, xanh dương, tím, đen, trắng) — phương án khác: nhớ màu gần đây — vì sao: ngoài phạm vi task.

- [gd2_01] Chú thích gắn với ảnh đóng băng: dời / đổi cỡ vùng chọn không dời chú thích, chỉ cắt — phương án khác: dời theo vùng — vì sao: spec task; giữ được hình khi chỉnh lại vùng.
- [gd2_01] Esc bỏ vùng vẫn giữ chú thích (thứ tự: bỏ nét → tắt công cụ → bỏ vùng → đóng) — phương án khác: bỏ vùng là xoá hết — vì sao: lỡ tay không mất công vẽ.
- [gd2_01] Có công cụ bật: ẩn tay nắm, nhấn ngoài vùng bỏ qua — phương án khác: nhấn ngoài vùng chọn lại — vì sao: tránh mất vùng khi vẽ trượt tay.
- [gd2_02] Bốn độ dày 2 / 3 / 5 / 8 logic, `lyon` thêm trực tiếp — phương án khác: thanh trượt; tự tessellate — vì sao: chọn một chạm; `lyon` đã có trong cây.
- [gd2_01..04] Icon `line undo redo bold italic underline plus minus` tự vẽ cùng hệ F-11 (viewBox 24, nét 2, đầu tròn) — phương án khác: chờ chủ dự án chọn từ bộ F-11 — vì sao: bộ chưa có, chủ dự án cho tự vẽ.
- [gd2_04] Một kiểu cho cả ô chữ; đổi đậm / cỡ áp cho cả ô đang soạn — phương án khác: nhiều kiểu trong một ô — vì sao: đúng phạm vi task.
- [gd2_04] Ảnh xuất vẽ chữ từ tệp font hệ thống (`fontdb` + `ttf-parser`), khử răng cưa khác trên màn chút ít, vị trí giữ nguyên — phương án khác: chụp lại lớp chữ của GPUI — vì sao: GPUI không cho lấy ảnh glyph.
- [gd2_04] Họ font `Segoe UI` / `Helvetica Neue` / `Noto Sans` theo OS, macOS + Ubuntu chưa chạy thử — phương án khác: font hệ thống ảo `.SystemUIFont` — vì sao: ảnh xuất cần tên tệp font thật.
- [gd2_04] Cỡ chữ 10–96 logic, bước 2, mặc định 20; Backspace xoá một ký tự (trừ emoji ghép) — phương án khác: xoá cả cụm — vì sao: Unikey lùi rồi gõ lại theo từng ký tự.
- [gd2_04] Đổi `FASTCAST_OVERLAY_FAKE`: giá trị lạ dùng màn giả nhỏ thay vì chụp màn thật — phương án khác: giữ nguyên — vì sao: session đã gõ sai `1.5` làm overlay thật mở trên máy chủ dự án hai lần (`plan/gd2_04_text.md` mục 9).

- [plan GĐ3] Thêm exe thứ tư `fastcast-rec`, quay ở tiến trình riêng — phương án khác: quay trong `fastcast-ui` (ba exe đúng F-4) — vì sao: sau khi dừng còn ~33 MB DLL Media Foundation, chỉ thoát tiến trình mới nhả (`docs/spikes/video.md` mục 7).
- [plan GĐ3] OCR và quay nói với UI qua stdin / stdout của tiến trình con — phương án khác: qua pipe của daemon (`Role::Ocr` có sẵn) — vì sao: daemon không đổi, không phải đo lại RAM; UI chết thì con tự biết; UI và engine tách được thành làn song song.
- [plan GĐ3] Q-1 âm thanh: Không / Hệ thống / Micro, mặc định Không — phương án khác: thêm "Cả hai" — vì sao: "Cả hai" phải trộn + bù lệch đồng hồ giữa hai thiết bị, chưa đáng ở GĐ3. Chỉ ghi ở đây, chưa vào `docs/decisions.md`.
- [plan GĐ3] Video ghi thẳng vào `save.videoDir`, dừng xong mới hỏi Lưu / Lưu thành… / Bỏ — phương án khác: hỏi đích trước khi quay — vì sao: Ctrl+S / Ctrl+Shift+S giống ảnh; không qua thư mục tạm (báo cáo spike). Đóng bảng không chọn = giữ tệp.
- [plan GĐ3] Làn engine soát bằng `-p` thay vì đủ bốn lệnh của `CLAUDE.md` — phương án khác: soát đủ mọi làn — vì sao: UI không phụ thuộc hai crate đó, đỡ build GPUI ~5 phút mỗi làn; gd3_13 soát đủ trên `master`.

- [gd1_11] Báo cáo GĐ1 ghi "chưa xác nhận" cho tiêu chí 2 màn khác Hz / khác scale, task vẫn ✅ — chờ kiểm tay, KHÔNG đóng giai đoạn — phương án khác: để task 🔄 tới khi kiểm xong — vì sao: session điều phối dặn; phần Claude làm được đã xong, không chạy được overlay / phím thật trên máy dùng thật.
- [gd1_11] Số độ trễ trong báo cáo đo lúc spike OCR + build session khác chạy xen kẽ, không đo lại lần nữa — phương án khác: chờ máy rảnh hẳn — vì sao: session điều phối dặn xong sớm, RAM không bị ảnh hưởng; số độ trễ cuối lấy từ kiểm tay A3, A4, A11.
- [gd1_11] Không sửa độ trễ trả RAM sau khi nhả GPU (5–7 s) — phương án khác: truy tiếp thành phần giữ — vì sao: tự hết, người dùng không gặp hậu quả, đã ghi cách đọc đúng.
- [gd1_10] Nền tối chế độ nhẹ nửa độ phân giải — phương án khác: đủ độ phân giải (+~6 MB mỗi màn 1080p) — vì sao: phần bị tối không cần nét, RAM là tính năng; nhìn thấy hơi mềm khi dùng RDP thì đổi `DARK_DOWNSCALE`.
- [gd1_10] Chế độ nhẹ vẽ 25 fps ở 1080p, giãn tới 10 fps ở 4K — phương án khác: 30 fps cố định (1,09–1,30 nhân) — vì sao: mục tiêu ≤ 1 nhân; mức giãn theo diện tích chưa đo được trên màn thật lớn.
- [gd1_10] Phiên RDP có GPU thật cũng vào chế độ nhẹ — phương án khác: chỉ theo adapter phần mềm — vì sao: đúng spec của task; chưa thử RDP thật nên chưa biết có cần không.
- [gd0_06] Quay theo vùng dùng Windows.Graphics.Capture (TẠM, đường theo màn chưa chạy thật) — phương án khác: DXGI Desktop
  Duplication — vì sao: có con trỏ sẵn, chạy được laptop 2 GPU, màn xoay; cái giá: **Windows 10 hiện viền vàng quanh cả màn,
  không tắt được**. Nhìn ở bước kiểm tay (`plan/_backlog.md`); không chấp nhận viền ⇒ DXGI + tự vẽ con trỏ.
- [gd0_06] Vùng vắt hai màn: mỗi màn một nguồn, ghép vào một khung, khe để đen — phương án khác: chỉ cho vùng trong một màn —
  vì sao: overlay GĐ1 đã cho kéo xuyên màn; pixel vật lý nên không phải co. Chưa chạy thật.
- [gd0_06] Spike vượt trần: 1 438 dòng, 8 tệp (trần 900 / 7), không tách — phương án khác: tách `--verify` + cửa sổ thử thành
  task riêng — vì sao: spike vứt đi; phần vượt phát sinh từ yêu cầu không quay màn thật.
- [gd1_05] Overlay đóng sau khi daemon báo đã chép — phương án khác: đóng ngay rồi chép nền — vì sao: hỏng thì còn vùng chọn để thử
  lại; đổi lại overlay còn thêm ~60–110 ms với ảnh 3840 × 1080.
- [gd1_05] Thông báo "Đã chép" là cửa sổ popup riêng (`crates/ui/src/notice.rs`) — phương án khác: `materiant::toast` — vì sao:
  toast cần cửa sổ còn mở, overlay đã đóng; giao diện đơn giản hơn toast, chưa có animation.
- [gd1_05] Thêm feature biên dịch `isolated` + `clipboard_probe` để đo RAM / chạy clipboard thật không đăng ký phím — phương án
  khác: cờ / biến môi trường lúc chạy — vì sao: bản phát hành không có đường tắt phím tắt.
- [gd1_05] `ClipboardText.text` là `PrivateText` thay vì `String` — phương án khác: đúng spec — vì sao: `{msg:?}` có ở nhiều chỗ
  log, kiểu riêng chặn nội dung lọt vào log; dây vẫn là chuỗi JSON.
- [gd1_05] Linux chưa bật `wayland-data-control` của `arboard` — phương án khác: bật sẵn — vì sao: không có máy Ubuntu để thử.

- [gd1_01] `fastcast-ui` nhả GPU (DirectX device + luồng vsync, `request_windowing(Headless)`) sau 10 s không cửa sổ,
  gắn lại khi có lệnh — phương án khác: giữ GPU suốt thời gian giữ ấm — vì sao: giữ ấm 9,7 → 4,2 MB (Task Manager),
  private bytes 51,7 → 12,5 MB; cái giá là lệnh đầu sau khi nhả chậm thêm 17–26 ms. Muốn lệnh nào cũng nhanh tuyệt đối
  ⇒ tăng `GPU_IDLE_DEFAULT` ở `crates/ui/src/app.rs`.
- [gd1_01] `fastcast-ui` nối `materiant` bằng đường dẫn `../materiant` (`[workspace.dependencies]`) — phương án khác:
  dependency git (khi có remote) hoặc chép vào `vendor/` — vì sao: `init.ps1` clone hai repo cạnh nhau, sửa materiant
  thấy ngay ở fastcast. Worktree cần junction `.claude/worktrees/materiant` → `materiant` (đã tạo, ghi ở `fastcast/CLAUDE.md`).
- [gd1_01] Daemon mất kết nối ⇒ UI thoát ngay nếu không cửa sổ, còn cửa sổ thì đợi đóng cửa sổ cuối — phương án khác:
  thoát ngay như khung GĐ0 — vì sao: daemon sập giữa lúc đang chụp / chú thích thì không mất việc dở của người dùng.
- [gd1_01] UI chỉ đọc `config.json` (thiếu / hỏng ⇒ mặc định, không ghi), `keepWarmMins: 0` ⇒ 1 phút, `fontSize` kẹp
  10–32 — phương án khác: UI cũng tạo file; 0 = không giữ ấm — vì sao: daemon là bên tạo / sửa file (tránh hai bên cùng
  ghi); giữ đúng hành vi GĐ0.
- [gd1_06] Launcher dựng sẵn ẩn nhưng **bị đóng khi UI nhả GPU** (10 s không cửa sổ nào hiện) — phương án khác: giữ
  launcher ẩn suốt thời gian giữ ấm (không bao giờ nhả GPU) — vì sao: GPUI từ chối nhả GPU khi còn cửa sổ, giữ launcher
  thì RAM giữ ấm 14,2 MB thay vì 7,3 MB suốt 5 phút; mở lại trong 10 s sau lần dùng vẫn tức thì, sau đó trả thêm thời gian
  gắn GPU + dựng cửa sổ ~200 ms (mục 9 của task). **Cập nhật**: đã giữ thêm — launcher vừa dùng được giữ ẩn (cùng GPU)
  ít nhất 60 s (`launcher::HOLD_AFTER_USE`), đổi lại 14,7 MB trong phút đó; muốn ngắn / dài hơn thì sửa hằng này.
- [gd1_06] Ẩn / hiện cửa sổ bằng Win32 `ShowWindowAsync` (`crates/ui/src/platform.rs`) — phương án khác: đóng / mở lại cửa
  sổ mỗi lần — vì sao: gpui-pre 0.3.10 không có `Window::set_visible` như plan ghi. macOS / Linux tạm đóng hẳn khi ẩn.
- [gd1_06] UI **ghi** `config.json` (chỉ khoá `launcher.position`, đọc lại file rồi ghi nguyên tử như `fst autostart`)
  — phương án khác: gửi IPC cho daemon ghi — vì sao: không thêm thông điệp IPC; daemon không giữ bản sao trong bộ nhớ để
  ghi đè. Đổi lại lựa chọn gd1_01 "UI chỉ đọc".
- [gd1_06] Bấm `open_launcher` khi launcher đang hiện ⇒ ẩn (bật / tắt như Raycast) — phương án khác: lệnh lặp đưa cửa sổ
  lên trước như tính năng khác — vì sao: giống Raycast / Spotlight. **Cập nhật 31/10/2026, chủ dự án đổi ý**: nhấp một
  dòng = chạy ngay (trước đây nhấp = chọn, nhấp đúp = chạy); rê chuột chỉ tô dòng, Enter giữ nguyên.
- [launcher-hotkey-fix] Giữ phím mặc định mở launcher `Alt+Space` trên mọi máy — phương án khác: đổi sang `Ctrl+Space` như
  chủ dự án tự gán — vì sao: `Ctrl+Space` toàn cục cướp gợi ý mã của VS Code và phím đổi bộ gõ, macOS cũng giữ tổ hợp này;
  `Alt+Space` chỉ đụng app launcher khác (Raycast, PowerToys Run). Muốn đổi thì sửa `Command::default_hotkey`.
- [launcher-hotkey-fix] Khối nổi đáy màn (thông báo, thanh quay) là viên thuốc nền trong suốt + bóng mờ; bảng quay xong nhiều hàng nút nên chỉ bo 16 px — phương án khác: acrylic thật — vì sao: acrylic phủ cả khung chữ nhật, lộ bốn góc. Nav Settings: có vạch ink, bỏ nền chọn và vòng focus (focus phím nhận biết qua vạch trượt).
- [launcher-hotkey-fix] Chip `Alt` trên Windows / Linux ghi chữ, chỉ macOS vẽ ⌥; `Ctrl` vẫn vẽ ⌃ theo bộ icon F-11 —
  phương án khác: đổi cả `Ctrl` sang chữ — vì sao: chỉ ⌥ gây đọc nhầm, chủ dự án đọc ⌃ đúng là Ctrl.
- [gd1_06] Chân launcher chưa có "Ctrl+K Hành động" (khoá `launcher.actions` đã có trong catalog) — phương án khác: hiện
  sẵn như bố cục mục 7 — vì sao: Ctrl+K làm ở gd1_07, hiện nhãn mà bấm không gì xảy ra gây khó hiểu.
- [gd1_02] UI đóng băng màn (không phải daemon), ngay khi nhận lệnh, trước khi gắn lại GPU — phương án khác: daemon chụp
  sẵn rồi gửi ảnh — vì sao: F-4 (daemon không mang `xcap` / GPU), ảnh vẫn là màn lúc bấm phím.
- [gd1_02] `GPU_IDLE_DEFAULT` 10 s → 60 s — phương án khác: giữ 10 s (RAM giữ ấm thấp hơn) hoặc giữ GPU suốt thời gian
  giữ ấm — vì sao: gắn lại GPU đo 150–405 ms trên máy nhà ⇒ overlay mở từ trạng thái đã nhả chậm ~3 lần (228–608 ms so
  với 57–164 ms); cái giá ~7 MB (16 thay vì 9 MB) trong một phút sau lần dùng.
- [gd1_02] Vùng chọn gồm cả pixel dưới con trỏ lúc nhả (kéo 0 → 1919 = 1920 px), nhấn – nhả tại chỗ = không chọn;
  Esc / chuột phải lần đầu bỏ vùng, lần hai đóng overlay — phương án khác: nửa mở (không với tới cột cuối của màn); Esc
  luôn đóng — vì sao: chọn được trọn màn; giống Snipaste / ShareX.
- [gd1_02] Khoá API overlay trên Windows khi chưa có spike Wayland gd0_07 — phương án khác: chờ máy Ubuntu — vì sao: GĐ1
  không bị chặn; điểm có thể vướng (cửa sổ toàn màn từng output, toạ độ toàn cục / kéo xuyên màn, chụp qua portal) ghi ở
  `plan/gd1_02_region-overlay.md` mục 8 cho gd0_07 soát.
- [gd1_02] Mở nguội overlay 496–674 ms (> 400 ms) nhưng KHÔNG cho daemon bật sẵn UI headless — phương án khác: daemon
  bật `fastcast-ui` lúc khởi động / sau khi UI tự thoát (~5 MB thường trực) — vì sao: trái F-4 ("UI bật khi dùng"), RAM
  thường trực là lựa chọn của chủ dự án; đã làm phần không đụng F-4 (đóng băng song song với gắn GPU). Gạch `_backlog.md`.
- [gd1_03] Chỉnh vùng (tay nắm, dời, mũi tên) kẹp trong **hình bao** desktop ảo — phương án khác: kẹp theo từng màn như
  kéo chọn (`Layout::clamp`) — vì sao: tay nắm cạnh chỉ dời một trục, kẹp theo màn gần nhất làm trục kia nhảy; bố cục so
  le cho dời vùng vào khe nhưng vẫn cắt được (phần khe trong suốt).
- [gd1_03] Kéo tay nắm đổi cỡ theo **độ lệch** con trỏ kể từ lúc nhấn — phương án khác: bắt cạnh về đúng con trỏ ngay khi
  nhấn — vì sao: nhấn lệch trong vùng bắt 8 px không làm cạnh nhảy; nhấn đúng pixel cạnh thì cạnh = pixel dưới con trỏ.
- [gd1_03] Thanh công cụ ở màn chứa góc **dưới phải** của vùng (khe ⇒ màn có mảnh lớn nhất); dưới → trên (né nhãn
  `W × H`) → trong — phương án khác: cùng màn với nhãn (góc trên trái) — vì sao: thanh nằm dưới-phải, chọn màn theo góc
  đó thì thanh sát chỗ nhả chuột.
- [gd1_03] "Lưu thành…" = icon Lưu + ba chấm vẽ tại chỗ — phương án khác: thêm icon `save-as` vào materiant `icon.rs` —
  vì sao: materiant đang nghiệm thu gd1_10, không sửa; gạch `_backlog.md`.
- [gd1_03] Overlay thật: chọn / chỉnh xong thì kích hoạt cửa sổ đang có thanh công cụ — phương án khác: để focus ở cửa sổ
  đã nhấn — vì sao: nhấn ở màn A nhả ở màn B thì Tab không tới được nút trên thanh (owner-qa của task).
- [gd1_03] Không giao Sonnet (i18n + ghép nút ~80 dòng) — phương án khác: giao theo D-5 — vì sao: dính interface đang
  chốt cùng lượt, giao đi tốn hơn tự làm.
- [gd1_07] UI gửi yêu cầu tới daemon trên chính kết nối nhận lệnh (trả lời FIFO) — phương án khác: mở kết nối `Cli` riêng
  mỗi yêu cầu — vì sao: UI chết ⇒ daemon thấy rớt và đăng ký lại phím tắt ngay, không chờ hạn 30 s.
- [gd1_07] (**Đã thay ở debt-ui**: mở ngay trên chân, góc phải.) Ctrl+K mở menu GIỮA launcher (`context_menu` trên gốc) — phương án khác: góc dưới phải như Raycast — vì sao:
  `Menu` của materiant chưa mở được theo neo từ code, materiant đang nghiệm thu gd1_10; gạch `_backlog.md`.
- [gd1_07] Thôi tạm gỡ phím tắt ngay khi bắt được tổ hợp (trước bước hỏi "Lấy phím") — phương án khác: giữ tạm gỡ tới lúc
  ghi xong — vì sao: hỏi / ghi không cần phím tắt tắt, giảm thời gian phím tắt chết.
- [gd1_07] Lịch sử là menu con (thời điểm tương đối + chip tổ hợp); Gỡ / Lịch sử / Mặc định trùng lệnh khác ⇒ cùng hộp
  thoại "Lấy phím" — phương án khác: hộp thoại danh sách riêng — vì sao: ít bước, dùng lại Menu.
- [gd1_07] Ký tự Shift của GPUI Windows (`@`) đổi ngược theo bố cục US — phương án khác: chờ GPUI lộ scan code — vì sao:
  bàn phím tiếng Việt dùng bố cục US; AZERTY… ghi mục 10.
- [gd1_07] Không giao Sonnet — phương án khác: giao phần ghép hộp thoại / i18n — vì sao: dính chặt pha capture phím của
  `LauncherView` + interceptor, interface đổi trong lượt.

- [gd1_04] Mã hoá PNG mức `Fast` (ảnh nhiễu 3840 × 1080: 89 ms, 6,1 MB) — phương án khác: `Default` (1 129 ms, 4,7 MB) — vì sao: overlay đứng tới khi tệp xuống đĩa; đổi lại tệp lớn hơn ~30 %. Đổi ở `crates/ui/src/save.rs::encode`.
- [gd1_04] Overlay chỉ đóng SAU khi tệp đã xuống đĩa — phương án khác: đóng ngay rồi ghi nền — vì sao: spec đòi lỗi thì không mất vùng chọn.
- [gd1_04] "Đã lưu" dùng cửa sổ thông báo riêng (`notice::show_saved`), không dùng `materiant::toast` như spec — phương án khác: thêm hành động bấm + cửa sổ trong suốt cho Toast ở materiant — vì sao: overlay đóng rồi thì Toast không còn cửa sổ để gắn, và Toast chưa có hành động bấm. Lỗi lưu vẫn dùng Toast vì overlay còn mở.
- [gd1_04] Thư mục `imageDir` người dùng tự chọn mà mất ⇒ báo lỗi, không tạo lại; Pictures mặc định chưa có thì tạo — phương án khác: luôn tạo — vì sao: tạo lại khi ổ USB đã rút sẽ ghi ảnh sang chỗ người dùng không ngờ.
- [gd1_04] Tên gõ trong hộp thoại có đuôi khác `.png` ⇒ nối thêm (`a.jpg` ⇒ `a.jpg.png`), trùng thì `_2` — phương án khác: giữ nguyên tên — vì sao: nội dung là PNG; hộp thoại chỉ hỏi ghi đè cho tên người dùng thấy.
- [gd1_04] `platform::exit_now` (`TerminateProcess`) ngay sau `ui stopped` — phương án khác: tìm gốc treo trong GPUI rồi vá — vì sao: treo chập chờn, tiến trình nằm mãi; không còn gì cần dọn lúc thoát. Chưa rõ gốc treo.
- [gd1_04] Thêm biến môi trường `FASTCAST_CONFIG_FILE` vào `paths::config_file` (daemon cũng đọc) — phương án khác: tham số dòng lệnh chỉ ở UI — vì sao: test phải không đụng cấu hình + Pictures thật; biến cùng người dùng đặt nên không mở thêm quyền.
- [gd1_04] Cửa sổ thông báo bật `WDA_EXCLUDEFROMCAPTURE` — phương án khác: chờ nó đóng rồi mới chụp — vì sao: không làm chậm lệnh chụp; đổi lại app khác (ghi hình, chia sẻ màn) cũng không thấy thông báo.
- [gd1_04] Mẫu tên tệp + JPEG / WebP đặt chỗ "Pro" ở `ROADMAP.md` GĐ4 — phương án khác: miễn phí — vì sao: D-4 chỉ đặt chỗ.

- [gd1_08] Số đo gồm cả pixel đầu và cuối (kéo từ pixel 300 tới 449 = 150 px, kéo đúng 100 px logic ở 150 % ra 151) — phương án khác: chỉ tính độ lệch — vì sao: nhấn trên pixel đầu, nhả trên pixel cuối của nút thì ra đúng cỡ nút; cùng quy ước vùng chọn gd1_02.
- [gd1_08] Esc thoát ngay dù đang có số đo; chuột phải mới bỏ số đo trước — phương án khác: Esc bỏ số đo rồi mới thoát như chọn vùng — vì sao: spec ghi "Esc thoát".
- [gd1_08] Chép xong đóng thước — phương án khác: giữ mở để đo tiếp — vì sao: focus phải trả về app để dán; giống chép ảnh gd1_05. Hỏng thì giữ số đo.
- [gd1_08] Vùng vắt qua hai màn khác scale không hiện phần `@` — phương án khác: quy theo màn chứa góc trên trái — vì sao: một số logic cho hai scale là số sai.
- [gd1_08] Lệnh overlay loại trừ nhau: đang mở thước mà bấm chụp vùng ⇒ đưa thước lên, không đổi công cụ — phương án khác: đóng cái cũ rồi mở cái mới — vì sao: ảnh đóng băng phải chụp sau khi overlay cũ đóng hẳn, phức tạp hơn; làm sau nếu thấy cần.
- [gd1_08] Thêm ngoài spec: Alt + mũi tên chỉnh số đo, thông báo "Đã chép 320×48" (`ruler.copied`), `ruler.copy_hint` có nhắc Alt + mũi tên — phương án khác: đúng spec — vì sao: đề xuất mục 10, cỡ S.

- [gd1_09] Chuỗi `rgb` giữ cú pháp CSS Color 4 có khoảng trắng `rgb(30 144 255)` — phương án khác: có dấu phẩy — vì sao: đúng spec; `rgba` đã là dạng dấu phẩy cho ai cần.
- [gd1_09] Sửa ví dụ spec: `#1E90FF` = `oklch(0.652 0.19 253.2)` — phương án khác: giữ `0.172 253.7` — vì sao: tính độc lập hai đường đều ra `0.19 253.2`.
- [gd1_09] Bỏ số 0 thừa trong OKLCH (`0.19`, không `0.190`) — phương án khác: luôn 3 chữ số — vì sao: spec đòi `oklch(1 0 0)`.
- [gd1_09] Lấy màu dùng phiên + view riêng (`PickerSession`) — phương án khác: `Tool::Picker` trong `OverlaySession` như spec và bàn giao gd1_08 — vì sao: `OverlaySession` mang vùng chọn / thanh công cụ không dùng tới; phiên riêng ít nhánh hơn.
- [gd1_09] Mũi tên kéo cả con trỏ thật (`SetCursorPos`) — phương án khác: chỉ dời điểm nhắm — vì sao: kính lúp + chữ thập phải cùng chỗ; GPUI không ẩn được con trỏ.
- [gd1_09] Nhớ định dạng lúc đóng overlay — phương án khác: ghi mỗi lần đổi — vì sao: Tab liên tiếp không ghi đĩa từng lần.
- [gd1_09] Thêm Shift+mũi tên, Ctrl+C, chuột phải đóng — phương án khác: đúng phím spec — vì sao: cùng phím với chọn vùng.

- [debt-ui] Menu Ctrl+K gắn vào phần thân launcher (thanh trên + kết quả) nên chuột phải trên chân launcher không còn mở menu — phương án khác: thêm chỗ neo riêng để chân vẫn mở — vì sao: Ctrl+K phải neo vào góc của thân thì mới nằm ngay trên chân; giống `examples/launcher.rs`.

## materiant
- [debt-ui] Shift+Tab ô số: gốc là `NumberInput` và `InputState` ghi cùng focus handle vào thứ tự Tab, không phải `OutdentInline`. Sửa bằng mốc focus cỡ 0 đứng trước ô — phương án khác: vá `gpui-base`, hoặc bỏ `NumberInput` tự dựng ô số — vì sao: không vá crate ngoài, giữ nguyên ↑ ↓ và nút bước.
- [debt-ui] `Tabs` theo cỡ chữ: chữ + chiều cao dòng co giãn, đệm và bề ngang sidebar 188 px giữ nguyên — phương án khác: co giãn cả đệm — vì sao: cỡ 20 đã xem ảnh, "Save and record" vừa cột.
- [debt-ui] Hằng riêng tư của component vào `style::tokens::<module>` (`pub(crate)`), hằng công khai giữ ở module — phương án khác: gộp thành token theme đổi được lúc chạy — vì sao: không đổi giá trị, không đổi API.
- [debt-ui] Select dùng `overlay::position::anchored` trực tiếp, không bọc `overlay::popover::Popover` — phương án khác: bọc Popover — vì sao: Popover tự bắt bấm, Enter, Space của trigger, trùng `gpui_base::Select`. Panel rộng thêm 2 px để thẳng mép khung ngoài (trước hụt 2 px).
- [debt-ui] Vòng focus switch nền tối dùng màu `muted` với độ đục vừa đủ 3:1 — phương án khác: tăng độ đục `neutral-400` — vì sao: `neutral-400` đục hẳn chỉ 2,8:1. Nền sáng giữ đúng web.
- [debt-ui] `ScrollbarMotion` 1 s + mờ 160 ms đặt ở theme `gpui-base`, áp cho mọi thanh cuộn kể cả Settings của fastcast — phương án khác: chỉ một số vùng — vì sao: đúng web, không đổi API. Mờ dần chưa xem được bằng mắt vì máy tắt Animation effects.
- [debt-ui] Chưa làm `ToastViewport` thành `RootPlugin`, Dialog mở bằng code — phương án khác: làm luôn — vì sao: plugin toast buộc đổi API fastcast đang dùng; Dialog mở bằng code chưa có nơi gọi. Gạch `_backlog.md`.
- [materiant-gd2_01] `ColorPicker` chỉ là nội dung bảng, `.floating(true)` tự vẽ nền nổi, không tự mở popover — phương án khác: nút màu + popover đóng gói sẵn — vì sao: overlay fastcast tự quản bảng, phím `c`, focus; bọc thêm sẽ phải vòng qua dismiss của Popover khi kéo ra ngoài.
- [materiant-gd2_01] Ô hex: đủ 6 chữ số áp ngay, 3 chữ số chỉ áp khi Enter / rời ô, chữ sai thì trả về màu hiện tại, không báo đỏ — phương án khác: chỉ áp khi Enter, hoặc viền lỗi — vì sao: thấy màu ngay lúc dán mã; `fff` có thể là nửa chừng của `fff000`; không có chữ báo lỗi cố định trong component.
- [materiant-gd2_01] Sắc độ kẹp 0–360, không xoay vòng khi bấm mũi tên; kiểu màu `Rgb` u8 đổi được `[u8; 3]` — phương án khác: xoay vòng, dùng `Rgba` f32 — vì sao: thumb không nhảy qua đầu kia; ảnh xuất cần đúng mã 8 bit.
- [materiant-gd2_01] Thêm ngoài phạm vi ghi trong task: `TextField::set_accessibility_label`, verb `drag@` của `--keys` — phương án khác: nhãn hex hiện thành chữ, không chạy thử được kéo — vì sao: bảng gọn, và `move@` gửi không giữ nút.

- [D-10] "trong suốt tầm 75%" đọc là độ đục 0,75 (nền còn đặc 75%) — hoặc trong suốt thật 75% (alpha 0,25, chữ khó đọc trên ảnh sáng) — vì chữ phải đọc được trên mọi ảnh nền; đổi một hằng `FLOATING_SURFACE_ALPHA` là xong. Dialog, toast giữ nền đặc — hoặc áp cả hai — vì yêu cầu chỉ nói popover và khối nổi trên overlay. Chữ phụ tông tối trên nền trắng tinh còn ~2,9:1.

- [dark-neutral] Tông tối mặc định: nền `#1c1c1c`, chữ `#f5f5f5`, chữ phụ `#a3a3a3`, viền trắng 8 %, viền ô nhập
  `#424242` — phương án khác: `#202020` / nền đen hẳn `#0a0a0a` như Black Pink — vì sao: gần nhất ảnh mẫu Raycast, chữ
  phụ 7,6:1. Black Pink (nhánh tối) cũng bỏ ánh xanh zinc ở muted / border; Rose / Rebecca giữ sắc ám có chủ ý.
- [dark-neutral] Tầng nổi phủ alpha (`ThemeColors::layer`) chỉ cho nền hover / chọn của List, chip Kbd, nút xoá /
  stepper, nền disabled ô nhập — phương án khác: đổi cả thang `neutral` thành alpha — vì sao: `neutral` còn làm viền,
  chữ, track switch, và phần tử có `ring_shadow` (bóng vẽ cả dưới nền ⇒ nền alpha sẽ bị ám màu vòng); thang đặc giữ
  nguyên nghĩa, `layer` đặt trên `surface` ra đúng cùng màu.
- [dark-neutral] Cửa sổ nền mờ = `Blurred` (acrylic) + nền tối alpha 0,88; tông sáng vẫn đục — phương án khác:
  `Transparent` không nhoè (chữ phía sau lộ, rối mắt) / sáng cũng trong — vì sao: brief "tông sáng không đổi"; đo không
  tốn RAM (gallery 15,0–16,0 MB mờ vs 15,9–16,4 MB đặc). Nền không đục ⇒ GPUI tắt ClearType (chữ AA xám); kéo cửa sổ
  acrylic Windows 10 có thể trễ — kiểm tay.
- [dark-neutral] Ô tìm của launcher vẫn là `TextField` có khung, nền `surface` ĐẶC (không phủ alpha) — phương án khác:
  nền ô alpha / ô trần không khung kiểu Raycast — vì sao: ô nhập vẽ vòng hover / focus bằng `ring_shadow` (bóng dưới
  nền) ⇒ nền alpha bị ám hồng khi focus; ô trần là đổi bố cục (ngoài phạm vi) — mục 10 của task. **Đã thay** ở lượt
  sửa sau kiểm: ô trần `InputBase` theo yêu cầu header kiểu Raycast.
- [dark-neutral] Nhấp ra ngoài launcher tự ẩn: ngoài `AllowSetForegroundWindow` từ daemon, UI còn đọc foreground + nút
  chuột mỗi 50 ms khi launcher hiện — phương án khác: hook chuột toàn cục `WH_MOUSE_LL` / chỉ dựa sự kiện mất active
  của GPUI — vì sao: hook toàn cục làm chậm chuột cả máy khi luồng UI bận; sự kiện GPUI không tới khi cửa sổ không
  giành được foreground (nguyên nhân lỗi). Nhịp 50 ms chỉ chạy lúc launcher hiện.
- [dark-neutral] Giữ `focus_search` trong `on_select` của launcher (khuyến nghị là bỏ) — vì sao: dòng của `VirtualList`
  lấy focus ở `on_click` lúc nhả chuột, sau handler nhấn chuột của cha ⇒ bỏ thì nhấp dòng mất con trỏ chữ (test bắt).
- [dark-neutral] Icon app tạm: ba lớp chồng tự vẽ (`fastcast/crates/ui/assets/app-icon.svg`, nét `currentColor`, tô
  theo màu chữ) — phương án khác: lấy icon `layers` của lucide (ISC) — vì sao: tự vẽ khỏi soát giấy phép; đổi icon chỉ
  thay tệp.

- [ripple / window] `materiant::window::window_options()` = `WindowOptions` mặc định với `inactive_frame_interval:
  None`; gallery + mọi cửa sổ materiant nên trải `..window_options()` — phương án khác: giữ mặc định GPUI (cửa sổ không
  active ~30 fps, tiết kiệm điện khi app chạy animation dài ở nền) — vì sao: đo ripple ở cửa sổ không active chỉ 24 fps
  (khung 41–50 ms), bỏ trần thì 60 fps đều, khung chậm nhất 17 ms; animation của materiant chỉ xin khung lúc đang chạy nên
  nghỉ không tốn gì. Có thể đây là cảm giác "FPS thua bản web" bạn thấy; nếu vẫn thấy giật khi cửa sổ ĐANG active, chạy
  `$env:GALLERY_FRAME_STATS=1; pwsh start.ps1 docs style` rồi bấm ô ripple — dòng `FRAMES … fps` cho biết số thật.
- [materiant-gd1_07] Dialog mở theo kiểu KHAI BÁO: app giữ `DialogHandle::new(cx)` (`open / close / is_open`) và vẽ
  `Dialog::new(id, &handle)…` trong cây của mình — phương án khác: đúng spec `Dialog::open(window, cx, |…| …)` mở bằng
  code — vì sao: mở bằng code cần một lớp chứa đăng ký vào `Root` TRƯỚC khi tạo cửa sổ (`Root::register_plugin` ⇒ sửa
  `lib.rs` / gallery `main.rs`, cấm khi làm song song); kiểu khai báo giống `ng-template overlayDialog [(open)]` của web.
  Muốn thêm `open` bằng code thì làm ở task sau (thêm `overlay::init` vào `materiant::init`).
- [materiant-gd1_07] Tooltip là `.with_tooltip(id, text)` (bọc phần tử) thay `.tooltip(text)` — phương án khác: đúng tên
  spec — vì sao: trùng `StatefulInteractiveElement::tooltip` của GPUI (gọi trên `div().id(…)` là lỗi biên dịch "nhiều
  method trùng tên"), và cần `id` để giữ trạng thái rê / focus.
- [materiant-gd1_07] Tự dựng định vị (`overlay::position::anchored`) + Popover + Dialog, KHÔNG bọc `gpui_base::Popover` /
  `Dialog` — phương án khác: bọc style lên primitive gpui-base — vì sao: `Popup` của gpui-base neo góc, không lật cạnh
  (spec cần lật); `gpui_base::Dialog` gán Enter = Confirm trong ngữ cảnh hộp thoại ⇒ Enter trên nút "Huỷ" chạy `on_ok`.
  Vẫn dùng lại `FocusTrapElement` (Tab vòng) và `motion` của gpui-base. Cỡ code vì thế ~1 300 dòng (trần 900).
- [materiant-gd1_07] Không mũi tên, hiệu ứng hiện / ẩn chỉ mờ dần (web: mờ + `scale .96`) — phương án khác: vẽ mũi tên
  bằng path — vì sao: GPUI không xoay / co giãn được `div`; mũi tên tuỳ chọn ở web, Material không dùng.
- [materiant-gd1_07] Bề mặt Popover nền tối có viền 1 px `border` (web: không viền) — phương án khác: đúng web — vì sao:
  ảnh gallery nền tối: panel cùng màu `surface` với trang, bóng đen gần như không thấy ⇒ panel lẫn vào nền. Menu
  (gd1_08) / Select dùng `popover::surface` sẽ cùng diện mạo.
- [materiant-gd1_09] Toast rê chuột rồi rời ra ⇒ đếm lại ĐỦ 5 s (đúng `toast-timer.ts` + spec "restart full duration")
  — phương án khác: tiếp phần còn lại (như ghi ở C2 của task, như Sonner / `gpui_base::ToastManager`) — vì sao: spec
  web là nguồn thật; đọc xong rời chuột thì toast không biến mất ngay sau 0,1 s.
- [materiant-gd1_09] `Select::new(id)` (không `cx`), RenderOnce + state theo id — phương án khác: đúng spec `new(id, cx)`
  + `Entity` do app giữ — vì sao: cùng kiểu Switch / Checkbox, app chỉ giữ chỉ số chọn.
- [materiant-gd1_09] Toast cần app đặt MỘT `ToastViewport::new()` ở view gốc; tối đa 5 toast (thêm nữa thì cái cũ nhất
  tự ra); ra kiểu ✕ = mờ tại chỗ, không phóng to; nền đặc (không blur) — phương án khác: `RootPlugin` đăng ký trong
  `materiant::init` (app khỏi đặt — cần sửa `lib.rs`, ghi nợ gd1_10); cuộn trong khung như web; scale — vì sao: làn song
  song không được sửa `lib.rs`; GPUI không có `scale` / `backdrop-filter` cho `div`.
- [materiant-gd1_09] Select tự vẽ khung theo `cx.field_tokens()`, không bọc `FieldShell` — phương án khác: bọc shell —
  vì sao: shell ép con trỏ chữ `I` và gộp nhãn / gợi ý vào vùng neo của popup (panel rơi dưới dòng gợi ý).
- [materiant-gd1_09] Tabs dọc: vạch + đường kẻ ở mép TRÁI — phương án khác: mép phải (phía nội dung) — vì sao: kiểu
  "vạch trái của cột menu" mà doc `tab-ink.ts` nêu.
- [materiant-gd1_04] `TextField::new(id, window, cx)` / `NumberField::new(id, window, cx)` (thêm `window`) — phương án
  khác: đúng spec `new(id, cx)`, tạo `InputState` trễ ở lần vẽ đầu — vì sao: `InputState::new` của gpui-base cần
  `window`; tạo trễ thì `value()` trước khung đầu không đọc được.
- [materiant-gd1_04] ↑ ↓ trong `TextField` đi tiếp tới cha (gallery: đổi trang khi đang gõ) — phương án khác: ô chữ nuốt
  ↑ ↓ — vì sao: launcher của fastcast cần ↑ ↓ chọn kết quả trong lúc con trỏ ở ô tìm kiếm, cùng luật "không nuốt Esc /
  Enter".
- [materiant-gd1_04] Ô lỗi / cảnh báo lúc nghỉ KHÔNG có quầng (chỉ viền màu), hover / focus mới có — phương án khác:
  quầng `/10` lúc nghỉ như comment của `FIELD_STATE_CLASS_MAPPED` bản web — vì sao: class thật của bản web là
  `ring-transparent` lúc nghỉ, theo code chứ không theo comment.
- [materiant-gd1_04] `NumberField` chỉ dấu thập phân `.`, chưa nhóm nghìn — phương án khác: cấu hình dấu theo locale
  (`1.000,5`) — vì sao: gpui-base bước / kẹp giá trị theo `.`; FPS / cỡ chữ không cần; `numeric_mask` đã có sẵn khi cần.
- [materiant-gd1_06] `VirtualList` dựng trên `uniform_list` của gpui-pre — phương án khác: `gpui_base::VirtualList` —
  vì sao: bản gpui-base cho dòng khác cao, đòi `Rc<Vec<Size>>` mỗi dòng một phần tử + một `Entity` view; dòng cùng cao
  thì `uniform_list` chỉ cần số dòng (RAM không theo số dòng) và `gpui_base::Scrollbar` nhận sẵn handle của nó.
- [materiant-gd1_06] Phím danh sách là action trong `key_context("VirtualList")`, gán lười một lần ở lần vẽ đầu
  (`materiant::list::bind_keys`) — phương án khác: `on_key_down` (không cần gán phím) / gán trong `materiant::init` —
  vì sao: GPUI chạy action của key binding TRƯỚC `on_key_down` ⇒ ↑ ↓ của view cha (gallery đổi trang) sẽ thắng;
  `lib.rs` cấm sửa ở làn song song ⇒ gd1_10 dời `bind_keys` vào `init`.
- [materiant-gd1_06] `ListNav::apply(key, ix: Option<usize>, …) -> Option<usize>` (spec ghi `ix -> ix`) — phương án khác:
  `usize` — vì sao: `count = 0` phải "không chọn gì", và chưa chọn gì thì ↓ vào dòng đầu / ↑ vào dòng cuối.
- [materiant-gd1_06] `ScrollArea` mặc định hiện thanh khi con trỏ trong khung + khi đang cuộn (`ScrollbarVisibility::
  Hover`) — phương án khác: mặc định web `scroll` (chỉ hiện lúc cuộn) — vì sao: task ghi "hiện khi rê / khi đang cuộn";
  `Scrolling` vẫn chọn được.
- [materiant-gd1_05] `on_change` của Checkbox / RadioGroup / Switch nhận `&T` (`Fn(&CheckState | &usize | &bool, …)`)
  — phương án khác: nhận giá trị `T` như primitive gpui-base — vì sao: dùng thẳng được `cx.listener(|this, v: &T, …|)`.
- [materiant-gd1_05] `Switch` có `.label()` (nhãn bên phải, cách track 8 px) — phương án khác: như web, nhãn để ngoài
  component (`field-shell`) — vì sao: bấm nhãn cũng bật / tắt, có tên cho trình đọc màn hình mà app khỏi tự ghép.
- [materiant-gd1_05] Thời lượng dấu tick / chấm radio = `CONTROL_DURATION_MS` 200 ms — phương án khác: đúng web
  (checkbox 180 ms, radio 250 ms) — vì sao: `style.rs` ghi token này cho cả ba control; chênh 20–50 ms khó thấy.
- [materiant-gd1_05] Tick lộ dần trái → phải bằng khung cắt; KHÔNG xoay tick ↔ trừ như web — phương án khác: vẽ nét
  thật (`stroke-dashoffset`) — vì sao: GPUI vẽ SVG thành mặt nạ, không có nét để chạy, không xoay được `div`.
- [materiant-gd1_03] "Màu nút chưa đúng": đã so 288 ô (6 dáng × 6 màu × nghỉ / rê / nhấn / disabled × sáng / tối) với
  Chrome chạy `btn.css` gốc — khớp ≤ 1/255, công thức KHÔNG lệch. Chỗ khác là BẢNG MÀU: gallery dùng theme mặc định Black
  Pink (bạn chốt ở gd1_01: danger tối `#ffb4ab` hồng nhạt, warning `#f5c518`…), còn trang tài liệu web ở theme "Mặc định"
  dùng màu dự phòng một mã cho cả hai nền (deeppink, đỏ `#ec003f`, `#faad14`, `#52c41a`). Trang `button` có nút
  "Palette" đổi qua lại để so 1:1 — phương án khác: đổi `DEFAULT_SEEDS` của materiant sang bảng web "Mặc định" (sửa
  `theme/`, đụng mọi trang) — vì sao: theme mặc định là quyết định của bạn ở gd1_01; muốn đổi thì báo, sửa ở gd1_10.
- [materiant-gd1_03] Bóng `elevated` nền tối = `--shadow-1` tối của web (đen 20 %, sáng 10 %) + nền ngả 4 % màu chữ (đề
  xuất 4 bạn chọn) — phương án khác: đậm hơn web (`--shadow-2` 40 %) — vì sao: đúng bản web; trên nền `#0f172a` bóng
  đen nào cũng khó thấy, chỗ tách nút khỏi nền chủ yếu là nền ngả 4 %. Vẫn thấy mờ ⇒ nói, đổi `SHADOW_ALPHA_DARK`.
- [materiant-gd1_03] Thêm `.selected(bool)` cho `Button` / `IconButton`: dáng `elevated` đang bật ⇒ nền màu gốc (chip
  bật / tắt như `aria-pressed="true"` của web) — phương án khác: không có (spec không ghi) — vì sao: "làm đủ theo button
  type", web có trạng thái này ở `elevated`.
- [materiant-gd1_08] Cột phím tắt của Menu là chip `Kbd` (`[Ctrl][C]`) — phương án khác: chữ trơn 12 px muted như web
  (`.menu-item-shortcut`) — vì sao: phác thảo mục 7 của task vẽ chip, `Kbd` có sẵn từ gd1_03; đổi sang chữ trơn chỉ một
  chỗ trong `menu.rs` nếu chủ dự án muốn giống web.
- [materiant-gd1_08] Menu không dùng roving focus: focus nằm ở khung menu, con trỏ là chỉ số (`menu_nav`); rê chuột dời
  con trỏ + kéo focus về khung đang rê — phương án khác: mỗi mục một `FocusHandle` như web — vì sao: một handle mỗi khung
  đủ cho bàn phím, khỏi giữ N handle; hành vi người dùng thấy như web.
- [materiant-gd1_08] Menu chuột phải = `.context_menu(|menu, window, cx| …)` trên `Stateful<Div>` + Shift+F10 (mở giữa
  phần tử) khi focus nằm trong phần tử — phương án khác: chỉ chuột phải như web — vì sao: dùng hết bằng bàn phím (luật
  "Xong một component"); Shift+F10 là phím menu ngữ cảnh chuẩn của Windows / Linux.
- [materiant-gd1_08] Menu chuột phải mở sát con trỏ (khoảng hở 0, web 4 px) — phương án khác: 4 px như dropdown — vì sao:
  giống menu hệ thống; dropdown giữ 4 px như web.
- [materiant-gd1_08] Chọn mục ⇒ đóng cả chuỗi menu TRƯỚC rồi mới gọi `on_select` (web: emit rồi đóng) — phương án khác:
  đúng thứ tự web — vì sao: handler mở Dialog (fastcast gd1_07 "Gán phím tắt…") thì Dialog giữ được focus, không bị
  menu đóng sau trả focus về nút.
- [materiant-gd1_10] Ô tìm của launcher example là `TextField` (khung + vòng focus) — phương án khác: ô trần
  `gpui_base::Input` như fastcast — vì sao: ví dụ để nghiệm thu component materiant.
- [materiant-gd1_10] Launcher example "ẩn" = đóng cửa sổ + nhớ chỗ kéo ở tệp nhỏ trong thư mục tạm — phương án khác: ẩn
  Win32 + giữ tiến trình như fastcast — vì sao: ví dụ không có tiến trình giữ ấm, không nhúng FFI ẩn cửa sổ vào crate.
- [materiant-gd1_10] Thêm `ContextMenuExt::context_menu_at(Anchor, …)` (mở bằng phím tại góc phần tử chủ) — phương án
  khác: để Ctrl+K mở giữa launcher — vì sao: Raycast mở ngay trên chân; fastcast launcher cần đúng kiểu này.
- [materiant-gd1_10] `materiant::init` gán phím mặc định của mọi component (vẫn gán lười được) — phương án khác: giữ gán
  lười ở lần vẽ đầu — vì sao: nợ gd1_05 / gd1_06; keymap đủ ngay từ đầu cho chip phím `MenuItem::action`.
- [materiant-gd1_10] Nợ "dời token lên `style.rs` / `icon.rs`" không làm ở gd1_10, gom một task GĐ2 — phương án khác:
  làm luôn — vì sao: chạm ~10 module, vượt cỡ S; đóng GĐ1 dù C3 (macOS / Ubuntu) / C4 (so web) chờ kiểm tay (D-9).
- [icon F-11] Chủ dự án gõ "25..9" ⇒ đọc là 25.9 (chữ DEL) — phương án khác: hỏi lại — vì sao: chỉ có bản 25.9 khớp.
- [icon F-11] Bản đặc đã chọn (1.6, 11.6, 12.6, 13.2, 31.2) giữ đặc, chỉ đưa về cùng khung; chỉ bản nét mới thống nhất nét 2 — phương án khác: đổi hết sang nét — vì sao: chủ dự án viết "các icon dạng outline thì đưa về chung", và đã tự chọn các bản đặc.
- [icon F-11] 2.7 bỏ ô nền + gradient, 1.6 / 12.6 bỏ màu riêng ⇒ một màu `currentColor` — phương án khác: giữ màu, nạp bằng ảnh — vì sao: yêu cầu ăn theo theme primary.
- [icon F-11] 15.1 giữ nét 1 / 2 / 4 — phương án khác: nét đều — vì sao: độ dày khác nhau chính là nghĩa của icon.
- [icon F-12] Icon tuỳ chỉnh Pro chỉ đặt chỗ (quyết định + ROADMAP GĐ4), chưa viết mã — phương án khác: thêm `IconSource` vào materiant ngay — vì sao: D-4 chỉ đặt chỗ, bộ icon cũng chưa nối vào app.
- [icon F-11] Dòng "Mở launcher" / "Settings" dùng icon materiant (`Search`, `Settings`), nút Đóng của thanh công cụ giữ `Close` — phương án khác: vẽ thêm vào bộ F-11 — vì sao: chủ dự án chưa chọn icon cho các mục này, icon materiant cùng hệ nét.
- [icon F-11] Chip phím hiện icon trên mọi OS (Ctrl = ^, Alt = ⌥ cả trên Windows) — phương án khác: chỉ macOS — vì sao: chủ dự án chọn bộ này không phân biệt OS; đổi chỉ một chỗ ở `assets::key_icon`.
- [icon F-11] Icon lệnh tô `primary` đúng như yêu cầu, primary mặc định hiện là hồng của materiant, khác đỏ icon app — phương án khác: đặt primary của fastcast thành đỏ `#FF6363` — vì sao: chủ dự án nói ăn theo theme, chưa đổi theme.
- [gd3_01] `target_size` đặt ở `fastcast_core::worker`, `fastcast_video::size` chỉ re-export — phương án khác: để ở `video` như spec, UI tự tính lại — vì sao: gd3_10 phải hiện cỡ ra thật mà UI không được phụ thuộc `fastcast-video`, chép hai nơi sẽ lệch.
- [gd3_01] `source::{D3d, create_device, create_bgra}` là mã thật ngay từ stub — phương án khác: stub, gd3_05 mới điền — vì sao: gd3_04 chạy song song cần device để mã hoá hoạ tiết.
- [gd3_01] `fastcast-video` phụ thuộc `fastcast-capture` chỉ để dùng `geometry` — phương án khác: `#[path]` như spike, hoặc tách crate — vì sao: một nguồn sự thật cho F-3; `xcap` tốn thời gian biên dịch, không gọi tới thì linker bỏ (chưa đo cỡ `fastcast-rec`, gd3_06 đo RAM).
- [gd3_01] Biến `FASTCAST_RECORD_*` kích hoạt qua lệnh `record_region` trong `commands::dispatch` — phương án khác: đọc lúc UI khởi động trong `app.rs` — vì sao: `app.rs` không thuộc tệp của task, lệnh lặp cũng thử được.
- [gd3_01] `FASTCAST_OCR_EXE` / `FASTCAST_REC_EXE` có hiệu lực cả ở bản release — phương án khác: chỉ bản debug — vì sao: gd3_13 đo bản release với exe giả; ai chỉnh được biến môi trường của tài khoản thì đã chạy được mã bất kỳ.
- [gd3_05] Vùng ngoài desktop ⇒ `RecError::DisplayChanged` — phương án khác: `Internal` — vì sao: vùng được chọn trên bố cục cũ, UI báo đúng nguyên nhân.
- [gd3_05] `Source::poll` giữ `windows::Result`, thêm `source::rec_error` — phương án khác: đổi `poll` sang `RecError` — vì sao: không đổi hợp đồng gd3_01 mà gd3_06 đang chờ.
- [gd3_05] `FASTCAST_REC_BACKEND=dxgi` mà một màn không mở được DXGI (adapter khác, màn xoay) ⇒ màn đó dùng WGC — phương án khác: báo lỗi — vì sao: vẫn quay được; nếu đổi mặc định sang DXGI thì màn xoay không chết. Đang kiểm viền vàng thì xem log `dxgi unavailable`, không thì tưởng nhầm đang chạy DXGI.
- [gd3_05] Thêm `FASTCAST_REC_WINDOW=<hwnd>` + `source_probe --serve`, có hiệu lực ở bản release — phương án khác: chỉ bản debug — vì sao: gd3_06, gd3_13 cần đo bản release trên cửa sổ thử mà không quay màn thật.
- [gd3_05] Con trỏ DXGI vẽ bằng `DrawIconEx` trên texture GDI-compatible — phương án khác: `GetFramePointerShape` + shader — vì sao: ít mã, GDI lo con trỏ đảo màu; cái giá: thêm hai texture cỡ vùng, con trỏ động đứng ở khung đầu, cỡ có thể lệch trên màn DPI khác DPI hệ thống.
- [gd3_05] Soát bố cục màn mỗi 500 ms giữa lúc quay — phương án khác: cửa sổ ẩn nghe `WM_DISPLAYCHANGE` — vì sao: vòng quay kiểu kéo, không có vòng thông điệp; trễ nửa giây chấp nhận được.
- [gd3_04] `Encoder` tự lấp im lặng khi stream âm thiếu mẫu (trễ > 200 ms, và lúc `finish`), `write_audio` căn mốc theo số mẫu đã ghi — phương án khác: `SendStreamTick`, hoặc để gd3_07 tự lấp — vì sao: Sink Writer chặn `WriteSample` của video ~1 s / khung khi stream âm không có mẫu, mà loopback im là ca thường; sửa một chỗ, track âm liên tục. Chưa thử `SendStreamTick`.
- [gd3_04] AAC 128 kbps — phương án khác: 96 / 160 / 192 kbps — vì sao: ~1 MB / phút, đủ cho âm hệ thống + giọng nói.
- [gd3_04] Thêm `examples/common/mod.rs` ngoài danh sách tệp của task — phương án khác: chép hoạ tiết vào từng example — vì sao: hai example + test cần chung; đúng trần 7 tệp.
- [gd3_04] Dừng trước khung đầu ⇒ `Internal`, không tự ghi khung giả — phương án khác: `Encoder` tự ghi một khung — vì sao: `Encoder` không biết nội dung, gd3_06 ghi khung ghép hiện tại.
- [gd3_12] Esc ở bảng sau khi quay = giữ + báo "đã lưu" như Ctrl+S — phương án khác: đóng im lặng — vì sao: tệp nằm lại trong thư mục, người dùng cần biết nó ở đâu; Alt+F4 thì đóng im.
- [gd3_12] Hộp Lưu thành… gợi ý tên hiện có của video, không sinh tên theo giờ mới — phương án khác: `file_name_now` như ảnh — vì sao: tên đã theo giờ lúc quay, sinh lại chỉ làm lệch.
- [gd3_12] Chọn đúng tệp đang có trong hộp thoại ⇒ không làm gì, báo đã lưu — phương án khác: báo lỗi — vì sao: chép đè lên chính nó rồi xoá bản cũ là mất video; người dùng chọn vậy nghĩa là giữ.
- [gd3_12] Chép sang ổ khác xong mà không xoá được bản cũ (app khác đang mở) ⇒ tính là thành công, chỉ log — phương án khác: báo lỗi — vì sao: video đã tới nơi, báo lỗi dễ khiến người dùng tưởng hỏng; đổi lại còn thừa một bản.
- [gd3_12] Không xoá được khi Bỏ ⇒ bảng vẫn mở, báo lỗi — phương án khác: đóng bảng — vì sao: người dùng đóng app đang giữ tệp rồi thử lại được.
- [gd3_12] Bảng cách đáy vùng làm việc 120 px, loại khỏi ảnh chụp, không có phím tắt riêng cho Bỏ — phương án khác: sát đáy như `notice`, thêm phím Delete — vì sao: chừa chỗ cho thông báo lỗi ngay dưới bảng; bảng để đó không lọt vào lần chụp / quay sau; xoá video không nên có phím nhanh.
- [gd3_12] Nút huỷ trong hộp xác nhận là khoá mới `record.discard_keep` ("giữ lại") — phương án khác: dùng lại `hotkey.cancel` ("Huỷ" / "Cancel") — vì sao: rõ nghĩa hơn cạnh nút "bỏ", đúng luật viết thường.
- [gd3_08] `render` của panel nhận `widgets`, `host`, `window`, bỏ `at`; thêm móc `state`, `size`, OCR thêm `copy` — phương án khác: giữ đúng ba móc của spec — vì sao: `NumberField` cần `Window` + chỗ giữ entity theo cửa sổ, nút Chép phải vào panel mà gd3_09 không được sửa `mod.rs`.
- [gd3_08] `Tool::Ocr` xếp thanh trên, panel dưới, cùng mép phải, cả khối qua `toolbar::place` — phương án khác: panel sát vùng, thanh dưới cùng — vì sao: panel thấp hơn chỗ dành sẵn thì không hở giữa hai khối.
- [gd3_08] Có panel: Enter lúc focus ở nút / ô nhập không tới `on_key`, mũi tên chỉ dời vùng khi focus ở gốc cửa sổ — phương án khác: mọi phím qua panel, panel tự xét focus — vì sao: móc chạy trong `Context<OverlaySession>`, không có `Window` để xét focus.
- [gd3_08] Lệnh lặp trên màn giả không gọi `activate_window` — phương án khác: giữ nguyên — vì sao: test mới gửi lệnh lặp, không được giành focus của máy đang dùng thật.
- [gd3_07] `pts` đếm theo số mẫu, neo vào `qpcPosition`, lệch > 20 ms thì neo lại — phương án khác: `devicePosition` thuần, hoặc giờ nhận gói — vì sao: đồng hồ thiết bị trôi so với video (QPC), giờ nhận gói bị giật; giá là lệch 100 ppm thì mỗi ~200 s có một bước 20 ms.
- [gd3_07] Giữ chữ ký stub `audio::start`, mốc `pts` 0 = lúc GỌI hàm — phương án khác: lúc hàm trả về, hoặc thêm tham số mốc thời gian — vì sao: `session.rs` của gd3_06 đo `offset` từ trước khi gọi rồi trừ khỏi `pts`; bản gộp đầu lấy lúc trả về nên đã sửa.
- [gd3_07] Mất thiết bị giữa chừng: mở lại mỗi 500 ms, đoạn thiếu thành im lặng, không `Failed` — phương án khác: dừng cuộc quay — vì sao: mất cả video vì rút tai nghe tệ hơn; UI chưa được báo (backlog).
- [gd3_07] Thêm cờ `--tone` cho `audio_probe`, tự phát sóng −46 dB khoảng 1 s trên máy chủ dự án khi chạy thử — phương án khác: chỉ thu lúc máy im — vì sao: máy im thì `packets=0`, nhánh đọc gói không chạy.
- [gd3_06] Mất nguồn giữa chừng (`DisplayChanged`, `CaptureLost`) ⇒ vẫn chốt và đặt tệp đích rồi mới `Failed` — phương án khác: xoá `.part` như `fake_rec` — vì sao: rút màn không nên mất video đã quay, hợp đồng không đổi; cái giá: UI báo lỗi mà chưa nói video còn (gd3_13 mục 0).
- [gd3_06] Không đổi tên được ⇒ `OutputUnwritable` và giữ `.part` — phương án khác: xoá — vì sao: video đã quay xong, xoá là mất; cái giá: sót tệp riêng tư tới lần quay cùng tên.
- [gd3_06] Không ghi đè bằng `fs::hard_link`, ổ FAT / exFAT soát rồi `fs::rename` — phương án khác: `MoveFileExW` — vì sao: không phải thêm feature vào `Cargo.toml` chung.
- [gd3_06] Sửa `video/src/lib.rs` ngoài tệp sở hữu (hai dòng `cfg` cho `unsupported`) — phương án khác: `allow(dead_code)` — vì sao: gd3_07 và gd3_06 cùng bỏ stub nên clippy đỏ; hàm chỉ còn dùng ngoài Windows.
- [gd3_11] Opus tự làm `controls.rs`, không giao Sonnet — phương án khác: giao theo mục 2b của plan — vì sao: view ~60 dòng dính chặt trạng thái phiên và cách đặt cửa sổ, lời giao dài bằng code.
- [gd3_11] Mỗi màn một cửa sổ nền trong, viền bám mép, vẽ ngoài vùng, sát mép màn thì vào trong — phương án khác: bốn cửa sổ thanh mảnh mỗi màn — vì sao: đúng spec, ít cửa sổ hơn; RAM đo được 17–18 MB.
- [gd3_11] Đã `Stop` mà 30 s chưa chốt ⇒ giết worker, báo lỗi — phương án khác: chờ mãi — vì sao: treo thì khung không bao giờ gỡ; chưa có exe giả để kiểm nhánh này.
- [gd3_11] Worker lỗi / chết ⇒ UI xoá `<output>.part` — phương án khác: để worker tự lo — vì sao: chết ngang thì worker không dọn được, `.part` chứa hình màn của người dùng và không mở được.
- [gd3_10] Opus tự làm phần `[sonnet]` — phương án khác: giao theo mục 2b — vì sao: panel và thứ tự đóng overlay cùng một tệp, lời giao dài bằng code.
- [gd3_10] Ô FPS không đặt `range`, số sai báo đỏ + khoá nút — phương án khác: `range(1..=60)` — vì sao: `NumberField` kẹp khi rời ô, trái "không kẹp lặng lẽ"; cái giá: ↑ ↓ vượt 60 không dừng mà báo lỗi.
- [gd3_10] Độ nét dùng `RadioGroup` — phương án khác: hai nút như bản vẽ — vì sao: mũi tên chọn sẵn, một điểm dừng Tab, Enter ở nhóm là bắt đầu.
- [gd3_10] Chờ tối đa 1 s cho overlay gỡ, quá hạn vẫn quay + ghi log — phương án khác: huỷ quay — vì sao: bấm mà không có gì xảy ra tệ hơn; cái giá: khung đầu có thể dính overlay ở ca hiếm.
- [gd3_09] Opus tự làm phần vẽ panel — phương án khác: giao Sonnet theo mục 2b — vì sao: cùng tệp với logic chép / huỷ.
- [gd3_09] Hàng đợi OCR một chỗ, mới thay cũ — phương án khác: gửi mọi ảnh cho worker, bỏ trả lời cũ — vì sao: chỉnh vùng liên tục không dồn ảnh cũ, engine thật mỗi ảnh tốn cả giây.
- [gd3_09] Thiếu exe `fastcast-ocr` báo "hãy cài lại" — phương án khác: lỗi chung kèm thử lại — vì sao: thử lại không giúp được gì.
- [gd3_09] Thêm hạn 60 s khi worker không trả lời, giết + báo lỗi — phương án khác: chờ mãi như spec — vì sao: không thì panel kẹt "đang đọc" và giữ ảnh đóng băng.
- [gd3_09] Sửa `tests/overlay.rs` (tệp của gd3_08): panel test luôn trỏ exe OCR không có — phương án khác: bỏ nút thử lại khỏi thứ tự Tab — vì sao: giữ dùng được bằng bàn phím, test không còn phụ thuộc `fastcast-ocr` thật trong `target/`.
- [gd3_03] Dll ở `<models>/onnxruntime.dll` — phương án khác: cạnh exe như spike — vì sao: task ghi vậy, bộ model gọn một thư mục khi đưa vào bản cài.
- [gd3_03] Đánh dấu ✅ khi C13 (engine thật) chưa chạy, giao gd3_02 chạy lúc gộp — phương án khác: chờ gd3_02 gộp rồi mới đóng — vì sao: luật làn GĐ3 "làn gộp sau chạy"; chữ và số đo vẫn chưa có tới lúc đó.
- [gd3_03] Sha256 zip ONNX Runtime ghim theo lần tải đầu — phương án khác: đối chiếu nguồn độc lập — vì sao: script dev, chỉ cần phát hiện tệp đổi; GĐ4 đưa vào bản cài thì nên soát lại.
- [gd3_02] Có tệp model thiếu thì báo `ModelMissing` kể cả khi tệp khác sai sha256 — phương án khác: báo `ModelCorrupt` nếu có bất kỳ tệp sai — vì sao: thiếu tệp gỡ được bằng cách chép lại, báo "hỏng" làm người dùng nghi nhầm.
- [gd3_02] Dựng phiên lỗi sau khi sha256 đã khớp ⇒ `Internal` — phương án khác: `ModelCorrupt` — vì sao: model đã được soát là đúng, lỗi lúc này do runtime hoặc mã.
- [gd3_02] Codec PNG / JPEG chỉ ở `dev-dependencies` — phương án khác: bật trong crate như gd3_01 gợi ý — vì sao: worker nhận RGBA thô, exe phát hành không cần giải mã ảnh.
- [gd3_02] Dùng `toml` 1 như `core` — phương án khác: ghim 0.9 như spike — vì sao: không thêm bản trùng; CER sau khi đổi vẫn 2,45 %, chữ đọc được trùng từng byte với spike.
- [gd4_07] Icon khay nhúng RGBA thẳng, chỉ hình, không ô nền — phương án khác: đọc từ resource ICO — vì sao: không thêm decoder, giữ đúng icon khay đang có.
- [gd4_07] Thêm manifest PerMonitorV2 cho `fst.exe`, ngoài danh sách tệp — phương án khác: để DPI-unaware, Windows phóng to icon 16 — vì sao: không có manifest thì không biết DPI thật; menu khay cũng đổi theo, cần xem ở kiểm tay.
- [gd4_07] Công cụ xuất là crate Rust `tools/export-icon/` ngoài workspace — phương án khác: GDI+ trong PowerShell — vì sao: đọc SVG thật bằng `resvg`, không chép hình vào script.
- [gd4_01] `store::update` thêm bound `Send` — giữ đúng chữ ký, ghi đĩa trên luồng UI — fsync không chặn UI
- [gd4_01] `settings-run.ps1` chỉ báo lỗi khi cửa sổ thử giành foreground — báo lỗi mọi lần foreground đổi — chủ dự án tự chuyển app thì lần chạy không nên đỏ
- [gd4_01] Thêm Ctrl/Cmd+W + focus sẵn ở sidebar cho Settings — chờ làn UI — test đóng cửa sổ cần và người dùng dùng bàn phím cần
- [materiant-gd4_01] Số đo Badge theo `kbd.rs` vì `xbds/materiant/projects` không có gói chip / badge — phương án khác: tự chế số mới — vì sao: cùng họ chip với Kbd.
- [materiant-gd4_01] Badge tự trộn `ink` về màu chữ tới khi đạt 4,5 : 1 — phương án khác: sửa `AccentTokens.ink` — vì sao: `ink` còn dùng cho nút, đổi sẽ lệch bản web.
- [gd4_10] Giữ phím mặc định Ctrl+Shift+1…5 trên macOS — đổi sang Cmd — `Cmd+Shift+3/4/5` là phím chụp màn của hệ thống, tổ hợp Ctrl không trùng `system_reserved`.
- [gd4_10] `SMAppService` lên ngay lúc đăng nhập, không có độ trễ cấu hình — luôn dùng LaunchAgent — API không có độ trễ và F-5 chốt `SMAppService`; LaunchAgent vẫn dùng `--delay`.
- [gd4_10] Không hạ ưu tiên daemon trên macOS — `Nice` / `ProcessType` trong plist — UI có thể thừa kế, Windows mới có cờ bật UI về ưu tiên thường.
- [gd4_10] Thêm `dispatch2` (đã có trong lock, Zlib / Apache-2.0 / MIT) ngoài danh sách task — tự khai báo `dispatch_async_f` — khỏi viết `unsafe`.
- [gd4_10] Nhãn LaunchAgent `com.fastcast.daemon` — theo tên người dùng như Task Scheduler — thư mục đã theo người dùng; đổi nếu gd4_13 chốt bundle id khác.
- [gd4_12] Tách âm thanh sang `gd4_19` trước khi code — làm chung một task — ước lượng ~1.210 dòng, vượt trần 900; nhánh Mac báo `AudioUnavailable` tới khi xong gd4_19.
- [gd4_12] Vùng vắt hai màn ghép bằng CPU trên bộ đệm từ pool — báo `Unsupported` — `SCStream` trả được từng màn, một màn phủ trọn thì vẫn đưa thẳng IOSurface, không chép.
- [gd4_12] Quyền Screen Recording thiếu ⇒ `CaptureLost` — `Unsupported` hoặc mã mới — không sửa tệp chung trong làn; mã riêng ghi backlog.
- [gd4_12] `Part`, `validate`, `pending` chép lại ở `macos/` — gom với `session.rs` — luật làn không cho sửa nhánh Windows; gd4_16 nên gom.
- [gd4_12] `source_probe` đổi sang mở ở màn phụ — giữ (0, 0) — (0, 0) là màn LG, trái luật màn hình; thay đổi nhỏ ở mã thử của Windows.
- [gd4_04] Sửa một dòng `daemon.rs` để truyền cờ vào `Clipboard::submit` — để `clipboard.rs` tự đọc tệp cấu hình — task yêu cầu đọc từ cấu hình daemon đang giữ; ngoài cột tệp sở hữu nhưng tối thiểu.
- [gd4_04] Bật tuỳ chọn thì chặn cả clipboard đám mây (`exclude_from_cloud`) — chỉ chặn lịch sử — cùng mục đích riêng tư; đồng bộ lên đám mây mà không vào Win+V là bất ngờ.
- [gd4_04] Lỗi thư mục / lỗi ghi hiện ngay trên trang — toast — `SettingsView` chưa có `ToastViewport` (tệp của gd4_01), chữ tại chỗ cũng không tự biến mất.
- [gd4_04] Không có tiêu đề nhóm trên trang — thêm khoá i18n — luật làn không sửa i18n; nhóm bằng khoảng cách, xem ảnh đã đủ rõ.
- [gd4_02] `store::update` áp `UiState` trước khi chờ daemon (tệp của gd4_01) — giữ thứ tự cũ — daemon bận đăng ký lại autostart thì giao diện không phải chờ, cũng không kẹt nếu daemon treo
- [gd4_02] `dev::run_keys` phát cả KeyUp (tệp của gd4_01) — test Switch trong bin bằng `#[gpui::test]` — Switch, nút kích hoạt lúc nhả phím, mọi làn Settings cần
- [gd4_02] Trạng thái tự khởi động theo config — thêm trường `DaemonStatus` — GĐ4 không đổi IPC, task cho phép
- [gd4_02] Độ trễ tự khởi động hoãn ghi 500 ms — ghi mỗi phím — gõ "120" là ba lần đăng ký tác vụ với OS
- [gd4_03] Tự làm phần `[sonnet]` — giao Sonnet — bảng dính chặt interface vừa tách và test tích hợp
- [gd4_03] Ghi phím tắt qua cùng khoá với `store` (`store::save` thành `pub`) — để `actions` tự ghi — tránh hai lần ghi đè nhau khi trang khác đang lưu
- [gd4_03] Dòng lỗi đăng ký là câu đầy đủ `settings.hotkeys_register_failed` — nhãn ngắn như phác thảo — không thêm khoá i18n, người dùng biết rõ lệnh và tổ hợp nào hỏng
- [gd4_19] Đổi đồng hồ mic qua `synchronizationClock`, mốc lệch giờ nhận quá 2 s thì lấy giờ nhận — tin thẳng mốc gói — chưa kiểm được đồng hồ của `AVCaptureSession` trên Mac, cách này giữ tiếng khớp hình dù đồng hồ khác dự đoán.
- [gd4_19] Khoá `AVFormatIDKey`… dùng chuỗi — thêm `objc2-avf-audio` — chỉ cần bốn hằng, giá trị đúng bằng tên; chạy trên Mac sẽ xác nhận.
- [gd4_19] Thêm `objc2-core-audio-types` vào khối macOS (đã có trong lock, Zlib / Apache-2.0 / MIT) ngoài dòng "Phụ thuộc mới" — tự khai báo struct — `AudioBufferList`, `AudioStreamBasicDescription` bắt buộc cho API của `objc2-core-media`.
- [gd4_19] Mất nguồn âm giữa lượt quay thành im lặng, không mở lại — mở lại như Windows — không thử được trên máy này.
- [gd4_06] Mở trang giấy phép bằng `open_with_system` — `open_url` như spec — khỏi mã hoá `file://` cho đường dẫn có dấu cách
- [gd4_06] Chép văn bản giấy phép ONNX Runtime vào repo (344 KB) — đọc từ thư mục model lúc sinh — script chạy được không cần mạng, ra cùng nội dung
- [gd4_06] Không ghi icon F-11 vào trang giấy phép — ghi như task liệt kê — dự án tự vẽ; nếu có bộ nào lấy từ ngoài thì phải thêm vào `extra.toml`
- [gd4_05] Dòng Pro dùng `Role::Group` + nhãn `<tên>, pro` — để trình đọc tự đọc chữ con — chữ con chưa chắc thành nút a11y, nhãn ghép đọc được chắc chắn hơn.
- [gd4_05] Dòng `Pro` giữ nguyên tên + mô tả, chỉ bỏ huy hiệu — thêm điều khiển bật tắt — chưa có tính năng thật (D-4).
- [gd3_13] Đo lúc gần rảnh sau 60 phút chờ, ghi tải từng bài — chờ tới khi GĐ4 xong — vì sao: chủ dự án cho GĐ4 chạy song song, gd4_08 + gd4_09 đang chờ task này.
- [gd3_13] Mất nguồn giữa chừng còn tệp ⇒ thông báo + mở bảng như quay xong — chỉ đổi chữ thông báo — vì sao: người dùng có ngay nút giữ / lưu / bỏ cho phần đã quay.
- [gd3_13] Dọn `.mp4.part` cũ hơn 24 giờ — dọn hết mỗi lần quay — vì sao: `.part` mới có thể là video đã quay xong mà worker không đặt được tên.
- [gd3_13] Biến chạy thử ở bản release để `gd4_08` chặn, phải báo lỗi — chặn ở đây — vì sao: task đó đã nhận; im lặng bỏ biến sẽ làm bài đo quay màn thật.
- [gd3_13] Xoá `C:/xdesktop-target/ocr-models`, giữ bản chép ở `fastcast/target/release/models` cho kiểm tay — giữ ở chỗ chung — vì sao: bàn giao gd3_03 dặn xoá; dựng lại cần Docker nên vẫn giữ một bản.
- [gd4_08] Endpoint::custom không kiểm exe của server, chỉ Endpoint::daemon / guarded kiểm — kiểm mọi endpoint — vì sao: fake_daemon, exe test nằm khác thư mục với UI.
- [gd4_08] Bản thiếu dev-env mà có biến quay cửa sổ thử thì fastcast-rec báo lỗi, so theo đuôi tên — bỏ qua im lặng — vì sao: gd3_13 yêu cầu, im lặng là quay màn thật.
- [gd4_09] Chốt NSIS, đóng câu hỏi ở `ROADMAP.md` — WiX / Inno — giấy phép Zlib trong D-2, cài theo người dùng không cần admin, một tệp.
- [gd4_09] Không chạy `fst --version` từ exe đã cài dù nghiệm thu gốc ghi — chạy vì lệnh tự thoát — vì sao: lần giao này cấm chạy `fst` đã cài, chỉ phủ bằng unit, chuyển kiểm tay.
- [gd4_09] E2e thay `fst.exe` bằng exe giả ghi đối số, không thêm cờ test vào bản phát hành — cờ `/NOFST` trong bộ gỡ — vì sao: chạy đúng đường gỡ thật, `autostart off` thật sẽ xoá tác vụ chung của máy.
- [gd4_09] Bộ cài không giết tiến trình, chờ tệp hết bị giữ 10 s rồi hỏi, im lặng thì mã 2 — `taskkill /IM` — vì sao: giết theo tên trúng bản ở thư mục khác.
- [gd4_09] Sổ không ghi dll thì engine cho qua + log — từ chối — vì sao: Mac chưa có sha, thư mục dev cũ; bản cài Windows bị script bắt phải có mục.
- [gd4_09] Sha ONNX Runtime soát qua digest GitHub + dll trong gói NuGet — tin lần tải đầu — vì sao: `confirm.md` gd3_03 hẹn soát lại khi đưa vào bản cài; đều khớp.
- [gd4_09] Cài NSIS bằng tệp `winget download` + `RunAsInvoker` vào `E:\codex\tools\nsis` — `winget install` — vì sao: tránh hộp UAC trên màn LG khi chủ dự án vắng.
- [gd4_09] Chép `setup.exe` vào `fastcast/dist/` (gitignore) sau khi gỡ worktree — bỏ cùng worktree — vì sao: để chủ dự án kiểm tay khỏi dựng lại.
- [gd4_10] Giữ khay, C7 đỏ ở 6,6–6,8 MB so với ngưỡng 5 MB — bỏ khay (còn ~5 MB) hoặc tách khay sang tiến trình riêng (tổng RAM tăng) — vì sao: sàn AppKit + khay 6,7 MB, không ép thêm được; nếu giữ khay thì ngưỡng macOS phải nới.
- [gd4_10] Daemon `exec` lại chính mình với `MallocSpaceEfficient=1`, `MallocMaxMagazines=1`, UI con gỡ hai biến — đặt trong plist / `LSEnvironment` — vì sao: phủ cả chạy tay, LaunchAgent, `.app`; giảm ~4 MB.
- [gd4_11] Để lỗi hai màn khác scale, chỉ log + backlog P1 — phương án khác: đổi hệ toạ độ ngay — vì sao: phải sửa cả `video`, ngoài làn, cần hai màn để thử.
- [gd4_11] Hoãn xin quyền micro sang gd4_13 — phương án khác: làm trong UI ngay — vì sao: không thử được hộp thoại TCC trên máy đang dùng, chưa có `Info.plist`.
- [gd4_11] Test Mac mở cửa sổ trong suốt, nổi, không bắt chuột (`FASTCAST_TEST_UNSEEN`) — phương án khác: cửa sổ thấy được, chiếm màn lúc chạy test — vì sao: GPUI không vẽ cửa sổ bị che, máy chỉ một màn đang dùng.
- [gd4_13] Không ký lại `libonnxruntime.dylib` — ký lại + đổi sha trong sổ — `check_runtime` so sha với sổ, tệp gốc đã có chữ ký ad-hoc đủ khi chưa bật hardened runtime.
- [gd4_13] Bundle id `com.fastcast.app`, giữ nhãn LaunchAgent `com.fastcast.daemon` — dùng chung một tên — một bên là app, một bên là dịch vụ launchd dự phòng.
- [gd4_13] Arm64, x86_64 mỗi bản một `.dmg` — universal — universal làm gấp đôi exe + dylib 44 MB cho mọi người; hiện mới có dylib arm64.
- [gd4_13] Thiếu model / trang giấy phép thì script dừng, `--draft` mới cho qua và gắn `-draft` vào tên `.dmg` — chỉ cảnh báo như `build.sh` — tránh phát hành nhầm bản thiếu (D-2).
- [gd4_11 · hai màn] Đặt màn từ màn chính, cạnh chung kề nhau, cỡ = điểm × scale (`display_points::place`), bỏ `display_rect`, `fastcast-rec` gọi chung `capture::macos::layout` — phương án khác: nhân mọi màn với scale lớn nhất — vì sao: scale chung làm cỡ màn 1× không còn là pixel thật, phải co ảnh, trái F-3.
- [gd4_11 · hai màn] Thêm đổi toạ độ khi kéo chuột ra ngoài cửa sổ (`platform::beyond_window`), ngoài vùng sửa được giao — phương án khác: để lại — vì sao: AppKit báo điểm, không sửa thì vùng kéo sang màn khác scale lệch con trỏ.
- [test chập chờn] Thêm bước `waitfile` vào kịch bản overlay, test OCR chờ log rồi mới cho đi tiếp — phương án khác: tăng `wait` — vì sao: tăng giờ vẫn đua, chỉ đỏ thưa hơn và chạy lâu hơn.
- [test chập chờn] Test picker khởi động lại di tới điểm biết trước, điểm mở giữa màn chuyển sang unit test `start_point` — phương án khác: màn giả bỏ qua sự kiện di thật — vì sao: kịch bản và chuột thật đi cùng một đường sự kiện, không tách được.
- [D-11] Còn để ở backlog: Metal ~28 MB (phải vá gpui-pre), xin quyền micro và mở lại micro (cần hộp thoại / thiết bị để thử), `real_ocr` và `--test session` chập chờn trên Windows (không có máy) — phương án khác: sửa mù — vì sao: không kiểm được.
