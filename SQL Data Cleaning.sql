/*
Cleaning Data in SQL
*/


select * from projectportfoliodb..NashvilleHousing

--Standardize Date Format

select SaleDate, convert(Date, SaleDate) 
from projectportfoliodb..NashvilleHousing

Alter table projectportfoliodb..NashvilleHousing
add SaleDateConverted Date;

update projectportfoliodb..NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

--Populate Property Address Data

select * 
from projectportfoliodb..NashvilleHousing
--where PropertyAddress is null
order by parcelID


select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress
from projectportfoliodb..NashvilleHousing as a
join projectportfoliodb..NashvilleHousing as b
	on a.parcelID = b.parcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is null

select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from projectportfoliodb..NashvilleHousing as a
join projectportfoliodb..NashvilleHousing as b
	on a.parcelID = b.parcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from projectportfoliodb..NashvilleHousing as a
join projectportfoliodb..NashvilleHousing as b
	on a.parcelID = b.parcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is null


--Breaking out address in individual columns (Address, City, State)

select PropertyAddress 
from projectportfoliodb..NashvilleHousing

select
PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as  Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as  City
from projectportfoliodb..NashvilleHousing

Alter table projectportfoliodb..NashvilleHousing
add AddressLine1 Nvarchar(255);

update projectportfoliodb..NashvilleHousing
set AddressLine1 = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

Alter table projectportfoliodb..NashvilleHousing
add AddressLine2_City Nvarchar(255);

update projectportfoliodb..NashvilleHousing
set AddressLine2_City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


-- Splitting Data using Parsename

select * 
from projectportfoliodb..NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3) as address,
parsename(replace(OwnerAddress,',','.'),2) as city,
parsename(replace(OwnerAddress,',','.'),1) as state
from projectportfoliodb..NashvilleHousing

Alter table projectportfoliodb..NashvilleHousing
add OwnerAddressLine1 Nvarchar(255);

update projectportfoliodb..NashvilleHousing
set OwnerAddressLine1 = parsename(replace(OwnerAddress,',','.'),3)

Alter table projectportfoliodb..NashvilleHousing
add OwnerAddressLine2_city Nvarchar(255);

update projectportfoliodb..NashvilleHousing
set OwnerAddressLine2_city = parsename(replace(OwnerAddress,',','.'),2)

Alter table projectportfoliodb..NashvilleHousing
add OwnerAddressLine3_state Nvarchar(255);

update projectportfoliodb..NashvilleHousing
set OwnerAddressLine3_state = parsename(replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in 'Sold as Vacant' field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from projectportfoliodb..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 END
from projectportfoliodb..NashvilleHousing

update projectportfoliodb..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 END


