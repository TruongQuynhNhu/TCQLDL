/* Tao bang */
CREATE DATABASE QLXNK;
USE QLXNK;
CREATE TABLE KHACHHANG_CDT(
ID_KH_CDT int unique not null,
Ten varchar(30),
DiaChi VARCHAR(30),
SDT INT,
Email VARCHAR(20)
);
CREATE TABLE CONGTRINH(
ID_CT INT UNIQUE NOT NULL,
Ten_CTrinh varchar(30),
ID_KH_CDT int,
DiaDiemThiCong varchar(30), /* trong thực tế, nếu cần lưu 2 cấp (tỉnh, huyện) thì nên làm như nào */
NgayKhoiCong DATE,
NgayDuKienHoanThanh DATE
);
CREATE TABLE NHACUNGCAP(
ID_NCC INT UNIQUE NOT NULL,
TenNCC VARCHAR(30)
);
CREATE TABLE KHO(
ID_Kho INT UNIQUE NOT NULL,
TenKho VARCHAR(30),
DiaChi VARCHAR(30)
);
CREATE TABLE VATTU(
ID_VatTu INT UNIQUE NOT NULL,
TenVatTu VARCHAR(30),
DonViTinh VARCHAR(10)
);
CREATE TABLE HOPDONG(
IDHopDong INT UNIQUE NOT NULL,
NgayHD DATE,
ID_Ctrinh INT,
TongGiaTri INT
);
CREATE TABLE PHIEUXUAT(
IDPhieuXuat INT UNIQUE NOT NULL,
NgayXuat DATE,
IDKhoXuat INT NOT NULL,
IDKhoNhan INT,
IDNCCNhan INT,
IDCTNhan INT
);
CREATE TABLE PHIEUNHAP(
IDPhieuNhap INT UNIQUE NOT NULL,
NgayNhap DATE,
IDKhoNhap INT NOT NULL,
IDKhoNguon INT,
IDNCCNguon INT,
IDCTNguon INT,
IDPhieuXuat INT
);
CREATE TABLE CHITIETPX(
IDPhieuXuat INT NOT NULL,
ID_VatTu INT NOT NULL,
SlgKeHoach INT,
SlgThucTe INT
);
CREATE TABLE CHITIETPN(
IDPhieuNhap INT NOT NULL,
ID_VatTu INT NOT NULL,
SlgKeHoach INT,
SlgThucTe INT,
IDPhieuXuat INT
);
CREATE TABLE TON(
ID_Kho INT NOT NULL,
ID_VatTu INT NOT NULL,
SttTonKho INT NOT NULL,
TonDauKy INT,
SLgNhap INT,
SLgXuat INT
);

/*Thiet lap PK,FK */

ALTER TABLE KHACHHANG_CDT
ADD CONSTRAINT PK_KHCDT PRIMARY KEY (ID_KH_CDT)
;
ALTER TABLE CONGTRINH
ADD CONSTRAINT PK_CT PRIMARY KEY (ID_CT),
	CONSTRAINT FK_KHCDT1 FOREIGN KEY (ID_KH_CDT) REFERENCES KHACHHANG_CDT(ID_KH_CDT),
	CONSTRAINT [
Chk_Ngay1:

NgayKhoiCong must not be after NgayDuKienHoanThanh

] CHECK (NgayKhoiCong <= NgayDuKienHoanThanh)
;
ALTER TABLE NHACUNGCAP
ADD CONSTRAINT PK_NCC PRIMARY KEY (ID_NCC)
;
ALTER TABLE KHO
ADD CONSTRAINT PK_Kho PRIMARY KEY (ID_Kho)
;
ALTER TABLE VATTU
ADD CONSTRAINT PK_VT PRIMARY KEY (ID_VatTu)
;
ALTER TABLE HOPDONG
ADD CONSTRAINT PK_HD PRIMARY KEY (IDHopDong),
	CONSTRAINT FK_CT FOREIGN KEY (ID_Ctrinh) REFERENCES CONGTRINH(ID_CT)
;

ALTER TABLE PHIEUXUAT
ADD CONSTRAINT PK_PX PRIMARY KEY (IDPhieuXuat),
	CONSTRAINT FK_Kho3 FOREIGN KEY (IDKhoXuat) REFERENCES KHO(ID_Kho),
	CONSTRAINT FK_Kho4 FOREIGN KEY (IDKhoNhan) REFERENCES KHO(ID_Kho),
	CONSTRAINT FK_NCC2 FOREIGN KEY (IDNCCNhan) REFERENCES NHACUNGCAP(ID_NCC),
	CONSTRAINT FK_CT3 FOREIGN KEY (IDCTNhan) REFERENCES CONGTRINH(ID_CT)
;
ALTER TABLE PHIEUNHAP
ADD CONSTRAINT PK_PN PRIMARY KEY (IDPhieuNhap),
	CONSTRAINT FK_Kho1 FOREIGN KEY (IDKhoNhap) REFERENCES KHO(ID_Kho),
	CONSTRAINT FK_Kho2 FOREIGN KEY (IDKhoNguon) REFERENCES KHO(ID_Kho),
	CONSTRAINT FK_NCC1 FOREIGN KEY (IDNCCNguon) REFERENCES NHACUNGCAP(ID_NCC),
	CONSTRAINT FK_CT2 FOREIGN KEY (IDCTNguon) REFERENCES CONGTRINH(ID_CT),
	CONSTRAINT FK_PX FOREIGN KEY (IDPhieuXuat) REFERENCES PHIEUXUAT(IDPhieuXuat)
;

ALTER TABLE CHITIETPX
ADD CONSTRAINT PK_PX_VT PRIMARY KEY (IDPhieuXuat, ID_VatTu),
	CONSTRAINT FK_PX2 FOREIGN KEY (IDPhieuXuat) REFERENCES PHIEUXUAT(IDPhieuXuat),
	CONSTRAINT FK_VT FOREIGN KEY (ID_VatTu) REFERENCES VATTU(ID_VatTu)
;
ALTER TABLE CHITIETPN
ADD CONSTRAINT PK_PN_VT PRIMARY KEY (IDPhieuNhap, ID_VatTu),
	CONSTRAINT FK_PN FOREIGN KEY (IDPhieuNhap) REFERENCES PHIEUNHAP(IDPhieuNhap),
	CONSTRAINT FK_VT2 FOREIGN KEY (ID_VatTu) REFERENCES VATTU(ID_VatTu),
	CONSTRAINT FK_PX_VT FOREIGN KEY (IDPhieuXuat, ID_VatTu) REFERENCES CHITIETPX(IDPhieuXuat, ID_VatTu) --truong hop dieu chuyen kho
;
ALTER TABLE TON
DROP CONSTRAINT IF EXISTS PK_TON;
ALTER TABLE TON
ADD CONSTRAINT PK_TON PRIMARY KEY (ID_Kho, ID_VatTu, SttTonKho),
	CONSTRAINT FK_Kho5 FOREIGN KEY (ID_Kho) REFERENCES KHO(ID_Kho),
	CONSTRAINT FK_VT3 FOREIGN KEY (ID_VatTu) REFERENCES VATTU(ID_VatTu)
;

/* Phiếu nhập:  - nguồn chỉ từ một trong 3 nguồn kho, nhà cung cấp, công trình
				- trường hợp điều chuyển kho, kho nhận khác kho nguồn 
				- trường hợp điều chuuyeern kho, ID Phiếu Xuất phải được nhập, không được NULL */
ALTER TABLE PHIEUNHAP
DROP CONSTRAINT IF EXISTS [

ChkNguon1:

There must be only 1 type of supplier
The IDPhieuXuat must be filled only if the supplier is a warehouse

];
ALTER TABLE PHIEUNHAP
DROP CONSTRAINT IF EXISTS [

ChkNguon2:

IDKhoNguon must be different from IDKhoNhap

];
ALTER TABLE PHIEUNHAP
ADD CONSTRAINT [

ChkNguon1:

There must be only 1 type of supplier
The IDPhieuXuat must be filled only if the supplier is a warehouse

] CHECK ((IDNCCNguon IS NULL AND IDCTNGuon IS NULL AND IDKhoNguon IS NOT NULL AND IDPhieuXuat IS NOT NULL) OR
								(IDNCCNguon IS NULL AND IDCTNGuon IS NOT NULL AND IDKhoNguon IS NULL AND IDPhieuXuat IS NULL) OR
								(IDNCCNguon IS NOT NULL AND IDCTNGuon IS NULL AND IDKhoNguon IS NULL AND IDPhieuXuat IS NULL)),
	CONSTRAINT [

ChkNguon2:

IDKhoNguon must be different from IDKhoNhap

] CHECK (NOT(IDKhoNguon = IDKhoNhap))
;
/* Phiếu xuất:  - nguồn chỉ từ một trong 3 nguồn kho, nhà cung cấp, công trình
				- trường hợp điều chuyển kho, kho nhận khác kho nguồn */
ALTER TABLE PHIEUXUAT
DROP CONSTRAINT IF EXISTS [
ChkNhan1:

There must be only 1 type of receiver: NCC or Kho or CongTrinh

];
ALTER TABLE PHIEUXUAT
DROP CONSTRAINT IF EXISTS [
ChkNhan2:
	
IDKhoXuat must be different from IDKhoNhan
	
];
ALTER TABLE PHIEUXUAT
ADD CONSTRAINT [
ChkNhan1:

There must be only 1 type of receiver: NCC or Kho or CongTrinh

] CHECK ((IDKhoNhan IS NULL AND IDNCCNhan IS NULL AND IDCTNhan IS  NOT NULL) OR
		(IDKhoNhan IS NOT NULL AND IDNCCNhan IS NULL AND IDCTNhan IS NULL) OR
		(IDKhoNhan IS NULL AND IDNCCNhan IS NOT NULL AND IDCTNhan IS NULL)),
	CONSTRAINT [
ChkNhan2:
	
IDKhoXuat must be different from IDKhoNhan
	
]
	CHECK (NOT(IDKhoXuat = IDKhoNhan))
;

/* TH điều chuyển kho, Phiếu nhập chỉ cần nhập ID Phiếu Xuất tương ứng thì trigger auto insert IDKhoNhan và IDKhoNguon*/
DROP TRIGGER IF EXISTS Autofill_IDKN1, 
						Autofill_IDKN3,
						Autofill_IDKN2;
GO
CREATE TRIGGER Autofill_IDKN1 ON PHIEUNHAP INSTEAD OF INSERT AS
BEGIN
	IF (SELECT IDPhieuXuat FROM inserted) IS NOT NULL
		INSERT INTO PHIEUNHAP
		SELECT i.IDPhieuNhap, i.NgayNhap, x.IDKhoNhan, x.IDKhoXuat, i.IDNCCNguon, i.IDCTNguon, i.IDPhieuXuat 
		FROM inserted i JOIN PHIEUXUAT x ON i.IDPhieuXuat = x.IDPhieuXuat
		PRINT 'IDKhoNhap and IDKhoNguon was auto-updated depending on the inserted IDPhieuXuat'
END
GO
CREATE TRIGGER Autofill_IDKN3 ON PHIEUNHAP INSTEAD OF UPDATE AS
BEGIN
	IF (SELECT IDPhieuXuat FROM inserted) IS NOT NULL
		UPDATE PHIEUNHAP
		SET NgayNhap = (SELECT NgayNhap from inserted),
			IDKhoNhap = (SELECT IDKhoNhan from PHIEUXUAT x join inserted i ON x.IDPhieuXuat = i.IDPhieuXuat),
			IDKhoNguon = (SELECT IDKhoXuat from PHIEUXUAT x join inserted i ON x.IDPhieuXuat = i.IDPhieuXuat),
			IDNCCNguon = (SELECT IDNCCNguon from inserted),
			IDCTNguon = (SELECT IDCTNguon from inserted),
			IDPhieuXuat = (SELECT IDPhieuXuat from inserted)
		WHERE IDPhieuNhap = (SELECT IDPhieuNhap from inserted)
		PRINT 'IDKhoNhap and IDKhoNguon was auto-updated depending on the updated IDPhieuXuat'
END
--update IDKhoNhan và IDKhoNguon của PHIEUNHAP trong trường hợp cập nhật lại PHIEUXUAT tương ứng
GO
CREATE TRIGGER Autofill_IDKN2 ON PHIEUXUAT AFTER UPDATE AS
BEGIN
	UPDATE PHIEUNHAP
	SET IDKhoNhap = (SELECT IDKhoNhan FROM inserted) WHERE IDPhieuXuat = (SELECT IDPhieuXuat FROM inserted)
	UPDATE PHIEUNHAP
	SET IDKhoNguon = (SELECT IDKhoXuat FROM inserted) WHERE IDPhieuXuat = (SELECT IDPhieuXuat FROM inserted)
	PRINT 'IDKhoNhap and IDKhoNguon was auto-updated depending on the updated information from PHIEUNHAP'
END

/* TH điều chuyển kho, Ngày nhập phải sau hoặc trùng ngày xuất*/
-- Tạo CONSTRAINT cho phiếu Xuất
GO
ALTER TABLE PHIEUNHAP DROP CONSTRAINT IF EXISTS [

ChkNgayNhapXuat1:
In case of warehouse-to-warehouse shipment, NgayNhap must not be before NgayXuat

];
DROP FUNCTION IF EXISTS SsNNNX1;
GO
CREATE FUNCTION SsNNNX1 (@IDPXuat int, @NN date)
RETURNS bit AS
BEGIN
	DECLARE @result bit
	IF ((SELECT NgayXuat from PHIEUXUAT x WHERE x.IDPhieuXuat = @IDPXuat) <= @NN) OR @IDPXuat IS NULL
		SET @result = 1
	ELSE
		SET @result = 0
	RETURN @result
END
GO
ALTER TABLE PHIEUNHAP
ADD CONSTRAINT [

ChkNgayNhapXuat1:
In case of warehouse-to-warehouse shipment, NgayNhap must not be before NgayXuat

] CHECK (dbo.SsNNNX1(IDPhieuXuat, NgayNhap) = 1)
;
-- Tạo CONSTRAINT cho phiếu Nhập
GO
ALTER TABLE PHIEUNHAP DROP CONSTRAINT IF EXISTS [

ChkNgayNhapXuat2:
In case of warehouse-to-warehouse shipment, NgayNhap must not be before NgayXuat

];
DROP FUNCTION IF EXISTS SsNNNX2;
GO
CREATE FUNCTION SsNNNX2 (@IDPXuat int, @NX date)
RETURNS bit AS
BEGIN
	DECLARE @result bit
	IF @IDPXuat IS NULL
		SET @result = 1
	ELSE IF (SELECT NgayNhap from PHIEUNHAP n WHERE n.IDPhieuXuat = @IDPXuat) IS NULL OR (SELECT NgayNhap from PHIEUNHAP n WHERE n.IDPhieuXuat = @IDPXuat)>= @NX
		SET @result = 1
	ELSE
		SET @result = 0
	RETURN @result
END
GO
ALTER TABLE PHIEUXUAT
ADD CONSTRAINT [

ChkNgayNhapXuat2:
In case of warehouse-to-warehouse shipment, NgayNhap must not be before NgayXuat

] CHECK (dbo.SsNNNX2(IDPhieuXuat, NgayXuat) = 1)
;


/* TH điều chuyển kho, CTPN auto fill IDPhieuXuat tương ứng với Phiếu nhập đó*/
--update CHITIETPN.IDPhieuXuat trong trường hợp tạo chitietpn mới

DROP TRIGGER IF EXISTS Autofill_IDPX1,
						Autofill_IDPX2;
GO
CREATE TRIGGER Autofill_IDPX1 ON CHITIETPN INSTEAD OF INSERT AS
BEGIN
	INSERT INTO CHITIETPN SELECT * FROM inserted
	UPDATE CHITIETPN
	SET IDPhieuXuat = (SELECT IDPhieuXuat FROM PHIEUNHAP WHERE IDPhieuNhap = CHITIETPN.IDPhieuNhap) 
	WHERE IDPhieuNhap = (SELECT IDPhieuNhap FROM inserted)
END
--update CHITIETPN trong trường hợp cập nhật lại phiếu nhập tương ứng
GO
CREATE TRIGGER Autofill_IDPX2 ON PHIEUNHAP AFTER UPDATE AS
BEGIN
	UPDATE CHITIETPN
	SET IDPhieuXuat = (SELECT IDPhieuXuat FROM inserted) 
	WHERE IDPhieuNhap = (SELECT IDPhieuNhap from inserted)
END
--check CHITIETPN.IDPhieuXuat = PHIEUNHAP.IDPhieuXuat
ALTER TABLE CHITIETPN
DROP CONSTRAINT IF EXISTS ChkIDPX;
DROP FUNCTION IF EXISTS SsIDPX;
GO
CREATE FUNCTION SsIDPX (@IDPN int, @IDPX int)
RETURNS bit AS
BEGIN
	DECLARE @result bit
	IF (SELECT IDPhieuXuat FROM PHIEUNHAP WHERE IDPhieuNhap=@IDPN) = @IDPX
		SET @result = 1
	ELSE
		SET @result = 0
	RETURN @result
END
GO

ALTER TABLE CHITIETPN
ADD CONSTRAINT ChkIDPX CHECK (dbo.SsIDPX(IDPhieuNhap, IDPhieuXuat)=1);
GO	
/*Ngày Hợp Đồng trước ngày Khởi công*/
--CONSTRAINT cho bảng HOPDONG
ALTER TABLE HOPDONG
DROP CONSTRAINT IF EXISTS [

Chk_NgHD:

NgayKhoiCong must be not before NgayHopDong

];
DROP FUNCTION IF EXISTS SsNgHD_KC;
GO
CREATE FUNCTION SsNgHD_KC (@IDCT INT, @NgayHD DATE)
RETURNS bit AS
BEGIN
	DECLARE @result bit
	IF (SELECT NgayKhoiCong FROM CONGTRINH WHERE ID_CT=@IDCT) >= @NgayHD
		SET @result = 1
	ELSE
		SET @result = 0
	RETURN @result
END
GO
ALTER TABLE HOPDONG
ADD CONSTRAINT [

Chk_NgHD:

NgayKhoiCong must be not before NgayHopDong

] CHECK (dbo.SsNgHD_KC(IDHopDong, NgayHD) = 1);
GO
--CONSTRAINT cho bảng CONGTRINH, trong truong hop trường dữ liệu đã nhập đúng nhưng sau đó bảng CONGTRINH bị sửa lại thì cần có CONSTRAINT
ALTER TABLE CONGTRINH
DROP CONSTRAINT IF EXISTS [

Chk_NgKC:

NgayKhoiCong must be not before NgayHopDong

];
DROP FUNCTION IF EXISTS SsNgHD_KC2;
GO
CREATE FUNCTION SsNgHD_KC2 (@IDCT INT, @NgayKC DATE)
RETURNS bit AS
BEGIN
	DECLARE @result bit
	IF (SELECT NgayHD FROM HOPDONG WHERE ID_Ctrinh=@IDCT) <= @NgayKC
		SET @result = 1
	ELSE
		SET @result = 0
	IF (SELECT NgayHD FROM HOPDONG WHERE ID_Ctrinh=@IDCT) IS NULL
		SET @result = 1
	RETURN @result
END
GO

ALTER TABLE CONGTRINH
ADD CONSTRAINT [

Chk_NgKC:

NgayKhoiCong must be not before NgayHopDong

] CHECK (dbo.SsNgHD_KC2(ID_CT, NgayKhoiCong) = 1);