---
name: msix-appdata-virtualization
description: "Tiến trình chạy từ app Claude desktop (Windows, gói MSIX) thấy AppData ảo hoá — config/log khác với khi chạy từ Explorer / Task Scheduler"
metadata:
  node_type: memory
  type: reference
  originSessionId: 8c0f3708-fdd0-40ce-b977-4e37db924852
  modified: 2026-10-29T12:31:41.577Z
---

Trên máy nhà Windows, Claude desktop là gói MSIX (`Claude_pzs8sxrjxfjjc`). Mọi tiến trình con (Bash, PowerShell, exe
fastcast chạy thử) bị ảo hoá AppData: ghi `%APPDATA%` / `%LOCALAPPDATA%` rơi vào
`%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\{Roaming,Local}\…`, và đọc thấy bản ảo đó trước bản thật.
Tiến trình do Explorer / Task Scheduler bật thì dùng AppData thật. HKCU\Software cũng có thể bị ảo hoá tương tự.

Hệ quả khi test fastcast (29/10/2026): `config.json` + log của daemon chạy từ session Claude ≠ của daemon tự khởi
động; muốn xem log thật của daemon do Task Scheduler bật thì không đọc thẳng được từ session. Named pipe, Task Scheduler
(schtasks) không bị ảo hoá. Liên quan: [[user-profile]].
