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
            (SELECT COUNT(*) FROM Donation WHERE donorId = transporters.nationalId) > 0
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
    @blood_transporter_id NVARCHAR(10),
    @blood_product_name NVARCHAR(64),
    @date_value DATE OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    Declare @last_donation_time DATE
    Declare @waiting_time INT
    SELECT @last_donation_time = MAX(donationTime) FROM Donation donation WHERE donation.donorId = @blood_transporter_id;
    SELECT @waiting_time = waitingTime FROM BloodProduct WHERE productName = @blood_product_name;
    SELECT @date_value = DATEADD(day, @waiting_time, @last_donation_time)
END
Go 

declare @date DATE;
exec GetTimeOfNextDonation @blood_transporter_id = N'0021190941', @blood_product_name = N'Plasma', @date_value = @date OUTPUT;
SELECT @date as nextDonationTime
GO

DROP PROCEDURE IF EXISTS GetClosestToExpirationBloodPacket
GO

-- Get closest to expiration blood packet for next donation
CREATE PROCEDURE GetClosestToExpirationBloodPacket
    @blood_type NVARCHAR(64),
    @blood_product NVARCHAR(64),
    @num_of_results INTEGER,
    @city_id_of_requester INTEGER
AS 
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@num_of_results) blood_packet.*
    FROM BloodPacket blood_packet, Donation donation, BloodTransporter blood_transporter, BloodBank blood_bank
    WHERE (
        blood_packet.donationId = donation.id AND 
        donation.donorId = blood_transporter.nationalId AND
        blood_transporter.bloodType = @blood_type AND
        blood_packet.bloodProduct = @blood_product AND
        blood_packet.locatedAt = blood_bank.cityId AND
        blood_bank.cityId = @city_id_of_requester
    ) ORDER BY blood_packet.expirationDate ASC
END
Go 

exec GetClosestToExpirationBloodPacket @blood_type = N'A+', @blood_product = N'Plasma', @num_of_results = 1, @city_id_of_requester = 1;
GO

DROP PROCEDURE IF EXISTS OrderNecessaryBloodProducts;
GO

-- Get most necessary blood type to expiration blood packet for next donation
CREATE PROCEDURE OrderNecessaryBloodProducts
    @city_id INTEGER,
    @blood_type NVARCHAR(3)
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT blood_product.*, (
        (
            SELECT COALESCE(SUM(need.needPriority), 0) FROM Need need, Hospital Hospital
            WHERE
            (
                hospital.cityId = @city_id AND
                need.bloodProduct = blood_product.productName AND
                need.bloodType = @blood_type
            )
        )
        - 
        (
            SELECT COUNT(*) FROM BloodPacket blood_packet, Donation donation, BloodTransporter blood_transporter, BloodBank blood_bank
            WHERE 
            (
                blood_packet.donationId = donation.id AND
                blood_packet.bloodProduct = blood_product.productName AND
                donation.donorId = blood_transporter.nationalId AND
                blood_transporter.bloodType = @blood_type AND
                blood_packet.locatedAt = blood_bank.id AND
                blood_bank.cityId = @city_id
            )
        )
    ) AS bloodProductNeed FROM BloodProduct blood_product ORDER BY bloodProductNeed DESC

END
Go 

exec OrderNecessaryBloodProducts @city_id = 1, @blood_type = N'A+';
