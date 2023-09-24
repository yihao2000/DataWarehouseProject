-- 1
IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'PurchaseFact'
)
BEGIN
SELECT  MedicineCode,
	 StaffCode,
	 DistributorCode,
	 TimeCode,
	 [Purchase Transaction] = SUM(Quantity * MedicineBuyingPrice),
	 [Medicine Purchased] = SUM(Quantity)

FROM OLTP_HospitalIE..TrPurchaseHeader ph JOIN OLTP_HospitalIE..TrPurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
JOIN MedicineDimension mdim ON mdim.MedicineID = pd.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = ph.StaffID
JOIN DistributorDimension ddim ON ddim.DistributorID = ph.DistributorID
JOIN TimeDimension tdim ON tdim.Date = ph.PurchaseDate
WHERE ph.PurchaseDate > (
	SELECT LastETL
	FROM FilterTimeStamp
	WHERE TableName = 'PurchaseFact'
)
GROUP BY MedicineCode,
	 StaffCode,
	 DistributorCode,
	 TimeCode
END
ELSE
BEGIN
SELECT  MedicineCode,
	 StaffCode,
	 DistributorCode,
	 TimeCode,
	 [Purchase Transaction] = SUM(Quantity * MedicineBuyingPrice),
	 [Medicine Purchased] = SUM(Quantity)

FROM OLTP_HospitalIE..TrPurchaseHeader ph JOIN OLTP_HospitalIE..TrPurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
JOIN MedicineDimension mdim ON mdim.MedicineID = pd.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = ph.StaffID
JOIN DistributorDimension ddim ON ddim.DistributorID = ph.DistributorID
JOIN TimeDimension tdim ON tdim.Date = ph.PurchaseDate
GROUP BY MedicineCode,
	 StaffCode,
	 DistributorCode,
	 TimeCode
END



-- 2
IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'PurchaseFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'PurchaseFact'
END

ELSE
BEGIN
	INSERT INTO FilterTimeStamp VALUES ('PurchaseFact', GETDATE())
END

