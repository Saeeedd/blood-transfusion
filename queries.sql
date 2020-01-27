use BloodTransfusion;
GO

-- Get the list of donors
DROP PROCEDURE IF EXISTS AddBloodTransporter;
GO

CREATE PROCEDURE AddBloodTransporter
    @nationalId NVARCHAR(10),
    @firstName NVARCHAR(64),
    @lastName NVARCHAR(64),
    @bloodType NVARCHAR(10)
AS 
BEGIN
    SET NOCOUNT ON;
    INSERT INTO BloodTransporter (firstName, lastName, bloodType)
        VALUES (@firstName, @lastName, @bloodType)
END
Go

-- Get all blood tranporters
DROP PROCEDURE IF EXISTS ListBloodTransporters;
GO

CREATE PROCEDURE ListBloodTransporters
AS 
BEGIN
    SELECT * FROM BloodTransporter;
END
GO

EXEC ListBloodTransporters
GO

----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetBloodTransporterById;
GO

-- Get specific blood transporter by id
CREATE PROCEDURE GetBloodTransporterById
    @national_id NVARCHAR(10)
AS 
BEGIN
    SELECT * FROM BloodTransporter WHERE nationalId = @national_id;
    RETURN
END
GO

EXEC GetBloodTransporterById @national_id = N'0021190941'
GO

----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetBloodTransporterByName;
GO

CREATE PROCEDURE GetBloodTransporterByName
    @name NVARCHAR(64)
AS 
BEGIN
    SELECT * FROM BloodTransporter WHERE firstName LIKE '%' + @name + '%' OR lastName LIKE '%' + @name + '%'
    RETURN
END
GO

EXEC GetBloodTransporterByName @name = N'عل'
GO


----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetListOfNeed;
GO

CREATE PROCEDURE GetListOfNeed
AS 
BEGIN
    SELECT * FROM Need
    RETURN
END
GO

EXEC GetListOfNeed
GO

----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS DeliverPacketToHospital;
GO

CREATE PROCEDURE DeliverPacketToHospital
    @packet_id INTEGER,
    @destination_hospital_id INTEGER
AS 
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT * FROM PresentBloodPacket WHERE id = @packet_id)
    BEGIN
        THROW 50001, 'Packet id has been delivered recently', 1
    END
    UPDATE BloodPacket SET isDelivered = 1 WHERE id = @packet_id;
    INSERT INTO DeliveredPackets (packetId, destinationHospitalId) VALUES (@packet_id, @destination_hospital_id);
END
GO

EXEC DeliverPacketToHospital @packet_id = 1, @destination_hospital_id = 1
GO

UPDATE BloodPacket SET isDelivered = 0 WHERE id = 1
GO

DELETE DeliveredPackets WHERE packetId = 1
GO


-- ----------------------------------------------------------------------------
-- DROP PROCEDURE IF EXISTS SatisfyNeed;
-- GO

-- CREATE PROCEDURE SatisfyNeed
--     @needId INTEGER
-- AS 
-- BEGIN
--     SET NOCOUNT ON;
--     EXEC GetClosestToExpirationBloodPacket @blood_typ;
-- END
-- GO

-- EXEC SatisfyNeed @needId = 1
-- GO

-- -- UPDATE BloodPacket SET isDelivered = 0 WHERE id = 1
-- -- GO

-- -- DELETE DeliveredPackets WHERE packetId = 1
-- -- GO
