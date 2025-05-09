--checking the patient_data table
select * from public.patient_data

---checking the min,max,avg values for some columns
select max(age_at_diagnosis), min(age_at_diagnosis),avg(age_at_diagnosis) from public.patient_data
select max(age), min(age),avg(age) from public.patient_data
select max(height), min(height), avg(height) from public.patient_data
select max(weight), min(weight), avg(weight) from public.patient_data

--checking the unique values in each column
select distinct gender from public.patient_data
select distinct handedness from public.patient_data
select distinct appearance_in_kinship from public.patient_data
select distinct appearance_in_first_grade_kinship from public.patient_data
select distinct effect_of_alcohol_on_tremor from public.patient_data

--checking the count of non null values in appearance_in_first_grade_kinship
SELECT COUNT(*)
FROM public.patient_data
WHERE appearance_in_first_grade_kinship IS not NULL;

select appearance_in_first_grade_kinship,count(*) 
from  public.patient_data
group by 1;

select effect_of_alcohol_on_tremor,count(*) 
from  public.patient_data
group by 1;

--Rename the column id to patient_id
ALTER TABLE public.patient_data
RENAME COLUMN id TO patient_id;

--checking the appearance_in_kinship null values is same for the other columns
SELECT id, condition,appearance_in_kinship, appearance_in_first_grade_kinship, effect_of_alcohol_on_tremor
FROM public.patient_data
WHERE effect_of_alcohol_on_tremor = 'Unknown' and appearance_in_first_grade_kinship is null
group by 1,2

--Removing the - in the diesease comment column
UPDATE public.patient_data
SET disease_comment = NULL
WHERE disease_comment = '-';

--checking the disease_comment column
select * from public.patient_data
where disease_comment is null

--changing the value of age_at_diagnosis for healthy condition to null
update public.patient_data
SET age_at_diagnosis = null
where condition ='Healthy' and age = age_at_diagnosis

--checking the updated column for healthy condition
select * from public.patient_data
where  condition ='Healthy' 

--Dropping the irrelevant column resource_type and study_id
ALTER TABLE public.patient_data
DROP COLUMN resource_type,
DROP COLUMN study_id;

--creating the new column for years_since_diagnosis
ALTER TABLE public.patient_data
ADD COLUMN years_since_diagnosis INT;

--adding the value to the column 
UPDATE public.patient_data
SET years_since_diagnosis = age - age_at_diagnosis;

--checking the condition column unique values
select distinct condition from public.patient_data

--Adding the new column patient_group
ALTER TABLE public.patient_data
ADD COLUMN patient_group VARCHAR(50);

--Adding the value to the column
UPDATE public.patient_data
SET patient_group = CASE 
    WHEN condition = 'Healthy' THEN 'Healthy Controls'
    WHEN condition = 'Parkinson''s' THEN 'PD Patients'
    ELSE 'Differential Diagnosis'
END;

select distinct patient_group from public.patient_data

--checking the count in the patient_group column
select patient_group,count(*) AS count 
from public.patient_data
group by patient_group
order by patient_group

--checking the count of the patient group with respect ot the gender (to understand the skewness)
SELECT patient_group,
       SUM(CASE WHEN gender = 'male' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN gender = 'female' THEN 1 ELSE 0 END) AS female_count
FROM public.patient_data
GROUP BY patient_group
ORDER BY patient_group;

--checking the overall gender count of the data set
SELECT distinct gender, count(*)
FROM public.patient_data
group by distinct gender;

--looks like the height and weight column are having outlier 
select * from public.patient_data
where weight = 181 

--Identifying the outlier by using IQR method
WITH quartiles AS (
  SELECT 
    percentile_cont(0.25) WITHIN GROUP (ORDER BY weight) AS q1_weight,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY weight) AS q3_weight,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY height) AS q1_height,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY height) AS q3_height
  FROM public.patient_data
),
iqr AS (
  SELECT 
    q1_weight, 
    q3_weight, 
    (q3_weight - q1_weight) AS iqr_weight,
    q1_height, 
    q3_height, 
    (q3_height - q1_height) AS iqr_height
  FROM quartiles
)
SELECT 
  *
FROM public.patient_data, iqr
WHERE 
  weight < q1_weight - 1.5 * iqr_weight OR 
  weight > q3_weight + 1.5 * iqr_weight OR 
  height < q1_height - 1.5 * iqr_height OR 
  height > q3_height + 1.5 * iqr_height;

--Identifying the outlier by using Z score value and selecting the patient_id Z score value < -3 to +3
WITH stats AS (
  SELECT 
    AVG(weight) AS mean_weight, 
    STDDEV(weight) AS stddev_weight,
    AVG(height) AS mean_height, 
    STDDEV(height) AS stddev_height
  FROM public.patient_data
)
SELECT 
  *,
  (weight - stats.mean_weight) / stats.stddev_weight AS weight_zscore,
  (height - stats.mean_height) / stats.stddev_height AS height_zscore
FROM public.patient_data, stats
WHERE 
  ABS((weight - stats.mean_weight) / stats.stddev_weight) > 3 
  OR ABS((height - stats.mean_height) / stats.stddev_height) > 3;

--As the outlier is present, calculating the median value for height and weight separately
SELECT 
    MAX(height) AS max_height, 
    MIN(height) AS min_height, 
    percentile_cont(0.5) WITHIN GROUP (ORDER BY height) AS median_height 
FROM 
    public.patient_data;
	
SELECT 
    MAX(weight) AS max_weight, 
    MIN(weight) AS min_weight, 
    percentile_cont(0.5) WITHIN GROUP (ORDER BY weight) AS median_weight 
FROM 
    public.patient_data;

--changing the datatype for the patient_id column to integer
ALTER TABLE public.patient_data
ALTER COLUMN patient_id TYPE integer USING patient_id::integer;

--needs to work on th outlier

--Questionnarie Table tansformation 
--checking the table
select distinct question from public.questionnaire_responses

--Transposing the questions as column using cross tab function
SELECT *
FROM crosstab(
  'SELECT subject_id, question, CAST(answer AS text) FROM public.questionnaire_responses ORDER BY 1'
) AS ct(
  subject_id text, 
  "Dribbling of saliva during the daytime" text,
  "Loss or change in your ability to taste or smell" text,
  "Difficulty swallowing food or drink or problems with choking" text,
  "Vomiting or feelings of sickness (nausea)" text,
  "Constipation (less than 3 bowel movements a week) or having to strain to pass a stool (faeces)" text,
  "Bowel (fecal) incontinence" text,
  "Feeling that your bowel emptying is incomplete after having been to the toilet" text,
  "A sense of urgency to pass urine makes you rush to the toilet" text,
  "Getting up regularly at night to pass urine" text,
  "Unexplained pains (not due to known conditions such as arthritis)" text,
  "Unexplained change in weight (not due to change in diet)" text,
  "Problems remembering things that have happened recently or forgetting to do things" text,
  "Loss of interest in what is happening around you or doing things" text,
  "Seeing or hearing things that you know or are told are not there" text,
  "Difficulty concentrating or staying focussed" text,
  "Feeling sad, low or blue" text,
  "Feeling anxious, frightened or panicky" text,
  "Feeling less interested in sex or more interested in sex" text,
  "Finding it difficult to have sex when you try" text,
  "Feeling light headed, dizzy or weak standing from sitting or lying" text,
  "Falling" text,
  "Finding it difficult to stay awake during activities such as working, driving or eating" text,
  "Difficulty getting to sleep at night or staying asleep at night" text,
  "Intense, vivid dreams or frightening dreams" text,
  "Talking or moving about in your sleep as if you are acting out a dream" text,
  "Unpleasant sensations in your legs at night or while resting, and a feeling that you need to move" text,
  "Swelling of your legs" text,
  "Excessive sweating" text,
  "Double vision" text,
  "Believing things are happening to you that other people say are not true" text
);

--------------------------------------------------------------------------------------------------------
--create a new table as questionnaire_responses_crosstab 
-- Create a new table from the crosstab results
-- Enable tablefunc extension if not already enabled
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Create the transposed table ensuring correct ordering
DROP TABLE new_questionnaire_responses

-- Create the transposed table ensuring correct ordering
CREATE TABLE public.new_questionnaire_responses AS
SELECT *
FROM crosstab(
  'SELECT subject_id, link_id, CAST(answer AS text) 
   FROM public.questionnaire_responses 
   ORDER BY subject_id, link_id'
) AS ct(
  subject_id text, 
  "Q1_Dribbling_Saliva" text,
  "Q2_Loss_Taste_Smell" text,
  "Q3_Difficulty_Swallowing" text,
  "Q4_Vomiting_Nausea" text,
  "Q5_Constipation" text,
  "Q6_Bowel_Incontinence" text,
  "Q7_Incomplete_Bowel" text,
  "Q8_Urgency_Urine" text,
  "Q9_Nighttime_Urination" text,
  "Q10_Unexplained_Pain" text,
  "Q11_Weight_Change" text,
  "Q12_Memory_Problems" text,
  "Q13_Loss_Interest" text,
  "Q14_Hallucinations" text,
  "Q15_Difficulty_Concentrating" text,
  "Q16_Feeling_Sad" text,
  "Q17_Feeling_Anxious" text,
  "Q18_Sex_Interest_Change" text,
  "Q19_Sex_Difficulty" text,
  "Q20_Dizziness_Standing" text,
  "Q21_Falling" text,
  "Q22_Daytime_Sleepiness" text,
  "Q23_Insomnia" text,
  "Q24_Vivid_Dreams" text,
  "Q25_Sleep_Movement" text,
  "Q26_Restless_Legs" text,
  "Q27_Leg_Swelling" text,
  "Q28_Excessive_Sweating" text,
  "Q29_Double_Vision" text,
  "Q30_Delusions" text
);

--checking the table 
select * from new_questionnaire_responses


--converting the subject_id to patient_id and changing 001 to 1
ALTER TABLE public.new_questionnaire_responses
RENAME COLUMN subject_id TO patient_id;

--change the column patient_id data type to integer
ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN patient_id TYPE INTEGER USING patient_id::INTEGER;

-- Change data type to boolean for each column
ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q1_Dribbling_Saliva" TYPE boolean USING "Q1_Dribbling_Saliva"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q2_Loss_Taste_Smell" TYPE boolean USING "Q2_Loss_Taste_Smell"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q3_Difficulty_Swallowing" TYPE boolean USING "Q3_Difficulty_Swallowing"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q4_Vomiting_Nausea" TYPE boolean USING "Q4_Vomiting_Nausea"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q5_Constipation" TYPE boolean USING "Q5_Constipation"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q6_Bowel_Incontinence" TYPE boolean USING "Q6_Bowel_Incontinence"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q7_Incomplete_Bowel" TYPE boolean USING "Q7_Incomplete_Bowel"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q8_Urgency_Urine" TYPE boolean USING "Q8_Urgency_Urine"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q9_Nighttime_Urination" TYPE boolean USING "Q9_Nighttime_Urination"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q10_Unexplained_Pain" TYPE boolean USING "Q10_Unexplained_Pain"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q11_Weight_Change" TYPE boolean USING "Q11_Weight_Change"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q12_Memory_Problems" TYPE boolean USING "Q12_Memory_Problems"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q13_Loss_Interest" TYPE boolean USING "Q13_Loss_Interest"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q14_Hallucinations" TYPE boolean USING "Q14_Hallucinations"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q15_Difficulty_Concentrating" TYPE boolean USING "Q15_Difficulty_Concentrating"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q16_Feeling_Sad" TYPE boolean USING "Q16_Feeling_Sad"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q17_Feeling_Anxious" TYPE boolean USING "Q17_Feeling_Anxious"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q18_Sex_Interest_Change" TYPE boolean USING "Q18_Sex_Interest_Change"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q19_Sex_Difficulty" TYPE boolean USING "Q19_Sex_Difficulty"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q20_Dizziness_Standing" TYPE boolean USING "Q20_Dizziness_Standing"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q21_Falling" TYPE boolean USING "Q21_Falling"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q22_Daytime_Sleepiness" TYPE boolean USING "Q22_Daytime_Sleepiness"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q23_Insomnia" TYPE boolean USING "Q23_Insomnia"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q24_Vivid_Dreams" TYPE boolean USING "Q24_Vivid_Dreams"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q25_Sleep_Movement" TYPE boolean USING "Q25_Sleep_Movement"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q26_Restless_Legs" TYPE boolean USING "Q26_Restless_Legs"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q27_Leg_Swelling" TYPE boolean USING "Q27_Leg_Swelling"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q28_Excessive_Sweating" TYPE boolean USING "Q28_Excessive_Sweating"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q29_Double_Vision" TYPE boolean USING "Q29_Double_Vision"::boolean;

ALTER TABLE public.new_questionnaire_responses
ALTER COLUMN "Q30_Delusions" TYPE boolean USING "Q30_Delusions"::boolean;

SELECT * FROM public.new_questionnaire_responses

SELECT "Q1_Dribbling_Saliva",count(*)
FROM public.new_questionnaire_responses
group by 1;

SELECT "Q2_Loss_Taste_Smell" ,count(*)
FROM public.new_questionnaire_responses
group by 1;

--checking whether joins are working 
SELECT *
FROM public.new_questionnaire_responses AS q
JOIN public.patient_data AS p ON p.patient_id = q.patient_id;

--checking the count of true and false for Q2
SELECT 
    p.patient_group, count(*) as total_count,
    COUNT(CASE WHEN q."Q2_Loss_Taste_Smell" = 'true' THEN 1 END) AS true_count,
    COUNT(CASE WHEN q."Q2_Loss_Taste_Smell" = 'false' THEN 1 END) AS false_count
FROM public.new_questionnaire_responses AS q
JOIN public.patient_data AS p ON p.patient_id = q.patient_id
GROUP BY p.patient_group;

--checking the count for Q5
SELECT 
    p.patient_group, count(*) as total_count,
    COUNT(CASE WHEN q."Q5_Constipation"= 'true' THEN 1 END) AS true_count,
    COUNT(CASE WHEN q."Q5_Constipation"= 'false' THEN 1 END) AS false_count
FROM public.new_questionnaire_responses AS q
JOIN public.patient_data AS p ON p.patient_id = q.patient_id
GROUP BY p.patient_group;

SELECT "Q5_Constipation",count(*)
FROM public.new_questionnaire_responses AS q
JOIN public.patient_data AS p ON p.patient_id = q.patient_id
group by 1;

SELECT "Q7_Incomplete_Bowel",count(*)
FROM public.new_questionnaire_responses AS q
JOIN public.patient_data AS p ON p.patient_id = q.patient_id
group by 1;

SELECT "Q11_Weight_Change",count(*)
FROM public.new_questionnaire_responses AS q
JOIN public.patient_data AS p ON p.patient_id = q.patient_id
group by 1;

select * from public.new_questionnaire_responses
where patient_id = 90

---checking the column from questionnaire_responses table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'questionnaire_responses'
  AND table_schema = 'public';

--checkin the question count for each subject id in questionnaire_responses table 
SELECT subject_id, link_id, COUNT(DISTINCT question) 
FROM public.questionnaire_responses 
GROUP BY subject_id, link_id
HAVING COUNT(DISTINCT question) < (SELECT COUNT(DISTINCT question) FROM public.questionnaire_responses);


select * from public.questionnaire_responses