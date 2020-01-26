use master;
GO

IF DB_ID('BloodTransfusion')>0
BEGIN
	ALTER DATABASE BloodTransfusion SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE BloodTransfusion
END
GO

CREATE DATABASE [BloodTransfusion]
GO

use BloodTransfusion;

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodTransporter' and xtype='U')
CREATE TABLE BloodTransporter (
    nationalId NVARCHAR(10) PRIMARY KEY CHECK (nationalId LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'),
    firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    bloodType NVARCHAR(3) NOT NULL CHECK (bloodType IN(N'O-', N'O+', N'A+', N'A-', N'B+', N'B-', N'AB+', N'AB-')),
    email NVARCHAR(320)
)
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Nurse' and xtype='U')
    CREATE TABLE Nurse (
        employeeId INTEGER PRIMARY KEY IDENTITY,
        firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        hiringDate SMALLDATETIME NOT NULL,        
        FOREIGN KEY (reportsTo) REFERENCES Nurse(employeeId), 
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodBank' and xtype='U')
    CREATE TABLE BloodBank (
        id INTEGER PRIMARY KEY IDENTITY,
        -- TODO: city
        bankAddress NVARCHAR(300) COLLATE PERSIAN_100_CI_AI NOT NULL,
        bankName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='WorksAt' and xtype='U')
    CREATE TABLE WorksAt (
        employeeId INTEGER,
        bloodBankId INTEGER,
        startTime SMALLDATETIME NOT NULL,
        endTime SMALLDATETIME, 
        PRIMARY KEY (employeeId, bloodBankId),
        FOREIGN KEY (employeeId) REFERENCES Nurse(employeeId),
        FOREIGN KEY (bloodBankId) REFERENCES BloodBank(id),
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='HealthReport' and xtype='U')
    CREATE TABLE HealthReport (
        id INTEGER NOT NULL IDENTITY,
        pressure INTEGER NOT NULL CHECK (pressure <= 20 AND pressure >= 3),
        temperature INTEGER NOT NULL CHECK (temperature < 50 AND temperature > 30),
        density INTEGER NOT NULL,
        testDate DATETIME NOT NULL,
        happendAt INTEGER NOT NULL,
        bloodTransporterNationalId NVARCHAR(10) NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (happendAt) REFERENCES BloodBank(id),
        FOREIGN KEY (bloodTransporterNationalId) REFERENCES BloodTransporter(nationalId),
        -- TODO:FK to Donation
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Donation' and xtype='U')
    CREATE TABLE Donation (
        id INTEGER NOT NULL IDENTITY,
        donorId NVARCHAR(10) NOT NULL,
        happendAt INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        donationTime DATETIME NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (happendAt) REFERENCES BloodBank(id),
        FOREIGN KEY (donorId) REFERENCES BloodTransporter(nationalId),
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodProduct' and xtype='U')
    CREATE TABLE BloodProduct (
        productName NVARCHAR(64) NOT NULL,
        volumePerUnit SMALLINT NOT NULL,
        -- TODO: waitingTime
        PRIMARY KEY (productName),
    )

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodPacket' and xtype='U')
    CREATE TABLE BloodPacket (
        id INTEGER NOT NULL IDENTITY,
        donationId INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL,
        expirationDate SMALLDATETIME NOT NULL,
        signedBy INTEGER NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (donationId) REFERENCES Donation(id),
        FOREIGN KEY (signedBy) REFERENCES Nurse(employeeId),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName),
    )
GO

-- TODO:HealthTest Table?
-- HIV Test
-- Cholesterol Test
-- ?


-- -- Geolocation data for location
-- IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Hospital' and xtype='U')
--     CREATE TABLE Hospital (
--         id INTEGER IDENTITY,
--         hospitalName INTEGER NOT NULL,
--         hospitalAddress NVARCHAR(300)
--         PRIMARY KEY (id),
--         FOREIGN KEY (neededBy) REFERENCES Donation(id),
--         FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName), 
--     )
-- GO

-- A trigger on Needs to delete and archive the need after amount set to 0
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Need' and xtype='U')
    CREATE TABLE Need (
        neededBy INTEGER NOT NULL,
        units INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL,
        needPriority INTEGER NOT NULL DEFAULT 1 CHECK (needPriority >= 1 AND needPriority <= 3),
        PRIMARY KEY (neededBy, bloodProduct),
        FOREIGN KEY (neededBy) REFERENCES Donation(id),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName), 
    )
GO

-- TEMP inserted datas
INSERT INTO BloodTransporter (nationalId, firstName, lastName, bloodType)
                VALUES      (N'0021190941', N'saeed', N'saeed', N'A+'),
                            (N'0021190942', N'ali', N'ali', N'B+'),
                            (N'0021190943', N'ahmad', N'ahmad', N'AB+'),
                            (N'0021190944', N'asghar', N'asghar', N'A-'),
                            (N'0021190945', N'akbar', N'akbar', N'A+');
GO

-- TEMP inserted datas
INSERT INTO BloodBank (bankAddress, bankName)
                VALUES      (N'bank1', N'bank1');
GO

-- TEMP inserted datas
INSERT INTO Donation (donorId, happendAt, amount, donationTime)
                VALUES      (N'0021190941', 1, 100, '2015-01-01 21:12:35'),
                            (N'0021190941', 1, 100, '2015-02-02 21:12:35'),
                            (N'0021190943', 1, 100, '2015-01-03 21:12:35'),
                            (N'0021190943', 1, 100, '2015-01-04 21:12:35'),
                            (N'0021190943', 1, 100, '2015-01-05 21:12:35');
GO

-- TEMP inserted datas
INSERT INTO Nurse (firstName, lastName, hiringDate)
                VALUES      (N'nurse1', N'nurse1', '2015-01-01 21:12:35'),
                            (N'nurse2', N'nurse2', '2015-02-02 21:12:35'),
                            (N'nurse3', N'nurse3', '2015-01-03 21:12:35'),
                            (N'nurse4', N'nurse4', '2015-01-04 21:12:35'),
                            (N'nurse5', N'nurse5', '2015-01-05 21:12:35');
GO

-- TEMP inserted datas
INSERT INTO BloodProduct (productName, volumePerUnit)
                VALUES      (N'Plasma', 200);
GO

-- TEMP inserted datas
INSERT INTO BloodPacket (donationId, bloodProduct, expirationDate, signedBy)
                VALUES      (1, N'Plasma', '2015-01-01 21:12:35', 1),
                            (1, N'Plasma', '2015-02-02 21:12:35', 2),
                            (1, N'Plasma', '2015-01-03 21:12:35', 3),
                            (1, N'Plasma', '2015-01-04 21:12:35', 4),
                            (2, N'Plasma', '2015-01-05 21:12:35', 5);
GO