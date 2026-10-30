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
- [gd1_06] Bấm `open_launcher` khi launcher đang hiện ⇒ ẩn (bật / tắt như Raycast); nhấp một dòng = chọn, nhấp đúp /
  Enter = chạy — phương án khác: lệnh lặp đưa cửa sổ lên trước như tính năng khác; nhấp một lần là chạy — vì sao: giống
  Raycast / Spotlight; nhấp một lần chạy dễ chạy nhầm khi chỉ định rê chuột.
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
- [gd1_07] Ctrl+K mở menu GIỮA launcher (`context_menu` trên gốc) — phương án khác: góc dưới phải như Raycast — vì sao:
  `Menu` của materiant chưa mở được theo neo từ code, materiant đang nghiệm thu gd1_10; gạch `_backlog.md`.
- [gd1_07] Thôi tạm gỡ phím tắt ngay khi bắt được tổ hợp (trước bước hỏi "Lấy phím") — phương án khác: giữ tạm gỡ tới lúc
  ghi xong — vì sao: hỏi / ghi không cần phím tắt tắt, giảm thời gian phím tắt chết.
- [gd1_07] Lịch sử là menu con (thời điểm tương đối + chip tổ hợp); Gỡ / Lịch sử / Mặc định trùng lệnh khác ⇒ cùng hộp
  thoại "Lấy phím" — phương án khác: hộp thoại danh sách riêng — vì sao: ít bước, dùng lại Menu.
- [gd1_07] Ký tự Shift của GPUI Windows (`@`) đổi ngược theo bố cục US — phương án khác: chờ GPUI lộ scan code — vì sao:
  bàn phím tiếng Việt dùng bố cục US; AZERTY… ghi mục 10.
- [gd1_07] Không giao Sonnet — phương án khác: giao phần ghép hộp thoại / i18n — vì sao: dính chặt pha capture phím của
  `LauncherView` + interceptor, interface đổi trong lượt.

## materiant

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
