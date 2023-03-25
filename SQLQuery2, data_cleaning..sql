--Cleaning data in SQL queries 

Select *
from ProtofolioProject..NashvilleHousing


--Standardize sale date  

Select saledateconverted, convert(date,saledate)
from ProtofolioProject..NashvilleHousing


update NashvilleHousing 
set saledate = convert(date,saledate)

alter table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property Address data

Select *
from ProtofolioProject..NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from ProtofolioProject..NashvilleHousing a
JOIN ProtofolioProject..NashvilleHousing b
ON a. parcelID = b. parcelID
and a.[uniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from ProtofolioProject..NashvilleHousing a
JOIN ProtofolioProject..NashvilleHousing b
ON a. parcelID = b. parcelID
and a.[uniqueID] <> b.[UniqueID]
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
from ProtofolioProject..NashvilleHousing
--where PropertyAddress is null 
--order by ParcelID


select
substring(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
,substring(propertyaddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as address

from ProtofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



select *
from ProtofolioProject..NashvilleHousing





select OwnerAddress
from ProtofolioProject..NashvilleHousing


select
parsename(replace(owneraddress,  ',', '.'),3)
,parsename(replace(owneraddress,  ',', '.'),2)
,parsename(replace(owneraddress,  ',', '.'),1)
from ProtofolioProject..NashvilleHousing





ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select *
from ProtofolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), Count(SoldAsVacant)
from ProtofolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2



select SoldAsVacant
,case when soldasvacant = 'Y' THEN 'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  else SoldAsVacant
	  end
from ProtofolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = case when soldasvacant = 'Y' THEN 'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  else SoldAsVacant
	  end


	  --------------------------------------------------------------------------------------------------------------------------------------------------------------
	  -- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From ProtofolioProject..NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From ProtofolioProject..NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From ProtofolioProject..NashvilleHousing

ALTER TABLE ProtofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




