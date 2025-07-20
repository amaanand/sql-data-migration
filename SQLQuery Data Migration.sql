IF OBJECT_ID('dbo.MigrateEmployeeData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.MigrateEmployeeData;
GO

CREATE PROCEDURE MigrateEmployeeData
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		--SAVE TRANSACTION EntrySavepoint;

		DROP TABLE IF EXISTS EmployeeMigration

		CREATE TABLE EmployeeMigration(
			EmployeeID INT PRIMARY KEY NOT NULL,
			NationalIDNumber NVARCHAR(40) UNIQUE NOT NULL,
			JobTitle NVARCHAR(200),
			Department NVARCHAR(50),
			Shift NVARCHAR(20),
			HireDate DATETIME,
			ModifiedDate DATETIME
		)

		CREATE NONCLUSTERED INDEX JobTitle ON EmployeeMigration(JobTitle)

		INSERT INTO EmployeeMigration
		(EmployeeID, NationalIDNumber, JobTitle, Department, Shift, HireDate, ModifiedDate)

		SELECT 
			em.BusinessEntityID AS EmployeeId,
			em.NationalIDNumber,
			em.JobTitle,
			dept.Name,
			sh.Name,
			em.HireDate,
			em.ModifiedDate
		FROM HumanResources.Employee AS em

		JOIN 
			HumanResources.EmployeeDepartmentHistory AS edh
			ON em.BusinessEntityID = edh.BusinessEntityID

		JOIN 
			HumanResources.Department AS dept
			ON edh.DepartmentID = dept.DepartmentID

		JOIN HumanResources.Shift AS sh
			ON edh.ShiftID = sh.ShiftID

		WHERE em.HireDate >= '2008-01-01' AND em.BusinessEntityID NOT IN (224, 234, 250)

	

		SELECT *
		FROM EmployeeMigration

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END
GO

EXEC MigrateEmployeeData;
