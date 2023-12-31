CREATE DATABASE BAI3
USE BAI3

CREATE TABLE DOCGIA
(
	MaDG char(5) NOT NULL,
	HoTen varchar(30),
	NgaySinh smalldatetime,
	DiaChi varchar(30),
	SoDT varchar(15),
	CONSTRAINT DOCGIA_PK PRIMARY KEY (MaDG)
)

CREATE TABLE SACH
(
	MaSach char(5) NOT NULL,
	TenSach varchar(25),
	TheLoai varchar(25),
	NhaXuatBan varchar(30),
	CONSTRAINT SACH_PK PRIMARY KEY (MaSach)
)

CREATE TABLE PHIEUTHUE 
(
	MaPT char(5) NOT NULL,
	MaDG char(5) NOT NULL,
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoSachThue int,
	CONSTRAINT PHIEUTHUE_PK PRIMARY KEY (MaPT),
	CONSTRAINT PT_DG_FK FOREIGN KEY (MaDG) REFERENCES DOCGIA(MaDG)
)

CREATE TABLE CHITIET_PT
(
	MaPT char(5) NOT NULL,
	MaSach char(5) NOT NULL,
	CONSTRAINT CHITIETPT_PK PRIMARY KEY (MaPT, MaSach),
	CONSTRAINT CT_PT_FK FOREIGN KEY (MaPT) REFERENCES PHIEUTHUE(MaPT),
	CONSTRAINT CT_SACH_FK FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)
)

-- Cau 2 --
-- Cau 2.1 --

CREATE TRIGGER ins_up_THUESACH ON PHIEUTHUE
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MADG char(5)
	DECLARE @NgayThue smalldatetime, @NgayTra smalldatetime
	SELECT @MADG = MaDG, @NgayThue = NgayThue, @NgayTra = NgayTra FROM inserted
	IF (DATEDIFF( DAY, @NgayTra, @NgayThue) > 10)
	BEGIN
		PRINT 'KHONG DUOC THUE QUA 10 NGAY'
		ROLLBACK TRAN
	END
	ELSE 
	BEGIN
		PRINT 'THAO TAC THANH CONG'
	END
END

-- Cau 2.2 --
CREATE TRIGGER ins_up_SOSACH ON PHIEUTHUE
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @SoSachThue int, @DEM int
	DECLARE @MAPT char(5)
	SELECT @SoSachThue = SoSachThue, @MAPT = MaPT FROM inserted
	SELECT @DEM = COUNT(MaPT) FROM CHITIET_PT WHERE @MAPT = MaPT
	IF (@SoSachThue != @DEM)
	BEGIN 
		PRINT 'THAO TAC KHONG THANH CONG'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT 'THAO TAC THANH CONG'
	END
END

-- Cau 3 --
-- Cau 3.1 --
SELECT DOCGIA.MaDG, HoTen
FROM DOCGIA
JOIN PHIEUTHUE ON DOCGIA.MaDG = PHIEUTHUE.MaDG
JOIN CHITIET_PT ON PHIEUTHUE.MaPT = CHITIET_PT.MaPT
JOIN SACH ON CHITIET_PT.MaSach = SACH.MaSach
WHERE TheLoai = 'Tin hoc' AND YEAR(NgayThue) = 2007

-- Cau 3.2 --
SELECT TOP 1 WITH TIES DOCGIA.MaDG, HoTen
FROM DOCGIA
JOIN PHIEUTHUE ON DOCGIA.MaDG = PHIEUTHUE.MaDG
JOIN CHITIET_PT ON PHIEUTHUE.MaPT = CHITIET_PT.MaPT
JOIN SACH ON SACH.MaSach = CHITIET_PT.MaSach
GROUP BY DOCGIA.MaDG, HoTen
ORDER BY COUNT(DISTINCT TheLoai) DESC

-- Cau 3.3 --
SELECT SACH.TheLoai, SACH.TenSach
FROM SACH
JOIN (
    SELECT TheLoai, MaSach, MAX(CountMaSach) AS MaxCount
    FROM (
        SELECT SACH.TheLoai, CHITIET_PT.MaSach, COUNT(*) AS CountMaSach
        FROM SACH
        JOIN CHITIET_PT ON SACH.MaSach = CHITIET_PT.MaSach
        GROUP BY SACH.TheLoai, CHITIET_PT.MaSach
    ) AS CountTable
    GROUP BY TheLoai, MaSach
) AS MaxCountTable ON SACH.TheLoai = MaxCountTable.TheLoai AND SACH.MaSach = MaxCountTable.MaSach 

	
