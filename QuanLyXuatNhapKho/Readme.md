**A. Mô hình hóa dữ liệu Quản lý vật tư xây dựng công trình bằng mô hình ER**
Ràng buộc dữ liệu:
1. Ngày Hợp Đồng trước ngày Khởi công
2. Ngày khởi công phải trước hoặc trùng ngày dự kiến hoàn thành
3. Bảng Nhập Xuất, ứng với một IDNhapXuat phải có 1 trong 2 thông tin IDPhieuXuat (TH xuất kho đi CT hoặc trả NCC) hoặc IDPhieuNhap (TH nhập kho từ CT hoặc NCC) hoặc có cả 2 thông tin IDPhieuXuat và IDPhieuNhap (TH chuyển từ kho tới kho)
4. Mỗi phiếu nhập chỉ liên quan đến một nguồn duy nhất
5. Mỗi phiếu xuất chỉ liên quan đến một nơi nhận duy nhất
6. Trường hợp chuyển kho, Kho xuất và Kho Nhập phải khác nhau
7. Trường hợp chuyển kho, ngày xuất phải trước hoặc cùng ngày nhập
8. Trường hợp chuyển kho, trong chi tiết phiếu chyển, số lượng nhập thực tế phải nhỏ hơn số lượng xuất thực tế

**B. Tạo bảng báo cáo Xuất Nhập cho các Kho, NCC, Công trình
