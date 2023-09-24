-- 1
IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'SalesFact'
	

)
BEGIN
SELECT
	 MedicineCode,
	 StaffCode,
	 CustomerCode,
	 TimeCode,
	 [Sales Transaction] = SUM(Quantity * MedicineSellingPrice),
	 [Medicine Sold] = SUM(Quantity)

FROM OLTP_HospitalIE..TrSalesHeader sh JOIN OLTP_HospitalIE..TrSalesDetail sd ON sh.SalesID = sd.SalesID 
JOIN MedicineDimension mdim ON mdim.MedicineID = sd.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = sh.StaffID
JOIN CustomerDimension cdim ON cdim.CustomerID = sh.CustomerID
JOIN TimeDimension tdim ON tdim.Date = sh.SalesDate

WHERE sh.SalesDate > (
	SELECT LastETL
	FROM FilterTimeStamp
	WHERE TableName = 'SalesFact'
)
GROUP BY 
	 MedicineCode,
	 StaffCode,
	 CustomerCode,
	 TimeCode
END
ELSE
BEGIN
SELECT
	 MedicineCode,
	 StaffCode,
	 CustomerCode,
	 TimeCode,
	 [Sales Transaction] = SUM(Quantity * MedicineSellingPrice),
	 [Medicine Sold] = SUM(Quantity)

FROM OLTP_HospitalIE..TrSalesHeader sh JOIN OLTP_HospitalIE..TrSalesDetail sd ON sh.SalesID = sd.SalesID 
JOIN MedicineDimension mdim ON mdim.MedicineID = sd.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = sh.StaffID
JOIN CustomerDimension cdim ON cdim.CustomerID = sh.CustomerID
JOIN TimeDimension tdim ON tdim.Date = sh.SalesDate

GROUP BY 
	 MedicineCode,
	 StaffCode,
	 CustomerCode,
	 TimeCode
END



-- 2
IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'SalesFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'SalesFact'
END

ELSE
BEGIN
	INSERT INTO FilterTimeStamp VALUES ('SalesFact', GETDATE())
END

