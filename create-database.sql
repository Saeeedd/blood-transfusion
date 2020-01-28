use master;
GO

IF DB_ID('BloodTransfusion')>0
BEGIN
	ALTER DATABASE BloodTransfusion SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE BloodTransfusion
END
GO

CREATE DATABASE [BloodTransfusion]
	ON
    PRIMARY
	(
		NAME=BloodTransfusion, FILENAME='C:\Dump\BloodTransfusion.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%
	),
    FILEGROUP FG1
	(
		NAME=BloodTransfusionFG1, FILENAME='C:\Dump\BloodTransfusion_fg1.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%
	)
	LOG ON
	(
		NAME=BloodTransfusionLog, FILENAME='C:\Dump\BloodTransfusion_log.LDF',
		SIZE=1GB,MAXSIZE=5GB,FILEGROWTH=1024MB
	)
GO

ALTER DATABASE BloodTransfusion MODIFY FILEGROUP FG1 DEFAULT
GO

use BloodTransfusion;

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodTransporter' and xtype='U')
CREATE TABLE BloodTransporter (
    nationalId NVARCHAR(10) PRIMARY KEY CHECK (nationalId LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'),
    firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    bloodType NVARCHAR(3) NOT NULL CHECK (bloodType IN(N'O-', N'O+', N'A+', N'A-', N'B+', N'B-', N'AB+', N'AB-')),
    email NVARCHAR(320)
) ON FG1
GO

CREATE INDEX BloodTransporterBloodTypeIndex ON BloodTransporter (bloodType)
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Nurse' and xtype='U')
    CREATE TABLE Nurse (
        employeeId INTEGER PRIMARY KEY IDENTITY,
        firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        hiringDate DATE NOT NULL,
        supervisedBy INTEGER,
        FOREIGN KEY (supervisedBy) REFERENCES Nurse(employeeId), 
    ) ON FG1
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='City' and xtype='U')
    CREATE TABLE City (
        id INTEGER PRIMARY KEY IDENTITY,
        cityName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI UNIQUE NOT NULL
    ) ON FG1
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodBank' and xtype='U')
    CREATE TABLE BloodBank (
        id INTEGER PRIMARY KEY IDENTITY,
        cityId INTEGER NOT NULL,
        bankAddress NVARCHAR(300) COLLATE PERSIAN_100_CI_AI NOT NULL,
        bankName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        FOREIGN KEY (cityId) REFERENCES City(id) ON DELETE CASCADE
    ) ON FG1
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='WorksAt' and xtype='U')
    CREATE TABLE WorksAt (
        employeeId INTEGER,
        bloodBankId INTEGER,
        startTime DATE NOT NULL,
        endTime DATE, 
        PRIMARY KEY (employeeId, bloodBankId),
        FOREIGN KEY (employeeId) REFERENCES Nurse(employeeId) ON DELETE CASCADE,
        FOREIGN KEY (bloodBankId) REFERENCES BloodBank(id) ON DELETE CASCADE,
    ) ON FG1
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
        FOREIGN KEY (donorId) REFERENCES BloodTransporter(nationalId) ON DELETE CASCADE,
    ) ON FG1
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
        FOREIGN KEY (bloodTransporterNationalId) REFERENCES BloodTransporter(nationalId) ON DELETE CASCADE,
        FOREIGN KEY (donationId) REFERENCES Donation(id)
    ) ON FG1
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodProduct' and xtype='U')
    CREATE TABLE BloodProduct (
        productName NVARCHAR(64) NOT NULL,
        volumePerUnit SMALLINT NOT NULL,
        waitingTime INT NOT NULL,
        PRIMARY KEY (productName),
    ) ON FG1

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
        FOREIGN KEY (donationId) REFERENCES Donation(id) ON DELETE CASCADE,
        FOREIGN KEY (signedBy) REFERENCES Nurse(employeeId),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName) ON DELETE CASCADE,
        FOREIGN KEY (locatedAt) REFERENCES BloodBank(id) ON DELETE CASCADE
    ) ON FG1
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
        FOREIGN KEY (cityId) REFERENCES City(id) ON DELETE CASCADE
    ) ON FG1
GO

-- A trigger on Needs to delete and archive the need after amount set to 0
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Need' and xtype='U')
    CREATE TABLE Need (
        id INTEGER IDENTITY NOT NULL,
        neededBy INTEGER NOT NULL,
        units INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL, -- satisfied
        needPriority INTEGER NOT NULL DEFAULT 1 CHECK (needPriority >= 1 AND needPriority <= 3),
        bloodType NVARCHAR(3) NOT NULL CHECK (bloodType IN(N'O-', N'O+', N'A+', N'A-', N'B+', N'B-', N'AB+', N'AB-')), 
        raisedAt DATETIME NOT NULL DEFAULT SYSDATETIME(),
        PRIMARY KEY (id),
        FOREIGN KEY (neededBy) REFERENCES Hospital(id) ON DELETE CASCADE,
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName) ON DELETE CASCADE, 
    ) ON FG1
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='DeliverPacket' and xtype='U')
    CREATE TABLE DeliveredPackets (
        packetId INTEGER NOT NULL,
        destinationHospitalId INTEGER NOT NULL,
        deliveredAt DATETIME NOT NULL,
        PRIMARY KEY (packetId, destinationHospitalId),
        FOREIGN KEY (packetId) REFERENCES BloodPacket(id) ON DELETE CASCADE,
        FOREIGN KEY (destinationHospitalId) REFERENCES Hospital(id)
    ) ON FG1
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PacketTransfer' and xtype='U')
    CREATE TABLE PacketTransfer (
        packetId INTEGER NOT NULL,
        destinationBloodBankId INTEGER NOT NULL,
        transferDate DATETIME NOT NULL,
        PRIMARY KEY (packetId, destinationBloodBankId, transferDate),
        FOREIGN KEY (packetId) REFERENCES BloodPacket(id) ON DELETE CASCADE,
        FOREIGN KEY (destinationBloodBankId) REFERENCES BloodBank(id) ON DELETE NO ACTION
    ) ON FG1
GO

-- TEMP inserted datas
INSERT INTO BloodTransporter (nationalId, firstName, lastName, bloodType)
                VALUES      (N'0021190941', N'سعید', N'زنگنه', N'A+'),
                            (N'0021190942', N'علی', N'توفیقی', N'B+'),
                            (N'0021190943', N'احمدی', N'احمدی', N'AB+'),
                            (N'0021190944', N'محمد', N'محمدی', N'A-'),
                            (N'0021190945', N'کنگر', N'کنگری', N'A+');
GO

-- TEMP inserted datas
INSERT INTO City            (cityName)
                VALUES      (N'شهر۱'),
                            (N'شهر۲'),
                            (N'شهر۳'),
                            (N'شهر۴'),
                            (N'شهر۵')
GO

-- TEMP inserted datas
INSERT INTO BloodBank (bankAddress, bankName, cityId)
                VALUES      (N'آدرس بانک ۱', N'بانک۱', 1),
                            (N'آدرس بانک ۲', N'بانک۲', 1),
                            (N'آدرس بانک ۳', N'بانک۳', 2);
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
                VALUES      (N'پرستار۱', N'پرستار۱', '2015-01-01', NULL),
                            (N'پرستار۲', N'پرستار۲', '2015-02-02', 1),
                            (N'پرستار۳', N'پرستار۳', '2015-01-03', 1),
                            (N'پرستار۴', N'پرستار۴', '2015-01-04', 2),
                            (N'پرستار۵', N'پرستار۵', '2015-01-05', 4);
GO

-- TEMP inserted datas
INSERT INTO Hospital (hospitalName, hospitalAddress, cityId)
                VALUES      (N'بیمارستان۱', N'address1', 1),
                            (N'بیمارستان۲', N'address2', 1),
                            (N'بیمارستان۳', N'address3', 1);
GO

-- TEMP inserted datas
INSERT INTO BloodProduct (productName, volumePerUnit, waitingTime)
                VALUES      (N'پلاسما', 200, 50),
                            (N'خون', 450, 150),
                            (N'پلاکت', 50, 100),
                            (N'گلبول', 100, 200);
GO

-- TEMP inserted datas
INSERT INTO Need (neededBy, units, bloodProduct, needPriority, bloodType)
                VALUES      (1, 1, N'پلاسما', 1, N'A+');
GO

-- TEMP inserted datas
INSERT INTO BloodPacket (donationId, bloodProduct, expirationDate, signedBy, locatedAt)
                VALUES      (1, N'پلاسما', '2015-01-01', 1, 1),
                            (1, N'خون', '2015-02-02', 2, 1),
                            (1, N'خون', '2015-01-03', 3, 1),
                            (1, N'خون', '2015-01-04', 4, 1),
                            (1, N'خون', '2015-01-04', 4, 1),
                            (1, N'پلاکت', '2015-01-04', 4, 1),
                            (2, N'پلاسما', '2015-01-05', 5, 1);
GO