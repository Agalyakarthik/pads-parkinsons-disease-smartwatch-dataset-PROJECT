--validating the count of records
select * from public.movement_data

--list the unique record name
select distinct record_name from public.movement_data

---list the unique device location
select distinct device_location from public.movement_data

--checking the records 
select * from public.movement_data
where record_name = 'Entrainment' and device_location = 'LeftWrist'

select * from public.movement_data
where record_name = 'Entrainment' and device_location = 'RightWrist' and subject_id = '469'

select * from public.movement_data
where record_name = 'CrossArms'
and device_location = 'LeftWrist'

select * from public.movement_data
where record_name = 'CrossArms'
and device_location = 'RightWrist'

select * from public.movement_data
where record_name = 'DrinkGlas' 
and device_location = 'LeftWrist'

select * from public.movement_data
where record_name = 'DrinkGlas' 
and device_location = 'RightWrist' 

select * from public.movement_data
where record_name = 'HoldWeight' 
and device_location = 'LeftWrist'

select * from public.movement_data
where record_name = 'HoldWeight' 
and device_location = 'RightWrist'
-----------------------------------------------------------------------------------------------------------
--create separate tables for each record_name and device_location( Total 22 tables)
-- For CrossArms
CREATE TABLE CrossArms_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'CrossArms' AND device_location = 'LeftWrist';

CREATE TABLE CrossArms_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'CrossArms' AND device_location = 'RightWrist';

-- For DrinkGlas
CREATE TABLE DrinkGlas_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'DrinkGlas' AND device_location = 'LeftWrist';

CREATE TABLE DrinkGlas_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'DrinkGlas' AND device_location = 'RightWrist';

-- For Entrainment
CREATE TABLE Entrainment_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'Entrainment' AND device_location = 'LeftWrist';

CREATE TABLE Entrainment_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'Entrainment' AND device_location = 'RightWrist';

-- For HoldWeight
CREATE TABLE HoldWeight_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'HoldWeight' AND device_location = 'LeftWrist';

CREATE TABLE HoldWeight_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'HoldWeight' AND device_location = 'RightWrist';

-- For LiftHold
CREATE TABLE LiftHold_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'LiftHold' AND device_location = 'LeftWrist';

CREATE TABLE LiftHold_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'LiftHold' AND device_location = 'RightWrist';

-- For PointFinger
CREATE TABLE PointFinger_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'PointFinger' AND device_location = 'LeftWrist';

CREATE TABLE PointFinger_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'PointFinger' AND device_location = 'RightWrist';

-- For Relaxed
CREATE TABLE Relaxed_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'Relaxed' AND device_location = 'LeftWrist';

CREATE TABLE Relaxed_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'Relaxed' AND device_location = 'RightWrist';

-- For RelaxedTask
CREATE TABLE RelaxedTask_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'RelaxedTask' AND device_location = 'LeftWrist';

CREATE TABLE RelaxedTask_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'RelaxedTask' AND device_location = 'RightWrist';

-- For StretchHold
CREATE TABLE StretchHold_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'StretchHold' AND device_location = 'LeftWrist';

CREATE TABLE StretchHold_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'StretchHold' AND device_location = 'RightWrist';

-- For TouchIndex
CREATE TABLE TouchIndex_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'TouchIndex' AND device_location = 'LeftWrist';

CREATE TABLE TouchIndex_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'TouchIndex' AND device_location = 'RightWrist';

-- For TouchNose
CREATE TABLE TouchNose_LeftWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'TouchNose' AND device_location = 'LeftWrist';

CREATE TABLE TouchNose_RightWrist AS
SELECT * FROM public.movement_data
WHERE record_name = 'TouchNose' AND device_location = 'RightWrist';


