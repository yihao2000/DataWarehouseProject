DROP DATABASE HospitalIEOLAP
CREATE DATABASE HospitalIEOLAP

USE HospitalIEOLAP

CREATE TABLE MedicineDimension(
	 MedicineCode INT PRIMARY KEY IDENTITY,
	 MedicineID INT,
	 MedicineName VARCHAR(100),
	 MedicineSellingPrice BIGINT,
	 MedicineBuyingPrice BIGINT,
	 MedicineExpiredDate DATE,
	 ValidFrom DATETIME,
	 ValidTo DATETIME

)

CREATE TABLE DoctorDimension(
 	 DoctorCode INT PRIMARY KEY IDENTITY,
	 DoctorID INT,
	 DoctorName VARCHAR(100),
	 DoctorDOB DATE,
	 DoctorSalary BIGINT,
	 DoctorAddress VARCHAR(100),
	 ValidFrom DATETIME,
	 ValidTo DATETIME
)


CREATE TABLE StaffDimension(
	 StaffCode INT PRIMARY KEY IDENTITY,
	 StaffID INT,
	 StaffName VARCHAR(100),
	 StaffDOB DATE,
	 StaffSalary BIGINT,
	 StaffAddress  VARCHAR(100),
	 ValidFrom DATETIME,
	 ValidTo DATETIME
)

CREATE TABLE CustomerDimension(
	 CustomerCode INT PRIMARY KEY IDENTITY,
	 CustomerID INT,
	 CustomerName VARCHAR(100),
	 CustomerAddress VARCHAR(100),
	 CustomerGender VARCHAR(6)
)

CREATE TABLE BenefitDimension(
	 BenefitCode INT PRIMARY KEY IDENTITY,
	 BenefitID INT,
	 BenefitName VARCHAR(100),
	 BenefitPrice BIGINT,
	 ValidFrom DATETIME,
	 ValidTo DATETIME
)

CREATE TABLE TreatmentDimension(
	 TreatmentCode INT PRIMARY KEY IDENTITY,
	 TreatmentID INT,
	 TreatmentName VARCHAR(100),
	 TreamentPrice BIGINT,
	 ValidFrom DATETIME,
	 ValidTo DATETIME
)

CREATE TABLE DistributorDimension(
	 DistributorCode INT PRIMARY KEY IDENTITY,
	 DistributorID INT,
	 DistributorName VARCHAR(100),
	 DistributorAddress VARCHAR(100),
	 CityName VARCHAR(100),
	 DistributorPhone VARCHAR(15)
)


CREATE TABLE TimeDimension(
	 TimeCode INT PRIMARY KEY IDENTITY,
 	 [Date] DATE,
	 [Month] INT,
	 [Quarter] INT,
	 [Year] INT,
)


CREATE TABLE SalesFact(
	 MedicineCode INT,
	 StaffCode INT,
	 CustomerCode INT,
	 TimeCode INT,
	 [Sales Transaction] BIGINT, 
	 [Medicine Sold] BIGINT
)




CREATE TABLE PurchaseFact (
	 MedicineCode INT,
	 StaffCode INT,
	 DistributorCode INT,
	 TimeCode INT,
	 [Purchase Transaction] BIGINT,
	 [Medicine Purchased] BIGINT
)

DROP TABLE PurchaseFact



CREATE TABLE SubscriptionFact(
	 CustomerCode INT,
	 StaffCode INT,
	 BenefitCode INT,
	 TimeCode INT,
	 [Subscription Earning] BIGINT,
	 [Subscriber Total] BIGINT,
)



CREATE TABLE ServiceFact(
	 CustomerCode INT,
	 TreatmentCode INT,
	 DoctorCode INT,
	 TimeCode INT,
	 [Service Earning] BIGINT, 
	 [Number of Doctor] BIGINT,
)



CREATE TABLE FilterTimeStamp(
	TableName VARCHAR(50) PRIMARY KEY,
	LastETL DATETIME
)


-- Command buat kolum tertentu saja
-- MedicineDimension
SELECT MedicineID,
	 MedicineName,
	 MedicineSellingPrice,
	 MedicineBuyingPrice,
	 MedicineExpiredDate
FROM OLTP_HospitalIE..MsMedicine

SELECT * FROM MedicineDimension

-- DoctorDimension
SELECT  
	 DoctorID,
	 DoctorName,
	 DoctorDOB,
	 DoctorSalary, 
	 DoctorAddress

FROM OLTP_HospitalIE..MsDoctor

SELECT * FROM DoctorDimension

-- StaffDimension
SELECT 
	 StaffID,
	 StaffName,
	 StaffDOB,
	 StaffSalary,
	 StaffAddress 

FROM OLTP_HospitalIE..MsStaff

SELECT * FROM StaffDimension

-- CustomerDimension
SELECT 
	 CustomerID,
	 CustomerName,
	 CustomerAddress ,
	 CustomerGender 

FROM OLTP_HospitalIE..MsCustomer

SELECT * FROM CustomerDimension

-- BenefitDimension
SELECT BenefitID,
	 BenefitName,
	 BenefitPrice 

FROM OLTP_HospitalIE..MsBenefit

SELECT * FROM BenefitDimension

-- TreatmentDimension
SELECT TreatmentID,
	 TreatmentName,
	 TreatmentPrice 
FROM OLTP_HospitalIE..MsTreatment

SELECT * FROM TreatmentDimension

-- DistributorDimension
SELECT DistributorID,
	 DistributorName,
	 DistributorAddress ,
	 DistributorPhone ,
	 CityName
FROM OLTP_HospitalIE..MsDistributor md
JOIN OLTP_HospitalIE..MsCity mc ON md.CityID = mc.CityID

SELECT * FROM DistributorDimension

-- TimeDimension

IF EXISTS(
	SELECT *
	FROM HospitalIEOLAP..FilterTimeStamp
	WHERE TableName = 'TimeDimension'
)
BEGIN
	SELECT
		[Date] = x.Date,
		[Month] = MONTH(x.Date),
		[Quarter] = DATEPART(QUARTER, x.Date),
		[Year] = YEAR(x.Date)
	FROM (
		SELECT
		ServiceDate as [Date]
	FROM OLTP_HospitalIE..TrServiceHeader
	UNION
	SELECT
		SubscriptionStartDate as [Date]
	FROM OLTP_HospitalIE..TrSubscriptionHeader
	UNION
	SELECT
		PurchaseDate as [Date]
	FROM OLTP_HospitalIE..TrPurchaseHeader
	UNION
	SELECT
		SalesDate as [Date]
	FROM OLTP_HospitalIE..TrSalesHeader
	)x
	WHERE [Date] > (
		SELECT LastETL
		FROM HospitalIEOLAP..FilterTimeStamp
		WHERE TableName = 'TimeDimension'
	)
END
ELSE
BEGIN
	SELECT
		[Date] = x.Date,
		[Month] = MONTH(x.Date),
		[Quarter] = DATEPART(QUARTER, x.Date),
		[Year] = YEAR(x.Date)
	FROM (
		SELECT
		ServiceDate as [Date]
	FROM OLTP_HospitalIE..TrServiceHeader
	UNION
	SELECT
		SubscriptionStartDate as [Date]
	FROM OLTP_HospitalIE..TrSubscriptionHeader
	UNION
	SELECT
		PurchaseDate as [Date]
	FROM OLTP_HospitalIE..TrPurchaseHeader
	UNION
	SELECT
		SalesDate as [Date]
	FROM OLTP_HospitalIE..TrSalesHeader
	)x
END




IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'TimeDimension'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'TimeDimension'
END

ELSE
BEGIN
	INSERT INTO FilterTimeStamp VALUES ('TimeDimension', GETDATE())
END