---
name: feedback-fastcast-tests-headless
description: "Máy Linux: cargo test của fastcast-ui mở cửa sổ thật (test fake_* overlay) — luôn chạy qua tools/headless-test.sh"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 71958465-e240-4949-9c29-2001dd929542
  modified: 2026-11-02T09:38:25.205Z
---

Trên máy Linux, `cargo test -p fastcast-ui` (nhất là `--test overlay`, các test `fake_*`) bật `fastcast-ui` với màn giả và mở cửa sổ thật. Chạy trần là hiện lên màn thật của chủ dự án (đã dính 02/11/2026: nhiều cửa sổ lưới màu + thanh công cụ overlay chồng nhau).

**Why:** chủ dự án đang dùng màn thật; luật máy cấm phủ / chụp màn thật.

**How to apply:** mọi lệnh có thể mở cửa sổ (test UI của fastcast, gallery / example materiant, exe fastcast) chạy qua `bash fastcast/tools/headless-test.sh <lệnh>` (bus riêng, `WAYLAND_DISPLAY` riêng, `unset DISPLAY`). `cargo build` / `clippy` và `ui-tests` của materiant (TestAppContext, không cửa sổ thật) chạy trần được. Xem thêm [[feedback-test-on-dell]].
