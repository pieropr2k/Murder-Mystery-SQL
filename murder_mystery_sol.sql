--- These are the schema of each table from all of the database:

--- crime_scene_report
--- date	|   type    |    description    |   city

--- drivers_license
--- id   |   age   |   height   |   eye_color   |   hair_color   |   gender   |   plate_number   |   car_make   |   car_model

--- facebook_event_checkin
--- person_id   |   event_id   |   event_name   |   date

--- get_fit_now_member
--- id   |   person_id   |   name   |   membership_start_date   |   membership_status

--- get_fit_now_check_in
--- membership_id   |   check_in_date   |   check_in_time   |   check_out_time

--- income
--- ssn   |   annual_income

--- interview
--- person_id	|   transcript

--- person
--- id   |   name   |   license_id   |   address_number   |   address_street_name   |   ssn


--- Who is the murderer? First read the PDF given in the repo

--- First you must filter the database using the PDF info
--- then you must read what the crime_scene_report description says to find some clues

SELECT description FROM crime_scene_report 
WHERE CONVERT(VARCHAR, type) = 'murder' 
AND CONVERT(VARCHAR, city) = 'SQL City' 
AND date = 20180115

---Description:
---Security footage shows that there were 2 witnesses. 
---The first witness lives at the last house on "Northwestern Dr". 
---The second witness, named Annabel, lives somewhere on "Franklin Ave".


--- You must relate the person table (witness info) with the interview table
--- and find what the transcript of the interview says

--- First witness:
--- person_id : 14887

SELECT TOP 1 interview.transcript FROM 
(SELECT * FROM person 
WHERE CONVERT(VARCHAR, address_street_name) = 'Northwestern Dr') AS suspicious
INNER JOIN interview
ON suspicious.id = interview.person_id
ORDER BY address_number DESC

--- Transcription content:
--- I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".


--- Second witness:
--- person_id : 16371

SELECT transcript FROM 
(SELECT * FROM person 
WHERE CONVERT(VARCHAR, name) LIKE 'Annabel%'
AND CONVERT(VARCHAR, address_street_name) = 'Franklin Ave') AS suspicious
INNER JOIN interview
ON suspicious.id = interview.person_id

--- Transcription content:
--- I saw the murder happen, and I recognized the killer from my gym when I was working out last week on ---January the 9th.



--- Now you must use the info given from the 2 transcriptions 
--- and search respect from this in the database.

--- I've searched in the get_fit_now_check_in but there's nothing important there

SELECT * FROM get_fit_now_check_in
WHERE CONVERT(VARCHAR, membership_id) LIKE '48Z%'
AND check_in_date = 20180109


--- Finally to find the murderer you must make a subquery 
--- where you join the person table with the drivers_license table 
--- with the info given in the transcription/interviews
--- then you join this subquery with the get_fit_now_member table with more of the info.
--- And the murderer is Jeremy Bowers

SELECT get_fit_now_member.person_id, get_fit_now_member.name, license_subquery.plate_number
FROM get_fit_now_member
INNER JOIN 
(SELECT person.id AS person_id, person.license_id, person.name, gender, plate_number, person.ssn 
FROM drivers_license
INNER JOIN person
ON person.license_id = drivers_license.id
WHERE CONVERT(VARCHAR, drivers_license.plate_number) LIKE '%H42W%')
AS license_subquery
ON license_subquery.person_id = get_fit_now_member.person_id
WHERE CONVERT(VARCHAR, get_fit_now_member.membership_status) = 'gold'
