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
    id INTEGER IDENTITY PRIMARY KEY,
    firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    bloodType NVARCHAR(10) NOT NULL CHECK (bloodType IN(N'O-', N'O+', N'A+', N'A-', N'B+', N'B-', N'AB+', N'AB-'))
)
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Nurse' and xtype='U')
    CREATE TABLE Nurse (
        employeeId INTEGER PRIMARY KEY IDENTITY,
        firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        hiringDate SMALLDATETIME NOT NULL,        
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodBank' and xtype='U')
    CREATE TABLE BloodBank (
        id INTEGER PRIMARY KEY IDENTITY,
        bankAddress NVARCHAR(200) COLLATE PERSIAN_100_CI_AI NOT NULL,
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
        testTime DATETIME NOT NULL,
        happendAt INTEGER NOT NULL,
        bloodTransporterId INTEGER NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (happendAt) REFERENCES BloodBank(id),
        FOREIGN KEY (bloodTransporterId) REFERENCES BloodTransporter(id),
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Donation' and xtype='U')
    CREATE TABLE Donation (
        id INTEGER NOT NULL IDENTITY,
        donorId INTEGER NOT NULL,
        happendAt INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        donationTime DATETIME NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (happendAt) REFERENCES BloodBank(id),
        FOREIGN KEY (donorId) REFERENCES BloodTransporter(id),
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodProduct' and xtype='U')
    CREATE TABLE BloodProduct (
        productName NVARCHAR(64) NOT NULL,
        PRIMARY KEY (productName),
    )

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodPacket' and xtype='U')
    CREATE TABLE BloodPacket (
        id INTEGER NOT NULL IDENTITY,
        donationId INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL,
        amount  INTEGER NOT NULL CHECK (amount > 0),
        expirationDate SMALLDATETIME NOT NULL,
        signedBy INTEGER NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (donationId) REFERENCES Donation(id),
        FOREIGN KEY (signedBy) REFERENCES Nurse(employeeId),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName),
    )
GO

-- A trigger on Needs to delete and archive the need after amount set to 0
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Need' and xtype='U')
    CREATE TABLE Need (
        neededBy INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        bloodProduct NVARCHAR(64) NOT NULL,
        needPriority INTEGER NOT NULL DEFAULT 1 CHECK (needPriority >= 1 AND needPriority <= 3),
        PRIMARY KEY (neededBy, bloodProduct),
        FOREIGN KEY (neededBy) REFERENCES Donation(id),
        FOREIGN KEY (bloodProduct) REFERENCES BloodProduct(productName), 
    )
GO

-- TEMP inserted datas
INSERT INTO BloodTransporter (firstName, lastName, bloodType)
                VALUES      (N'saeed', N'saeed', N'A+'),
                            (N'ali', N'ali', N'B+'),
                            (N'ahmad', N'ahmad', N'AB+'),
                            (N'asghar', N'asghar', N'A-'),
                            (N'akbar', N'akbar', N'A+');
GO

-- TEMP inserted datas
INSERT INTO BloodBank (bankAddress, bankName)
                VALUES      (N'bank1', N'bank1');
GO

-- TEMP inserted datas
INSERT INTO Donation (donorId, happendAt, amount, donationTime)
                VALUES      (1, 1, 100, '2015-01-01 21:12:35'),
                            (1, 1, 100, '2015-02-02 21:12:35'),
                            (3, 1, 100, '2015-01-03 21:12:35'),
                            (3, 1, 100, '2015-01-04 21:12:35'),
                            (3, 1, 100, '2015-01-05 21:12:35');
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
INSERT INTO BloodProduct (productName)
                VALUES      (N'Plasma');
GO

-- TEMP inserted datas
INSERT INTO BloodPacket (donationId, bloodProduct, amount, expirationDate, signedBy)
                VALUES      (1, N'Plasma', 500, '2015-01-01 21:12:35', 1),
                            (1, N'Plasma', 500, '2015-02-02 21:12:35', 2),
                            (1, N'Plasma', 500, '2015-01-03 21:12:35', 3),
                            (1, N'Plasma', 500, '2015-01-04 21:12:35', 4),
                            (2, N'Plasma', 500, '2015-01-05 21:12:35', 5);
GO