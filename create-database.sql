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
        hiringDate DATE NOT NULL,
        supervisedBy INTEGER,
        FOREIGN KEY (supervisedBy) REFERENCES Nurse(employeeId), 
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='City' and xtype='U')
    CREATE TABLE City (
        id INTEGER PRIMARY KEY IDENTITY,
        cityName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodBank' and xtype='U')
    CREATE TABLE BloodBank (
        id INTEGER PRIMARY KEY IDENTITY,
        cityId INTEGER NOT NULL,
        bankAddress NVARCHAR(300) COLLATE PERSIAN_100_CI_AI NOT NULL,
        bankName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        FOREIGN KEY (cityId) REFERENCES City(id)
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='WorksAt' and xtype='U')
    CREATE TABLE WorksAt (
        employeeId INTEGER,
        bloodBankId INTEGER,
        startTime DATE NOT NULL,
        endTime DATE, 
        PRIMARY KEY (employeeId, bloodBankId),
        FOREIGN KEY (employeeId) REFERENCES Nurse(employeeId),
        FOREIGN KEY (bloodBankId) REFERENCES BloodBank(id),
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Donation' and xtype='U')
    CREATE TABLE Donation (
        id INTEGER NOT NULL IDENTITY,
        donorId NVARCHAR(10) NOT NULL,
        happendAt INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        donationTime DATE NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (happendAt) REFERENCES BloodBank(id),
        FOREIGN KEY (donorId) REFERENCES BloodTransporter(nationalId),
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='HealthReport' and xtype='U')
    CREATE TABLE HealthReport (
        id INTEGER NOT NULL IDENTITY,
        pressure INTEGER NOT NULL CHECK (pressure <= 20 AND pressure >= 3),
        temperature INTEGER NOT NULL CHECK (temperature < 50 AND temperature > 30),
        density INTEGER NOT NULL,
        testDate DATE NOT NULL,
        happendAt INTEGER NOT NULL,
        bloodTransporterNationalId NVARCHAR(10) NOT NULL,
        donationId INTEGER NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (happendAt) REFERENCES BloodBank(id),
        FOREIGN KEY (bloodTransporterNationalId) REFERENCES BloodTransporter(nationalId),
        FOREIGN KEY (donationId) REFERENCES Donation(id)
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodProduct' and xtype='U')
    CREATE TABLE BloodProduct (
        productName NVARCHAR(64) NOT NULL,
        volumePerUnit SMALLINT NOT NULL,
        waitingTime INT NOT NULL,
        PRIMARY KEY (productName),
    )

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodPacket' and xtype='U')
    CREATE TABLE BloodPacket (
        id INTEGER NOT NULL IDENTITY,
        donationId INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL,
        expirationDate DATE NOT NULL,
        signedBy INTEGER NOT NULL,
        locatedAt INTEGER NOT NULL,
        isDelivered BIT DEFAULT 0 NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (donationId) REFERENCES Donation(id),
        FOREIGN KEY (signedBy) REFERENCES Nurse(employeeId),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName),
        FOREIGN KEY (locatedAt) REFERENCES BloodBank(id)
    )
GO

DROP VIEW IF EXISTS PresentBloodPacket
GO

CREATE VIEW PresentBloodPacket AS (
    SELECT * FROM BloodPacket WHERE isDelivered = 0
)
GO

-- TODO:HealthTest Table?
-- HIV Test
-- Cholesterol Test
-- ?


-- Geolocation data for location
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Hospital' and xtype='U')
    CREATE TABLE Hospital (
        id INTEGER IDENTITY,
        hospitalName NVARCHAR(64) NOT NULL,
        cityId INTEGER NOT NULL,
        hospitalAddress NVARCHAR(300)
        PRIMARY KEY (id),
        FOREIGN KEY (cityId) REFERENCES City(id)
    )
GO

-- A trigger on Needs to delete and archive the need after amount set to 0
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Need' and xtype='U')
    CREATE TABLE Need (
        id INTEGER IDENTITY NOT NULL,
        neededBy INTEGER NOT NULL,
        units INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL,
        needPriority INTEGER NOT NULL DEFAULT 1 CHECK (needPriority >= 1 AND needPriority <= 3),
        bloodType NVARCHAR(3) NOT NULL CHECK (bloodType IN(N'O-', N'O+', N'A+', N'A-', N'B+', N'B-', N'AB+', N'AB-')), 
        PRIMARY KEY (id),
        FOREIGN KEY (neededBy) REFERENCES Hospital(id),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName), 
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='DeliverPacket' and xtype='U')
    CREATE TABLE DeliveredPackets (
        packetId INTEGER NOT NULL,
        destinationHospitalId INTEGER NOT NULL,
        PRIMARY KEY (packetId, destinationHospitalId),
        FOREIGN KEY (packetId) REFERENCES BloodPacket(id),
        FOREIGN KEY (destinationHospitalId) REFERENCES Hospital(id)
    )
GO

-- TEMP inserted datas
INSERT INTO BloodTransporter (nationalId, firstName, lastName, bloodType)
                VALUES      (N'0021190941', N'saeed', N'saeed', N'A+'),
                            (N'0021190942', N'علی', N'شسیبسب', N'B+'),
                            (N'0021190943', N'ahmad', N'ahmad', N'AB+'),
                            (N'0021190944', N'asghar', N'asghar', N'A-'),
                            (N'0021190945', N'akbar', N'akbar', N'A+');
GO

-- TEMP inserted datas
INSERT INTO City            (cityName)
                VALUES      (N'city1'),
                            (N'city2'),
                            (N'city3'),
                            (N'city4'),
                            (N'city5')
GO

-- TEMP inserted datas
INSERT INTO BloodBank (bankAddress, bankName, cityId)
                VALUES      (N'bank1', N'bank1', 1),
                            (N'bank2', N'bank1', 1),
                            (N'bank3', N'bank1', 2);
GO

-- TEMP inserted datas
INSERT INTO Donation (donorId, happendAt, amount, donationTime)
                VALUES      (N'0021190941', 1, 100, '2015-01-01'),
                            (N'0021190941', 1, 100, '2015-02-02'),
                            (N'0021190943', 1, 100, '2015-01-03'),
                            (N'0021190943', 1, 100, '2015-01-04'),
                            (N'0021190943', 1, 100, '2015-01-05');
GO

-- TEMP inserted datas
INSERT INTO Nurse (firstName, lastName, hiringDate, supervisedBy)
                VALUES      (N'nurse1', N'nurse1', '2015-01-01', NULL),
                            (N'nurse2', N'nurse2', '2015-02-02', 1),
                            (N'nurse3', N'nurse3', '2015-01-03', 1),
                            (N'nurse4', N'nurse4', '2015-01-04', 2),
                            (N'nurse5', N'nurse5', '2015-01-05', 4);
GO

-- TEMP inserted datas
INSERT INTO Hospital (hospitalName, hospitalAddress, cityId)
                VALUES      (N'Hospital1', N'address1', 1),
                            (N'Hospital2', N'address2', 1),
                            (N'Hospital3', N'address3', 1);
GO

-- TEMP inserted datas
INSERT INTO BloodProduct (productName, volumePerUnit, waitingTime)
                VALUES      (N'Plasma', 200, 50),
                            (N'Blood', 450, 150),
                            (N'Pelacket', 50, 100),
                            (N'Globulin', 100, 200);
GO

-- TEMP inserted datas
INSERT INTO BloodPacket (donationId, bloodProduct, expirationDate, signedBy, locatedAt)
                VALUES      (1, N'Plasma', '2015-01-01', 1, 1),
                            (1, N'Blood', '2015-02-02', 2, 1),
                            (1, N'Blood', '2015-01-03', 3, 1),
                            (1, N'Blood', '2015-01-04', 4, 1),
                            (1, N'Blood', '2015-01-04', 4, 1),
                            (1, N'Pelacket', '2015-01-04', 4, 1),
                            (2, N'Plasma', '2015-01-05', 5, 1);
GO