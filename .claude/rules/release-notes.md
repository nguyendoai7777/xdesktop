---
paths:
  - "*/release-notes/**"
  - ".claude/worktrees/*/release-notes/**"
  - "tag.sh"
  - "tag.ps1"
---

# Release note (D-22)

Mỗi tag `v<version>` của một repo (`fastcast`, `groove`, `materiant`) có đúng một tệp `<repo>/release-notes/v<version>.md`. Tệp
đó là changelog của bản phát hành: `tag.sh` / `tag.ps1` commit nó cùng lần nâng version và dùng nguyên văn làm nội dung tag
(`git tag -a --cleanup=verbatim -F`). Sau này dựng trang tải / GitHub Release thì đọc thẳng tệp này.

## Quy trình

Chạy `bash tag.sh` (hoặc `pwsh ./tag.ps1`) như thường — **không phải điền gì** (chủ dự án 13/11/2026: "cho phép release êm"):

- Chưa có tệp của version sắp tag (hoặc tệp còn dòng mẫu `<!-- release-note: điền xong thì xoá dòng này -->`) ⇒ script **tự sinh**
  từ tiêu đề commit kể từ tag `v*` trước (`git log <tag trước>..HEAD`, bỏ commit `plan:` / `release` / `deps:` / `decisions:`, bỏ mã
  task đầu dòng, bỏ trùng) thành một mục `## Thay đổi`, rồi nâng version, commit `Cargo.toml` + `Cargo.lock` + tệp, đánh tag luôn.
- Muốn note viết cho người dùng: tạo sẵn tệp đúng tên theo khuôn dưới rồi mới chạy script (tệp chưa commit vẫn được phép, đi
  cùng commit nâng version). Sửa note tự sinh trước khi push: sửa tệp, `git commit --amend`, `git tag -f -a v<version> --cleanup=verbatim -F <tệp>`.
- Hộp "Có gì mới" của app (gd8_01) và `notes` của manifest cập nhật (`publish-release --notes`) đọc đúng tệp này.

`--current` (tag version đang có) cũng vậy; tệp chưa commit thì có thêm commit `release notes: v<version>`.

## Khuôn

```markdown
# <repo> v<version> (<yyyy-mm-dd>)

## Mới

- <tính năng người dùng thấy, viết cho người dùng, không cho dev>

## Sửa lỗi

- <lỗi người dùng từng gặp, đã hết>

## Thay đổi khác

- <hiệu năng, gói cài, phụ thuộc, nền tảng>
```

- Viết tiếng Việt, câu ngắn, theo góc nhìn người dùng ("Hàng đợi tự cuộn tới bài đang phát"), không mã commit / tên hàm.
- Mục nào trống thì xoá mục đó. Không có gì người dùng thấy (bản chỉ sửa nội bộ) vẫn ghi một dòng ở "Thay đổi khác".
- Lấy ý từ `git log v<bản trước>..HEAD` của repo (lịch sử thẳng, D-12: commit mở đầu bằng mã task), gom theo ý chứ không chép từng commit.
