use master;
DROP DATABASE BloodTransfusion;

IF NOT EXISTS 
   (
     SELECT name FROM master.dbo.sysdatabases 
     WHERE name = N'BloodTransfusion'
    )
CREATE DATABASE [BloodTransfusion]
GO

use BloodTransfusion;

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodTransporter' and xtype='U')
CREATE TABLE BloodTransporter (
    id INTEGER PRIMARY KEY,
    firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    bloodType NVARCHAR(10) NOT NULL CHECK (bloodType IN(N'O-', N'O+', N'A+', N'A-', N'B+', N'B-', N'AB+', N'AB-'))
)
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Nurse' and xtype='U')
    CREATE TABLE Nurse (
        employeeId INTEGER PRIMARY KEY,
        firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        hiringDate SMALLDATETIME NOT NULL,        
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='WorksAt' and xtype='U')
    CREATE TABLE BloodBank (
        id INTEGER PRIMARY KEY,
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
        id INTEGER NOT NULL,
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
        id INTEGER NOT NULL,
        donorId INTEGER NOT NULL,
        happendAt INTEGER NOT NULL,
        amount INTEGER NOT NULL,
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
        id INTEGER NOT NULL,
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