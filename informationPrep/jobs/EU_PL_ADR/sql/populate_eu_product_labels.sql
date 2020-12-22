-- fix inconsistent date field formats and one bad age_group record
truncate table staging_eu_pl_adr.eu_product_labels;
insert into staging_eu_pl_adr.eu_product_labels
select product,
       substance,
       to_date(substring(spc_date, 1, 10), 'DD/MM/YYYY'), -- convert '(opinion) date format from ISO format to standard postgres date format
       adr,
       soc,
       hlgt,
       hlt,
       llt,
       meddra_pt,
       pt_code,
       soc_code,
       cast(case age_group when 'o' then '0' else age_group end as integer),
       cast(gender as integer),
       cast(causality as integer),
       cast(frequency as integer),
       cast(class_warning as integer),
       cast(clinical_trials as integer),
       cast(post_marketing as integer),
       comment
from staging_eu_pl_adr.eu_product_labels_original;