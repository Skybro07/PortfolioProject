/*  
Cleaning Data in SQL Queries

*/

SELECT *
FROM portfolioproject.. NashvilleHousing


-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM portfolioproject.. NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER  TABLE  NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate property address data

SELECT *
FROM portfolioproject .. NashvilleHousing
--WHERE  PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress , ISNULL(A.PropertyAddress, B.PropertyAddress )
FROM  portfolioproject .. NashvilleHousing A
JOIN portfolioproject .. NashvilleHousing B
    ON A.ParcelID = B.ParcelID
	AND  A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress  is null

UPDATE A
SET  PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress )
FROM  portfolioproject .. NashvilleHousing A
JOIN portfolioproject .. NashvilleHousing B
    ON A.ParcelID = B.ParcelID
	AND  A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress  is null

SELECT ParcelID, PropertyAddress
FROM portfolioproject .. NashvilleHousing
WHERE  PropertyAddress is null
ORDER BY ParcelID  

/*
now no null property address is in present in the data 
*/

-- Breaking Out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM portfolioproject .. NashvilleHousing


SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
--CHARINDEX(',', PropertyAddress)  -- it basically a giving position 

FROM portfolioproject .. NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE  NashvilleHousing
SET  PropertySplitAddress  = SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE  NashvilleHousing
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM portfolioproject .. NashvilleHousing

-- owner adderess

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM  portfolioproject .. NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM portfolioproject .. NashvilleHousing


-- Change
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM  portfolioproject .. NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = '1'THEN 'YES'
     WHEN SoldAsVacant =  '0' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM portfolioproject ..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = '1'THEN 'YES'
     WHEN SoldAsVacant =  '0' THEN 'NO'
	 ELSE SoldAsVacant
	 END





-- REMOVE Duplicates

WITH RowNumCTE AS(
SELECT *, 
     ROW_NUMBER() OVER(
	 PARTITION BY  ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				       UniqueID
					   ) row_num
FROM  portfolioproject .. NashvilleHousing
)

--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- Delete Unused Columns

SELECT *
FROM  portfolioproject .. NashvilleHousing

ALTER TABLE  NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE  NashvilleHousing
DROP COLUMN SaleDate