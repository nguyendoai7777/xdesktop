---
name: feedback-test-on-dell
description: "Máy nhà có hai màn; cửa sổ chạy thử chỉ mở ở màn DELL (màn phụ), màn LG là màn chủ dự án đang dùng"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 8ebe2be3-bf9c-47a8-80b5-098ce21fb70b
  modified: 2026-10-30T13:45:39.106Z
---

Cửa sổ chạy thử chỉ mở trên màn DELL S2319H (DISPLAY1, màn phụ, 60 Hz, x từ -1920 tới -1). Màn LG ULTRAGEAR (DISPLAY2, màn chính, 144 Hz, x từ 0) để chủ dự án dùng: không mở cửa sổ, không lấy focus, không giả lập phím, không chụp ảnh ở đó.

**Why:** chủ dự án đang xem / làm việc ở màn LG thì bị cửa sổ màn giả của session gd3_09 đè lên (30/10/2026).

**How to apply:** `FASTCAST_OVERLAY_FAKE` đã tự chọn màn phụ qua `overlay::fake_display`; cửa sổ thử kiểu khác thì tự đặt sang màn phụ. Máy khác không có hai màn này thì theo luật chung: không đè màn đang dùng. Nhắn session khác phải dùng id `local_…`, gửi theo tên không tới. Liên quan [[user-profile]].
