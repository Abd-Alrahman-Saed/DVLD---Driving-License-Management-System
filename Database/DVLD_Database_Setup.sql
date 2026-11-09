-- =====================================================================
-- DVLD (Driving & Vehicle License Department) Management System
-- Database Creation & Setup Script
-- DBMS: Microsoft SQL Server (2014 or later)
-- =====================================================================

USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DVLD')
BEGIN
    CREATE DATABASE [DVLD];
END
GO

USE [DVLD];
GO

-- =====================================================================
-- 1. Table: Countries
-- =====================================================================
IF OBJECT_ID(N'dbo.Countries', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Countries (
        CountryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CountryName NVARCHAR(50) NOT NULL
    );
END
GO

-- =====================================================================
-- 2. Table: People
-- =====================================================================
IF OBJECT_ID(N'dbo.People', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.People (
        PersonID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        NationalNo NVARCHAR(20) NOT NULL UNIQUE,
        FirstName NVARCHAR(20) NOT NULL,
        SecondName NVARCHAR(20) NOT NULL,
        ThirdName NVARCHAR(20) NULL,
        LastName NVARCHAR(20) NOT NULL,
        DateOfBirth DATETIME NOT NULL,
        Gendor TINYINT NOT NULL, -- 0: Male, 1: Female
        Address NVARCHAR(500) NOT NULL,
        Phone NVARCHAR(20) NOT NULL,
        Email NVARCHAR(50) NULL,
        NationalityCountryID INT NOT NULL,
        ImagePath NVARCHAR(250) NULL,
        CONSTRAINT FK_People_Countries FOREIGN KEY (NationalityCountryID)
            REFERENCES dbo.Countries(CountryID)
    );
END
GO

-- =====================================================================
-- 3. Table: Users
-- =====================================================================
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        UserID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PersonID INT NOT NULL UNIQUE,
        UserName NVARCHAR(50) NOT NULL UNIQUE,
        Password NVARCHAR(64) NOT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsAdmin BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_Users_People FOREIGN KEY (PersonID)
            REFERENCES dbo.People(PersonID)
    );
END
GO

-- =====================================================================
-- 4. Table: ApplicationTypes
-- =====================================================================
IF OBJECT_ID(N'dbo.ApplicationTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ApplicationTypes (
        ApplicationTypeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationTypeTitle NVARCHAR(150) NOT NULL,
        ApplicationFees SMALLMONEY NOT NULL DEFAULT 0
    );
END
GO

-- =====================================================================
-- 5. Table: Applications
-- =====================================================================
IF OBJECT_ID(N'dbo.Applications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Applications (
        ApplicationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicantPersonID INT NOT NULL,
        ApplicationDate DATETIME NOT NULL DEFAULT GETDATE(),
        ApplicationTypeID INT NOT NULL,
        ApplicationStatus TINYINT NOT NULL DEFAULT 1, -- 1: New, 2: Cancelled, 3: Completed
        LastStatusDate DATETIME NOT NULL DEFAULT GETDATE(),
        PaidFees SMALLMONEY NOT NULL DEFAULT 0,
        CreatedByUserID INT NOT NULL,
        CONSTRAINT FK_Applications_People FOREIGN KEY (ApplicantPersonID)
            REFERENCES dbo.People(PersonID),
        CONSTRAINT FK_Applications_ApplicationTypes FOREIGN KEY (ApplicationTypeID)
            REFERENCES dbo.ApplicationTypes(ApplicationTypeID),
        CONSTRAINT FK_Applications_Users FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID)
    );
END
GO

-- =====================================================================
-- 6. Table: LicenseClasses
-- =====================================================================
IF OBJECT_ID(N'dbo.LicenseClasses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LicenseClasses (
        LicenseClassID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ClassName NVARCHAR(50) NOT NULL,
        ClassDescription NVARCHAR(500) NOT NULL,
        MinimumAllowedAge TINYINT NOT NULL DEFAULT 18,
        DefaultValidityLength TINYINT NOT NULL DEFAULT 10,
        ClassFees SMALLMONEY NOT NULL DEFAULT 0
    );
END
GO

-- =====================================================================
-- 7. Table: LocalDrivingLicenseApplications
-- =====================================================================
IF OBJECT_ID(N'dbo.LocalDrivingLicenseApplications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LocalDrivingLicenseApplications (
        LocalDrivingLicenseApplicationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationID INT NOT NULL UNIQUE,
        LicenseClassID INT NOT NULL,
        CONSTRAINT FK_LocalDrivingLicenseApplications_Applications FOREIGN KEY (ApplicationID)
            REFERENCES dbo.Applications(ApplicationID) ON DELETE CASCADE,
        CONSTRAINT FK_LocalDrivingLicenseApplications_LicenseClasses FOREIGN KEY (LicenseClassID)
            REFERENCES dbo.LicenseClasses(LicenseClassID)
    );
END
GO

-- =====================================================================
-- 8. Table: TestTypes
-- =====================================================================
IF OBJECT_ID(N'dbo.TestTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TestTypes (
        TestTypeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        TestTypeTitle NVARCHAR(100) NOT NULL,
        TestTypeDescription NVARCHAR(500) NOT NULL,
        TestTypeFees SMALLMONEY NOT NULL DEFAULT 0
    );
END
GO

-- =====================================================================
-- 9. Table: TestAppointments
-- =====================================================================
IF OBJECT_ID(N'dbo.TestAppointments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TestAppointments (
        TestAppointmentID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        TestTypeID INT NOT NULL,
        LocalDrivingLicenseApplicationID INT NOT NULL,
        AppointmentDate DATETIME NOT NULL,
        PaidFees SMALLMONEY NOT NULL DEFAULT 0,
        CreatedByUserID INT NOT NULL,
        IsLocked BIT NOT NULL DEFAULT 0,
        RetakeTestApplicationID INT NULL,
        CONSTRAINT FK_TestAppointments_TestTypes FOREIGN KEY (TestTypeID)
            REFERENCES dbo.TestTypes(TestTypeID),
        CONSTRAINT FK_TestAppointments_LocalDrivingLicenseApplications FOREIGN KEY (LocalDrivingLicenseApplicationID)
            REFERENCES dbo.LocalDrivingLicenseApplications(LocalDrivingLicenseApplicationID),
        CONSTRAINT FK_TestAppointments_Users FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_TestAppointments_RetakeApplication FOREIGN KEY (RetakeTestApplicationID)
            REFERENCES dbo.Applications(ApplicationID)
    );
END
GO

-- =====================================================================
-- 10. Table: Tests
-- =====================================================================
IF OBJECT_ID(N'dbo.Tests', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tests (
        TestID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        TestAppointmentID INT NOT NULL UNIQUE,
        TestResult BIT NOT NULL, -- 0: Fail, 1: Pass
        Notes NVARCHAR(500) NULL,
        CreatedByUserID INT NOT NULL,
        CONSTRAINT FK_Tests_TestAppointments FOREIGN KEY (TestAppointmentID)
            REFERENCES dbo.TestAppointments(TestAppointmentID),
        CONSTRAINT FK_Tests_Users FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID)
    );
END
GO

-- =====================================================================
-- 11. Table: Drivers
-- =====================================================================
IF OBJECT_ID(N'dbo.Drivers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Drivers (
        DriverID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PersonID INT NOT NULL UNIQUE,
        CreatedByUserID INT NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Drivers_People FOREIGN KEY (PersonID)
            REFERENCES dbo.People(PersonID),
        CONSTRAINT FK_Drivers_Users FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID)
    );
END
GO

-- =====================================================================
-- 12. Table: Licenses
-- =====================================================================
IF OBJECT_ID(N'dbo.Licenses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Licenses (
        LicenseID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationID INT NOT NULL,
        DriverID INT NOT NULL,
        LicenseClass INT NOT NULL,
        IssueDate DATETIME NOT NULL DEFAULT GETDATE(),
        ExpirationDate DATETIME NOT NULL,
        Notes NVARCHAR(500) NULL,
        PaidFees SMALLMONEY NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1,
        IssueReason TINYINT NOT NULL DEFAULT 1, -- 1: FirstTime, 2: Renew, 3: DamagedReplacement, 4: LostReplacement
        CreatedByUserID INT NOT NULL,
        CONSTRAINT FK_Licenses_Applications FOREIGN KEY (ApplicationID)
            REFERENCES dbo.Applications(ApplicationID),
        CONSTRAINT FK_Licenses_Drivers FOREIGN KEY (DriverID)
            REFERENCES dbo.Drivers(DriverID),
        CONSTRAINT FK_Licenses_LicenseClasses FOREIGN KEY (LicenseClass)
            REFERENCES dbo.LicenseClasses(LicenseClassID),
        CONSTRAINT FK_Licenses_Users FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID)
    );
END
GO

-- =====================================================================
-- 13. Table: InternationalLicenses
-- =====================================================================
IF OBJECT_ID(N'dbo.InternationalLicenses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.InternationalLicenses (
        InternationalLicenseID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationID INT NOT NULL UNIQUE,
        DriverID INT NOT NULL,
        IssuedUsingLocalLicenseID INT NOT NULL,
        IssueDate DATETIME NOT NULL DEFAULT GETDATE(),
        ExpirationDate DATETIME NOT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedByUserID INT NOT NULL,
        CONSTRAINT FK_InternationalLicenses_Applications FOREIGN KEY (ApplicationID)
            REFERENCES dbo.Applications(ApplicationID),
        CONSTRAINT FK_InternationalLicenses_Drivers FOREIGN KEY (DriverID)
            REFERENCES dbo.Drivers(DriverID),
        CONSTRAINT FK_InternationalLicenses_Licenses FOREIGN KEY (IssuedUsingLocalLicenseID)
            REFERENCES dbo.Licenses(LicenseID),
        CONSTRAINT FK_InternationalLicenses_Users FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID)
    );
END
GO

-- =====================================================================
-- 14. Table: DetainedLicenses
-- =====================================================================
IF OBJECT_ID(N'dbo.DetainedLicenses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DetainedLicenses (
        DetainID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        LicenseID INT NOT NULL,
        DetainDate DATETIME NOT NULL DEFAULT GETDATE(),
        FineFees SMALLMONEY NOT NULL DEFAULT 0,
        CreatedByUserID INT NOT NULL,
        IsReleased BIT NOT NULL DEFAULT 0,
        ReleaseDate DATETIME NULL,
        ReleasedByUserID INT NULL,
        ReleaseApplicationID INT NULL,
        CONSTRAINT FK_DetainedLicenses_Licenses FOREIGN KEY (LicenseID)
            REFERENCES dbo.Licenses(LicenseID),
        CONSTRAINT FK_DetainedLicenses_Users_CreatedBy FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_DetainedLicenses_Users_ReleasedBy FOREIGN KEY (ReleasedByUserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_DetainedLicenses_Applications FOREIGN KEY (ReleaseApplicationID)
            REFERENCES dbo.Applications(ApplicationID)
    );
END
GO

-- =====================================================================
-- DATABASE VIEWS
-- =====================================================================

-- View 1: LocalDrivingLicenseApplications_View
IF OBJECT_ID(N'dbo.LocalDrivingLicenseApplications_View', N'V') IS NOT NULL
    DROP VIEW dbo.LocalDrivingLicenseApplications_View;
GO

CREATE VIEW dbo.LocalDrivingLicenseApplications_View
AS
SELECT 
    LDLA.LocalDrivingLicenseApplicationID,
    LC.ClassName,
    P.NationalNo,
    P.FirstName + ' ' + P.SecondName + ' ' + ISNULL(P.ThirdName + ' ', '') + P.LastName AS FullName,
    A.ApplicationDate,
    (
        SELECT COUNT(DISTINCT T.TestTypeID)
        FROM dbo.Tests T
        INNER JOIN dbo.TestAppointments TA ON T.TestAppointmentID = TA.TestAppointmentID
        WHERE TA.LocalDrivingLicenseApplicationID = LDLA.LocalDrivingLicenseApplicationID
          AND T.TestResult = 1
    ) AS PassedTestCount,
    CASE A.ApplicationStatus
        WHEN 1 THEN 'New'
        WHEN 2 THEN 'Cancelled'
        WHEN 3 THEN 'Completed'
        ELSE 'Unknown'
    END AS Status
FROM dbo.LocalDrivingLicenseApplications LDLA
INNER JOIN dbo.Applications A ON LDLA.ApplicationID = A.ApplicationID
INNER JOIN dbo.LicenseClasses LC ON LDLA.LicenseClassID = LC.LicenseClassID
INNER JOIN dbo.People P ON A.ApplicantPersonID = P.PersonID;
GO

-- View 2: Drivers_View
IF OBJECT_ID(N'dbo.Drivers_View', N'V') IS NOT NULL
    DROP VIEW dbo.Drivers_View;
GO

CREATE VIEW dbo.Drivers_View
AS
SELECT 
    D.DriverID,
    D.PersonID,
    P.NationalNo,
    P.FirstName + ' ' + P.SecondName + ' ' + ISNULL(P.ThirdName + ' ', '') + P.LastName AS FullName,
    D.CreatedDate AS [Date],
    (
        SELECT COUNT(*) 
        FROM dbo.Licenses L 
        WHERE L.DriverID = D.DriverID AND L.IsActive = 1
    ) AS [Active Licenses]
FROM dbo.Drivers D
INNER JOIN dbo.People P ON D.PersonID = P.PersonID;
GO

-- View 3: TestAppointments_View
IF OBJECT_ID(N'dbo.TestAppointments_View', N'V') IS NOT NULL
    DROP VIEW dbo.TestAppointments_View;
GO

CREATE VIEW dbo.TestAppointments_View
AS
SELECT 
    TA.TestAppointmentID,
    TA.LocalDrivingLicenseApplicationID,
    TT.TestTypeTitle,
    TA.AppointmentDate,
    TA.PaidFees,
    TA.IsLocked
FROM dbo.TestAppointments TA
INNER JOIN dbo.TestTypes TT ON TA.TestTypeID = TT.TestTypeID;
GO

-- View 4: DetainedLicenses_View
IF OBJECT_ID(N'dbo.DetainedLicenses_View', N'V') IS NOT NULL
    DROP VIEW dbo.DetainedLicenses_View;
GO

CREATE VIEW dbo.DetainedLicenses_View
AS
SELECT 
    DL.DetainID,
    DL.LicenseID,
    DL.DetainDate,
    DL.IsReleased,
    DL.FineFees,
    DL.ReleaseDate,
    P.NationalNo,
    P.FirstName + ' ' + P.SecondName + ' ' + ISNULL(P.ThirdName + ' ', '') + P.LastName AS FullName,
    DL.ReleaseApplicationID
FROM dbo.DetainedLicenses DL
INNER JOIN dbo.Licenses L ON DL.LicenseID = L.LicenseID
INNER JOIN dbo.Drivers D ON L.DriverID = D.DriverID
INNER JOIN dbo.People P ON D.PersonID = P.PersonID;
GO

-- =====================================================================
-- SEED / REFERENCE DATA
-- =====================================================================

-- Seed ApplicationTypes
IF NOT EXISTS (SELECT 1 FROM dbo.ApplicationTypes)
BEGIN
    SET IDENTITY_INSERT dbo.ApplicationTypes ON;
    INSERT INTO dbo.ApplicationTypes (ApplicationTypeID, ApplicationTypeTitle, ApplicationFees) VALUES
    (1, N'New Local Driving License Service', 15.00),
    (2, N'Renew Driving License Service', 5.00),
    (3, N'Replacement for a Lost Driving License', 10.00),
    (4, N'Replacement for a Damaged Driving License', 5.00),
    (5, N'Release Detained Driving License Service', 15.00),
    (6, N'New International License Service', 50.00),
    (7, N'Retake Test', 5.00);
    SET IDENTITY_INSERT dbo.ApplicationTypes OFF;
END
GO

-- Seed TestTypes
IF NOT EXISTS (SELECT 1 FROM dbo.TestTypes)
BEGIN
    SET IDENTITY_INSERT dbo.TestTypes ON;
    INSERT INTO dbo.TestTypes (TestTypeID, TestTypeTitle, TestTypeDescription, TestTypeFees) VALUES
    (1, N'Vision Test', N'Evaluates the visual acuity and field of vision required for safe vehicle operation.', 10.00),
    (2, N'Written (Theory) Test', N'Assesses knowledge of traffic laws, road signs, and driving safety regulations.', 20.00),
    (3, N'Practical (Street) Test', N'Evaluates on-road driving skills, vehicle handling, and real-world traffic adherence.', 30.00);
    SET IDENTITY_INSERT dbo.TestTypes OFF;
END
GO

-- Seed LicenseClasses
IF NOT EXISTS (SELECT 1 FROM dbo.LicenseClasses)
BEGIN
    SET IDENTITY_INSERT dbo.LicenseClasses ON;
    INSERT INTO dbo.LicenseClasses (LicenseClassID, ClassName, ClassDescription, MinimumAllowedAge, DefaultValidityLength, ClassFees) VALUES
    (1, N'Class 1 - Small Motorcycle', N'Allows driving light motorcycles with engine capacity up to 125cc.', 16, 5, 15.00),
    (2, N'Class 2 - Heavy Motorcycle', N'Allows driving high-power motorcycles with no engine limit.', 18, 5, 20.00),
    (3, N'Class 3 - Ordinary driving license', N'Allows driving private passenger cars, station wagons, and light transport up to 3.5 tons.', 18, 10, 20.00),
    (4, N'Class 4 - Commercial', N'Allows driving taxis, transport vehicles, and small passenger vans.', 21, 10, 50.00),
    (5, N'Class 5 - Agricultural', N'Allows driving tractors and agricultural vehicles.', 18, 10, 50.00),
    (6, N'Class 6 - Small and medium bus', N'Allows driving mini buses and mid-sized transport buses.', 21, 5, 100.00),
    (7, N'Class 7 - Truck and heavy vehicle', N'Allows driving heavy transport trucks, articulated vehicles, and large buses.', 21, 5, 250.00);
    SET IDENTITY_INSERT dbo.LicenseClasses OFF;
END
GO

-- Seed Countries (Sample Top Countries)
IF NOT EXISTS (SELECT 1 FROM dbo.Countries)
BEGIN
    INSERT INTO dbo.Countries (CountryName) VALUES
    (N'Egypt'), (N'United States'), (N'United Kingdom'), (N'Canada'), (N'Germany'),
    (N'France'), (N'Saudi Arabia'), (N'United Arab Emirates'), (N'Jordan'), (N'Kuwait'),
    (N'Qatar'), (N'Oman'), (N'Bahrain'), (N'Lebanon'), (N'Australia'), (N'Japan');
END
GO

-- Seed Default Admin Person & User (Credentials: admin / 1234)
IF NOT EXISTS (SELECT 1 FROM dbo.People WHERE NationalNo = N'N1')
BEGIN
    INSERT INTO dbo.People (NationalNo, FirstName, SecondName, ThirdName, LastName, DateOfBirth, Gendor, Address, Phone, Email, NationalityCountryID, ImagePath)
    VALUES (N'N1', N'Admin', N'System', N'DVLD', N'Manager', '1995-01-01', 0, N'Main HQ, City Center', N'+123456789', N'admin@dvld.local', 1, NULL);

    DECLARE @AdminPersonID INT = SCOPE_IDENTITY();

    INSERT INTO dbo.Users (PersonID, UserName, Password, IsActive, IsAdmin)
    VALUES (@AdminPersonID, N'admin', N'1234', 1, 1);
END
GO

PRINT 'DVLD Database setup completed successfully.';
GO
