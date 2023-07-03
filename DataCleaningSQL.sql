/*
   
     Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.Nashville

-------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDateConverted , CONVERT(Date, SaleDate)
From PortfolioProject.dbo.Nashville

ALTER TABLE Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.Nashville
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville a
JOIN PortfolioProject.dbo.Nashville b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville a
JOIN PortfolioProject.dbo.Nashville b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


--------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.Nashville
--where PropertyAddress is null
--Order by ParcelID

Select 
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.Nashville

Alter TABLE NAshville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

Select *
From PortfolioProject.dbo.Nashville


Select OwnerAddress
From PortfolioProject.dbo.Nashville

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject.dbo.Nashville


Alter TABLE NAshville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


Select *
From PortfolioProject.dbo.Nashville


---------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and No in "Sold as Vacant" Field


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashville
GROUP BY SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' Then'No'
	   Else SoldAsVacant
	   END
FROM PortfolioProject.dbo.Nashville

Update Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' Then'No'
	   Else SoldAsVacant
	   END

---------------------------------------------------------------------------------------------------


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
      ROW_NUMBER() Over(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				         UniqueID
						 ) row_num

From PortfolioProject.dbo.Nashville
--Order BY ParcelID
)
Select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------

-- Ddelete Unsued Columns

Select *
From PortfolioProject.dbo.Nashville

Alter TABLE PortfolioProject.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
