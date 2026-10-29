# Khung tệp task và cách ước lượng — workspace xdesktop

> Bản Rust / desktop của `xbds/plan/_tasking-convention.md` (D-5), soạn 29/10/2026. Skill dùng khung này:
> `.claude/skills/run-task` (làm một task), `.claude/skills/handoff` (bàn giao khi xong task — mục 6),
> `.claude/skills/close-phase` (đóng giai đoạn).

## 0. Bố cục + đặt tên — tên PHẢI nói lên thứ tự

Một thư mục plan cho cả workspace: `plan/` ở repo gốc (chủ dự án chốt 29/10/2026). Không lồng trong `docs/`.

```
plan/
  _tasking-convention.md        # tệp này
  _backlog.md                   # việc treo / đề xuất đã chọn, chia mục theo dự án
  gd<N>_<NN>_<slug>.md          # task của fastcast — app chính
  <repo>-gd<N>_<NN>_<slug>.md   # task của repo khác (materiant-gd1_03_button-kbd.md…)
  <repo>-gd<N>.md               # plan giai đoạn chưa tách task (tạm, tách ngay khi bắt đầu giai đoạn)
completed/<repo>/gd<N>/         # giai đoạn đã đóng (skill close-phase dời về đây)
```

- `NN` hai chữ số, đúng **thứ tự làm**; `ls plan/` cho ra đúng thứ tự. Chèn task vào giữa ⇒ đổi tên các tệp sau nó
  + cập nhật bảng task trong lộ trình của repo.
- `slug` tiếng Anh, kebab-case, nói **cái đích** của task (`region-overlay`, `save-image`).
- Lộ trình + bảng task từng giai đoạn của một app nằm ở **repo của app**: `fastcast/ROADMAP.md`. Bảng chỉ có tên tệp +
  một dòng mô tả + phụ thuộc; chi tiết và trạng thái ở tệp task (một nguồn sự thật).
- Spike sống trong repo nó phục vụ: `<repo>/spikes/<tên>/` (crate riêng, ngoài cargo workspace), báo cáo
  `<repo>/docs/spikes/<tên>.md`.

## 1. Khung bắt buộc của một tệp task

```
# gd<N>_<NN> — <tên ngắn>

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ / 🔄 / ✅ (ngày) / ⛔ (lý do) |
| Repo | repo bị sửa (fastcast, materiant…) — run-task nạp `<repo>/CLAUDE.md` theo dòng này |
| Cỡ | S / M — kèm ước lượng dòng code |
| Phụ thuộc | task phải ✅ trước, kể cả task của repo khác (`materiant-gd1_03`) |
| Quyết định áp dụng | D-… / F-… trong `docs/decisions.md` |
| Phụ thuộc mới | crate + giấy phép (soát D-2), hoặc "—" |
| File đụng tới | đường dẫn thật tính từ repo, MỚI / SỬA |

## 1. Làm gì (3–8 gạch, mỗi gạch kiểm được)
## 2. Không làm trong task này (chống phình phạm vi)
## 2b. Phân vai — [opus] / [sonnet] / [owner-qa] (mục 8)
## 3. Kiểu dữ liệu · IPC · cấu hình (struct / enum mới, thông điệp IPC, khoá config.json — đủ để code theo)
## 4. Code (module, hàm chính, chỗ nối vào; mẫu đã chạy ở spike nào)
## 5. Đo (RAM theo Task Manager, độ trễ, CPU — con số + cách đo; "—" nếu không có)
## 6. Nghiệm thu — Case test C1, C2… (Cho / Khi / Thì, mỗi case ghi ai phủ)
## 7. Ghi chú UI (bố cục ASCII, khoá i18n `area.item`, phím, sáng / tối)
## 8. Nợ chuyển task khác
## 9. Bàn giao thực tế (điền khi xong)
## 10. Đề xuất cải tiến (Opus soi sau khi xanh — run-task mục 5; chủ dự án chọn)
```

Plan mới viết có thể để 2b / 6 ở dạng gạch nghiệm thu — run-task viết Phân vai + Case test lúc bắt đầu task.

## 2. Ước lượng: trần, vượt cái nào cũng phải tách

| Chỉ số | Trần |
|---|---|
| File Rust tạo mới hoặc sửa lớn | ≤ 7 |
| Dòng code mới (không tính test) | ≤ 900 |
| Phụ thuộc mới | ≤ 2 crate; vào `daemon` / `core` ⇒ đo RAM daemon trước / sau |
| Thông điệp IPC mới | ≤ 4 |

Nửa sau của session dài là chỗ chất lượng tụt; một task tràn sang session sau tốn hơn hai task gọn. Tách theo **lát
dọc** chạy được ngay (một tính năng từ phím tắt tới pixel), không theo tầng ngang.

## 3. Bốn loại kiểm

| Loại | Nội dung |
|---|---|
| **Đơn vị** | Hàm thuần: hình học, màu, phân tích phím, trạng thái chọn vùng… Mọi ngưỡng số có ca biên |
| **Tích hợp** | IPC thật qua endpoint riêng (`Endpoint::custom`), file thật trong `tempfile`, không đụng cấu hình người dùng |
| **Chạy thật** `[opus-run]` | Opus chạy exe release, giả lập phím (`keybd_event`), đọc log, đo RAM bằng `fastcast/tools/measure-ram.ps1` |
| **Tay** `[owner-qa]` | Chủ dự án kiểm thứ máy không tự kiểm được: nhìn bằng mắt, nhiều màn khác DPI / Hz, bộ gõ tiếng Việt, khởi động lại máy, macOS / Ubuntu. Ghi rõ bước + kết quả mong đợi |

Lệnh soát xanh mỗi repo: `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test`,
`cargo deny check licenses` (chạy với cwd = worktree của task).

## 4. Quy ước sẵn có — dùng lại, đừng phát minh

| Việc | Dùng |
|---|---|
| Toạ độ màn / vùng chọn | `fastcast_capture::geometry` — toàn cục, pixel vật lý; logic chỉ ở lớp vẽ (`MonitorInfo::to_logical`) |
| Ảnh đóng băng | `fastcast_capture::freeze()` → `Frozen { layout, frames }`, `crop`, `pixel` |
| Cấu hình | `fastcast_core::config` — thêm trường có `#[serde(default)]`; ghi qua `config::save` (nguyên tử) |
| Chữ hiển thị | `fastcast_core::i18n` + `i18n/{vi,en}.toml` cùng bộ khoá (có test) |
| Phím tắt | `fastcast_core::hotkey::{Command, Hotkey, Hotkeys}` — gán / trùng / lịch sử / quay lại đã có |
| IPC | `fastcast_core::ipc::Message` — thêm biến thể, không đổi biến thể cũ; JSON một dòng |
| Log | `fastcast_core::logging::init("<tiến trình>")` + macro `log` |
| JSON | khoá camelCase, giá trị enum snake_case |
| Ngôn ngữ | định danh tiếng Anh; comment / tài liệu tiếng Việt |

## 5. Khi nào dừng và hỏi

- Task đụng quyết định chưa chốt (Q-… ở `docs/decisions.md`, câu hỏi mở trong lộ trình) → dừng, hỏi.
- Cần vượt trần mục 2 → tách tệp, cập nhật bảng lộ trình, rồi mới code.
- Plan sai so với code thật → sửa task, ghi mục 9, **không sửa lén plan**.
- Cần dịch vụ trả phí / thiết bị không có (Mac, máy Ubuntu, chứng chỉ ký) → dừng, ghi `[owner-qa]` hoặc backlog.

## 6. Bàn giao khi xong

Làm bằng skill `handoff` (chế độ A; run-task mục 6 gọi). Task vừa ✅ thì — TRƯỚC khi gộp `master` — chèn khối bàn
giao vào **task kế tiếp cùng repo, cùng giai đoạn** (theo số;
task trong làn song song — lộ trình có sơ đồ làn, vd `materiant/ROADMAP.md` — ⇒ vào các task ghi nó ở dòng
"Phụ thuộc"), ngay sau bảng thuộc tính; có khối cũ thì đặt khối mới lên trên:

```markdown
## 0. Bàn giao từ gd<N>_<NN> (dd/mm/yyyy)

<!-- handoff: gd<N>_<NN> -->

- **Đã có sẵn để dùng**: module / hàm / cấu hình task trước để lại mà task này cần (đường dẫn thật).
- **Đổi so với lúc viết spec này**: tên hàm, khoá config, thông điệp IPC đã khác…
- **Nợ chuyển sang đây** (mục 8 của task trước nêu tên task này).
- **Bẫy đã gặp**: điều mất công mới biết và sẽ lặp lại ở task này.
- **Soát lại khi làm**: lệnh / số đo cụ thể.
```

5–15 gạch, chỉ điều liên quan task kế; chi tiết thì trỏ về mục 9 của task trước. Task cuối giai đoạn ⇒ ghi vào mục
"Bàn giao" của giai đoạn trong lộ trình repo (`fastcast/ROADMAP.md`).

## 7. Nhánh + gộp

Theo `CLAUDE.md` gốc: mỗi repo bị sửa một worktree `claude/<task>`, đặt ở `<gốc>/.claude/worktrees/<repo>-<task>`
(`.claude` chỉ ở repo gốc, thư mục này đã gitignore). Xong: soát xanh → `merge --no-ff` vào `master` → gỡ worktree →
`branch -d`. Có xung đột thì dừng hỏi. Task chỉ sửa plan / tài liệu ⇒ làm thẳng `master` của repo gốc, commit theo
đường dẫn.

## 8. Phân vai Opus ↔ Sonnet

Opus (session chính) bàn với chủ dự án, viết plan, **tự code phần khó**, giao Sonnet phần đã đặc tả kỹ, đọc diff + log
để verify. Sonnet = `Agent` với `subagent_type: "general-purpose"`, `model: "sonnet"` (workspace chưa có agent riêng).

| Nhãn | Ai | Làm gì |
| --- | --- | --- |
| `[opus]` | Opus tự code | hình học / toạ độ đa màn, luồng sự kiện + đa luồng, IPC + giao thức, mã `unsafe` / FFI theo OS, quyết định kiến trúc, interface giữa crate |
| `[sonnet]` | subagent Sonnet | ghép UI từ component `materiant` theo bố cục trong task, catalog i18n, đọc / ghi cấu hình đơn giản, test theo case Opus đã liệt kê — trên interface Opus đã chốt |
| `[owner-qa]` | chủ dự án | kiểm tay theo bước ghi trong case |

Phần `[sonnet]` phải đủ để làm mà không đoán: file MỚI / SỬA (phần của Opus không được chạm), bố cục ASCII, component
`materiant` cho từng khối, khoá i18n, interface đã chốt, case `C<n>` Cho / Khi / Thì. Case phủ bởi: `[opus-unit]` (ca
biên hàm thuần), `[sonnet-test]` (test theo case), `[opus-run]`, `[owner-qa]`.

Thứ tự trong task: `[opus]` chốt interface + logic → `[sonnet]` (song song nếu khác file) → Opus đọc diff + soát xanh
→ `[opus-run]` → `[owner-qa]` → lỗi: giao lại đúng người đã viết → gộp `master` + bàn giao.
