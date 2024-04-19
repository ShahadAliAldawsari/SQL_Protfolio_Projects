/*
Cleaning Data in SQL Queries
*/

-- let's see what we have got!
select * from Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------




/*
Standardize Date Format
*/

--First way: the updateing existing column the 'did not work!'
Select saleDate, CONVERT(Date,SaleDate)
From Nashville_Housing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

select saleDate
from Nashville_Housing



--Second way: add a new column and fill it using 'update' statement 'worked well'
select saleDate, convert(date, saleDate)
from Nashville_Housing

alter table Nashville_Housing
add SaleDateConverted Date

update Nashville_Housing
set SaleDateConverted=convert(date, saleDate)

--let's check if it went well
select saleDate, SaleDateConverted
from Nashville_Housing

-- finally delete the olde column
alter table Nashville_Housing
drop column saleDate

--------------------------------------------------------------------------------------------------------------------------




/*
Populate property address date
*/

select *
from Nashville_Housing
where PropertyAddress is null

--in the following query I want to check if the same parcel IDs always have the same Property address
with cte (ParcelID, PropertyAddress, id_redund) as
(select ParcelID, PropertyAddress, count(*) over(partition by ParcelID)
from Nashville_Housing)
select * from cte
where id_redund>1
order by id_redund DESC, ParcelID;
--so yes, when ever the parcel IDs are the sane, the Property addresses are the same. Accordingly, we will populate PropertyAddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a join Nashville_Housing b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a 
join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--let's check if it's worked
-- this should give us null
select *
from Nashville_Housing
where PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------




/*
Breaking out Address into Individual Columns (Address, City)
*/

select PropertyAddress 
from Nashville_Housing

--since it separeted by comma we can do this
select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
	--to take chars from index 1 to the index befor the comma
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, len(PropertyAddress)) as city
	--to take chars from the index after the 'comma and the white space' to the end
from Nashville_Housing

--let's add the address column
alter table Nashville_Housing
add address varchar(255);
update Nashville_Housing
set address=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

--let's add the city column
alter table Nashville_Housing
add city varchar(255);
update Nashville_Housing
set city=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, len(PropertyAddress))

-- let's check our new columns
select PropertyAddress, address, city
from Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------




/*
Breaking out Owner Address into Individual Columns (Owner_Address, Owner_City, Owner_state)
*/

-- let's use different way 'an easier one' to separet OwnerAddress
select OwnerAddress
from Nashville_Housing

-- PARSENAME works only with periods '.' so first replace commas ',' with periods '.' then apply PARSENAME
select OwnerAddress,
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from Nashville_Housing

alter table Nashville_Housing
add Owner_Address varchar(255);
update Nashville_Housing
set Owner_Address=PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table Nashville_Housing
add Owner_city varchar(255);
update Nashville_Housing
set Owner_city=PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table Nashville_Housing
add Owner_state varchar(255);
update Nashville_Housing
set Owner_state=PARSENAME(replace(OwnerAddress, ',', '.'), 1)

-- let's check the new columns
select OwnerAddress, Owner_Address, Owner_city, Owner_state
from Nashville_Housing

alter table Nashville_Housing
drop column OwnerAddress
--------------------------------------------------------------------------------------------------------------------------


/*
Change Y and N to Yes and No in "Sold as Vacant" field
*/

-- lets see what values do we have and how many of each one them in "Sold as Vacant" column
select distinct SoldAsVacant, count(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by count(SoldAsVacant) DESC

select SoldAsVacant,
case
	when SoldAsVacant='N' then 'No'
	when SoldAsVacant='Y' then 'Yes'
	else SoldAsVacant end as updated_SoldAsVacant
from Nashville_Housing

alter table Nashville_Housing
add updated_SoldAsVacant varchar(16);
update Nashville_Housing
set updated_SoldAsVacant=
case
	when SoldAsVacant='N' then 'No'
	when SoldAsVacant='Y' then 'Yes'
	else SoldAsVacant end
from Nashville_Housing

-- let's check if it is went well
select distinct updated_SoldAsVacant, count(updated_SoldAsVacant)
from Nashville_Housing
group by updated_SoldAsVacant
order by count(updated_SoldAsVacant) DESC

alter table Nashville_Housing
drop column SoldAsVacant
--------------------------------------------------------------------------------------------------------------------------


/*
Remove Duplicates
*/

--Note: we should NOT delet any data unless the stakeholders approve it
with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from Nashville_Housing
)
delete 
from RowNumCTE
where row_num > 1


--This is it for now
--Thank you for pass by
--------------------------------------------------------------------------------------------------------------------------
