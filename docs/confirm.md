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

## Linux (gd0_07, 02/11/2026)

- [gd0_07] Khay Linux tự viết SNI trên `zbus` — thêm Unlicense vào D-2 rồi dùng `ksni` (ít mã hơn) — D-2 không có Unlicense, Claude không tự nới luật giấy phép.
- [gd0_07] Chụp đóng băng Linux bằng `ScreenCast` + token — portal `Screenshot` — Screenshot nháy + kêu trên GNOME gốc và ghi ảnh vào Pictures.
- [gd0_07] Vá `gpui-pre-linux` để fullscreen đúng màn — đổi nền UI — bản vá 7 dòng, D-6 giữ nguyên.
- [gd0_07] Gán phím trên Linux đi qua hộp thoại hệ thống, lệch F-2 — ghi thẳng dconf — dconf là bố cục nội bộ của GNOME.
  - [hotkey-override, 02/11/2026] Bỏ hướng "không ghi dconf" trên GNOME: `custom-keybindings` là schema công khai, gán phím có hiệu lực ngay và ghi đè được — phương án khác: giữ portal + hộp thoại.
- [no-scale, 02/11/2026] Đóng băng trên Linux theo máy: extension `no-screenshot-flash@mobio.local` đang bật ⇒ `Screenshot` như Flameshot (không chip, không nháy; lần đầu mở bước làm quen xin quyền, ảnh thoáng qua Pictures rồi app xoá), GNOME gốc giữ `ScreenCast` (chip ≥ 5 s, dính ảnh khi vùng chọn chạm góc đó) — phương án khác: `Screenshot` cho mọi máy (nháy + kêu mỗi lần chụp) hoặc đóng gói extension trong `.deb` để máy khác tự bật — trên GNOME gốc đổi chip lấy nháy + kêu là chủ dự án quyết, chưa đổi.
- [no-scale] Không gọi thẳng `org.gnome.Shell.Screenshot` bằng cách chiếm tên bus được phép — nhanh nhất, không chip, không nháy, không quyền — là lách kiểm soát quyền của GNOME trong app phát hành.
- [no-scale] Bỏ hiệu ứng scale bằng cách vẽ rỗng lúc Shell chạy hiệu ứng, ảnh hiện sau map 145–250 ms — Xwayland override-redirect (không hiệu ứng, kiểu Flameshot) — phải viết lại overlay trên X11 và phụ thuộc Xwayland. Đóng overlay giữ cửa sổ vô hình thêm 280 ms, trong lúc đó click / phím vẫn vào cửa sổ đó — gỡ ngay thì khung đen thu lại rất rõ.
- [no-scale] 28 test có sẵn đỏ cả trên `master` trong màn ảo (`record_control`, `record_setup`, `settings_capture`, `settings_general`, `settings_hotkeys`), không sửa trong việc này: `record_control` vì `last_layout` chưa có bố cục khi không qua overlay. `launcher: moved to` đôi khi báo dù chưa kéo (3/5 lần màn ảo), ghi `launcher.position` sai, chưa tìm gốc.
- [no-zoom-close, 02/11/2026] Gỡ cửa sổ theo khung trong suốt đã vẽ (`render` gọi `veiled`) + một nhịp, không theo đồng hồ 40 / 280 ms — giữ cửa sổ ẩn lâu hơn rồi mới huỷ, hoặc đổi kiểu cửa sổ (xdg_popup không có hiệu ứng) — màn ảo không tái hiện được zoom kể cả khi chép extension + dconf của máy, gốc nghi là gỡ trước khi khung trong suốt tới nên Shell thu khung ảnh còn 0,8; popup phải neo vào cửa sổ cha, không phủ được màn. Quá 1 s không có khung vẫn gỡ, log `last frame not drawn transparent` để lần thử sau có số.
- [no-zoom-close] Áp che map + đóng trong suốt cho mọi cửa sổ Linux: thông báo, khung + thanh quay, bảng xong quay, Settings, bước làm quen — chỉ overlay + launcher — chủ dự án muốn bỏ hết zoom trên Linux. Đổi lại cửa sổ hiện trễ ~180 ms sau map (như launcher); lúc che vẫn vẽ đủ cây với `opacity(0)` để focus + phím gõ sớm không mất; Settings, làm quen đổi nền cửa sổ sang trong suốt trên Linux, view tô nền đục.
- [no-zoom-close] Từ lúc đóng, cửa sổ đặt vùng nhận chuột rỗng: click trong ~320 ms chờ gỡ rơi xuống app bên dưới — giữ như cũ (cửa sổ vô hình nuốt click). Phím vẫn tới cửa sổ đang đóng tới khi gỡ.
- [no-zoom-close] Cửa sổ còn mở lúc app thoát (`quit`) vẫn gỡ thẳng, còn zoom — đợi khung trước khi thoát — hiếm, thoát từ khay khi đang mở Settings.
- [no-zoom-close] Test màn ảo: đỏ đúng 28 test như `master` (`record_control` 13, `record_setup` 5, `settings_capture` 2, `settings_general` 7, `settings_hotkeys` 1); `overlay` 68/68 khi chạy riêng, chạy chung nhiều tệp có lần đỏ 7 test màn giả do tải.
- [display-drop, 02/11/2026] Gốc thật của zoom lúc đóng trên máy chủ dự án: `current_display` của bản vá GPUI huỷ nhầm cửa sổ đang focus (thông báo sau copy gọi `primary_display`), rồi panic `drop_window` làm UI abort; tìm ra từ chuỗi panic trong core apport `/var/crash`. Sửa trong bản vá, `drop_window` ghi log thay vì `unwrap`, panic ghi vào log — phương án khác: chỉ sửa `current_display` — vì sao: panic ở tiến trình nền trước đây mất vào `/dev/null`, mất cả giờ để tìm.
- [gd4_15] Giữ `ScreenCast` dù ảnh đóng băng dính chip cam "đang chia sẻ màn" ở góc trên phải thanh GNOME — đổi sang `Screenshot` (không chip, nhưng nháy + kêu, ghi tạm vào Pictures) — chốt của gd0_07 giữ nguyên; **cần chủ dự án chọn**, chip lọt vào ảnh khi vùng chọn chạm góc đó.
- [gd4_15] Thêm `Message::ActivationToken` trong `crates/core`, ngoài danh sách tệp của task — chỉ dùng biến môi trường lúc bật UI — UI đang giữ ấm không nhận được biến môi trường, gd4_14 phải gửi trước `Run`.
- [gd4_15] Cấp quyền xong bấm lại phím tắt — tự chụp ngay sau hộp thoại — tự chụp dễ dính cửa sổ làm quen vào ảnh.
- [gd4_15] Font giao diện theo `fc-match sans-serif` (tiến trình con lúc khởi động, máy này ra Noto Sans) — đọc `font-name` của GNOME (Ubuntu Sans) — fontconfig chạy được ngoài GNOME.
- [gd4_14] App id `com.fastcast.app`, đổi tệp autostart thành `com.fastcast.app.desktop`, daemon tự ghi `.desktop` ẩn khi chạy rời — giữ `fastcast.desktop`, chờ gói `.deb` — portal cần `.desktop` theo id, scope của GNOME lấy id từ tên tệp.
- [gd4_14] Clipboard trên GNOME đi X11 qua Xwayland, không có Xwayland thì chép báo lỗi — tự viết đường khác — Mutter 50 không có data-control.
- [gd4_16] Quay Linux gọi tiến trình con `gst-launch-1.0`, cả âm trong đó, không `cpal` — link GStreamer / thu âm riêng — D-2 cấm link khi chưa hỏi, chung đồng hồ khỏi tự canh tiếng khớp hình. Không tách `gd4_20`.
- [gd4_16] `mp4mux` ghi theo mảnh 2 s — `moov` cuối tệp — giết cứng chỉ mất đoạn cuối; chưa soát mở trên Media Player, QuickTime, không hợp thì bỏ một tham số.
- [gd4_16] Dùng portal của gd4_15, thêm `open_session_with`, `watch_closed` vào `capture/src/portal.rs`; chưa có token thì `fastcast-rec` hiện hộp thoại — báo thiếu quyền như `freeze` — quay đã qua overlay nên hiếm gặp, bấm dừng vẫn thoát được.
- [gd4_16] Đóng hộp thoại chọn màn báo `PermissionDenied`, tệp đứng 8 s báo `CaptureLost` — thêm mã lỗi mới — làn không được sửa `core`, `i18n`.
  - [gd4_16 video lượt 2, 02/11/2026] Thay gạch "tiến trình con `gst-launch-1.0`" ở trên theo G-3.
- [gd4_16 video] GStreamer chạy TRONG `fastcast-rec`, nạp `libgstreamer-1.0.so.0` lúc chạy bằng `libloading` (24 hàm khai tay, hai chỗ đọc struct theo ABI 1.x có test soát) — crate `gstreamer` / `gstreamer-app` — crate đòi gói `-dev` lúc build (máy này không có, sẽ chặn build của mọi session cho tới khi `sudo apt`), exe không mở được khi máy thiếu GStreamer; nạp lúc chạy thì thiếu chỉ là `no_encoder`. Vẫn là link động thư viện hệ thống, không kèm vào gói.
- [gd4_16 video] Bỏ tiến trình con — giữ `gst-launch-1.0` — trong tiến trình có lỗi theo element, số khung bỏ thật, dừng bằng EOS, bớt một tiến trình (RAM 720p: `fastcast-rec` 54 MB VmHWM gồm cả GStreamer). Đổi lại SIGKILL `fastcast-rec` mất mảnh cuối ≤ 2 s (SIGTERM vẫn chốt đủ).
- [gd4_16 video] Âm AAC bằng `voaacenc` (plugins-bad), dự phòng `fdkaacenc`; không `avenc_aac` — Opus trong MP4 — Media Player / QuickTime chưa chắc phát Opus-trong-MP4; G-3 không cho phụ thuộc libav.
- [gd4_16 video] openh264: `rate-control=bitrate`, bỏ `usage-type=screen` — giữ chế độ màn hình — chế độ màn hình bỏ qua trần bitrate (7 Mbps thay vì 3,3 ở 720p30 hoạ tiết động), chế độ thường ra 4 Mbps, không bỏ khung. Màn tĩnh ~1 MB/phút.
- [gd4_16 video] `.deb` `Depends` thêm `libgstreamer1.0-0`, `gstreamer1.0-plugins-{base,good,bad}`, `gstreamer1.0-pipewire`; driver VA chỉ ở `Recommends` — đưa VA vào `Depends` — không có VA vẫn quay bằng OpenH264, driver Intel non-free nằm ở multiverse.
- [gd4_16 video] Trang giấy phép thêm khoá `os` (mục GStreamer chỉ ở trang dựng trên Linux) và `exception = "G-3"` (miễn soát nhãn LGPL cho đúng mục đó) — nới chốt soát nhãn cho mọi LGPL — giữ chốt D-2 cho phần còn lại.
- [gd4_17] Gỡ gói xoá autostart của người dùng ngay ở `postrm` (chỉ tệp có `Exec` trỏ `/opt/fastcast/`), không đợi "lúc chạy kế" — để lại tệp mồ côi — tệp gói đã mất thì không còn mã nào chạy để xoá.
- [gd4_17] `Depends` lấy từ `dpkg-shlibdeps` + `libwayland-client0`, `libwayland-egl1`, `libegl1` (nạp lúc chạy) — chỉ thư viện ELF khai — ELF không khai thư viện nạp bằng `dlopen`; `Recommends` encoder / driver VA.
- [gd4_17] Bản `.deb` chỉ dựng được `-draft` tới khi sổ model có `libonnxruntime.so` Linux — tự tải một bản ONNX Runtime và ghi sha — không tự nhận thư viện lạ vào sổ.
  - [gd4_16 OCR, 02/11/2026] Đã ghi sổ: `onnxruntime-linux-x64-1.31.1.tgz` tải với đồng ý của chủ dự án, sha tệp nén khớp GitHub, `.so` nạp chạy được.
- [gd4_16 OCR] `build.sh` (Linux) tự chạy `fetch-ocr-models.sh` (tải ONNX Runtime khi thiếu, sha ghim trong script) và `cargo install cargo-about` khi thiếu — chỉ báo thiếu rồi ra `-draft` như cũ — chủ dự án muốn dựng OCR tự động như Windows; không sudo, tải từ nguồn ghim sha.
- [gd4_16 OCR] Trang giấy phép trên Linux bằng `tools/gen-licenses.sh` (bash + `python3`) — cài `pwsh` (snap) — Ubuntu có sẵn `python3`, khỏi thêm công cụ; vẫn cần `cargo-about`.
- [gd4_16 OCR] `fastcast-ocr` không thấy `models/` cạnh exe thì mượn `/opt/fastcast/models` của bản cài — chỉ cạnh exe — exe build tay chạy được OCR mà không chép 260 MB model; sha vẫn soát theo sổ.
- [gd4_16 OCR] CER Linux đo trên bộ ảnh vẽ lại bằng font Linux (`spikes/ocr/linux-bench`, resvg) — dựng lại GDI+ của `gen-bench.ps1` — Linux không có GDI+; số không so 1:1 với 2,45 % của Windows.

- [materiant ripple-hit, 02/11] Vùng bấm của checkbox / radio = hình vuông bao vòng phản hồi (40 px) + nhãn, gồm cả bốn
  góc ngoài vòng tròn — cắt đúng hình tròn — ripple cũng bắt chuột theo hình vuông đó, nên "ripple chạy ⇔ tick" khớp.
  Bố cục ngoài giữ nguyên (đệm + lề âm).
- [materiant ripple-hit, 02/11] Hàng checkbox / radio chặn chuột tới phần tử phía sau (`block_mouse_except_scroll`):
  hai hàng xếp dọc sát nhau có vòng chồng 12 px thì chỗ chồng thuộc hàng dưới (vẽ sau) — chia đôi chỗ chồng — chia đôi
  phải tính ở cấp nhóm; không chặn thì một cú bấm đổi cả hai ô. Hệ quả: hover / click của phần tử cha không nhận khi
  chuột ở trên ô (như nút trong vùng kéo phải `.occlude()`).

- [pull 02/11] Số D-14 bị trùng giữa remote (giao việc theo độ khó) và sửa chưa commit của session khác (cách ly máy công ty): đổi bản chưa commit thành D-15, vẫn để chưa commit.

## Thanh cuộn sát mép (02/11/2026)

- [scrollbar-edge] Thêm `padding_x` cho `ScrollArea` (mặc định 0, nội dung tự đệm) và `VirtualList` (mặc định `TRACK_THICKNESS` 9 px theo D-16) như `VirtualGrid` — vá từng chỗ ở app — một API chung; `ScrollArea` để 0 vì nội dung tuỳ ý (bảng cuộn ngang, trang Settings đã đệm trong con).
- [scrollbar-edge] Select, menu, launcher, lịch sử clipboard: padding ngang 4 / 8 px của bề mặt dời vào vùng cuộn và nâng lên 9 px (D-16 đòi ≥ `TRACK_THICKNESS`) ⇒ dòng hẹp lại 5 px mỗi bên ở select / menu / clipboard, 1 px ở launcher — giữ 4 px cho dòng rộng như cũ, để thumb đè mép dòng — luật D-16.
- [scrollbar-edge] Bảng OCR: lúc hiện chữ panel chỉ giữ padding dọc, padding ngang 12 px nằm trong vùng cuộn + dòng gợi ý; các trạng thái khác giữ `p(12)` — margin âm cho vùng cuộn tràn ra padding — D-16: nơi chứa quyết định padding.
