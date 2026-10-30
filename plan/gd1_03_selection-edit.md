# gd1_03 — Chỉnh vùng chọn + thanh công cụ

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | gd1_02 · materiant-gd1_02 (ripple), gd1_03 (`IconButton`), gd1_07 (`Tooltip`) |
| Quyết định áp dụng | F-3, F-1 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/selection.rs` SỬA · `crates/ui/src/overlay/handles.rs` MỚI · `crates/ui/src/overlay/toolbar.rs` MỚI · `crates/ui/src/overlay/view.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 0. Bàn giao từ gd1_02 (30/10/2026)

<!-- handoff: gd1_02 -->

- **Đã có sẵn để dùng**: `crates/ui/src/overlay/` — `selection.rs` (`SelectionState::{Idle, Dragging { start, current },
  Selected(Rect)}`, `press` / `drag` / `release` / `cancel() -> Cancel::{Cleared, Close}`, mọi điểm toàn cục vật lý, tự
  `Layout::clamp`); `mod.rs` (`OverlaySession { layout, shots, selection, windows }` là Entity dùng chung, `to_global(monitor,
  (x, y), window_scale)`, `close(cx)` đóng mọi màn, `crop(rect)` cho gd1_04 / gd1_05); `view.rs` (`OverlayView`, `Geometry`
  vẽ lớp tối / viền / nhãn, chuột di / nhả nghe bằng `canvas` + `window.on_mouse_event`).
- **Đổi so với spec này**: `Selected(Rect)` là tuple — đổi sang `Selected { rect, grab }` thì sửa `press` (hiện nhấn khi
  đã chọn = chọn lại từ đầu) + test trong `selection.rs`. Vùng gồm CẢ pixel góc lúc nhả (`span`: kéo 0 → 1919 = 1920);
  cỡ tối thiểu 1 × 1 đã đúng vì nhấn – nhả tại chỗ ⇒ `Idle`. Esc / chuột phải đã là "bỏ vùng, lần hai đóng" — giữ.
- **Vẽ lại**: `OverlayView` chỉ `notify` khi `Visible::of(session, monitor)` đổi (mảnh + cạnh thật + nhãn). Thêm tay nắm /
  thanh công cụ / trạng thái `grab` ⇒ đưa vào `Visible`, không thì cửa sổ không vẽ lại.
- **Phím**: mỗi cửa sổ `track_focus` handle riêng; cửa sổ có con trỏ được kích hoạt lúc mở (`activate_under_cursor`).
  Mũi tên / Enter gắn vào `on_key_down` trong `OverlayView::render` cạnh nhánh `escape`.
- **Thanh công cụ trọn một màn**: `session.layout.monitors` + `Layout::split` / `monitor_at`; nhãn `W × H` đang ở màn chứa
  góc trên trái (`Visible::label`) — thanh công cụ nên theo cùng quy tắc, đừng đè nhãn.
- **Bẫy đã gặp**: chuột di / nhả khi kéo sang màn khác về cửa sổ ĐÃ NHẤN (SetCapture), toạ độ ngoài biên — đừng hit-test
  bằng hitbox của div; `cx.listener` trong `on_mouse_down` chỉ chạy khi trúng div. Đóng cửa sổ từ trong sự kiện ⇒ hoãn
  (`close` đã `cx.defer`). Lệnh `capture_region` thật chụp + phủ MỌI màn và giành focus — trên máy dùng thật chỉ chạy
  thử bằng màn giả.
- **Soát lại khi làm**: test chạy thật trên màn giả — `FASTCAST_OVERLAY_FAKE=1` + `FASTCAST_OVERLAY_SCRIPT` (thêm bước
  `key 0 shift-right`, `down`/`move`/`up` trên tay nắm; cú pháp `overlay/dev.rs`) theo mẫu `crates/ui/tests/overlay.rs`.
  CPU kéo 2 s (mục 5) so gd1_02: 141–359 ms / ~2 s, hai cửa sổ — `cargo test --release -p fastcast-ui --test overlay --
  --ignored --nocapture`. Chi tiết số đo: `plan/gd1_02_region-overlay.md` mục 9.

## 1. Làm gì

- Sau khi nhả chuột: 8 tay nắm (4 góc + 4 cạnh) kéo đổi cỡ, kéo bên trong để dời, kéo ra ngoài vùng ⇒ chọn lại từ đầu.
- Phím: mũi tên dời 1 px vật lý, Shift + mũi tên 10 px, Alt + mũi tên đổi cỡ cạnh phải / dưới; Esc bỏ vùng chọn (lần
  hai đóng overlay); Enter = hành động mặc định (chép — gd1_05).
- Mọi phép chỉnh tính bằng toạ độ toàn cục vật lý, kẹp trong desktop ảo, cỡ tối thiểu 1 × 1.
- Thanh công cụ nổi cạnh vùng chọn (dưới, phải; không đủ chỗ thì lật lên / vào trong; luôn nằm trọn trên **một** màn):
  Lưu, Lưu thành…, Chép, Đóng — nút gắn hành động từ gd1_04 / gd1_05 (task này chỉ phát sự kiện).
- `handles.rs`: hit-test tay nắm + phép đổi cỡ thuần (kéo qua cạnh đối diện thì lật) — test đơn vị.

## 2. Không làm trong task này

- Công cụ chú thích (chữ nhật, mũi tên, chữ…): GĐ2 — chỉ chừa chỗ trên thanh công cụ.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `handles.rs` (hit-test logic, resize / translate / grow thuần), `selection.rs` (`Selected { rect, grab }`) | [opus] |
| `toolbar.rs` vị trí thuần + ghép nút `IconButton` / `Tooltip`, `view.rs` (tay nắm, con trỏ, phím), `mod.rs` (sự kiện) | [opus] |
| `i18n/{vi,en}.toml` khoá `toolbar.*`, test tích hợp màn giả `tests/overlay.rs` | [opus] |
| Nhìn bằng mắt trên màn thật nhiều DPI, Tab / Enter / Space, tooltip | [owner-qa] |

Opus chọn 30/10/2026: không giao Sonnet — phần "ghép UI + i18n" (~80 dòng) dính chặt interface đang chốt cùng lượt
(`ToolbarAction`, `toolbar_at`, nhãn trong `OverlaySession`), giao đi tốn hơn tự làm.

## 3. Kiểu dữ liệu · IPC · cấu hình

`SelectionState::Selected { rect, grab: Option<Grab> }`, `Grab = Move | Resize(Handle)`;
`ToolbarAction = Save | SaveAs | Copy | Close`.

## 4. Code

Hit-test tay nắm theo pixel **logic** của cửa sổ đang chứa con trỏ (vùng bắt 8 px logic), rồi đổi về toàn cục vật lý
bằng `MonitorInfo::from_logical`. Vị trí thanh công cụ là hàm thuần (rect vùng chọn, layout, cỡ thanh) → (màn, toạ độ).

## 5. Đo

CPU khi kéo đổi cỡ liên tục 2 s trên 2 màn (so gd1_02).

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ |
| --- | --- | --- |
| C1 | Vùng đã chọn / nhấn trong 8 px logic quanh góc, cạnh, trong thân, ngoài / ⇒ `Resize(góc)`, `Resize(cạnh)`, `Move`, `None` (chọn lại); màn 150 % bắt 8 px logic = 12 px vật lý | [opus-unit] `handles` |
| C2 | Kéo tay nắm qua cạnh đối diện / quá mép desktop / ⇒ vùng lật, tối thiểu 1 × 1, kẹp trong hình bao desktop ảo; dời thân kẹp trọn | [opus-unit] `handles`, `selection` |
| C3 | Vùng vắt hai màn khác scale / kéo cạnh phải từ màn này sang màn kia / ⇒ pixel cạnh = pixel dưới con trỏ lúc nhả | [opus-unit] `selection` + [opus-run] màn giả |
| C4 | Đã chọn / mũi tên, Shift + mũi tên, Alt + mũi tên / ⇒ dời 1 px, 10 px, đổi cỡ cạnh phải / dưới (≥ 1 px); Esc bỏ vùng, lần hai đóng | [opus-unit] + [opus-run] |
| C5 | Vùng bất kỳ trên layout 3 màn (âm, lệch, 100 / 150 / 200 %) / đặt thanh / ⇒ dưới-phải, hết chỗ lật lên (né nhãn `W × H`) rồi vào trong; luôn trọn một màn | [opus-unit] `toolbar` (quét > 5000 vùng) |
| C6 | Đã chọn / Enter, Ctrl+S, Ctrl+Shift+S, nút / ⇒ phát `ToolbarAction` (log `overlay: action …`); Đóng ⇒ đóng overlay | [opus-run] màn giả |
| C7 | Thanh ở màn 1 / Tab ×4 rồi Enter / ⇒ nút Đóng bấm được bằng bàn phím | [opus-run] màn giả |
| C8 | Kéo tay nắm đổi cỡ ~2 s xuyên hai màn 1080p / ⇒ CPU so với kéo chọn gd1_02 (141–359 ms / 2 s) | [opus-run] đo |
| C9 | Màn thật nhiều DPI, sáng / tối / ⇒ tay nắm + con trỏ đổi hình đúng hướng, tooltip "Lưu  Ctrl+S", Tab / Enter / Space trên thanh | [owner-qa] |

## 7. Ghi chú UI

```
┌───────────────── vùng chọn ─────────────────┐
■                                             ■   ■ = tay nắm 8 px logic
└─────────────────────────────────────────────┘
                     [💾] [💾…] [⧉] [✕]          IconButton sm, tonal; tooltip "Lưu  Ctrl+S"
```

Khoá i18n: `toolbar.save`, `toolbar.save_as`, `toolbar.copy`, `toolbar.close`.

## 8. Nợ chuyển task khác

- Hành động Lưu / Lưu thành: gd1_04. Chép: gd1_05 — `Copy` đã phát (Enter / Ctrl+C / nút), chỉ cần
  `cx.subscribe(&session, …)` ở `overlay::open`, cắt bằng `session.crop(session.selection.selected())`; không cần sửa
  phím trong `view.rs` (mục 9).
- gd1_10 (overlay nhẹ): tay nắm (8 div) + thanh công cụ (một cửa sổ) vẽ trong `view.rs` cạnh lớp tối — chế độ nhẹ giữ
  nguyên chúng; đo CPU kéo đổi cỡ: `measure_resize_drag_cpu` trong `tests/overlay.rs`.

## 9. Bàn giao thực tế

Xong 30/10/2026, nhánh `claude/gd1_03` của fastcast.

- **Đã có**: `overlay/handles.rs` (`Handle` 8 tay nắm, `Grab::{Move, Resize(Handle)}`, `hit_test(sel, gốc màn, scale,
  điểm logic)` bắt 8 px logic ngoài / tối đa 1/3 cạnh phía trong, `resize` / `translate` / `grow` thuần kẹp trong
  `Layout::bounds()`), `overlay/selection.rs` (`Selected { rect, grab: Option<Grabbing> }`, `grab`, `release → Released::
  {Selected, Adjusted, Nothing}`, `nudge`, `grow`, `selected()`, `grabbing()`), `overlay/toolbar.rs` (`ToolbarAction`,
  `place` thuần, `render` bằng `IconButton` sm tonal + `Tooltip`), `OverlaySession: EventEmitter<ToolbarAction>`.
- **Lệch spec có chủ đích**: `grab` là `Option<Grabbing { grab: Grab, from, start }>` (cần điểm nhấn + vùng lúc nhấn để
  tính theo độ lệch, cạnh không nhảy về con trỏ khi nhấn lệch trong vùng bắt); hit-test dùng scale của cửa sổ +
  `OverlaySession::to_global` (cùng phép với `MonitorInfo::from_logical`). Sửa thêm `overlay/mod.rs` (sự kiện, nhãn,
  kích hoạt cửa sổ có thanh) và `overlay/dev.rs` (bước `key` phát cả key-up — nút GPUI bấm lúc nhả phím) ngoài dòng
  "File đụng tới".
- **Opus chọn 30/10/2026** (ghi `plan/confirm.md`): (1) kẹp chỉnh vùng trong **hình bao** desktop ảo, không theo từng màn
  (bố cục so le: vùng dời vào khe được — vẫn cắt được, phần khe trong suốt); (2) đổi cỡ theo độ lệch con trỏ (không
  bắt cạnh về con trỏ); (3) thanh ở màn chứa góc **dưới phải** của vùng (khe ⇒ màn có mảnh lớn nhất), dưới → trên (né nhãn,
  sang phải nhãn nếu chồng) → trong; (4) "Lưu thành…" = icon Lưu + ba chấm vẽ tại chỗ (materiant chưa có icon riêng,
  không sửa materiant lúc gd1_10 đang chạy); (5) Đóng không ghi phím tắt trong tooltip (Esc bỏ vùng trước); (6) overlay
  thật: chọn / chỉnh xong thì kích hoạt cửa sổ có thanh (nhấn màn A nhả màn B ⇒ Tab vẫn tới nút) — màn giả không giành
  focus; (7) thanh ẩn khi đang kéo chỉnh, hiện lại lúc nhả.
- **Phím**: mũi tên / Shift (10 px) / Alt (đổi cỡ phải-dưới, ≥ 1 px); Enter (chỉ khi focus ở gốc overlay, không phải
  nút) = `Copy`; Ctrl/⌘+S `Save`, Ctrl/⌘+Shift+S `SaveAs`, Ctrl/⌘+C `Copy`. Lưu / chép cần vùng đã chọn xong; Đóng luôn
  được. Log: `overlay: adjusted …`, `overlay: toolbar on <màn> at x,y size WxH`, `overlay: action <id>`.
- **Sửa sau khi soi (trong phạm vi)**: Esc khi focus ở nút ⇒ trả focus về gốc trước khi bỏ vùng (không thì thanh biến
  mất cùng nút, Esc lần hai không tới overlay — test `fake_overlay_escape_twice_from_a_toolbar_button`); nhả chuột cập
  nhật hình con trỏ ngay; tooltip mở xuống khi thanh dưới vùng (không đè mép vùng).
- **Soát**: `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test` (ui 73 + overlay 5 tích hợp màn
  giả, 2 đo ignored), `cargo deny check licenses` — xanh trên worktree. [opus-run] ảnh PrintWindow màn giả (xem xong xoá): tay nắm ở
  màn chứa nó, cạnh nối không viền, thanh + tooltip "Save  Ctrl+S" + vòng focus bàn phím đúng; `foreground_unchanged=True`.
- **Đo C8** (release, hai màn giả 1080p, nắm cạnh phải, 120 lần di xuyên hai màn ~2 s + nhịp 16 ms): CPU 109 / 125 / 141 ms
  trên ~3,2 s (ba vòng) — ngang kéo chọn đo cùng lượt (141–328 ms; gd1_02: 141–359 ms). Lệnh: `cargo test --release -p
  fastcast-ui --test overlay -- --ignored --nocapture --test-threads=1` (dòng `resize_cpu_ms`; `--test-threads=1` để
  hai phép đo không chạy chồng).
- **Chờ kiểm tay [owner-qa] C9**: màn thật nhiều DPI — rê tay nắm thấy con trỏ đổi cỡ đúng hướng (thân vùng trên Windows
  là mũi tên thường — gpui-pre-windows không có IDC_SIZEALL), kéo cạnh vắt hai màn khác scale bám con trỏ, Tab / Enter
  / Space trên thanh, tooltip có phím tắt, Alt + mũi tên không bật menu hệ thống; sáng / tối.

## 10. Đề xuất cải tiến

- [ux] Thân vùng trên Windows hiện mũi tên thường — `gpui-pre-windows` `util.rs` map `OpenHand` / `ClosedHand` về
  `IDC_ARROW`, không có `IDC_SIZEALL` — vá upstream / đặt con trỏ Win32 qua `platform` — người dùng biết vùng dời được —
  M — P3 (cần đụng crate ngoài ⇒ `plan/_backlog.md`).
- [ux] Icon riêng "Lưu thành…" trong materiant (`icon.rs`, lucide `save-all` / `folder-down`) thay ba chấm vẽ tay ở
  `toolbar.rs` — đồng bộ nét icon — S — P3 (repo materiant đang nghiệm thu gd1_10 ⇒ `plan/_backlog.md`).
- [pro] Vùng chụp đặt tên (lưu vùng hay chụp + phím tắt, chụp lại đúng vùng) — người chụp lặp lại cùng vùng (báo cáo,
  tài liệu) — M — đã ghi chỗ Pro ở `fastcast/ROADMAP.md` GĐ4.
- Bảo mật / riêng tư: không áp (không I/O, log chỉ có toạ độ). RAM: không áp (8 ô tay nắm + 4 nút; thanh chỉ dựng ở một
  cửa sổ).
