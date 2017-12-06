################################################################################
# CONNECTIONS
################################################################################
#Connection
config <- read.csv("extras/config.csv",as.is=TRUE)[1,]

Sys.setenv(dbms = config$dbms)
Sys.setenv(user = config$user)
Sys.setenv(pw = config$pw)
Sys.setenv(server = config$server)
Sys.setenv(port = config$port)
Sys.setenv(vocabulary = config$vocabulary)
Sys.setenv(clean = config$evidenceProcessingClean)
Sys.setenv(translated = config$evidenceProcessingTranslated)
Sys.setenv(evidence = config$postProcessing)
rm(config)

#connect
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("dbms"),
  server = Sys.getenv("server"),
  port = as.numeric(Sys.getenv("port")),
  user = Sys.getenv("user"),
  password = Sys.getenv("pw")
)
conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

#connect
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("dbms"),
  server = Sys.getenv("server"),
  port = as.numeric(Sys.getenv("port")),
  user = Sys.getenv("user"),
  password = Sys.getenv("pw")
)
conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

#Used when connecting to patient data to inform raw data pull
patient_config <- read.csv("extras/config_patient_data.csv",as.is=TRUE)[1,]
Sys.setenv(patient_dbms = patient_config$dbms)
Sys.setenv(patient_user = patient_config$user)
Sys.setenv(patient_pw = patient_config$pw)
Sys.setenv(patient_server = patient_config$server)
Sys.setenv(patient_port = patient_config$port)
Sys.setenv(patient_schema = patient_config$schema)
rm(patient_config)

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("patient_dbms"),
  server = Sys.getenv("patient_server"),
  port = as.numeric(Sys.getenv("patient_port"))#,
  #user = Sys.getenv("patient_user"),
  #password = Sys.getenv("patient_pw")
)
connPatientData <- DatabaseConnector::connect(connectionDetails = connectionDetails)

library(postProcessingNegativeControls)

################################################################################
# VARIABLES
################################################################################
sourceData <- paste0(Sys.getenv("patient_schema"),".dbo")
vocabulary <-"VOCABULARY.dbo"
fqSTCM <- paste0(vocabulary,".CEM_SOURCE_TO_CONCEPT_MAP")

faers <- paste0(Sys.getenv("translated"),".AEOLUS")
splicer <- paste0(Sys.getenv("translated"),".SPLICER")

conceptUniverseData <- paste0(Sys.getenv("evidence"),".NC_CONCEPT_UNIVERSE")
conceptsToExcludeData <- paste0(Sys.getenv("evidence"),".NC_EXCLUDED_CONCEPTS")
conceptsToIncludeData <- paste0(Sys.getenv("evidence"),".NC_INCLUDED_CONCEPTS")
indicationData <- paste0(Sys.getenv("evidence"),".NC_INDICATIONS")
evidenceData <- paste0(Sys.getenv("evidence"),".NC_EVIDENCE")
broadConceptsData <- paste0(Sys.getenv("evidence"),".NC_BROAD_CONDITIONS")
drugInducedConditionsData <- paste0(Sys.getenv("evidence"),".NC_DRUG_INDUCED_CONDITIONS")
pregnancyConditionData <- paste0(Sys.getenv("evidence"),".NC_PREGNANCY_CONDITIONS")
safeConceptData <- paste0(Sys.getenv("evidence"),".NC_SAFE_CONCEPTS")
splicerConditionData <- paste0(Sys.getenv("evidence"),".NC_SPLICER_CONDITIONS")
faersConceptsData <- paste0(Sys.getenv("evidence"),".NC_FAERS_CONCEPTS")
summaryData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY")


################################################################################
# CONFIG
################################################################################
outcomeOfInterest <- 'condition'
conceptsOfInterest <- '932745,956874,942350'
conceptsToExclude <- '23567,24970,25068,25297,26286,26711,26908,28060,73372,74472,74719,75065,75652,75689,76492,78200,78838,79864,79908,80070,132277,133299,134732,137520,138255,192952,193326,193431,193522,193587,193818,193871,193874,194418,194598,194687,194696,194802,195307,195581,195588,195598,195856,196152,196469,197028,197033,197040,197239,197675,197857,197928,198528,199063,199067,199767,199867,200154,200445,200461,201613,201916,254387,255348,259043,259874,261782,261895,313459,313928,315078,315361,317009,318459,321822,374335,374882,374952,376065,376132,376416,377821,378427,379020,379801,380100,380724,381003,381024,381308,381581,432580,432668,433163,433435,433467,433531,434334,434630,434654,434688,434821,434891,434904,434942,434951,434953,435216,435238,435371,435781,436070,436080,436100,436470,436741,436785,437260,437316,437390,437854,437969,438114,438760,438827,438990,439007,439081,439150,439708,439787,440092,440360,440418,440436,440516,440676,440748,441488,441563,441868,442124,442147,443082,443252,443259,443285,443366,443393,443464,443528,443593,443728,443732,443757,444066,444285,4002341,4004309,4006964,4008556,4009650,4012113,4024266,4026125,4027701,4027866,4028970,4029271,4029274,4029305,4029581,4029726,4030908,4031955,4032530,4033295,4035007,4035987,4043001,4044240,4044391,4044708,4046075,4050086,4050884,4051488,4052837,4053008,4053597,4054527,4054827,4054828,4054848,4056780,4061735,4062175,4062223,4065364,4065997,4066421,4068232,4069540,4071164,4080994,4082164,4083353,4084167,4086243,4089963,4090248,4090255,4090425,4090706,4096201,4096643,4097132,4100788,4101056,4101067,4101284,4101367,4101563,4101639,4102114,4102562,4102614,4103032,4103327,4104000,4104536,4110492,4110860,4111953,4112735,4112878,4113121,4113129,4113577,4114039,4114353,4115107,4115258,4115282,4116574,4116962,4117276,4124650,4129143,4129243,4129244,4129246,4129383,4129884,4130022,4130032,4130040,4130046,4130672,4130676,4131105,4131446,4131447,4131448,4131451,4131455,4131457,4131745,4131780,4131905,4132314,4133353,4137468,4138403,4141640,4142875,4142899,4146209,4148456,4149084,4150042,4151134,4151209,4151524,4151990,4152165,4152934,4155482,4155516,4156941,4159366,4160231,4161410,4164436,4167363,4169809,4171394,4171556,4172646,4173734,4175787,4176754,4176868,4177067,4177483,4177944,4178874,4179145,4181960,4182008,4182009,4182010,4182168,4182643,4182966,4184089,4184091,4185031,4185034,4185036,4185976,4186437,4188155,4194792,4194981,4197065,4198126,4198513,4201883,4203097,4205375,4205810,4206592,4212562,4214297,4227607,4228816,4229392,4230641,4232324,4234083,4238978,4241146,4241538,4242338,4242875,4242980,4243821,4243823,4245842,4246495,4248277,4252861,4253315,4254781,4261933,4263577,4263898,4264617,4266864,4269209,4269221,4279461,4283689,4286030,4286497,4287787,4288544,4290837,4290877,4294393,4300116,4303664,4305841,4307801,4308074,4308096,4310238,4313723,4314958,4315934,4315952,4315953,4316615,4317551,4318546,4319325,4322945,4325344,4328026,4328350,4328804,4331815,4338958,4340397,4344027,4344273,4347310,36712690,36716000,36716623,36716871,36717482,37016195,37017539,37396727,40304526,40480875,40481372,40481632,40481843,40481857,40481907,40482260,40482713,40483183,40483714,40486464,40486678,40487030,40490423,40491510,42709799,42709838,42709844,43530717,43531045,44782778,44783159,45757269,45757434,45757649,45757656,45763790,45763814,45770917,45772100,46273430,46273829'
conceptsToInclude <- '434005,4134455,437264,136788,141825,4155902,136661,4167354,139099,4266367,4216771,138384,373478,440329,201606,80951,4193169,4291005,4085100,133727,378424,432730,4173025,433527,4088920,432798,374044,4088290,4248728,4273391,4296205,4092565,440693,374923,201728,134718,4179823,45757488,76797,434327,376981,437784,198715,4187659,377294,436581,4241530,79884,141508,4019094'
fileName <-paste0("NEGATIVE_LOOP_DIURETICS_",Sys.Date(),".xlsx")

################################################################################
# FIND POTENTIAL CONCEPTS
################################################################################
#For a given concept of interest, find concepts after to be used for the
#outcome of interest
conceptUniverse <- findConceptUniverse(connPatientData=connPatientData,
                                       schemaRaw=sourceData,
                                       conn=conn,
                                       storeData=conceptUniverseData,
                                       outcomeOfInterest=outcomeOfInterest,
                                       conceptsOfInterest = conceptsOfInterest)

################################################################################
# FIND CONDITIONS OF INTEREST
################################################################################

#BROAD CONDITIONS
findConcepts(conn = conn,
             storeData = broadConceptsData,
             vocabulary=vocabulary,
             conceptUniverseData=conceptUniverseData,
             sqlFile="broadConcepts.sql")

#DRUG RELATED
findConcepts(conn = conn,
             storeData = drugInducedConditionsData,
             conceptUniverseData=conceptUniverseData,
             sqlFile="drugRelatedConditions.sql")

#PREGNANCY
findConcepts(conn = conn,
             storeData = pregnancyConditionData,
             conceptUniverseData=conceptUniverseData,
             sqlFile="pregnancyConditions.sql")

#SPLICER
findSplicerConditions(conn=conn,
                    storeData=splicerConditionData,
                    splicerData=splicer,
                    sqlFile="splicerConditions.sql",
                    conceptsOfInterest=conceptsOfInterest,
                    vocabulary=vocabulary)

#FIND INDICATIONS
findDrugIndications(conn=conn,
                    storeData=indicationData,
                    vocabulary=vocabulary,
                    conceptsOfInterest=conceptsOfInterest,
                    outcomeOfInterest=outcomeOfInterest)

#USER IDENTIFIED CONCEPTS TO EXCLUDE
findConcepts(conn = conn,
             storeData = conceptsToExcludeData,
             vocabulary=vocabulary,
             concepts=conceptsToExclude,
             expandConcepts=1)

#USER IDENTIFIED CONCEPTS TO INCLUDE
findConcepts(conn = conn,
             storeData = conceptsToIncludeData,
             vocabulary=vocabulary,
             concepts=conceptsToInclude)

#FAERS
findFaersADRs(conn = conn,
              faersData = faers,
              storeData = faersConceptsData,
              vocabulary=vocabulary,
              conceptsOfInterest=conceptsOfInterest,
              outcomeOfInterest = outcomeOfInterest)
