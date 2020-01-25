use BloodTransfusion;
GO

-- Get the list of donors
DROP PROCEDURE IF EXISTS GetListOfDonors;
GO

CREATE PROCEDURE GetListOfDonors
AS 
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM BloodTransporter transporters
        WHERE (
            (SELECT COUNT(*) FROM Donation WHERE donorId = transporters.id) > 0
        );
    RETURN
END
Go

EXEC GetListOfDonors;
GO

DROP PROCEDURE IF EXISTS GetTimeOfNextDonation
GO

-- Get the time for next donation
CREATE PROCEDURE GetTimeOfNextDonation
    @blood_transporter_id [INTEGER],
    @date_value DATETIME OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    Declare @last_donation_time INTEGER
    SELECT @last_donation_time = MAX(CONVERT(INTEGER, donationTime)) FROM Donation donation WHERE donation.donorId = @blood_transporter_id;
    SELECT @date_value = CONVERT(DATETIME, @last_donation_time) + CONVERT(DATETIME, 90); 
END
Go 

declare @date DATETIME;
exec GetTimeOfNextDonation 1, @date OUTPUT;
SELECT @date as nextDonationTime;