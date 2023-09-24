-- 1
IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'SubscriptionFact'
)
BEGIN
SELECT  CustomerCode,
	 StaffCode,
	 BenefitCode,
	 TimeCode,
	 [Subscription Earning] = SUM(BenefitPrice),
	 [Subscriber Total] = COUNT(sd.SubscriptionID)

FROM OLTP_HospitalIE..TrSubscriptionHeader sh JOIN OLTP_HospitalIE..TrSubscriptionDetail sd ON sh.SubscriptionID = sd.SubscriptionID
JOIN CustomerDimension cdim ON cdim.CustomerID = sh.CustomerID
JOIN StaffDimension sdim ON sdim.StaffID = sh.StaffID
JOIN BenefitDimension bdim ON bdim.BenefitID = sd.BenefitID
JOIN TimeDimension tdim ON tdim.Date = sh.SubscriptionStartDate
WHERE sh.SubscriptionStartDate > (
	SELECT LastETL
	FROM FilterTimeStamp
	WHERE TableName = 'SubscriptionFact'
)
GROUP BY CustomerCode,
	 StaffCode,
	 BenefitCode,
	 TimeCode
END
ELSE
BEGIN
SELECT  CustomerCode,
	 StaffCode,
	 BenefitCode,
	 TimeCode,
	 [Subscription Earning] = SUM(BenefitPrice),
	 [Subscriber Total] = COUNT(sh.SubscriptionID)

FROM OLTP_HospitalIE..TrSubscriptionHeader sh JOIN OLTP_HospitalIE..TrSubscriptionDetail sd ON sh.SubscriptionID = sd.SubscriptionID
JOIN CustomerDimension cdim ON cdim.CustomerID = sh.CustomerID
JOIN StaffDimension sdim ON sdim.StaffID = sh.StaffID
JOIN BenefitDimension bdim ON bdim.BenefitID = sd.BenefitID
JOIN TimeDimension tdim ON tdim.Date = sh.SubscriptionStartDate
GROUP BY CustomerCode,
	 StaffCode,
	 BenefitCode,
	 TimeCode
END


-- 2
IF EXISTS(
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'SubscriptionFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'SubscriptionFact'
END

ELSE
BEGIN
	INSERT INTO FilterTimeStamp VALUES ('SubscriptionFact', GETDATE())
END


