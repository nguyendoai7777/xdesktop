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

## materiant
