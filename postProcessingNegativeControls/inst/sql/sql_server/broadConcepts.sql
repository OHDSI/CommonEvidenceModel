IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

SELECT *
INTO @storeData
FROM @conceptUniverseData c1
WHERE PERSON_COUNT >= 1000000
OR UPPER(c1.CONCEPT_NAME) LIKE '%FINDING%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%DISORDER OF%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%INJURY%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%DEAD%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%SYMPTOMS%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%DISEASE OF%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%BY SITE'
OR UPPER(c1.CONCEPT_NAME) LIKE '%BY BODY SITE'
OR UPPER(c1.CONCEPT_NAME) LIKE '%BY MECHANISM'
OR UPPER(c1.CONCEPT_NAME) LIKE '%OF BODY REGION%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%OF SPECIFIC BODY STRUCTURE%'
OR c1.CONCEPT_ID IN (
  select ancestor_concept_id
  from @vocabulary.concept_ancestor ca
  	JOIN @vocabulary.concept c
  		on ca.ancestor_concept_id = c.concept_id
  		AND UPPER(c.STANDARD_CONCEPT) = 'S'
  WHERE UPPER(c.domain_id) = 'CONDITION'
  group  by concept_name, ancestor_concept_id
  having count(*) > 45
)
OR c1.CONCEPT_ID IN (
  	313878, /*Respiratory symptom*/
  	198194, /*Female genital organ symptoms*/
  	135033, /*Hair and hair follicle diseases*/
  	443949, /*Disease type AND/OR category unknown*/
  	4272240,	/*Malaise*/
    4309912,	/*Generally unwell*/
    4047120,	/*Disorders of attention and motor control*/
    436222,	/*Altered mental status*/
    443403,	/*Sequela*/
    77673,	/*Sign or symptom of the urinary system*/
    4164707,	/*Canceled operative procedure*/
    40490404,	/*Adverse reaction to biological substance*/
    437758,	/*Dependence on enabling machine or device*/
    4106092,	/*Carrier of disorder*/
    4036154,	/*Comfort alteration*/
    433600,	/*Problem, abnormal test*/
    40492403,	/*Superficial foreign body*/
    433656,	/*Abnormal patient reaction*/
    4192174,	/*Illness*/
    4022204,	/*Effect of foreign body*/
    4031958,	/*Trace element excess*/
    4221798,	/*Allergic disorder by allergen type*/
    440005, /*Complication of medical care*/
    4201705,	/*Sequela of disorder*/
    4102111,	/*Mass of body structure*/
    4339468,	/*Ear, nose and throat disorder*/
    4208786,	/*Musculoskeletal and connective tissue disorder*/
    4266186,	/*Neoplasm and/or hamartoma*/
    4134440,	/*Visual system disorder*/
    252662,	/*Tracheobronchial disorder*/
    432586,	/*Mental disorder*/
    4160062,	/*Disorder characterized by pain*/
    4090739,	/*Nutritional disorder*/
    4180154,	/*Female reproductive system disorder*/
    442019,	/*Complication of procedure*/
    4113999,	/*Mass of body region*/
    438112,	/*Neoplastic disease*/
    4178431,	/*Cartilage disorder*/
    40481517,	/*Mass of soft tissue*/
    444208,	/*Chronic inflammatory disorder*/
    435227,	/*Nutritional deficiency disorder*/
    4028244,	/*Chronic disease of cardiovascular system*/
    4288734,	/*Bronchiolar disease*/
    4134595,	/*Chronic disease of genitourinary system*/
    4024558,	/*Disorder associated with menstruation AND/OR menopause*/
    4018852,	/*Acute genitourinary disorder*/
    440059,	/*Recurrent disease*/
    4134593,	/*Chronic digestive system disorder*/
    4168498,	/*Deformity*/
    4022830,	/*General problem AND/OR complaint*/
    4116964,	/*Mass of musculoskeletal structure*/
    4180645,	/*Connective tissue disorder by body site*/
    4134596,	/*Chronic mental disorder*/
    4145825,	/*Anorectal disorder*/
    378444,	/*Hearing disorder*/
    45772120,	/*Gastroduodenal disorder*/
    4115105,	/*Mass of respiratory structure*/
    436677,	/*Adjustment disorder*/
    4051956,	/*Vulvovaginal disease*/
    432250,	/*Disorder due to infection*/
    4134294,	/*Acute inflammatory disease*/
    43021226,	/*Hypersensitivity condition*/
    4168335,	/*Wound*/
    4028367,	/*Acute disease of cardiovascular system*/
    40488439,	/*Abnormality of systemic vein*/
    4239975,	/*Myocardial disease*/
    4338120,	/*Altered bowel function*/
    376961,	/*Disturbance of consciousness*/
    434621,	/*Autoimmune disease*/
    443240,	/*Collapse*/
    4167096,	/*Bone inflammatory disease*/
    444201,	/*Post-infectious disorder*/
    432585,	/*Blood coagulation disorder*/
    135526,	/*Spinal cord disease*/
    4116208,	/*Choroidal and/or chorioretinal disorder*/
    444199,	/*Iatrogenic disorder*/
	  4181217,	/*Sequelae of disorders classified by disorder-system*/
	  4206460	/*Problem*/
);
