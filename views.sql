use BloodTransfusion;

DROP VIEW IF EXISTS PresentBloodPacket
GO

CREATE VIEW PresentBloodPacket AS (
    SELECT * FROM BloodPacket WHERE isDelivered = 0
)
GO
