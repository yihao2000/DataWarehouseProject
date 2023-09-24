-- 1

IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'ServiceFact'

)
BEGIN
SELECT
	 CustomerCode,
	 TreatmentCode,
	 DoctorCode,
	 TimeCode,
	 [Service Earning] = SUM(Quantity * TreamentPrice),
	 [Number of Doctor] = COUNT(sh.DoctorID)

FROM OLTP_HospitalIE..TrServiceHeader sh JOIN OLTP_HospitalIE..TrServiceDetail sd ON sh.ServiceID = sd.ServiceID
JOIN CustomerDimension cdim ON cdim.CustomerID = sh.CustomerID
JOIN TreatmentDimension tdim ON tdim.TreatmentID = sd.TreatmentID
JOIN DoctorDimension ddim ON ddim.DoctorID = sh.DoctorID
JOIN TimeDimension timedim ON timedim.Date = sh.ServiceDate
WHERE sh.ServiceDate > (
	SELECT LastETL
	FROM FilterTimeStamp
	WHERE TableName = 'ServiceFact'
)
GROUP BY  CustomerCode,
	 TreatmentCode,
	 DoctorCode,
	 TimeCode
END
ELSE
BEGIN
SELECT
	 CustomerCode,
	 TreatmentCode,
	 DoctorCode,
	 TimeCode,
	 [Service Earning] = SUM(Quantity * TreamentPrice),
	 [Number of Doctor] = COUNT(sh.DoctorID)

FROM OLTP_HospitalIE..TrServiceHeader sh JOIN OLTP_HospitalIE..TrServiceDetail sd ON sh.ServiceID = sd.ServiceID
JOIN CustomerDimension cdim ON cdim.CustomerID = sh.CustomerID
JOIN TreatmentDimension tdim ON tdim.TreatmentID = sd.TreatmentID
JOIN DoctorDimension ddim ON ddim.DoctorID = sh.DoctorID
JOIN TimeDimension timedim ON timedim.Date = sh.ServiceDate
GROUP BY  CustomerCode,
	 TreatmentCode,
	 DoctorCode,
	 TimeCode
END


-- 2
IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'ServiceFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'ServiceFact'
END

ELSE
BEGIN
	INSERT INTO FilterTimeStamp VALUES ('ServiceFact', GETDATE())
END


