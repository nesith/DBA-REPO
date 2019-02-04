--Script to create Standerdised Maintenance Jobs which uses OLA (Only DBCC and Index-Stats maintenance) 

DECLARE @job_name           AS sysname
DECLARE @step_name          AS sysname
DECLARE @sub_system         AS varchar(MAX)
DECLARE @command_dbcc       AS varchar(MAX)
DECLARE @command_index      AS varchar(MAX)
DECLARE @schedule_name      AS varchar(MAX)
DECLARE @freq_type          AS INT
DECLARE @active_start_time  AS INT
DECLARE @version            AS NUMERIC(18,10)
DECLARE @enabled            AS INT
DECLARE @category_id        AS INT
DECLARE @freq_interval	    AS INT
DECLARE @freq_recur_factor  AS INT
DECLARE @owner		    AS sysname
DECLARE @description	    AS VARCHAR(MAX)

--Command and Subsytem need to chnage based on SQL server version

SET @version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

IF @version < 10
	BEGIN
        SET @command_dbcc       = 'SQLCMD -E -d master -Q "EXECUTE dbo.DatabaseIntegrityCheck @Databases = ''ALL_DATABASES''" -b'
        SET @command_index      = 'SQLCMD -E -d master -Q "EXECUTE dbo.IndexOptimize @Databases = ''USER_DATABASES'',@FragmentationLow = NULL,@FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',@FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',@FragmentationLevel1 = 5,@FragmentationLevel2 = 30,@UpdateStatistics = ''ALL'',@SortInTempdb = ''Y''" -b'      
        SET @sub_system         = 'CMDEXEC'
	END

IF @version >=11
	BEGIN
        SET @command_dbcc       = 'EXECUTE dbo.DatabaseIntegrityCheck @Databases = ''ALL_DATABASES'',@CheckCommands = ''CHECKDB'''
        SET @command_index      = 'EXECUTE dbo.IndexOptimize
                                            @Databases = ''ALL_DATABASES'',
                                            @FragmentationLow = NULL,
                                            @FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
                                            @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
                                            @FragmentationLevel1 = 5,
                                            @FragmentationLevel2 = 30,
                                            @UpdateStatistics = ''ALL'',
                                            @SortInTempdb = ''Y'''
        SET @sub_system         = 'TSQL'
	END
--setup DBCC Check DB job
SET @job_name           = 'DBA - Database Integrity Check - All Databases'
SET @step_name          = 'Run OLA''s DBCC Command'
SET @schedule_name      = 'Weekly DBCC'
SET @freq_type          = 8
SET @active_start_time  = 230000
SET @enabled            = 0
SET @category_id        = 3
SET @freq_interval      = 1
SET @freq_recur_factor	= 1
SET @owner		= 'sa'
SET @description	= 'This Job does weekly integrity checks on all databases using OLA''s scripts'


--create job
EXECUTE msdb.dbo.sp_add_job
        @job_name = @job_name,
        @category_id = @category_id,
        @enabled = @enabled,
	@owner_login_name = @owner,
	@description = @description
        
EXECUTE msdb.dbo.sp_add_jobstep
        @job_name = @job_name,
        @step_name = @step_name,
        @subsystem = @sub_system,
        @command = @command_dbcc
        
EXECUTE msdb.dbo.sp_add_schedule
        @schedule_name = @schedule_name,
        @freq_type = @freq_type,
	@freq_interval = @freq_interval,
	@freq_recurrence_factor = @freq_recur_factor,
        @active_start_time = @active_start_time

EXECUTE msdb.dbo.sp_attach_schedule
        @job_name = @job_name,
        @schedule_name = @schedule_name

EXECUTE msdb.dbo.sp_add_jobserver
        @job_name = @job_name

-- End of setting up Check DB job

--set up Index maintenance and update stats job
SET @job_name           = 'DBA - Index Optimize - All Databases'
SET @step_name          = 'Run OLA''s Indexoptimize Command'
SET @schedule_name      = 'Daily Index maintenance'
SET @freq_type          = 4
SET @active_start_time  = 010000
SET @enabled            = 0
SET @category_id        = 3
SET @freq_interval	= 1
SET @owner		= 'sa'
SET @description	= 'This Job does daily index maintenance and stats updates using OLA''s scripts'

--create job
EXECUTE msdb.dbo.sp_add_job
        @job_name = @job_name,
        @category_id = @category_id,
        @enabled = @enabled,
	@owner_login_name = @owner,
	@description = @description
        
EXECUTE msdb.dbo.sp_add_jobstep
        @job_name = @job_name,
        @step_name = @step_name,
        @subsystem = @sub_system,
        @command = @command_dbcc
        
EXECUTE msdb.dbo.sp_add_schedule
        @schedule_name = @schedule_name,
        @freq_type = @freq_type,
	@freq_interval = @freq_interval,
        @active_start_time = @active_start_time

EXECUTE msdb.dbo.sp_attach_schedule
        @job_name = @job_name,
        @schedule_name = @schedule_name

EXECUTE msdb.dbo.sp_add_jobserver
        @job_name = @job_name

--End of setting up Index Maintenance and Update Stats
