/*
Winnenburg R, Sorbello A, Ripple A, Harpaz R, Tonning J, Szarfman A, Francis
H, Bodenreider O. Leveraging MEDLINE indexing for pharmacovigilance - Inherent
limitations and mitigation strategies. J Biomed Inform. 2015 Oct;57:425-35. doi: 
10.1016/j.jbi.2015.08.022. Epub 2015 Sep 2. PubMed PMID: 26342964; PubMed Central
PMCID: PMC4775467.
*/

/*Typically, ADEs are identified by the co-occurrence of a drug descriptor qualified by adverse effects and a disease descriptor qualified by chemically induced*/
/*Whils the method is generally similar to Avillach's, this tends to be more aggressive and goes beyond the simple co-occurrence of descriptors-qualifier pairs*/

/*IMPROVEMENT #1*/
/*2.1 The following MeSH terms imply denoting the chemically induced qualifier*/
SELECT *
FROM staging_medline.mesh_term
WHERE UI IN (
'D056486','D004893','D013262','D004409','D004409','D055963','D000014','D003875','D017109','D020230','D009459','D064807','D063926','D056487','D060831','D020267','D011605','D056150','D064146','D020258'
)
ORDER BY NAME

/*IMPROVEMENT #2*/
/*2.2 ADE citations should consider not only the qualifier adverse effects, but also the qualifiers it subsumes*/
SELECT *
FROM staging_medline.medcit_meshheadinglist_meshheading_qualifiername 
WHERE ui IN (
	'Q000009', /*adverse effects*/
	'Q000506', /*poisoning*/
	'Q000633', /*toxivity*/
	'Q000744'  /*contraindications*/
)
LIMIT 10

/*IMPROVEMENT #3*/
/*2.3 the ADE context is sometimes borne by a broader term rather than the drug of interest*/
/*Already doing in our Avillach, however we can probably do a better job of describing when this happens and when it doesn't*/
--https://github.com/OHDSI/CommonEvidenceModel/tree/master/evidenceProcessingClean/inst/sql/sql_server#L80

/*IMPROVEMENT #4*/
--Storing "JOURNAL ARTICLE" is probably not informative from PUBLICATION_TYPES.

/*IMPROVEMENT #???*/
/*Some MeSH tags are used for more than one drug, however I'm not sure how we can handle this wholistically*/

/*IMPROVEMENT #???*/
/*2.7 Rule of 3 - a group of three or more specific descriptors must be replaced by one more general descriptor*/
--Maybe this could be where we text string search the title for the description.  If we have a descriptor but no other drugs specific tags look for text in title.
--However the Improvment #3 might help here

/*IMPROVEMENT #???*/
/*Leverage the RxNorm API to map the MeSH terms to RxNorm*/
/*We currently do this with UMLS, which I think is good enough*/

/*IMPROVEMENT #???*/
/*Collect meta data like epi methods and gender*/
/*We do some of this already just not as much as they do*/

/*NOTES*/
--Looks like animal studies are included on their side, we would like to exclude this.

--i/c = involved/concomitant -- involved drugs have some sort of AE qualifier, while concomitant drugs do not (concomitant drugs should not be considered linked to ADEs).
