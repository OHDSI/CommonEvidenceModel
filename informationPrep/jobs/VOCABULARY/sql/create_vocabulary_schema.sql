--
-- Database: cem
--

DROP SCHEMA IF EXISTS staging_vocabulary CASCADE;
CREATE SCHEMA IF NOT EXISTS staging_vocabulary;

-- --------------------------------------------------------

--
-- Table structure for table concept
--
DROP TABLE IF EXISTS staging_vocabulary.concept CASCADE;
CREATE TABLE staging_vocabulary.concept
(
    concept_id       integer     NOT NULL,
    concept_name     text        NOT NULL,
    domain_id        varchar(20) NOT NULL,
    vocabulary_id    varchar(20) NOT NULL,
    concept_class_id varchar(20) NOT NULL,
    standard_concept varchar(1) DEFAULT NULL,
    concept_code     varchar(50) NOT NULL,
    valid_start_date date        NOT NULL,
    valid_end_date   date        NOT NULL,
    invalid_reason   varchar(1) DEFAULT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table concept_ancestor
--
DROP TABLE IF EXISTS staging_vocabulary.concept_ancestor CASCADE;
CREATE TABLE staging_vocabulary.concept_ancestor
(
    ancestor_concept_id      integer NOT NULL,
    descendant_concept_id    integer NOT NULL,
    min_levels_of_separation integer NOT NULL,
    max_levels_of_separation integer NOT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table concept_class
--
DROP TABLE IF EXISTS staging_vocabulary.concept_class CASCADE;
CREATE TABLE staging_vocabulary.concept_class
(
    concept_class_id         varchar(20) NOT NULL,
    concept_class_name       text        NOT NULL,
    concept_class_concept_id integer     NOT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table concept_relationship
--

DROP TABLE IF EXISTS staging_vocabulary.concept_relationship CASCADE;
CREATE TABLE staging_vocabulary.concept_relationship
(
    concept_id_1     integer     NOT NULL,
    concept_id_2     integer     NOT NULL,
    relationship_id  varchar(20) NOT NULL,
    valid_start_date date        NOT NULL,
    valid_end_date   date        NOT NULL,
    invalid_reason   varchar(1) DEFAULT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table concept_synonym
--

DROP TABLE IF EXISTS staging_vocabulary.concept_synonym CASCADE;
CREATE TABLE staging_vocabulary.concept_synonym
(
    concept_id           integer NOT NULL,
    concept_synonym_name text    NOT NULL,
    language_concept_id  integer NOT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table domain
--

DROP TABLE IF EXISTS staging_vocabulary.domain CASCADE;
CREATE TABLE staging_vocabulary.domain
(
    domain_id         varchar(20)  NOT NULL,
    domain_name       varchar(255) NOT NULL,
    domain_concept_id integer      NOT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table drug_strength
--

DROP TABLE IF EXISTS staging_vocabulary.drug_strength CASCADE;
CREATE TABLE staging_vocabulary.drug_strength
(
    drug_concept_id             integer NOT NULL,
    ingredient_concept_id       integer NOT NULL,
    amount_value                float      DEFAULT NULL,
    amount_unit_concept_id      integer    DEFAULT NULL,
    numerator_value             float      DEFAULT NULL,
    numerator_unit_concept_id   integer    DEFAULT NULL,
    denominator_value           float      DEFAULT NULL,
    denominator_unit_concept_id integer    DEFAULT NULL,
    box_size                    integer    DEFAULT NULL,
    valid_start_date            date    NOT NULL,
    valid_end_date              date    NOT NULL,
    invalid_reason              varchar(1) DEFAULT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table relationship
--
DROP TABLE IF EXISTS staging_vocabulary.relationship CASCADE;
CREATE TABLE staging_vocabulary.relationship
(
    relationship_id         varchar(20)  NOT NULL,
    relationship_name       varchar(255) NOT NULL,
    is_hierarchical         varchar(1)   NOT NULL,
    defines_ancestry        varchar(1)   NOT NULL,
    reverse_relationship_id varchar(20)  NOT NULL,
    relationship_concept_id integer      NOT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table source_to_concept_map
--
DROP TABLE IF EXISTS staging_vocabulary.source_to_concept_map CASCADE;
CREATE TABLE staging_vocabulary.source_to_concept_map
(
    source_code             varchar(50) NOT NULL,
    source_concept_id       integer     NOT NULL,
    source_vocabulary_id    varchar(20) NOT NULL,
    source_code_description varchar(255) DEFAULT NULL,
    target_concept_id       integer     NOT NULL,
    target_vocabulary_id    varchar(20) NOT NULL,
    valid_start_date        date        NOT NULL,
    valid_end_date          date        NOT NULL,
    invalid_reason          varchar(1)   DEFAULT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table vocabulary
--
DROP TABLE IF EXISTS staging_vocabulary.vocabulary CASCADE;
CREATE TABLE staging_vocabulary.vocabulary
(
    vocabulary_id         varchar(20)  NOT NULL,
    vocabulary_name       varchar(255) NOT NULL,
    vocabulary_reference  varchar(255) NOT NULL,
    vocabulary_version    varchar(255),
    vocabulary_concept_id integer      NOT NULL
);

