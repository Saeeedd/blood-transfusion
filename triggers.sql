use BloodTransfusion;
GO

DROP TRIGGER IF EXISTS LogThePacketTransfersBetweenBloodBanks
GO

DELETE FROM PacketTransfer
GO

CREATE TRIGGER LogThePacketTransfersBetweenBloodBanks 
    ON BloodPacket
    AFTER UPDATE
AS
BEGIN
    PRINT SYSDATETIME()
    INSERT INTO PacketTransfer VALUES (
            (SELECT TOP 1 inserted.id FROM inserted), 
            (SELECT TOP 1 inserted.locatedAt FROM inserted), 
            (SYSDATETIME())
    )
END
GO

UPDATE BloodPacket SET locatedAt = 2 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 1 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 2 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 1 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 2 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 1 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 2 WHERE id = 1
GO

UPDATE BloodPacket SET locatedAt = 1 WHERE id = 1
GO

SELECT * FROM PacketTransfer ORDER BY transferDate
GO