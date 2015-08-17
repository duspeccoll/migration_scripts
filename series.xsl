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
		<xsl:for-each select="RediscoveryExport">
			<xsl:variable name="coll" select="Collection_Nbr"/>
			<xsl:variable name="id">
				<xsl:for-each select="document('tables/resources.xml')/records/record">
					<xsl:if test="id = $coll">
						<xsl:value-of select="substring-after(uri,'/repositories/2/resources/')"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="document('series.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll]">
				<xsl:result-document href="children/series/{$id}.json" method="text">
					<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
					<xsl:for-each select="document('series.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll]">
						<xsl:variable name="component_id" select="concat(Collection_Nbr,'.',Series_Nbr)"/>
						<xsl:variable name="series_nbr" select="Series_Nbr"/>
						<xsl:text>{"jsonmodel_type":"archival_object","title":</xsl:text>
						<xsl:choose>
							<xsl:when test="Series_Title">
								<xsl:value-of select="concat($quot,replace(Series_Title,$quot,$qrep),$quot)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($quot,'Series ',$series_nbr,$quot)"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>,"resource":{"ref":</xsl:text>
						<xsl:variable name="uri">
							<xsl:for-each select="document('tables/resources.xml')">
								<xsl:if test="id = $coll">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="concat($quot,$uri,$quot)"/>
						<xsl:text>},"component_id":</xsl:text>
						<xsl:value-of select="concat($quot,$component_id,$quot)"/>
						<xsl:text>,"level":"series"</xsl:text>
						<xsl:if test="Language">
							<xsl:text>,"language":</xsl:text>
							<xsl:value-of select="concat($quot,Language_Language_Code,$quot)"/>
						</xsl:if>
						<xsl:text>,"publish":true,</xsl:text>
						
						<!-- DATES -->
						<xsl:text>"dates":[</xsl:text>
						<xsl:if test="Inclusive_Dates">
							<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":</xsl:text>
							<xsl:choose>
								<xsl:when test="contains(Dates,'-')">
									<xsl:text>"range",</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>"single",</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>"expression":</xsl:text>
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
							<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":</xsl:text>
							<xsl:choose>
								<xsl:when test="contains(Dates,'-')">
									<xsl:text>"range",</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>"single",</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>"expression":</xsl:text>
							<xsl:value-of select="concat($quot,Bulk_Dates,$quot)"/>
							<xsl:text>}</xsl:text>
						</xsl:if>
						<xsl:text>],</xsl:text>
						
						<!-- EXTENTS -->
						<xsl:text>"extents":[</xsl:text>
						<xsl:if test="Extent">
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
						</xsl:if>
						<xsl:text>],</xsl:text>
						
						<!-- AGENTS -->
						<xsl:text>"linked_agents":[</xsl:text>
						<xsl:if test="Creator">
							<xsl:variable name="creator">
								<xsl:value-of select="replace(Creator,'--',' ')"/>
							</xsl:variable>
							<xsl:variable name="ref">
								<xsl:for-each select="document('tables/agents.xml')/records/record">
									<xsl:if test="title = $creator">
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
										<xsl:when test="Creator_Role = 'Producer'">
											<xsl:text>"pro",</xsl:text>
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
								<xsl:variable name="corp">
									<xsl:value-of select="replace(.,'--',' ')"/>
								</xsl:variable>
								<xsl:variable name="ref">
									<xsl:for-each select="document('tables/agents.xml')/records/record">
										<xsl:if test="title = $corp">
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
								<xsl:variable name="persfam">
									<xsl:value-of select="replace(.,'--',' ')"/>
								</xsl:variable>
								<xsl:variable name="ref">
									<xsl:for-each select="document('tables/agents.xml')/records/record">
										<xsl:if test="title = $persfam">
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
						
						<!-- SUBJECTS -->
						<xsl:text>"subjects":[</xsl:text>
						<xsl:if test="Topic_Term or Geogr_Name or Genre_Form or Occupation or Function_Act.">
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
						</xsl:if>
						<xsl:text>],</xsl:text>
						
						<!-- NOTES: -->
						<!-- (there are many different types of note) -->
						<xsl:text>"notes":[</xsl:text>
						<xsl:if test="Arrang_Organiz or Arrang_Organiz_Separated_Materials or Bio_Org_History or Notes 
							or Scope-Content or Provenance or Proc_By">
							<xsl:if test="Arrang_Organiz">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"arrangement","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(Arrang_Organiz,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="Arrang_Organiz_Separated_Materials or Bio_Org_History or Notes 
										or Scope-Content or Provenance or Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="Arrang_Organiz_Separated_Materials">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"separatedmaterial","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(Arrang_Organiz_Separated_Materials,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="Bio_Org_History or Notes or Scope-Content or Provenance or Proc_By">
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
									<xsl:when test="Notes or Scope-Content or Provenance or Proc_By">
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
									<xsl:when test="Scope-Content or Provenance or Proc_By">
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
									<xsl:when test="Provenance or Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="Provenance">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"custodhist","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(Provenance,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="Proc_By">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"processinfo","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":"</xsl:text>
								<xsl:value-of select="replace(replace(replace(substring-before(Proc_By,' __'),'.$',''),'&#10;',' '),$quot,$qrep)"/>
								<xsl:value-of select="concat(', ',replace(replace(substring-after(Proc_By,' __'),'&#10;',' '),$quot,$qrep),'.')"/>
								<xsl:text>","publish":true}]}</xsl:text>
							</xsl:if>
						</xsl:if>
						<xsl:text>]</xsl:text>
						<xsl:choose>
							<xsl:when test="position() != last()">
								<xsl:text>},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<xsl:text>]}</xsl:text>
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>