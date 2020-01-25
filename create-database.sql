IF NOT EXISTS 
   (
     SELECT name FROM master.dbo.sysdatabases 
     WHERE name = N'BloodTransfusion'
    )
CREATE DATABASE [BloodTransfusion]
GO

use BloodTransfusion;

CREATE TABLE tab_events ( id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
                          event_name STRING NOT NULL,
                          event_day ENUM ('Mon','Tue','Wed','Thu','Fri','Sat','Sun'),
                          status STRING CHECK (status in ('Active','Inactive') )
                         );

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BloodTransporter' and xtype='U')
    CREATE TABLE BloodTransporter (
        id INTEGER PRIMARY KEY,
        firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    )
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Nurse' and xtype='U')
    CREATE TABLE Nurse (
        employeeId INTEGER PRIMARY KEY,
        firstName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
        lastName NVARCHAR(64) COLLATE PERSIAN_100_CI_AI NOT NULL,
    )
GO
