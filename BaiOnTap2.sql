CREATE DATABASE BAI2
USE BAI2

CREATE TABLE NHANVIEN
(
	MaNV char(5) NOT NULL,
	HoTen varchar(20),
	NgayVL smalldatetime,
	HSLuong numeric(4,2),
	MaPhong char(5) NOT NULL,
	CONSTRAINT NHANVIEN_PK PRIMARY KEY (MaNV),
)

CREATE TABLE PHONGBAN
(
	MaPhong char(5) NOT NULL,
	TenPhong varchar(25),
	TruongPhong char(5),
	CONSTRAINT PHONGBAN_PK PRIMARY KEY (MaPhong),
)

ALTER TABLE NHANVIEN ADD CONSTRAINT NV_PB_FK FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong)
ALTER TABLE PHONGBAN ADD CONSTRAINT PB_NV_FK FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNV)

CREATE TABLE XE
(
	MaXe char(5) NOT NULL,
	LoaiXe varchar(20),
	SoChoNgoi int,
	NamSX int,
	CONSTRAINT XE_PK PRIMARY KEY (MaXe),
)

CREATE TABLE PHANCONG
(
	MaPC char(5) NOT NULL,
	MaNV char(5) NOT NULL,
	MaXe char(5) NOT NULL,
	NgayDi smalldatetime,
	NgayVe smalldatetime,
	NoiDen varchar(25),
	CONSTRAINT PHANCONG_PK PRIMARY KEY (MaPC,MaNV,MaXe),
	CONSTRAINT PC_NV_FK FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
	CONSTRAINT PC_XE_FK FOREIGN KEY (MaXe) REFERENCES XE(MaXe)
)

-- Cau 2 --
-- Cau 2.1 --
ALTER TABLE XE ADD CONSTRAINT KT_NamSX CHECK ((LoaiXe = 'Toyota' AND NamSX > 2006) OR LoaiXe != 'Toyota')

-- Cau 2.2 --
CREATE TRIGGER ins_CAU2 ON PHANCONG
FOR INSERT
AS
BEGIN
	IF EXISTS ( SELECT 1
				FROM inserted i
				JOIN NHANVIEN ON i.MaNV = NHANVIEN.MaNV
				JOIN XE ON i.MaXe = XE.MaXe
				JOIN PHONGBAN ON NHANVIEN.MaPhong = PHONGBAN.MaPhong
				WHERE LoaiXe != 'Toyota' AND TenPhong = 'NgoaiThanh' )
	BEGIN
		PRINT 'NHAN VIEN THUOC PHONG NGOAI THANH CHI DUOC LAI XE TOYOTA'
		ROLLBACK TRAN
	END
	ELSE 
	BEGIN
		PRINT 'THAO TAC THANH CONG'
	END
END

-- Cau 3 --
-- Cau 3.1 --
SELECT NHANVIEN.MaNV, HoTen 
FROM NHANVIEN
JOIN PHANCONG ON NHANVIEN.MaNV = PHANCONG.MaNV
JOIN PHONGBAN ON NHANVIEN.MaPhong = NHANVIEN.MaPhong
JOIN XE ON PHANCONG.MaXe = XE.MaXe
WHERE TenPhong = 'Noi Thanh' AND LoaiXe = 'Toyota' AND SoChoNgoi = 4

-- Cau 3.2 --

SELECT NHANVIEN.MaNV, HoTen
FROM NHANVIEN	
JOIN PHONGBAN ON NHANVIEN.MaNV = PHONGBAN.TruongPhong
JOIN PHANCONG ON NHANVIEN.MaNV = PHANCONG.MaNV
JOIN XE ON PHANCONG.MaXe = XE.MaXE
GROUP BY NHANVIEN.MaNV, HoTen
HAVING COUNT(DISTINCT LoaiXe) = ( SELECT COUNT(DISTINCT LoaiXe)
								  FROM XE )

-- Cau 3.3 --
SELECT NHANVIEN.MaNV, HoTen
FROM NHANVIEN
JOIN PHONGBAN ON NHANVIEN.MaPhong = PHONGBAN.MaPhong
WHERE EXISTS ( SELECT 1
			   FROM PHANCONG
			   JOIN XE ON PHANCONG.MaXe = XE.MaXe
			   WHERE PHANCONG.MaNV = NHANVIEN.MaNV AND LoaiXe = 'Toyota')
GROUP BY NHANVIEN.MaNV, PHONGBAN.MaPhong, NHANVIEN.HoTen