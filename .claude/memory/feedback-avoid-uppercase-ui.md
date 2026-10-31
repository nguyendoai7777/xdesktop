---
name: feedback-avoid-uppercase-ui
description: "Nhãn giao diện viết hoa chữ cái đầu dòng, không viết toàn chữ hoa; tên app là Fastcast — chủ dự án đổi 31/10/2026"
metadata:
  node_type: memory
  type: feedback
  originSessionId: d5bb5cbf-22da-49cb-9f50-919c0d4ef95d
  modified: 2026-10-31T11:40:00.000Z
---

Mọi chữ trên giao diện viết hoa chữ cái đầu dòng ("Quay vùng", "Bắt đầu", "Hex"), không viết toàn chữ hoa, không uppercase transform. Tên app hiển thị là `Fastcast`; định danh, tên crate, đường dẫn vẫn viết thường.

**Why:** 30/10/2026 chủ dự án nói toàn chữ hoa "rất khó chịu khi nhìn"; 31/10/2026 khi xem bảng quay viết thường hết thì yêu cầu "tất cả những text nên viết hoa chữ cái đầu dòng". Thay luật cũ "viết thường". Chốt ở `docs/decisions.md` D-13.

**How to apply:** khi thêm khoá vào `i18n/*.toml` hoặc nhãn cố định, viết hoa chữ đầu. Giá trị do người dùng chép (mã `#1E90FF`) là dữ liệu, không phải nhãn.
