USE [MiralixGreenbox];
GO
/****** Object:  StoredProcedure [dbo].[OfficeTeamAgentEventsCleanup]    Script Date: 31-01-2018 10:15:47 ******/
GO
SET QUOTED_IDENTIFIER ON;
GO
-- Slet SP'en hvis den findes
IF EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'OfficeTeamAgentEventsCleanup')
          AND type IN ( N'P', N'PC' )
)
    DROP PROCEDURE OfficeTeamAgentEventsCleanup;
GO
-- Opret SP
CREATE PROCEDURE [dbo].[OfficeTeamAgentEventsCleanup]
    @Cleanup BIT = 0,
    @Repport BIT = 0,
    @RepportFromDate DATETIME2(7) = '0001-01-01 00:00:00.0000000'
AS
BEGIN

    IF @Repport = 1
    BEGIN
        PRINT 'SP is in Rapport mode!';

        IF @RepportFromDate = '0001-01-01 00:00:00.0000000'
            PRINT 'Rapporting on all OfficeTeam Agent Events!';
        ELSE
            PRINT 'Rapporting from ' + CAST(@RepportFromDate AS NVARCHAR(24));

        -- Hvis der allerede er en agent events rapport tabel, slet den
        IF OBJECT_ID('dbo.office_team_statistics_agent_event_error_repport', 'U') IS NOT NULL
            DROP TABLE dbo.office_team_statistics_agent_event_error_repport;
        CREATE TABLE [office_team_statistics_agent_event_error_repport]
        (
            [_error_event] NVARCHAR(128) NOT NULL,
            [_created] [DATETIME2](7) NOT NULL,
            [_call_id] [INT] NULL,
            [_quarter_number] [INT] NOT NULL,
            [_global_call_id] [VARCHAR](128) NULL,
            [_sequence_number] [INT] NULL,
            [_event_start] [DATETIME2](7) NOT NULL,
            [_event_stop] [DATETIME2](7) NOT NULL,
            [_agent_id] [INT] NULL,
            [_agent_name] [VARCHAR](257) NULL,
            [_agent_skill] [INT] NULL,
            [_agent_client] [VARCHAR](256) NULL,
            [_agent_company_id] [INT] NULL,
            [_agent_company_name] [VARCHAR](256) NULL,
            [_agent_department_id] [INT] NULL,
            [_agent_department_name] [VARCHAR](256) NULL,
            [_agent_address_id] [INT] NULL,
            [_agent_address_name] [VARCHAR](256) NULL,
            [_queue_call_id] [INT] NULL,
            [_queue_id] [INT] NULL,
            [_queue_name] [VARCHAR](256) NULL,
            [_event_type] [VARCHAR](128) NOT NULL,
            [_transfer_contact_endpoint] [VARCHAR](256) NULL,
            [_transfer_agent_id] [INT] NULL,
            [_transfer_agent_name] [VARCHAR](256) NULL,
            [_call_qualification_id] [INT] NULL,
            [_call_qualification_name] [VARCHAR](256) NULL,
            [_role_id] [INT] NOT NULL,
            [_role_name] [VARCHAR](256) NOT NULL,
            [_private_call_id] [VARCHAR](128) NULL,
            [_tags] [VARCHAR](1024) NULL,
            [_paf_call] [BIT] NOT NULL
        );

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'CallOfferedNotAcceptedCall',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE1
        WHERE OTSAE1._event_type = 'CallOfferedNotAcceptedCall'
              AND _queue_call_id IS NOT NULL
              AND DATEDIFF(   SECOND,
                              OTSAE1._event_start,
                  (
                      SELECT TOP 1
                             OTSAE2._event_start
                      FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE2
                      WHERE OTSAE2._sequence_number = (OTSAE1._sequence_number + 1)
                            AND OTSAE1._queue_call_id = OTSAE2._queue_call_id
                            AND OTSAE2._event_type = 'CallOfferedNotAcceptedCall'
                            AND OTSAE2._event_start > @RepportFromDate
                  )
                          ) < 1
              AND OTSAE1._event_start > @RepportFromDate;

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'CallOfferedAcceptedCall',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
        WHERE EXISTS
        (
            SELECT MAX(id)
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'CallOfferedAcceptedCall'
                  AND _queue_call_id IS NOT NULL
                  AND _event_start > @RepportFromDate
            GROUP BY _queue_call_id
            HAVING COUNT(*) > 1
        )
              AND _event_start > @RepportFromDate;

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'AfterCallWorkTime',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
        WHERE EXISTS
        (
            SELECT MAX(id)
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'AfterCallWorkTime'
                  AND _queue_call_id IS NOT NULL
                  AND _event_start > @RepportFromDate
            GROUP BY _queue_call_id
            HAVING COUNT(*) > 1
        )
              AND _event_start > @RepportFromDate;

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'OfficeTeamCall',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
        WHERE EXISTS
        (
            SELECT MAX(id)
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'OfficeTeamCall'
                  AND _queue_call_id IS NOT NULL
                  AND _event_start > @RepportFromDate
            GROUP BY _queue_call_id
            HAVING COUNT(*) > 1
        )
              AND _event_start > @RepportFromDate;

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'CallQualification',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
        WHERE EXISTS
        (
            SELECT MAX(id)
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'CallQualification'
                  AND _queue_call_id IS NOT NULL
                  AND _event_start > @RepportFromDate
            GROUP BY _queue_call_id
            HAVING COUNT(*) > 1
        )
              AND _event_start > @RepportFromDate;

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'PickedUpCall',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
        WHERE EXISTS
        (
            SELECT MAX(id)
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'PickedUpCall'
                  AND _queue_call_id IS NOT NULL
                  AND _event_start > @RepportFromDate
            GROUP BY _queue_call_id
            HAVING COUNT(*) > 1
        )
              AND _event_start > @RepportFromDate;

        INSERT INTO dbo.[office_team_statistics_agent_event_error_repport]
        (
            [_error_event],
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT 'CallOfferedCallerHangup',
               [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
        WHERE EXISTS
        (
            SELECT MAX(id)
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'CallOfferedCallerHangup'
                  AND _queue_call_id IS NOT NULL
                  AND _event_start > @RepportFromDate
            GROUP BY _queue_call_id
            HAVING COUNT(*) > 1
        )
              AND _event_start > @RepportFromDate;

        DECLARE @NumberOfRapportRowsInserted INT = 0;
        SET @NumberOfRapportRowsInserted =
        (
            SELECT COUNT(*)
            FROM dbo.[office_team_statistics_agent_event_error_repport]
        );
        PRINT 'Number of agent events rapport rows inserted into office_team_statistics_agent_event_error_repport is: '
              + CAST(@NumberOfRapportRowsInserted AS NVARCHAR(10));
        PRINT 'Use a select on office_team_statistics_agent_event_error_repport to get the number of agent events for calls what have error events in them';

    END;

    IF @Cleanup = 1
    BEGIN
        PRINT 'SP is in Cleanup mode!';
        -- Står nogen kald med et forkert sluttidspunkt i user call log tablellen så...
        IF EXISTS
        (
            SELECT *
            FROM [MiralixGreenbox].[dbo].[user_call_log]
            WHERE [_call_ended] = '0001-01-01 00:00:00.0000000'
        )
        BEGIN
            DECLARE @UserCallLogDeleted INT;
            -- Find ud af hvor mange kald der er tale om ift. outputtet
            SET @UserCallLogDeleted =
            (
                SELECT COUNT(*)
                FROM [MiralixGreenbox].[dbo].[user_call_log]
                WHERE [_call_ended] = '0001-01-01 00:00:00.0000000'
            );
            -- Slet disse kald
            DELETE FROM [MiralixGreenbox].[dbo].[user_call_log]
            WHERE [_call_ended] = '0001-01-01 00:00:00.0000000';

            PRINT 'Wrong formated user call logs found: ' + CAST(@UserCallLogDeleted AS NVARCHAR(64))
                  + ' calls deleted from user call log';
        END;

        IF OBJECT_ID('tempdb..#office_team_statistics_agent_event_temp') IS NOT NULL
            DROP TABLE #office_team_statistics_agent_event_temp;

        CREATE TABLE [#office_team_statistics_agent_event_temp]
        (
            [_created] [DATETIME2](7) NOT NULL,
            [_call_id] [INT] NULL,
            [_quarter_number] [INT] NOT NULL,
            [_global_call_id] [VARCHAR](128) NULL,
            [_sequence_number] [INT] NULL,
            [_event_start] [DATETIME2](7) NOT NULL,
            [_event_stop] [DATETIME2](7) NOT NULL,
            [_agent_id] [INT] NULL,
            [_agent_name] [VARCHAR](257) NULL,
            [_agent_skill] [INT] NULL,
            [_agent_client] [VARCHAR](256) NULL,
            [_agent_company_id] [INT] NULL,
            [_agent_company_name] [VARCHAR](256) NULL,
            [_agent_department_id] [INT] NULL,
            [_agent_department_name] [VARCHAR](256) NULL,
            [_agent_address_id] [INT] NULL,
            [_agent_address_name] [VARCHAR](256) NULL,
            [_queue_call_id] [INT] NULL,
            [_queue_id] [INT] NULL,
            [_queue_name] [VARCHAR](256) NULL,
            [_event_type] [VARCHAR](128) NOT NULL,
            [_transfer_contact_endpoint] [VARCHAR](256) NULL,
            [_transfer_agent_id] [INT] NULL,
            [_transfer_agent_name] [VARCHAR](256) NULL,
            [_call_qualification_id] [INT] NULL,
            [_call_qualification_name] [VARCHAR](256) NULL,
            [_role_id] [INT] NOT NULL,
            [_role_name] [VARCHAR](256) NOT NULL,
            [_private_call_id] [VARCHAR](128) NULL,
            [_tags] [VARCHAR](1024) NULL,
            [_paf_call] [BIT] NOT NULL
        );

        -- Hvis der allerede er taget en backup af agent events tabellen, slet den
        IF OBJECT_ID('dbo.office_team_statistics_agent_event_backup', 'U') IS NOT NULL
            DROP TABLE dbo.office_team_statistics_agent_event_backup;

        -- Opret tabel til backup af agent events
        CREATE TABLE [office_team_statistics_agent_event_backup]
        (
            [_created] [DATETIME2](7) NOT NULL,
            [_call_id] [INT] NULL,
            [_quarter_number] [INT] NOT NULL,
            [_global_call_id] [VARCHAR](128) NULL,
            [_sequence_number] [INT] NULL,
            [_event_start] [DATETIME2](7) NOT NULL,
            [_event_stop] [DATETIME2](7) NOT NULL,
            [_agent_id] [INT] NULL,
            [_agent_name] [VARCHAR](257) NULL,
            [_agent_skill] [INT] NULL,
            [_agent_client] [VARCHAR](256) NULL,
            [_agent_company_id] [INT] NULL,
            [_agent_company_name] [VARCHAR](256) NULL,
            [_agent_department_id] [INT] NULL,
            [_agent_department_name] [VARCHAR](256) NULL,
            [_agent_address_id] [INT] NULL,
            [_agent_address_name] [VARCHAR](256) NULL,
            [_queue_call_id] [INT] NULL,
            [_queue_id] [INT] NULL,
            [_queue_name] [VARCHAR](256) NULL,
            [_event_type] [VARCHAR](128) NOT NULL,
            [_transfer_contact_endpoint] [VARCHAR](256) NULL,
            [_transfer_agent_id] [INT] NULL,
            [_transfer_agent_name] [VARCHAR](256) NULL,
            [_call_qualification_id] [INT] NULL,
            [_call_qualification_name] [VARCHAR](256) NULL,
            [_role_id] [INT] NOT NULL,
            [_role_name] [VARCHAR](256) NOT NULL,
            [_private_call_id] [VARCHAR](128) NULL,
            [_tags] [VARCHAR](1024) NULL,
            [_paf_call] [BIT] NOT NULL
        );

        -- Lav backup af agent events
        INSERT INTO dbo.[office_team_statistics_agent_event_backup]
        (
            [_created],
            [_call_id],
            [_quarter_number],
            [_global_call_id],
            [_sequence_number],
            [_event_start],
            [_event_stop],
            [_agent_id],
            [_agent_name],
            [_agent_skill],
            [_agent_client],
            [_agent_company_id],
            [_agent_company_name],
            [_agent_department_id],
            [_agent_department_name],
            [_agent_address_id],
            [_agent_address_name],
            [_queue_call_id],
            [_queue_id],
            [_queue_name],
            [_event_type],
            [_transfer_contact_endpoint],
            [_transfer_agent_id],
            [_transfer_agent_name],
            [_call_qualification_id],
            [_call_qualification_name],
            [_role_id],
            [_role_name],
            [_private_call_id],
            [_tags],
            [_paf_call]
        )
        SELECT [_created],
               [_call_id],
               [_quarter_number],
               [_global_call_id],
               [_sequence_number],
               [_event_start],
               [_event_stop],
               [_agent_id],
               [_agent_name],
               [_agent_skill],
               [_agent_client],
               [_agent_company_id],
               [_agent_company_name],
               [_agent_department_id],
               [_agent_department_name],
               [_agent_address_id],
               [_agent_address_name],
               [_queue_call_id],
               [_queue_id],
               [_queue_name],
               [_event_type],
               [_transfer_contact_endpoint],
               [_transfer_agent_id],
               [_transfer_agent_name],
               [_call_qualification_id],
               [_call_qualification_name],
               [_role_id],
               [_role_name],
               [_private_call_id],
               [_tags],
               [_paf_call]
        FROM MiralixGreenbox.dbo.office_team_statistics_agent_event;

        PRINT 'Backup of agent events completed';

        -- CallOfferedNotAcceptedCall --
        -- NOTE: Finder de kald der ikke blevet accepterede imellem 2 sekevens på under et sek, dvs. de er forkerte da det ikke burde være muligt at afvise kald med så kort mellemrum
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE1
            WHERE OTSAE1._event_type = 'CallOfferedNotAcceptedCall'
                  AND OTSAE1._queue_call_id IS NOT NULL
                  AND DATEDIFF(   SECOND,
                                  OTSAE1._event_start,
                      (
                          SELECT TOP 1
                                 OTSAE2._event_start
                          FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE2
                          WHERE OTSAE2._sequence_number = (OTSAE1._sequence_number + 1)
                                AND OTSAE1._queue_call_id = OTSAE2._queue_call_id
                                AND _event_type = 'CallOfferedNotAcceptedCall'
                      )
                              ) < 1
        )
        BEGIN
            -- Find ud af hvor mange kald der er tale om
            DECLARE @CallOfferedNotAcceptedCallQueueCalls INT;
            SET @CallOfferedNotAcceptedCallQueueCalls =
            (
                SELECT COUNT(*)
                FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE1
                WHERE OTSAE1._event_type = 'CallOfferedNotAcceptedCall'
                      AND OTSAE1._queue_call_id IS NOT NULL
                      AND DATEDIFF(   SECOND,
                                      OTSAE1._event_start,
                          (
                              SELECT TOP 1
                                     OTSAE2._event_start
                              FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE2
                              WHERE OTSAE2._sequence_number = (OTSAE1._sequence_number + 1)
                                    AND OTSAE1._queue_call_id = OTSAE2._queue_call_id
                                    AND _event_type = 'CallOfferedNotAcceptedCall'
                          )
                                  ) < 1
            );

            PRINT 'Errors found in regard to events: CallOfferedAcceptedCall. Number of Queue calls: '
                  + CAST(@CallOfferedNotAcceptedCallQueueCalls AS NVARCHAR(64));
            -- Slet disse kald
            DELETE FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE EXISTS
            (
                SELECT DISTINCT
                       (OTSAE1._queue_call_id)
                FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE1
                WHERE OTSAE1._event_type = 'CallOfferedNotAcceptedCall'
                      AND _queue_call_id IS NOT NULL
                      AND DATEDIFF(   SECOND,
                                      OTSAE1._event_start,
                          (
                              SELECT TOP 1
                                     OTSAE2._event_start
                              FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event] AS OTSAE2
                              WHERE OTSAE2._sequence_number = (OTSAE1._sequence_number + 1)
                                    AND OTSAE1._queue_call_id = OTSAE2._queue_call_id
                                    AND _event_type = 'CallOfferedNotAcceptedCall'
                          )
                                  ) < 1
            );

            PRINT 'Events regarding events: CallOfferedNotAcceptedCall deleted';

        END;

        -- CallOfferedAcceptedCall --
        -- Find ud af om der er flere end et agent event af typen CallOfferedAcceptedCall for et kø kald, hvis der er skal der ryddes op
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE [_event_type] = 'CallOfferedAcceptedCall'
                  AND [_queue_call_id] IS NOT NULL
            GROUP BY [_queue_call_id]
            HAVING COUNT(*) > 1
        )
        BEGIN
            -- Find ud af hvor mange kald der er tale om
            DECLARE @CallOfferedAcceptedCallQueueCalls INT;
            SET @CallOfferedAcceptedCallQueueCalls =
            (
                SELECT COUNT(DISTINCT (_queue_call_id))
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE EXISTS
                (
                    SELECT _queue_call_id
                    FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                    WHERE _event_type = 'CallOfferedAcceptedCall'
                    GROUP BY _queue_call_id
                    HAVING COUNT(*) > 1
                )
            );

            PRINT 'Errors found in regard to events: CallOfferedAcceptedCall. Number of Queue calls: '
                  + CAST(@CallOfferedAcceptedCallQueueCalls AS NVARCHAR(64));
            -- Indsæt et event fra hver kø kald i en tabel ud fra id, det event af en bestemt type inden for et bestemt kø kald med højst id bliver lagt over i denne tabel. 
            INSERT INTO [#office_team_statistics_agent_event_temp]
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE EXISTS
            (
                SELECT MAX(id)
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'CallOfferedAcceptedCall'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events inserted into [#office_team_statistics_agent_event_temp]';
            -- Slet de event der står forkert i agent events tabellen
            DELETE FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'CallOfferedAcceptedCall'
                  AND EXISTS
            (
                SELECT _queue_call_id
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'CallOfferedAcceptedCall'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events regarding events: CallOfferedAcceptedCall deleted';
            -- Indsæt de events vi fandt i første omgange så der nu kun står det korrekte agent events ift. denne event type
            INSERT INTO MiralixGreenbox.dbo.office_team_statistics_agent_event
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM [#office_team_statistics_agent_event_temp];

            PRINT 'Events inserted into [office_team_statistics_agent_event]';
            -- Tøm den midlertidige tabel
            TRUNCATE TABLE [#office_team_statistics_agent_event_temp];

        END;

        -- AfterCallWorkTime --
        -- Find ud af om der er flere end et agent event af typen AfterCallWorkTime for et kø kald, hvis der er skal der ryddes op
        -- NOTE: Se CallOfferedAcceptedCall event type oprydningen ovenfor for nærmer beskrivelse af de enkelte funktioner i denne if
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE [_event_type] = 'AfterCallWorkTime'
                  AND [_queue_call_id] IS NOT NULL
            GROUP BY [_queue_call_id]
            HAVING COUNT(*) > 1
        )
        BEGIN

            DECLARE @AfterCallWorkTimeQueueCalls INT;
            SET @AfterCallWorkTimeQueueCalls =
            (
                SELECT COUNT(DISTINCT (_queue_call_id))
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE EXISTS
                (
                    SELECT _queue_call_id
                    FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                    WHERE _event_type = 'AfterCallWorkTime'
                    GROUP BY _queue_call_id
                    HAVING COUNT(*) > 1
                )
            );

            PRINT 'Errors found in regard to events: AfterCallWorkTime. Number of Queue calls: '
                  + CAST(@AfterCallWorkTimeQueueCalls AS NVARCHAR(64));

            INSERT INTO [#office_team_statistics_agent_event_temp]
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE EXISTS
            (
                SELECT MAX(id)
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'AfterCallWorkTime'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events inserted into [#office_team_statistics_agent_event_temp]';

            DELETE FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'AfterCallWorkTime'
                  AND EXISTS
            (
                SELECT _queue_call_id
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'AfterCallWorkTime'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events regarding events: AfterCallWorkTime deleted';

            INSERT INTO MiralixGreenbox.dbo.office_team_statistics_agent_event
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM [#office_team_statistics_agent_event_temp];

            PRINT 'Events inserted into [office_team_statistics_agent_event]';

            TRUNCATE TABLE [#office_team_statistics_agent_event_temp];

        END;


        -- OfficeTeamCall --
        -- Find ud af om der er flere end et agent event af typen OfficeTeamCall for et kø kald, hvis der er skal der ryddes op
        -- NOTE: Se CallOfferedAcceptedCall event type oprydningen ovenfor for nærmer beskrivelse af de enkelte funktioner i denne if
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE [_event_type] = 'OfficeTeamCall'
                  AND [_queue_call_id] IS NOT NULL
            GROUP BY [_queue_call_id]
            HAVING COUNT(*) > 1
        )
        BEGIN

            DECLARE @OfficeTeamCallQueueCalls INT;
            SET @OfficeTeamCallQueueCalls =
            (
                SELECT COUNT(DISTINCT (_queue_call_id))
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE EXISTS
                (
                    SELECT _queue_call_id
                    FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                    WHERE _event_type = 'OfficeTeamCall'
                    GROUP BY _queue_call_id
                    HAVING COUNT(*) > 1
                )
            );

            PRINT 'Errors found in regard to events: OfficeTeamCall. Number of Queue calls: '
                  + CAST(@OfficeTeamCallQueueCalls AS NVARCHAR(64));

            INSERT INTO [#office_team_statistics_agent_event_temp]
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE EXISTS
            (
                SELECT MAX(id)
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'OfficeTeamCall'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events inserted into [#office_team_statistics_agent_event_temp]';

            DELETE FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'OfficeTeamCall'
                  AND EXISTS
            (
                SELECT _queue_call_id
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'OfficeTeamCall'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events regarding events: OfficeTeamCall deleted';

            INSERT INTO MiralixGreenbox.dbo.office_team_statistics_agent_event
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM [#office_team_statistics_agent_event_temp];

            PRINT 'Events inserted into [office_team_statistics_agent_event]';

            TRUNCATE TABLE [#office_team_statistics_agent_event_temp];

        END;

        -- CallQualification --
        -- Find ud af om der er flere end et agent event af typen CallQualification for et kø kald, hvis der er skal der ryddes op
        -- NOTE: Se CallOfferedAcceptedCall event type oprydningen ovenfor for nærmer beskrivelse af de enkelte funktioner i denne if
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE [_event_type] = 'CallQualification'
                  AND [_queue_call_id] IS NOT NULL
            GROUP BY [_queue_call_id]
            HAVING COUNT(*) > 1
        )
        BEGIN

            DECLARE @CallQualificationQueueCalls INT;
            SET @CallQualificationQueueCalls =
            (
                SELECT COUNT(DISTINCT (_queue_call_id))
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE EXISTS
                (
                    SELECT _queue_call_id
                    FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                    WHERE _event_type = 'CallQualification'
                    GROUP BY _queue_call_id
                    HAVING COUNT(*) > 1
                )
            );

            PRINT 'Errors found in regard to events: CallQualification. Number of Queue calls: '
                  + CAST(@CallQualificationQueueCalls AS NVARCHAR(64));

            INSERT INTO [#office_team_statistics_agent_event_temp]
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE EXISTS
            (
                SELECT MAX(id)
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'CallQualification'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events inserted into [#office_team_statistics_agent_event_temp]';

            DELETE FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'CallQualification'
                  AND EXISTS
            (
                SELECT _queue_call_id
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'CallQualification'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events regarding events: CallQualification deleted';

            INSERT INTO MiralixGreenbox.dbo.office_team_statistics_agent_event
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM [#office_team_statistics_agent_event_temp];

            PRINT 'Events inserted into [office_team_statistics_agent_event]';

            TRUNCATE TABLE [#office_team_statistics_agent_event_temp];

        END;

        -- PickedUpCall --
        -- Find ud af om der er flere end et agent event af typen PickedUpCall for et kø kald, hvis der er skal der ryddes op
        -- NOTE: Se CallOfferedAcceptedCall event type oprydningen ovenfor for nærmer beskrivelse af de enkelte funktioner i denne if
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE [_event_type] = 'PickedUpCall'
                  AND [_queue_call_id] IS NOT NULL
            GROUP BY [_queue_call_id]
            HAVING COUNT(*) > 1
        )
        BEGIN

            DECLARE @PickedUpCallQueueCalls INT;
            SET @PickedUpCallQueueCalls =
            (
                SELECT COUNT(DISTINCT (_queue_call_id))
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE EXISTS
                (
                    SELECT _queue_call_id
                    FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                    WHERE _event_type = 'PickedUpCall'
                    GROUP BY _queue_call_id
                    HAVING COUNT(*) > 1
                )
            );

            PRINT 'Errors found in regard to events: PickedUpCall. Number of Queue calls: '
                  + CAST(@PickedUpCallQueueCalls AS NVARCHAR(64));

            INSERT INTO [#office_team_statistics_agent_event_temp]
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE EXISTS
            (
                SELECT MAX(id)
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'PickedUpCall'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events inserted into [#office_team_statistics_agent_event_temp]';

            DELETE FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'PickedUpCall'
                  AND EXISTS
            (
                SELECT _queue_call_id
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'PickedUpCall'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events regarding events: PickedUpCall deleted';

            INSERT INTO MiralixGreenbox.dbo.office_team_statistics_agent_event
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM [#office_team_statistics_agent_event_temp];

            PRINT 'Events inserted into [office_team_statistics_agent_event]';

            TRUNCATE TABLE [#office_team_statistics_agent_event_temp];

        END;


        -- CallOfferedCallerHangup --
        -- Find ud af om der er flere end et agent event af typen CallOfferedCallerHangup for et kø kald, hvis der er skal der ryddes op
        -- NOTE: Se CallOfferedAcceptedCall event type oprydningen ovenfor for nærmer beskrivelse af de enkelte funktioner i denne if
        IF EXISTS
        (
            SELECT COUNT(*)
            FROM [MiralixGreenbox].[dbo].[office_team_statistics_agent_event]
            WHERE [_event_type] = 'CallOfferedCallerHangup'
                  AND [_queue_call_id] IS NOT NULL
            GROUP BY [_queue_call_id]
            HAVING COUNT(*) > 1
        )
        BEGIN

            DECLARE @CallOfferedCallerHangupQueueCalls INT;
            SET @CallOfferedCallerHangupQueueCalls =
            (
                SELECT COUNT(DISTINCT (_queue_call_id))
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE EXISTS
                (
                    SELECT _queue_call_id
                    FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                    WHERE _event_type = 'CallOfferedCallerHangup'
                    GROUP BY _queue_call_id
                    HAVING COUNT(*) > 1
                )
            );

            PRINT 'Errors found in regard to events: CallOfferedCallerHangup. Number of Queue calls: '
                  + CAST(@CallOfferedCallerHangupQueueCalls AS NVARCHAR(64));

            INSERT INTO [#office_team_statistics_agent_event_temp]
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE EXISTS
            (
                SELECT MAX(id)
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'CallOfferedCallerHangup'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events inserted into [#office_team_statistics_agent_event_temp]';

            DELETE FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
            WHERE _event_type = 'CallOfferedCallerHangup'
                  AND EXISTS
            (
                SELECT _queue_call_id
                FROM MiralixGreenbox.dbo.office_team_statistics_agent_event
                WHERE _event_type = 'CallOfferedCallerHangup'
                      AND _queue_call_id IS NOT NULL
                GROUP BY _queue_call_id
                HAVING COUNT(*) > 1
            );

            PRINT 'Events regarding events: CallOfferedCallerHangup deleted';

            INSERT INTO MiralixGreenbox.dbo.office_team_statistics_agent_event
            (
                [_created],
                [_call_id],
                [_quarter_number],
                [_global_call_id],
                [_sequence_number],
                [_event_start],
                [_event_stop],
                [_agent_id],
                [_agent_name],
                [_agent_skill],
                [_agent_client],
                [_agent_company_id],
                [_agent_company_name],
                [_agent_department_id],
                [_agent_department_name],
                [_agent_address_id],
                [_agent_address_name],
                [_queue_call_id],
                [_queue_id],
                [_queue_name],
                [_event_type],
                [_transfer_contact_endpoint],
                [_transfer_agent_id],
                [_transfer_agent_name],
                [_call_qualification_id],
                [_call_qualification_name],
                [_role_id],
                [_role_name],
                [_private_call_id],
                [_tags],
                [_paf_call]
            )
            SELECT [_created],
                   [_call_id],
                   [_quarter_number],
                   [_global_call_id],
                   [_sequence_number],
                   [_event_start],
                   [_event_stop],
                   [_agent_id],
                   [_agent_name],
                   [_agent_skill],
                   [_agent_client],
                   [_agent_company_id],
                   [_agent_company_name],
                   [_agent_department_id],
                   [_agent_department_name],
                   [_agent_address_id],
                   [_agent_address_name],
                   [_queue_call_id],
                   [_queue_id],
                   [_queue_name],
                   [_event_type],
                   [_transfer_contact_endpoint],
                   [_transfer_agent_id],
                   [_transfer_agent_name],
                   [_call_qualification_id],
                   [_call_qualification_name],
                   [_role_id],
                   [_role_name],
                   [_private_call_id],
                   [_tags],
                   [_paf_call]
            FROM [#office_team_statistics_agent_event_temp];

            PRINT 'Events inserted into [office_team_statistics_agent_event]';

            TRUNCATE TABLE [#office_team_statistics_agent_event_temp];

        END;
    END;

END;