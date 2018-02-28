CTD staging data load process
===================================

Background
----------
This is the Comparative Toxicogenomics Database (CTD) staging data load process.

DATA CITATION:
Curated chemical–disease data were retrieved from the Comparative Toxicogenomics Database (CTD), MDI Biological Laboratory, Salisbury Cove, Maine, and NC State University, Raleigh, North Carolina. World Wide Web (URL: http://ctdbase.org/). [February, 2018]

------------------------------------------------------------
LEGAL NOTICES:
Legal Notices
The Comparative Toxicogenomics DatabaseTM (CTDTM) is provided to enhance knowledge and encourage progress in the scientific community. It is to be used only for research and educational purposes. Medical treatment decisions should not be made based on the information in CTD.

Any reproduction or use for commercial purpose is prohibited without the prior express written permission of the MDI Biological Laboratory and NC State University.

This data and software are provided “as is”, “where is” and without any express or implied warranties, including, but not limited to, any implied warranties of merchantability and/or fitness for a particular purpose, or any warranties that use will not infringe any third party patents, copyrights, trademarks or other rights. In no event shall the MDI Biological Laboratory nor NC State University, nor their agents, employers or representatives be liable for any direct, indirect, incidental, special, exemplary, or consequential damages however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way or form out of the use of this data or software, even if advised of the possibility of such damage.

THE COMPARATIVE TOXICOGENOMICS DATABASE and CTD are trademarks of the MDI Biological Laboratory and NC State University. All rights reserved.

Copyright 2002-2012 MDI Biological Laboratory. All rights reserved.

Copyright 2012-2016 MDI Biological Laboratory & NC State University. All rights reserved.

Additional Terms of Data Use
Use of CTD data is subject to the following additional terms:

All forms of publication (e.g., web sites, research papers, databases, software applications, etc.) that use or rely on CTD data must cite CTD. Please follow our citation guidelines.
All electronic or online applications must include hyperlinks from contexts that use CTD data to the applicable CTD data pages. Please refer to our linking instructions.
You must notify CTD and describe your use of our data.
For quality control purposes, you must provide CTD with periodic access to your publication of our data.
NLM Terms
Data from the U.S. National Library of Medicine (NLM) are provided pursuant to the following terms:

NLM represents that its data were formulated with a reasonable standard of care. Except for this representation, NLM makes no representation or warranties, expressed or implied. This includes, but is not limited to, any implied warranty of merchantability or fitness for a particular purpose, with respect to the NLM data, and NLM specifically disclaims any such warranties and representations.

NLM databases are produced by a U.S. Government agency and as such are not protected by US copyright laws. Use of the databases outside the United States may be governed by applicable foreign copyright laws.

All complete or parts of NLM-derived records that are redistributed or retransmitted must be identified as being derived from NLM databases. Examples are: “From MEDLINE®/PubMed®, a database of the U.S. National Library of Medicine.” and “MeSH Headings from MEDLINE®/PubMed®, a database of the U.S. National Library of Medicine.”

Some material in the NLM databases derives from copyrighted publications. Publishers and/or authors often claim copyright on the abstracts in MEDLINE®/PubMed®. Refer to the publication data appearing in the citations, as well as to the copyright notices appearing in the original publications, all of which are hereby incorporated by reference. Users of the NLM databases are solely responsible for compliance with fair use guidelines and applicable copyright restrictions. Users should consult legal counsel before using NLM-produced records to be certain that their plans are in compliance with appropriate laws.

CAS Registry Number
CAS Registry Number is a Registered Trademark of the American Chemical Society.

------------------------------------------------------------
INSTRUCTIONS TO RETRIEVE THE DATA:

(1) Go to http://ctdbase.org
(2) Click on "Download", then on "Data Files" from the dropdown
    menu.
(3) Scroll down to "Chemical-disease associations".
(4) Click on and download "CTD_chemicals.tsv.gz".
(5) Extract the file "CTD_chemicals.tsv" to the CTD_chemicals_diseases.tsv in folder you want.



Table(s) loaded
---------------
staging_ctd.ctd_chemical_disease

Instructions
------------
1. Load the Pentaho job in the Pentaho Spoon client.
2. Update the file name in the URL variable within the "set job variables" step.
3. Save the job.
4. Run the job.

