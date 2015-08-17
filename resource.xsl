<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

	<xsl:output method="text"/>
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="NewDataSet">
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:variable name="fs">\</xsl:variable>
		<xsl:variable name="fsrep">\\</xsl:variable>
		
		<xsl:for-each select="RediscoveryExport">
			<xsl:variable name="coll" select="Collection_Nbr"/>
			<xsl:result-document href="resource/{$coll}.json" method="text">
				
				<xsl:text>{"jsonmodel_type":"resource","title":</xsl:text>
				<xsl:value-of select="concat($quot,replace(Collection_Title,$quot,$qrep),$quot,',')"/>
				<xsl:text>"id_0":</xsl:text>
				<xsl:value-of select="concat($quot,Collection_Nbr,$quot,',')"/>
				<xsl:text>"level":"collection",</xsl:text>
				<xsl:if test="substring-after(Language,' __') != ''">
					<xsl:text>"language":</xsl:text>
					<xsl:value-of select="concat($quot,substring-after(Language,' __'),$quot,',')"/>
				</xsl:if>
				
				<!-- DATES: -->
				<xsl:text>"dates":[</xsl:text>
				<xsl:if test="Inclusive_Dates">
					<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":"inclusive","expression":</xsl:text>
					<xsl:value-of select="concat($quot,Inclusive_Dates,$quot)"/>
					<xsl:choose>
						<xsl:when test="Bulk_Dates">
							<xsl:text>},</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>}</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="Bulk_Dates">
					<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":"bulk","expression":</xsl:text>
					<xsl:value-of select="concat($quot,Bulk_Dates,$quot)"/>
					<xsl:text>}</xsl:text>
				</xsl:if>
				<xsl:text>],</xsl:text>
				
				<!-- EXTENTS: -->
				<xsl:text>"extents":[</xsl:text>
				<xsl:choose>
					<xsl:when test="Extent">
						<xsl:variable name="ext" select="tokenize(Extent,' __')"/>
						<xsl:variable name="ext_number" select="substring-after($ext[1],'[Extent]')"/>
						<xsl:variable name="ext_unit" select="substring-after($ext[2],'[Unit]')"/>
						<xsl:variable name="ext_note" select="substring-after($ext[3],'[Note]')"/>
						<xsl:text>{"jsonmodel_type":"extent","portion":"whole","number":</xsl:text>
						<xsl:choose>
							<xsl:when test="$ext_number = ''">
								<xsl:text>"0",</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($quot,$ext_number,$quot,',')"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>"extent_type":</xsl:text>
						<xsl:choose>
							<xsl:when test="$ext_unit = 'linear feet' or $ext_unit = 'linear foot' or $ext_unit = ''">
								<xsl:text>"linear_feet",</xsl:text>
							</xsl:when>
							<xsl:when test="$ext_unit = 'item' or $ext_unit = 'items' or $ext_unit = 'Item(s)'">
								<xsl:text>"items",</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"items","physical_details":</xsl:text>
								<xsl:value-of select="concat($quot,$ext_unit,$quot,',')"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>"container_summary":</xsl:text>
						<xsl:value-of select="concat($quot,replace($ext_note,$quot,$qrep),$quot)"/>
						<xsl:text>}</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>{"jsonmodel_type":"extent","portion":"whole","number":"0","extent_type":"linear_feet"}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>],</xsl:text>
				
				<!-- AGENTS: -->
				<xsl:text>"linked_agents":[</xsl:text>
				<xsl:if test="Creator">
					<xsl:variable name="n">
						<xsl:value-of select="replace(Creator,'--',' ')"/>
					</xsl:variable>
					<xsl:variable name="ref">
						<xsl:for-each select="document('tables/agents.xml')/records/record">
							<xsl:if test="title = $n">
								<xsl:value-of select="uri"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="$ref != ''">
						<xsl:text>{"role":"creator",</xsl:text>
						<xsl:if test="Creator_Role">
							<xsl:text>"relator":</xsl:text>
							<xsl:choose>
								<xsl:when test="Creator_Role = 'Author'">
									<xsl:text>"aut",</xsl:text>
								</xsl:when>
								<xsl:when test="Creator_Role = 'Photographer'">
									<xsl:text>"pht",</xsl:text>
								</xsl:when>
								<xsl:when test="Creator_Role = 'Artist'">
									<xsl:text>"art",</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:text>"ref":</xsl:text>
						<xsl:value-of select="concat($quot,$ref,$quot)"/>
						<xsl:text>},</xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="Corp_Name">
					<xsl:for-each select="tokenize(Corp_Name, ' --')">
						<xsl:variable name="n">
							<xsl:value-of select="replace(.,'--',' ')"/>
						</xsl:variable>
						<xsl:variable name="ref">
							<xsl:for-each select="document('tables/agents.xml')/records/record">
								<xsl:if test="title = $n">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="$ref != ''">
							<xsl:text>{"role":"subject","ref":</xsl:text>
							<xsl:value-of select="concat($quot,$ref,$quot)"/>
							<xsl:text>},</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="Pers_Fam_Name">
					<xsl:for-each select="tokenize(Pers_Fam_Name, ' --')">
						<xsl:variable name="n">
							<xsl:value-of select="replace(.,'--',' ')"/>
						</xsl:variable>
						<xsl:variable name="ref">
							<xsl:for-each select="document('tables/agents.xml')/records/record">
								<xsl:if test="title = $n">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="$ref != ''">
							<xsl:text>{"role":"subject","ref":</xsl:text>
							<xsl:value-of select="concat($quot,$ref,$quot)"/>
							<xsl:text>},</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="Meeting_Name">
					<xsl:for-each select="tokenize(Meeting_Name, ' --')">
						<xsl:variable name="n">
							<xsl:value-of select="replace(.,'--',' ')"/>
						</xsl:variable>
						<xsl:variable name="ref">
							<xsl:for-each select="document('tables/agents.xml')/records/record">
								<xsl:if test="title = $n">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="$ref != ''">
							<xsl:text>{"role":"subject","ref":</xsl:text>
							<xsl:value-of select="concat($quot,$ref,$quot)"/>
							<xsl:text>},</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>],</xsl:text>
				
				<!-- SUBJECTS: -->
				<xsl:text>"subjects":[</xsl:text>
				<xsl:if test="Topic_Term or Geogr_Name or Genre_Form or Occupation or Function_Act. or Meeting_Name">
					<xsl:if test="Topic_Term">
						<xsl:for-each select="tokenize(Topic_Term, ' --')">
							<xsl:variable name="term">
								<xsl:variable name="n">
									<xsl:value-of select="replace(.,'--',' -- ')"/>
								</xsl:variable>
								<xsl:for-each select="document('tables/subjects.xml')/records/record">
									<xsl:if test="title = $n">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$term != ''">
								<xsl:text>{"ref":</xsl:text>
								<xsl:value-of select="concat($quot,$term,$quot)"/>
								<xsl:text>},</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="Geogr_Name">
						<xsl:for-each select="tokenize(Geogr_Name, ' --')">
							<xsl:variable name="term">
								<xsl:variable name="n">
									<xsl:value-of select="replace(.,'--',' -- ')"/>
								</xsl:variable>
								<xsl:for-each select="document('tables/subjects.xml')/records/record">
									<xsl:if test="title = $n">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$term != ''">
								<xsl:text>{"ref":</xsl:text>
								<xsl:value-of select="concat($quot,$term,$quot)"/>
								<xsl:text>},</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="Genre_Form">
						<xsl:for-each select="tokenize(Genre_Form, ' --')">
							<xsl:variable name="term">
								<xsl:variable name="n">
									<xsl:value-of select="replace(.,'--',' -- ')"/>
								</xsl:variable>
								<xsl:for-each select="document('tables/subjects.xml')/records/record">
									<xsl:if test="title = $n">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$term != ''">
								<xsl:text>{"ref":</xsl:text>
								<xsl:value-of select="concat($quot,$term,$quot)"/>
								<xsl:text>},</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="Occupation">
						<xsl:for-each select="tokenize(Occupation, ' --')">
							<xsl:variable name="term">
								<xsl:variable name="n">
									<xsl:value-of select="replace(.,'--',' -- ')"/>
								</xsl:variable>
								<xsl:for-each select="document('tables/subjects.xml')/records/record">
									<xsl:if test="title = $n">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$term != ''">
								<xsl:text>{"ref":</xsl:text>
								<xsl:value-of select="concat($quot,$term,$quot)"/>
								<xsl:text>},</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="Function_Act.">
						<xsl:for-each select="tokenize(Function_Act., ' --')">
							<xsl:variable name="term">
								<xsl:variable name="n">
									<xsl:value-of select="replace(.,'--',' -- ')"/>
								</xsl:variable>
								<xsl:for-each select="document('tables/subjects.xml')/records/record">
									<xsl:if test="title = $n">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$term != ''">
								<xsl:text>{"ref":</xsl:text>
								<xsl:value-of select="concat($quot,$term,$quot)"/>
								<xsl:text>},</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="Meeting_Name">
						<xsl:for-each select="tokenize(Meeting_Name, ' --')">
							<xsl:variable name="term">
								<xsl:variable name="n">
									<xsl:value-of select="replace(.,'--',' -- ')"/>
								</xsl:variable>
								<xsl:for-each select="document('tables/subjects.xml')/records/record">
									<xsl:if test="title = $n">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$term != ''">
								<xsl:text>{"ref":</xsl:text>
								<xsl:value-of select="concat($quot,$term,$quot)"/>
								<xsl:text>},</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
				<xsl:text>],</xsl:text>
				
				<!-- NOTES: -->
				<!-- (there are many different types of note) -->
				<xsl:text>"notes":[</xsl:text>
				<xsl:if test="Abstract or Bio_Org_History or Scope-Content or Arrang_Organiz or Assoc_Materials 
					or Notes or Accruals or Preferred_Citation or Acquisition">
					<xsl:if test="Abstract">
						<xsl:text>{"jsonmodel_type":"note_singlepart","type":"abstract","content":[</xsl:text>
						<xsl:value-of select="concat($quot,'&lt;p&gt;',replace(replace(replace(replace(Abstract,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;',$quot)"/>
						<xsl:text>],"publish":true</xsl:text>
						<xsl:choose>
							<xsl:when test="Bio_Org_History or Scope-Content or Arrang_Organiz or Assoc_Materials 
								or Notes or Accruals or Preferred_Citation or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					
					<xsl:if test="Bio_Org_History">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"bioghist","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:if test="Bio_Org_History_Biograph._History">
							<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Biograph._History,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
						</xsl:if>
						<xsl:if test="Bio_Org_History_Bio._Expansion">
							<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Bio._Expansion,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
						</xsl:if>
						<xsl:if test="Bio_Org_History_Organiz._History">
							<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Organiz._History,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
						</xsl:if>
						<xsl:if test="Bio_Org_History_Org._Expansion">
							<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Org._Expansion,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
						</xsl:if>
						<xsl:text>","publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Scope-Content or Arrang_Organiz or Assoc_Materials or Notes or Accruals 
								or Preferred_Citation or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Scope-Content">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"scopecontent","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(Scope-Content,'&#10;',' '),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Arrang_Organiz or Assoc_Materials or Notes or Accruals or Preferred_Citation 
								or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Arrang_Organiz">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"arrangement","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(Arrang_Organiz,'&#10;',' '),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Assoc_Materials or Notes or Accruals or Preferred_Citation or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Assoc_Materials">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"relatedmaterial","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(Assoc_Materials,'&#10;',' '),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Notes or Accruals or Preferred_Citation or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					
					<xsl:if test="Notes">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"odd","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(replace(replace(Notes,'&#10;',' '),'&#09;',''),'\\','\\\\'),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Accruals or Preferred_Citation or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Accruals">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"accruals","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(Accruals,'&#10;',' '),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Preferred_Citation or Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Preferred_Citation">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"prefercite","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(Preferred_Citation,'&#10;',' '),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]</xsl:text>
						<xsl:choose>
							<xsl:when test="Acquisition">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Acquisition">
						<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"acqinfo","subnotes":[</xsl:text>
						<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
						<xsl:value-of select="concat($quot,replace(replace(Acquisition,'&#10;',' '),$quot,$qrep),$quot)"/>
						<xsl:text>,"publish":true}]}</xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:text>],</xsl:text>
				
				<xsl:text>"external_documents":[</xsl:text>
				<xsl:variable name="bibnum" select="substring-after(Persistent_IDs_Bib_Number,'[Bib Number]')"/>
				<xsl:variable name="oclcnum" select="substring-after(Persistent_IDs_OCLC_Number,'[OCLC Number]')"/>
				<xsl:variable name="handle" select="substring-after(Persistent_IDs_Handle,'[Handle]')"/>
				<xsl:if test="$bibnum != '' or $oclcnum != '' or $handle != ''">
					<xsl:if test="$bibnum != ''">
						<xsl:text>{"jsonmodel_type":"external_document","title":"Encore record","location":</xsl:text>
						<xsl:value-of select="concat($quot,$bibnum,$quot)"/>
						<xsl:text>,"publish":true}</xsl:text>
						<xsl:if test="$oclcnum != '' or $handle != ''">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$oclcnum != ''">
						<xsl:text>{"jsonmodel_type":"external_document","title":"OCLC record","location":</xsl:text>
						<xsl:value-of select="concat($quot,'http://worldcat.org/oclc/',$oclcnum,$quot)"/>
						<xsl:text>,"publish":true}</xsl:text>
						<xsl:if test="$handle != ''">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$handle != ''">
						<xsl:text>{"jsonmodel_type":"external_document","title":"Digital DU collection","location":</xsl:text>
						<xsl:value-of select="concat($quot,'http://digitaldu.coalliance.org/fedora/repository/',$handle,$quot)"/>
						<xsl:text>,"publish":true}</xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:text>],"publish":true}</xsl:text>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>