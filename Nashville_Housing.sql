--Cleaning Nashvill Housing Data with SQL
Select *
From [Portfolio Project]..Nashville$

-- Standardize Date Format, get rid of time 

Select SaleDate, CONVERT(Date,SaleDate) As SaleDate1
From [Portfolio Project]..Nashville$

Update [Portfolio Project]..Nashville$
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio Project]..Nashville$
Add SaleDateConverted Date;

Update [Portfolio Project]..Nashville$
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select *
From [Portfolio Project]..Nashville$

------------------------------
--Populate Missing Property Address Values

--Property Address That is Null
Select *
From [Portfolio Project]..Nashville$
Where PropertyAddress is null
order by ParcelID


--Property Address Null with different unique ID
Select a.ParcelID, a.UniqueID,a.PropertyAddress, b.ParcelID,b.UniqueID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..Nashville$ a
JOIN [Portfolio Project]..Nashville$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

--Update dataframe 
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..Nashville$ a
JOIN [Portfolio Project]..Nashville$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking Property Address into 2 Columns (Address, City)
Select *
From [Portfolio Project]..Nashville$


--Separate Address and City
Select
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2) AS Property_Address
,PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1) AS Property_City
From [Portfolio Project]..Nashville$

--Make Property Address Column

ALTER TABLE [Portfolio Project]..Nashville$
Add Property_Address Nvarchar(255);

Update [Portfolio Project]..Nashville$
SET Property_Address = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)


Select *
From [Portfolio Project]..Nashville$

--Make Property City Column
ALTER TABLE [Portfolio Project]..Nashville$
Add Propertycity Nvarchar(255);

Update [Portfolio Project]..Nashville$
SET Propertycity = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)

Select *
From [Portfolio Project]..Nashville$

--Split Owner Address into Address, City, and State Column
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) As Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) As City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) As State
From [Portfolio Project]..Nashville$

--Create new Owner_Address Column
ALTER TABLE [Portfolio Project]..Nashville$
Add Owner_Address Nvarchar(255);

Update [Portfolio Project]..Nashville$
Set Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

--Create new Owner_City Column
ALTER TABLE [Portfolio Project]..Nashville$
Add Owner_City Nvarchar(255);

Update [Portfolio Project]..Nashville$
Set Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

--Create new OwnerState column
ALTER TABLE [Portfolio Project]..Nashville$
Add OwnerState nvarchar(25);

Update [Portfolio Project]..Nashville$
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From [Portfolio Project]..Nashville$


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Counts
From [Portfolio Project]..Nashville$
Group by SoldAsVacant
order by Counts

--We have 52 Y's and 399 N's when the column is all supposed tobe Yes or No
--Query that changes Y's and N's to Yes and No's

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END As soldasvacant2
From [Portfolio Project]..Nashville$

--Update table 
Update [Portfolio Project]..Nashville$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Look at this query again and I have all Yes and No in the Sold as Vacant column
Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Counts
From [Portfolio Project]..Nashville$
Group by SoldAsVacant
order by Counts


--Remove Duplicates

WITH DuplicateCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) As duplicate_count

From [Portfolio Project]..Nashville$
)
Delete 
From DuplicateCTE
Where duplicate_count > 1

--Check if duplicates are gone

WITH DuplicateCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) As duplicate_count

From [Portfolio Project]..Nashville$
)
Select *
From DuplicateCTE
Where duplicate_count > 1

--...And they are!

Select * From [Portfolio Project]..Nashville$

--Drop Unused Columns including the ones I made new columns for (OwnerAddress, PropertyAddress, Saledate)
Alter Table [Portfolio Project]..Nashville$
Drop Column OwnerAddress, PropertyAddress, SaleDate, Owner_State


--See if my columns have been dropped
Select * From [Portfolio Project]..Nashville$

--...and I am done! The dataset has been cleaned. 