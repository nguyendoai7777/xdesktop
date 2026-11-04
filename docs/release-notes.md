# Release note (D-22)

Mỗi tag `v<version>` của một repo (`fastcast`, `groove`, `materiant`) có đúng một tệp `<repo>/release-notes/v<version>.md`. Tệp
đó là changelog của bản phát hành: `tag.sh` / `tag.ps1` commit nó cùng lần nâng version và dùng nguyên văn làm nội dung tag
(`git tag -a --cleanup=verbatim -F`). Sau này dựng trang tải / GitHub Release thì đọc thẳng tệp này.

## Quy trình

1. Chạy `bash tag.sh` (hoặc `pwsh ./tag.ps1`) như thường. Chưa có tệp của version sắp tag ⇒ script tạo khung
   `<repo>/release-notes/v<version>.md` rồi dừng, chưa đổi gì khác.
2. Điền khung, **xoá dòng `<!-- release-note: điền xong thì xoá dòng này -->`** (còn dòng đó thì script từ chối).
3. Chạy lại đúng lệnh cũ: script nâng version, commit `Cargo.toml` + `Cargo.lock` + tệp release note, đánh tag.

Có thể viết trước: tạo sẵn tệp đúng tên rồi mới chạy script — tệp chưa commit vẫn được phép, nó đi cùng commit nâng version.
`--current` (tag version đang có) cũng đòi tệp; tệp chưa commit thì có thêm commit `release notes: v<version>`.

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
- Lấy ý từ `git log v<bản trước>..HEAD --merges` của repo, gom theo ý chứ không chép từng commit.
