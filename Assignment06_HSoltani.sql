--*************************************************************************--
-- Title: Assignment06
-- Author: HSoltani
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-08-15,HSoltani,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_HSoltani')
	 Begin 
	  Alter Database [Assignment06DB_HSoltani] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_HSoltani;
	 End
	Create Database Assignment06DB_HSoltani;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_HSoltani;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
GO
-- DROP VIEW vCategories 
CREATE VIEW vCategories 
	WITH SCHEMABINDING AS
	SELECT [CategoryID], [CategoryName] 	-- attributes of the view
	FROM  dbo.Categories; --<< 2-part name
GO
--Select * From vCategories;
--Select * From Categories;

-- DROP VIEW vEmployees 
CREATE VIEW vEmployees 
	WITH SCHEMABINDING AS
	SELECT [EmployeeID], [EmployeeFirstName], [EmployeeLastName], [ManagerID] 	-- attributes of the view
	FROM  dbo.Employees;  --<< 2-part name
GO
--Select * From vEmployees;
--Select * From Employees;

-- DROP VIEW vInventories
CREATE VIEW vInventories
	WITH SCHEMABINDING AS
	SELECT [InventoryID], [InventoryDate], [EmployeeID], [ProductID], [Count] 	-- attributes of the view
	FROM  dbo.Inventories;  --<< 2-part name
GO
--Select * From vInventories;
--Select * From Inventories;

-- DROP VIEW vProducts
CREATE VIEW vProducts
	WITH SCHEMABINDING AS
	SELECT [ProductID], [ProductName], [CategoryID], [UnitPrice] 	-- attributes of the view
	FROM  dbo.Products;  --<< 2-part name
GO
--Select * From vProducts;
--Select * From Products;


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;
GO

DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GO

DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;
GO

DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Select * From vCategories;
--Select * From vProducts;
--Select * From vEmployees;

-- I will be using the Views created above instead of the base tables to create new views.

-- DROP VIEW vProductsByCategories
CREATE VIEW vProductsByCategories AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause 
	C.CategoryName, P.ProductName, P.UnitPrice  	-- attributes of the view
	FROM  vCategories AS C  -- use the view
		INNER JOIN vProducts AS P  -- use the view
		ON C.CategoryID = P.CategoryID
	ORDER BY C.CategoryName, P.ProductName;
GO
-- Select * From vProductsByCategories


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- DROP VIEW vInventoriesByProductsByDates
CREATE VIEW vInventoriesByProductsByDates AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause 
	P.ProductName, I.InventoryDate, I.Count  	-- attributes of the view
	FROM  vProducts AS P  -- use the view
		INNER JOIN vInventories AS I  -- use the view
		ON P.ProductID =	I.ProductID
	ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO
-- Select * From vInventoriesByProductsByDates


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- DROP VIEW vInventoriesByEmployeesByDates
CREATE VIEW vInventoriesByEmployeesByDates AS
	SELECT DISTINCT TOP 1000000   -- use DISTINCT to remove repeated rows; use the TOP clause trick to allow the ORDER BY clause 
	I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName 	-- attributes of the view
	FROM  vInventories AS I  -- use the view
		INNER JOIN vEmployees AS E  -- use the view
		ON I.EmployeeID = E.EmployeeID
	ORDER BY I.InventoryDate;
GO
-- Select * From vInventoriesByEmployeesByDates


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- DROP VIEW vInventoriesByProductsByCategories
CREATE VIEW vInventoriesByProductsByCategories AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause 
	C.CategoryName, P.ProductName, I.InventoryDate, I.Count  	-- attributes of the view
	FROM vCategories AS C   -- use the view
		INNER JOIN vProducts AS P   -- use the view
		ON C.CategoryID = P.CategoryID   
		INNER JOIN vInventories AS I  -- use the view
		ON P.ProductID =	I.ProductID
	ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.Count;
GO
-- Select * From vInventoriesByProductsByCategories


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- DROP VIEW vInventoriesByProductsByEmployees
CREATE VIEW vInventoriesByProductsByEmployees AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause 
	C.CategoryName, P.ProductName, I.InventoryDate, I.Count,  	
	E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName   -- attributes of the view
	FROM vCategories AS C   -- use the view
		INNER JOIN vProducts AS P   -- use the view
		ON C.CategoryID = P.CategoryID   
		INNER JOIN vInventories AS I  -- use the view
		ON P.ProductID =	I.ProductID
		INNER JOIN vEmployees AS E
		ON I.EmployeeID = E.EmployeeID
	ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO
-- Select * From vInventoriesByProductsByEmployees


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- DROP VIEW vInventoriesForChaiAndChangByEmployees
CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause 
	C.CategoryName, P.ProductName, I.InventoryDate, I.Count,  	
	E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName   -- attributes of the view
	FROM vCategories AS C   -- use the view
		INNER JOIN vProducts AS P   -- use the view
		ON C.CategoryID = P.CategoryID   
		INNER JOIN vInventories AS I  -- use the view
		ON P.ProductID =	I.ProductID
		INNER JOIN vEmployees AS E
		ON I.EmployeeID = E.EmployeeID
	WHERE P.ProductName IN ('Chai','Chang')   -- filter the results for products Chai snd Change
	--WHERE P.ProductID IN (SELECT ProductID FROM vProducts WHERE ProductName IN ('Chai', 'Chang'))  -- A subquery for ProductID
	ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO
-- Select * From vInventoriesForChaiAndChangByEmployees


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- DROP VIEW vEmployeesByManager
CREATE VIEW vEmployeesByManager AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause 
	A.EmployeeFirstName + ' ' + A.EmployeeLastName AS Manager, 
	B.EmployeeFirstName + ' ' + B.EmployeeLastName AS Employee   -- attributes of the view
	FROM vEmployees AS B 
	INNER JOIN vEmployees AS A
		ON B.ManagerID = A.EmployeeID
	ORDER BY Manager, Employee;  
	-- Note: Although the Question is only asking to order the results by Manager's name,
	-- the view will not be the same as the provided image of the results unless we order by Employee's name as well!
GO
-- Select * From vEmployeesByManager


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- DROP VIEW vInventoriesByProductsByCategoriesByEmployees
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
	SELECT TOP 1000000   -- the TOP clause trick to allow the ORDER BY clause
	C.CategoryID, C.CategoryName, 
	P.ProductID, P.ProductName, P.UnitPrice,
	I.InventoryID, I.InventoryDate, I.Count,
	E.EmployeeID, 
	E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee, 
	M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager   -- attributes of the view
	FROM vCategories AS C   -- use the view
		INNER JOIN vProducts AS P   -- use the view
		ON C.CategoryID = P.CategoryID   
		INNER JOIN vInventories AS I  -- use the view
		ON P.ProductID =	I.ProductID
		INNER JOIN vEmployees AS E
		ON I.EmployeeID = E.EmployeeID
		INNER JOIN vEmployees AS M
		ON E.ManagerID = M.EmployeeID
	-- ORDER BY C.CategoryName, P.ProductName,I.InventoryID, Employee;
	-- Note: Although the Question is asking to order the results by CategoryName, ProductName, InventoryID, and Employee
	-- the view will not be the same as the provided image of the results unless we order by 
	-- CategoryID, ProductID, InventoryID, and EmployeeID!!
		ORDER BY C.CategoryID, P.ProductID, I.InventoryID, E.EmployeeID;
GO
-- Select * FROM vInventoriesByProductsByCategoriesByEmployees

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]  --Q3
Select * From [dbo].[vInventoriesByProductsByDates]  --Q4
Select * From [dbo].[vInventoriesByEmployeesByDates]  --Q5
Select * From [dbo].[vInventoriesByProductsByCategories]  --Q6
Select * From [dbo].[vInventoriesByProductsByEmployees]  --Q7
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]  --Q8
Select * From [dbo].[vEmployeesByManager]  --Q9
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]  --Q10

/***************************************************************************************/