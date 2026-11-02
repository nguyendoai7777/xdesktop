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
- [gd4_15] Giữ `ScreenCast` dù ảnh đóng băng dính chip cam "đang chia sẻ màn" ở góc trên phải thanh GNOME — đổi sang `Screenshot` (không chip, nhưng nháy + kêu, ghi tạm vào Pictures) — chốt của gd0_07 giữ nguyên; **cần chủ dự án chọn**, chip lọt vào ảnh khi vùng chọn chạm góc đó.
- [gd4_15] Thêm `Message::ActivationToken` trong `crates/core`, ngoài danh sách tệp của task — chỉ dùng biến môi trường lúc bật UI — UI đang giữ ấm không nhận được biến môi trường, gd4_14 phải gửi trước `Run`.
- [gd4_15] Cấp quyền xong bấm lại phím tắt — tự chụp ngay sau hộp thoại — tự chụp dễ dính cửa sổ làm quen vào ảnh.
- [gd4_15] Font giao diện theo `fc-match sans-serif` (tiến trình con lúc khởi động, máy này ra Noto Sans) — đọc `font-name` của GNOME (Ubuntu Sans) — fontconfig chạy được ngoài GNOME.
- [gd4_14] App id `com.fastcast.app`, đổi tệp autostart thành `com.fastcast.app.desktop`, daemon tự ghi `.desktop` ẩn khi chạy rời — giữ `fastcast.desktop`, chờ gói `.deb` — portal cần `.desktop` theo id, scope của GNOME lấy id từ tên tệp.
- [gd4_14] Clipboard trên GNOME đi X11 qua Xwayland, không có Xwayland thì chép báo lỗi — tự viết đường khác — Mutter 50 không có data-control.
- [pull 02/11] Số D-14 bị trùng giữa remote (giao việc theo độ khó) và sửa chưa commit của session khác (cách ly máy công ty): đổi bản chưa commit thành D-15, vẫn để chưa commit.
