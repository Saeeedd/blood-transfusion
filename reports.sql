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
exec GetTimeOfNextDonation @blood_transporter_id = N'0021190941', @blood_product_name = N'پلاسما', @date_value = @date OUTPUT;
SELECT @date as nextDonationTime
GO

DROP FUNCTION IF EXISTS GetBloodPacketsAccordingTypeAndProductAndCity
GO

-- Get closest to expiration blood packet for next donation
CREATE FUNCTION GetBloodPacketsAccordingTypeAndProductAndCity (
    @blood_type NVARCHAR(64),
    @blood_product NVARCHAR(64),
    @city_name_of_requester NVARCHAR(64)
) RETURNS TABLE
AS 
RETURN 
(
    SELECT blood_packet.*
    FROM    BloodPacket blood_packet, 
            Donation donation, 
            BloodTransporter blood_transporter, 
            BloodBank blood_bank, 
            City city
    WHERE 
    (
        blood_packet.donationId = donation.id AND 
        donation.donorId = blood_transporter.nationalId AND
        blood_transporter.bloodType = @blood_type AND
        blood_packet.bloodProduct = @blood_product AND
        blood_packet.locatedAt = blood_bank.cityId AND
        blood_bank.cityId = city.id AND
        city.cityName = @city_name_of_requester
    )
)
Go 

SELECT * FROM GetBloodPacketsAccordingTypeAndProductAndCity(N'A+', N'پلاسما', N'شهر۱');
GO

DROP PROCEDURE IF EXISTS OrderNecessaryBloodProductsInCity;
GO

-- Get most necessary blood type according to city
CREATE PROCEDURE OrderNecessaryBloodProductsInCity
    @blood_type NVARCHAR(3),
    @city_name_of_requester NVARCHAR(64)
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT blood_product.*, (
        (
            SELECT COALESCE(SUM(need.needPriority), 0) FROM Need need, Hospital hospital, City city
            WHERE
            (
                need.neededBy = hospital.id AND
                hospital.cityId = city.id AND
                city.cityName = @city_name_of_requester AND
                need.bloodProduct = blood_product.productName AND
                need.bloodType = @blood_type
            )
        )
        - 
        (
            SELECT COUNT(*) FROM    PresentBloodPacket blood_packet, 
                                    Donation donation, 
                                    BloodTransporter blood_transporter, 
                                    BloodBank blood_bank,
                                    City city
            WHERE 
            (
                blood_packet.donationId = donation.id AND
                blood_packet.bloodProduct = blood_product.productName AND
                donation.donorId = blood_transporter.nationalId AND
                blood_transporter.bloodType = @blood_type AND
                blood_packet.locatedAt = blood_bank.id AND
                blood_bank.cityId = city.id AND
                city.cityName = @city_name_of_requester
            )
        )
    ) AS bloodProductNeed FROM BloodProduct blood_product ORDER BY bloodProductNeed DESC

END
Go 

exec OrderNecessaryBloodProductsInCity @city_name_of_requester = N'شهر۱', @blood_type = N'A+';

DROP PROCEDURE IF EXISTS OrderNecessaryBloodProducts;
GO

-- Get most necessary blood types in all cities
CREATE PROCEDURE OrderNecessaryBloodProducts
    @blood_type NVARCHAR(3)
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT blood_product.*, (
        (
            SELECT COALESCE(SUM(need.needPriority), 0) FROM Need need
            WHERE
            (
                need.bloodProduct = blood_product.productName AND
                need.bloodType = @blood_type
            )
        )
        - 
        (
            SELECT COUNT(*) FROM    PresentBloodPacket blood_packet, 
                                    Donation donation, 
                                    BloodTransporter blood_transporter
            WHERE 
            (
                blood_packet.donationId = donation.id AND
                blood_packet.bloodProduct = blood_product.productName AND
                donation.donorId = blood_transporter.nationalId AND
                blood_transporter.bloodType = @blood_type 
            )
        )
    ) AS bloodProductNeed FROM BloodProduct blood_product ORDER BY bloodProductNeed DESC

END
Go 

exec OrderNecessaryBloodProducts @blood_type = N'A+'
GO


DROP PROCEDURE IF EXISTS GiveNursesLevels;
GO

CREATE PROCEDURE GiveNursesLevels
    @root_nurse_id INTEGER
AS
BEGIN
    WITH CTE_NumOfBloodPacketSignedByInferiors AS
    (
        SELECT employeeId, 1 AS nurseLevel FROM Nurse WHERE employeeId = @root_nurse_id

        UNION ALL
        SELECT
            nurse.employeeId, CTE_NumOfBloodPacketSignedByInferiors.nurseLevel + 1
            FROM Nurse Nurse
            INNER JOIN CTE_NumOfBloodPacketSignedByInferiors
            ON nurse.supervisedBy = CTE_NumOfBloodPacketSignedByInferiors.employeeId
    )
    SELECT * FROM CTE_NumOfBloodPacketSignedByInferiors
END
GO

EXEC GiveNursesLevels @root_nurse_id = 1
GO
