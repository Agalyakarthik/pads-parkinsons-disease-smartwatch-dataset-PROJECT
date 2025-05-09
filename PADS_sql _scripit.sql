---create table for patient_data
CREATE TABLE patient_data (
    resource_type TEXT,
    id TEXT PRIMARY KEY,
    study_id TEXT,
    condition TEXT,
    disease_comment TEXT,
    age_at_diagnosis INT,
    age INT,
    height FLOAT,
    weight FLOAT,
    gender TEXT,
    handedness TEXT,
    appearance_in_kinship BOOLEAN,
    appearance_in_first_grade_kinship BOOLEAN,
    effect_of_alcohol_on_tremor TEXT
);

SELECT version();
SELECT * FROM public.patient_data

-----create table for questionnarie_responses
CREATE TABLE questionnaire_responses (
    resource_type TEXT,
    subject_id TEXT,
    study_id TEXT,
    questionnaire_id TEXT,
    questionnaire_name TEXT,
    link_id TEXT,
    question TEXT,
    answer BOOLEAN
);


SELECT * FROM public.questionnaire_responses

SELECT subject_id, COUNT(*) FROM questionnaire_responses GROUP BY subject_id order by subject_id;

-------create table for movement_data
CREATE TABLE IF NOT EXISTS movement_data (
        id SERIAL PRIMARY KEY,
        subject_id TEXT,
        study_id TEXT,
        device_id TEXT,
        record_id TEXT,
        record_name TEXT,
        rows INTEGER,
        device_location TEXT,
        time FLOAT,
        accelerometer_x FLOAT,
        accelerometer_y FLOAT,
        accelerometer_z FLOAT,
        gyroscope_x FLOAT,
        gyroscope_y FLOAT,
        gyroscope_z FLOAT
    )

SELECT * FROM public.movement_data