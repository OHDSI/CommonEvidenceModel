DROP SCHEMA IF EXISTS staging_sherlock CASCADE;
CREATE SCHEMA staging_sherlock;

SET SEARCH_PATH = staging_sherlock;

CREATE TABLE Analysis
(
    AnalysisGroup1         int,
    AnalysisGroup2         int,
    StudyOutcomeID         int NOT NULL,
    AnalysisDescription    text,
    NonInferiority         bit,
    NonInferiorityComments text,
    PValue                 varchar(50),
    PValueComments         text,
    Method                 varchar(450),
    MethodComments         text,
    EstimationParameter    text,
    EstimatedValue         float,
    DispersionType         text,
    DispersionValue        float,
    CILevel                float,
    CINumberOfSides        int,
    CILowerLimit           float,
    CIUpperLimit           float,
    EstimateDescription    text,
    ID                     int NOT NULL,
    TotalNumberOfGroups    int NOT NULL
);


CREATE TABLE Arm
(
    ArmID           int  NOT NULL,
    StudyID         int  NOT NULL,
    ArmLabel        text NOT NULL,
    ArmTitle        text,
    ArmDescription  text,
    ArmType         varchar(450),
    ArmSource       varchar(450),
    IsDoseProcessed bit  NOT NULL
);


CREATE TABLE ArmDose
(
    ArmDoseID           int   NOT NULL,
    ArmID               int   NOT NULL,
    InterventionAliasID int   NOT NULL,
    Dose                text,
    MaxStrength         float,
    MaxStrengthUnit     text,
    Concentration       text,
    ConcentrationUnit   text,
    Frequency           text,
    Exposure            text,
    Route               text,
    Source              varchar(450),
    Score               float NOT NULL
);


CREATE TABLE ArmIntervention
(
    ArmID          int NOT NULL,
    InterventionID int NOT NULL
);


CREATE TABLE ArmInterventionAlias
(
    ArmID               int NOT NULL,
    InterventionAliasID int NOT NULL,
    Score               float,
    Trace               text,
    Source              varchar(50)
);


CREATE TABLE ArmStats
(
    ArmID                int NOT NULL,
    NumberOfParticipants int,
    AgeMean              float,
    AgeStdev             float,
    AgeDescription       text,
    PercentMale          float,
    PercentFemale        float
);


CREATE TABLE ArmType
(
    ArmTypeID       int  NOT NULL,
    ArmID           int  NOT NULL,
    ArmType         text NOT NULL,
    "Rule"          text NOT NULL,
    RuleID          int  NOT NULL,
    RuleDescription text NOT NULL
);


CREATE TABLE Baseline
(
    BaselineID             int  NOT NULL,
    BaselineTitle          text NOT NULL,
    MeasureParam           varchar(900),
    MeasureDispersion      text,
    MeasureUnits           text,
    StudyID                int  NOT NULL,
    BaselineDescription    text,
    DemographicsID         int,
    DemographicsStatus     int,
    MeasureUnitsNormalized varchar(450),
    MeasurePopulation      text,
    UnitsAnalyzed          varchar(100)
);


CREATE TABLE BaselineAnalyzed
(
    BaselineAnalyzedID int NOT NULL,
    GroupID            int NOT NULL,
    Units              varchar(100),
    Scope              varchar(100),
    Value              float
);


CREATE TABLE BaselineMeasure
(
    GroupID           int NOT NULL,
    CategoryTitle     text,
    Value             float,
    Spread            float,
    BaselineMeasureID int NOT NULL,
    UpperLimit        float,
    LowerLimit        float,
    BaselineID        int NOT NULL
);


CREATE TABLE BaselineMeasureAnalyzed
(
    BaselineMeasureAnalyzedID int NOT NULL,
    GroupID                   int NOT NULL,
    Units                     varchar(100),
    Scope                     varchar(100),
    Value                     float,
    BaselineID                int NOT NULL
);


CREATE TABLE Condition
(
    ConditionID       int NOT NULL,
    StudyID           int NOT NULL,
    ConditionName     varchar(450),
    NormalizedName    varchar(450),
    TherapeuticAreaId int
);


CREATE TABLE ConditionUmls
(
    ConditionUmlsID int          NOT NULL,
    ConditionID     int,
    PTSTR           varchar(450) NOT NULL,
    PTSAB           varchar(50),
    PTCUI           varchar(50),
    PTAUI           varchar(50),
    MatchAUI        nchar(50),
    MatchSTR        varchar(450),
    MatchType       varchar(50),
    Score           float        NOT NULL,
    CODE            varchar(50),
    OmopConceptID   int,
    Trace           text,
    PTSTY           varchar(450)
);


CREATE TABLE Coop
(
    StudyID int NOT NULL,
    Text    text
);


CREATE TABLE Demographics
(
    DemographicsID int          NOT NULL,
    DGMeasureTitle varchar(450) NOT NULL
);


CREATE TABLE EventReporting
(
    EventReportingID     int NOT NULL,
    StudyID              int NOT NULL,
    ReportingTimeFrame   text,
    ReportingDescription text,
    FrequencyThreshold   varchar(50)
);


CREATE TABLE EventType
(
    EventTypeID int          NOT NULL,
    OrganSystem varchar(450) NOT NULL
);


CREATE TABLE "group"
(
    GroupID              int  NOT NULL,
    ArmID                int,
    StudyID              int,
    GroupLabel           text NOT NULL,
    GroupTitle           varchar(450),
    GroupDescription     text,
    NumberOfParticipants int,
    Source               varchar(50),
    ArmMapStatus         varchar(450),
    ArmMapScore          float,
    IsDoseProcessed      bit  NOT NULL
);


CREATE TABLE GroupAlias
(
    GroupAliasID  int NOT NULL,
    GroupID       int NOT NULL,
    Alias         text,
    Source        varchar(50),
    RxNormAUI     varchar(50),
    Score         float,
    RxNormCUI     varchar(50),
    RxNormCODE    varchar(50),
    Release       varchar(450),
    Phrase        text,
    OmopConceptID int,
    PhraseSource  varchar(50),
    AliasDomain   text,
    AliasClass    text
);


CREATE TABLE GroupDose
(
    GroupDoseID       int   NOT NULL,
    GroupAliasID      int   NOT NULL,
    Dose              text,
    MaxStrength       float,
    MaxStrengthUnit   text,
    Concentration     text,
    ConcentrationUnit text,
    Frequency         text,
    Exposure          text,
    Route             text,
    Source            varchar(450),
    Score             float NOT NULL
);


CREATE TABLE GroupMapping
(
    Group1ID int   NOT NULL,
    Group2ID int   NOT NULL,
    Score    float NOT NULL
);


CREATE TABLE GroupPeriod
(
    GroupID  int NOT NULL,
    PeriodID int NOT NULL,
    score    float
);


CREATE TABLE Intervention
(
    InterventionID          int  NOT NULL,
    StudyID                 int  NOT NULL,
    InterventionType        text NOT NULL,
    InterventionName        varchar(450),
    InterventionDescription text,
    InterventionOtherNames  text
);


CREATE TABLE InterventionAlias
(
    InterventionAliasID int NOT NULL,
    InterventionID      int NOT NULL,
    Alias               text,
    Source              varchar(50),
    RxNormAUI           varchar(50),
    Score               float,
    RxNormCUI           varchar(50),
    RxNormCODE          varchar(50),
    Release             varchar(450),
    Phrase              text,
    OmopConceptID       int,
    PhraseSource        varchar(50),
    AliasDomain         text,
    AliasClass          text
);


CREATE TABLE InterventionAliasAttribute
(
    InterventionAliasID int NOT NULL,
    VocabularyID        int NOT NULL
);


CREATE TABLE Location
(
    LocationID        int NOT NULL,
    StudyID           int NOT NULL,
    Name              varchar(450),
    City              varchar(450),
    State             varchar(450),
    PostalCode        varchar(50),
    Country           varchar(450),
    RecruitmentStatus varchar(450),
    CentralContact    varchar(450)
);


CREATE TABLE MeshTerm
(
    StudyID  int NOT NULL,
    Term     varchar(450),
    Category varchar(450),
    ID       int NOT NULL
);


CREATE TABLE Milestone
(
    ID                int  NOT NULL,
    PeriodID          int  NOT NULL,
    GroupID           int  NOT NULL,
    MilestoneTitle    text NOT NULL,
    MilestoneCount    int  NOT NULL,
    MilestoneComments text
);


CREATE TABLE NotCompleted
(
    ID                 int NOT NULL,
    PeriodID           int NOT NULL,
    GroupID            int NOT NULL,
    NotCompletedReason varchar(250),
    NotCompletedCount  int NOT NULL,
    NotCompletedClass  varchar(400)
);


CREATE TABLE Outcome
(
    OutcomeID              int NOT NULL,
    StudyID                int NOT NULL,
    OutcomeType            varchar(450),
    OutcomeTitle           text,
    OutcomeDescription     text,
    TimeFrame              text,
    SafetyIssue            bit,
    Population             text,
    MeasureParam           varchar(450),
    MeasureDispersion      text,
    MeasureUnits           varchar(450),
    PostingDate            timestamp,
    MeasureUnitsNormalized varchar(450),
    MeasurePopulation      text,
    UnitsAnalyzed          varchar(100)
);


CREATE TABLE OutcomeMeasure
(
    OutcomeMeasureID        int NOT NULL,
    GroupID                 int NOT NULL,
    CategoryTitle           varchar(450),
    Value                   float,
    Spread                  float,
    OutcomeID               int NOT NULL,
    UpperLimit              varchar(50),
    LowerLimit              varchar(50),
    TimeFrame               float,
    TimeUnit                varchar(10),
    OutcomeClass            varchar(450),
    ChangeFromBaseline      bit,
    Scale                   varchar(450),
    Subscale                varchar(450),
    ScaleRange              varchar(450),
    Method                  varchar(450),
    OutcomeClassScore       float,
    ChangeFromBaselineScore float,
    ScaleScore              float,
    SubscaleScore           float,
    ScaleRangeScore         float,
    MethodScore             float,
    BaselineValue           float,
    BaselineSpread          float,
    Category                varchar(450),
    CategoryScore           float
);


CREATE TABLE OutcomeMeasureAnalyzed
(
    OutcomeMeasureAnalyzedID int NOT NULL,
    OutcomeID                int,
    GroupID                  int,
    Units                    varchar(100),
    Scope                    varchar(100),
    Value                    float
);


CREATE TABLE OversightInfo
(
    OversightInfoID      int NOT NULL,
    HasDmc               bit,
    IsFdaRegulatedDrug   bit,
    IsFdaRegulatedDevice bit,
    IsUnapprovedDevice   bit,
    IsPpsd               bit,
    IsUsExport           bit,
    StudyID              int NOT NULL
);


CREATE TABLE PatientData
(
    PatientDataID  int NOT NULL,
    StudyID        int NOT NULL,
    SharingIpd     text,
    IpdDescription text
);


CREATE TABLE Period
(
    PeriodID    int  NOT NULL,
    StudyID     int  NOT NULL,
    PeriodTitle text NOT NULL
);


CREATE TABLE ReportedEvent
(
    GroupID                      int NOT NULL,
    EventTypeID                  int NOT NULL,
    EventReportingID             int NOT NULL,
    SeriousEvent                 bit NOT NULL,
    EventTerm                    varchar(200),
    EventDescription             text,
    NumberOfAffectedParticipants int NOT NULL,
    NumberOfParticipantsAtRisk   int NOT NULL,
    NumberOfEvents               int,
    ID                           int NOT NULL,
    AssessmentType               varchar(450),
    SourceVocabularyName         text
);


CREATE TABLE ReportedEventAttribute
(
    ReportedEventID int NOT NULL,
    VocabularyID    int NOT NULL,
    IsSocMatched    bit NOT NULL,
    Score           float,
    Trace           text
);


CREATE TABLE ResultsReference
(
    Id       int NOT NULL,
    StudyID  int NOT NULL,
    PMID     varchar(50),
    Citation text
);


CREATE TABLE Sponsor
(
    SponsorID   int NOT NULL,
    StudyID     int NOT NULL,
    Agency      varchar(450),
    AgencyClass varchar(450),
    Type        varchar(450),
    Name        varchar(450)
);


CREATE TABLE Study
(
    StudyID                             int          NOT NULL,
    ClinicalTrialsID                    varchar(50)  NOT NULL,
    BriefTitle                          text         NOT NULL,
    Sponsor                             text,
    Summary                             text,
    StudyType                           varchar(450),
    OverallStatus                       varchar(450) NOT NULL,
    StudyPhase                          varchar(450),
    NumberOfArms                        int,
    StudyStartDate                      date,
    PrimaryCompletionDate               date,
    StudyCompletionDate                 date,
    RecordVerificationDate              date         NOT NULL,
    LastUpdateDate                      date         NOT NULL,
    StudyDownloadDate                   date,
    ProtocolReceivedDate                date,
    Enrollment                          int,
    EnrollmentType                      text,
    Source                              varchar(450),
    PreAssignmentDetails                text,
    RecruitmentDetails                  text,
    DetailedDescription                 text,
    TargetDuration                      text,
    Origin                              varchar(50),
    TimeFrame                           float,
    TimeFrameDescription                text,
    FirstReceivedResultsDispositionDate date,
    LastKnownStatus                     varchar(1000)
);


CREATE TABLE StudyAlias
(
    Id               int         NOT NULL,
    StudyID          int         NOT NULL,
    ClinicalTrialsID varchar(50) NOT NULL
);


CREATE TABLE StudyAttribute
(
    AttributeID   int          NOT NULL,
    AttributeName varchar(450) NOT NULL,
    Category      text
);


CREATE TABLE StudyAttributeValue
(
    StudyID     int  NOT NULL,
    AttributeID int  NOT NULL,
    Value       text NOT NULL,
    ID          int  NOT NULL
);


CREATE TABLE StudyDesign
(
    StudyID                int NOT NULL,
    PrimaryPurpose         text,
    InterventionalModel    varchar(450),
    ObservationalModel     varchar(450),
    Masking                text,
    Allocation             varchar(450),
    EndpointClassification varchar(450),
    TimePerspective        text,
    BiospecimenRetention   text,
    BiospecimenDescription text
);


CREATE TABLE StudyDocument
(
    StudyDocumentID int NOT NULL,
    DocumentID      text,
    Type            text,
    Url             text,
    Comment         text,
    StudyID         int NOT NULL
);


CREATE TABLE StudyEligibility
(
    StudyID                  int  NOT NULL,
    StudyPopulation          text,
    SamplingMethod           text,
    InclusionCriteria        text,
    ExclusionCriteria        text,
    Gender                   text NOT NULL,
    MinimumAge               text NOT NULL,
    MaximumAge               text NOT NULL,
    AcceptsHealthyVolunteers bit,
    GenderBased              bit,
    GenderDescription        varchar(4000)
);


CREATE TABLE StudyResults
(
    StudyID                      int NOT NULL,
    FirstReceivedDate            date,
    LastUpdateDate               date,
    OverallLimitationsAndCaveats text,
    HasSeriousEvents             bit
);


CREATE TABLE SubAdverseEvent
(
    ID                                 int          NOT NULL,
    ArmID                              int          NOT NULL,
    GroupID                            int          NOT NULL,
    ReportedEventID                    int,
    ArmLabel                           text         NOT NULL,
    ArmTitle                           text,
    ArmDescription                     text,
    ArmType                            text,
    BriefTitle                         text         NOT NULL,
    Sponsor                            text,
    Summary                            text,
    StudyType                          varchar(450),
    NumberOfArms                       int,
    StudyPhase                         varchar(450),
    LastUpdateDate                     date         NOT NULL,
    Enrollment                         int,
    Source                             varchar(450),
    EnrollmentType                     text,
    OverallStatus                      varchar(450) NOT NULL,
    StudyStartDate                     date,
    StudyCompletionDate                date,
    PrimaryCompletionDate              date,
    ProtocolReceivedDate               date,
    RecordVerificationDate             date         NOT NULL,
    Origin                             varchar(50),
    AgeMean                            float,
    AgeStdev                           float,
    AgeDescription                     text,
    PercentMale                        float,
    PercentFemale                      float,
    GroupTitle                         varchar(450),
    PrimaryPurpose                     text,
    Allocation                         varchar(450),
    InterventionalModel                varchar(450),
    InclusionCriteria                  text,
    ExclusionCriteria                  text,
    StudyID                            int          NOT NULL,
    ClinicalTrialsID                   varchar(50)  NOT NULL,
    AENumberOfParticipants             int,
    AEOther                            int,
    AEOtherPercent                     float,
    AESerious                          int,
    AESeriousPercent                   float,
    EventTerm                          varchar(200),
    EventTermHLT                       text,
    EventTermPT                        text,
    EventTermSOC                       text,
    PeriodTitle                        text,
    GroupDescription                   text,
    InterventionOmopConceptID          text,
    ETC                                text,
    ATC                                text,
    ConditionNames                     text,
    ConditionNormalizedNames           text,
    ConditionOmopConceptID             text,
    StudyAliasNames                    text,
    CollaboratorNames                  text,
    AgencyClass                        varchar(450),
    EventTermPTOmopConceptID           text,
    EventTermHLTOmopConceptID          text,
    EventTermSOCOmopConceptID          text,
    InterventionTypes                  text,
    FrequencyThreshold                 varchar(50),
    ReportingTimeFrame                 text,
    ReportingDescription               text,
    NumberOfEvents                     int,
    AssessmentType                     varchar(450),
    GroupInterventionOmopConceptID     text,
    GroupInterventionRxNORMMapScore    float,
    ConditionSNOMEDMapScore            float,
    InterventionRxNORMMapScore         float,
    EventMedDRAMapScore                float,
    GroupArmMapScore                   float,
    Score                              float,
    ArmGroupInterventionRxNORMMapScore float,
    StudyTimeFrame                     float,
    StudyTimeFrameDescription          text
);


CREATE TABLE Synonym
(
    ID           int  NOT NULL,
    StudyID      int  NOT NULL,
    Abbreviation text NOT NULL,
    Meaning      text NOT NULL,
    Origin       text NOT NULL
);


CREATE TABLE TherapeuticArea
(
    TherapeuticAreaId int          NOT NULL,
    Name              varchar(250) NOT NULL
);


CREATE TABLE Vocabulary
(
    VocabularyID   int          NOT NULL,
    VocabularyName varchar(50)  NOT NULL,
    RecordCode     varchar(50),
    RecordText     varchar(450) NOT NULL,
    RecordId       int
);



