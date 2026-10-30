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

## materiant

- [ripple / window] `materiant::window::window_options()` = `WindowOptions` mặc định với `inactive_frame_interval:
  None`; gallery + mọi cửa sổ materiant nên trải `..window_options()` — phương án khác: giữ mặc định GPUI (cửa sổ không
  active ~30 fps, tiết kiệm điện khi app chạy animation dài ở nền) — vì sao: đo ripple ở cửa sổ không active chỉ 24 fps
  (khung 41–50 ms), bỏ trần thì 60 fps đều, khung chậm nhất 17 ms; animation của materiant chỉ xin khung lúc đang chạy nên
  nghỉ không tốn gì. Có thể đây là cảm giác "FPS thua bản web" bạn thấy; nếu vẫn thấy giật khi cửa sổ ĐANG active, chạy
  `$env:GALLERY_FRAME_STATS=1; pwsh start.ps1 docs style` rồi bấm ô ripple — dòng `FRAMES … fps` cho biết số thật.
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
