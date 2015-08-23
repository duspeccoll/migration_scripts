# Migration scripts

Here are our migration scripts for moving from Re:Discovery to ArchivesSpace. Each XSLT document transforms one ArchivesSpace JSON model and/or level of description from the Re:Discovery source XML (as defined by us) to the ArchivesSpace metadata rules, and saves each record as an individual JSON object. From there they were posted through the ArchivesSpace backend.

Basic guidelines:
* Every Re:Discovery XML export consists of <RediscoveryExport> wrappers, one per record, in which all of the metadata elements are contained; these are wrapped in turn in a <NewDataSet> wrapper.
* Each of the XSLTs is a for-each loop, where each field within the <RediscoveryExport> is mapped to something in the ArchivesSpace schemas.

Very optimized for DU's experience and metadata decisions. I haven't commented much of the code or tried to generalize it for other users (Re:Discovery or otherwise). I'll be working on this.

Questions? E-mail kevin.clair@du.edu.
