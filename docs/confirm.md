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
- [gd4_17] Gỡ gói xoá autostart của người dùng ngay ở `postrm` (chỉ tệp có `Exec` trỏ `/opt/fastcast/`), không đợi "lúc chạy kế" — để lại tệp mồ côi — tệp gói đã mất thì không còn mã nào chạy để xoá.
- [gd4_17] `Depends` lấy từ `dpkg-shlibdeps` + `libwayland-client0`, `libwayland-egl1`, `libegl1` (nạp lúc chạy) — chỉ thư viện ELF khai — ELF không khai thư viện nạp bằng `dlopen`; `Recommends` encoder / driver VA.
- [gd4_17] Bản `.deb` chỉ dựng được `-draft` tới khi sổ model có `libonnxruntime.so` Linux — tự tải một bản ONNX Runtime và ghi sha — không tự nhận thư viện lạ vào sổ.

- [pull 02/11] Số D-14 bị trùng giữa remote (giao việc theo độ khó) và sửa chưa commit của session khác (cách ly máy công ty): đổi bản chưa commit thành D-15, vẫn để chưa commit.
