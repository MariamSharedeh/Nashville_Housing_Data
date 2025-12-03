/* ================================================================
   🧹 DATA CLEANING PROJECT – SQL SERVER
   Table: Data_Cleaning
   Author: Mariam Sharedeh
================================================================ */

/* =============================================================
   1️ CHECK TABLE STRUCTURE
   ============================================================= */
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Data_Cleaning';


/* =============================================================
   2️ STANDARDIZE DATE FORMAT
   ============================================================= */
ALTER TABLE Data_Cleaning
ADD SaleDateConverted DATE;

UPDATE Data_Cleaning
SET SaleDateConverted = CONVERT(DATE, SaleDate);


/* =============================================================
   3️ POPULATE MISSING PROPERTY ADDRESSES
   ============================================================= */

-- 🔍 Check missing property addresses
SELECT * 
FROM Data_Cleaning
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Option 1: Replace NULL PropertyAddress with OwnerAddress
UPDATE Data_Cleaning
SET PropertyAddress = COALESCE(OwnerAddress, 'Unknown')
WHERE PropertyAddress IS NULL;

--  Option 2: Use values from rows with the same ParcelID
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning a
JOIN Data_Cleaning b
  ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


/* =============================================================
   4️ SPLIT ADDRESS INTO INDIVIDUAL COLUMNS
   ============================================================= */

-- Add new columns
ALTER TABLE Data_Cleaning ADD 
    PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255),
    OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

-- Property Address Split
UPDATE Data_Cleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity    = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Owner Address Split
UPDATE Data_Cleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity    = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState   = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


/* =============================================================
   5️ FIX INCONSISTENT VALUES
   ============================================================= */

-- Standardize 'SoldAsVacant' values
UPDATE Data_Cleaning
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Replace NULL TaxDistrict with 'Unknown'
UPDATE Data_Cleaning
SET TaxDistrict = 'Unknown'
WHERE TaxDistrict IS NULL;


/* =============================================================
   6️⃣ REMOVE DUPLICATES
   ============================================================= */
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Data_Cleaning
)
DELETE FROM RowNumCTE WHERE row_num > 1;


/* =============================================================
   7️ DELETE UNUSED COLUMNS
   ============================================================= */
ALTER TABLE Data_Cleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


/* =============================================================
    FINAL CHECK
   ============================================================= */
SELECT TOP 50 *
FROM Data_Cleaning
ORDER BY ParcelID;

