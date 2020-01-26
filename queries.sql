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
