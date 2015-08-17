<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	
	<xsl:output method="text"/>
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- we take collection.xml as source but since the collections are already in ASpace at this point, we ignore that file -->
	
	<xsl:template match="NewDataSet">
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:for-each select="RediscoveryExport">
			<xsl:variable name="coll_nbr" select="Collection_Nbr"/>
			<xsl:variable name="uri_nbr">
				<xsl:for-each select="document('as_resource.xml')/records/record">
					<xsl:if test="$coll_nbr = id">
						<xsl:value-of select="substring-after(uri,'repositories/2/resources/')"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="document('series.xml')/NewDataSet/RediscoveryExport/Collection_Nbr[text() = $coll_nbr]">
			
				<xsl:result-document href="children/{$uri_nbr}.json" method="text">
				
				<!-- declare archival_record_children data model -->
					<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
				
					<xsl:for-each select="document('series.xml')/NewDataSet/RediscoveryExport/Collection_Nbr[text() = $coll_nbr]">
						<xsl:variable name="series_nbr" select="parent::*/Series_Nbr"/>
						<xsl:text>{"jsonmodel_type":"archival_object","resource":{"ref":</xsl:text>
						<xsl:variable name="resource_ref">
							<xsl:for-each select="document('as_resource.xml')/records/record">
								<xsl:if test="$coll_nbr = id">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="concat($quot,$resource_ref,$quot)"/>
						<xsl:text>},"title":</xsl:text>
						<xsl:value-of select="concat($quot,parent::*/Series_Title,$quot)"/>
						<xsl:text>,"component_id":</xsl:text>
						<xsl:value-of select="concat($quot,parent::*/Collection_Nbr,'.',parent::*/Series_Nbr,$quot)"/>
						<xsl:text>,"level":"series"</xsl:text>
						<xsl:if test="parent::*/Language">
							<xsl:text>,"language":</xsl:text>
							<xsl:value-of select="concat($quot,parent::*/Language_Language_Code,$quot)"/>
						</xsl:if>
						<xsl:text>,"publish":true,</xsl:text>
						
						<!-- DATES -->
						<xsl:text>"dates":[</xsl:text>
						<xsl:if test="parent::*/Inclusive_Dates">
							<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":"inclusive","expression":</xsl:text>
							<xsl:value-of select="concat($quot,parent::*/Inclusive_Dates,$quot,',')"/>
							<xsl:text>"begin":</xsl:text>
							<xsl:value-of select="concat($quot,normalize-space(replace(substring-before(parent::*/Inclusive_Dates,'-'),'(between|circa)','')),$quot,',')"/>
							<xsl:text>"end":</xsl:text>
							<xsl:value-of select="concat($quot,normalize-space(replace(substring-after(parent::*/Inclusive_Dates,'-'),'(between|circa)','')),$quot)"/>
							<xsl:choose>
								<xsl:when test="parent::*/Bulk_Dates">
									<xsl:text>},</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>}</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="parent::*/Bulk_Dates">
							<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":"bulk","expression":</xsl:text>
							<xsl:value-of select="concat($quot,parent::*/Bulk_Dates,$quot,',')"/>
							<xsl:text>"begin":</xsl:text>
							<xsl:value-of select="concat($quot,normalize-space(substring-before(parent::*/Bulk_Dates,'-')),$quot,',')"/>
							<xsl:text>"end":</xsl:text>
							<xsl:value-of select="concat($quot,normalize-space(substring-after(parent::*/Bulk_Dates,'-')),$quot)"/>
							<xsl:text>}</xsl:text>
						</xsl:if>
						<xsl:text>],</xsl:text>
						
						<!-- EXTENTS -->
						<xsl:text>"extents":[</xsl:text>
						<xsl:if test="parent::*/Extent">
							<xsl:variable name="ext" select="tokenize(parent::*/Extent,' __')"/>
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
						<xsl:if test="parent::*/Creator">
							<xsl:text>{"role":"creator",</xsl:text>
							<xsl:if test="parent::*/Creator_Role">
								<xsl:text>"relator":</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Creator_Role = 'Author'">
										<xsl:text>"aut",</xsl:text>
									</xsl:when>
									<xsl:when test="parent::*/Creator_Role = 'Photographer'">
										<xsl:text>"pht",</xsl:text>
									</xsl:when>
									<xsl:when test="parent::*/Creator_Role = 'Artist'">
										<xsl:text>"art",</xsl:text>
									</xsl:when>
									<xsl:when test="parent::*/Creator_Role = 'Producer'">
										<xsl:text>"pro",</xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:variable name="creator">
								<xsl:value-of select="replace(parent::*/Creator,'--',' ')"/>
							</xsl:variable>
							<xsl:variable name="ref">
								<xsl:for-each select="document('agents.xml')/records/record">
									<xsl:if test="title = $creator">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:variable name="model">
								<xsl:for-each select="document('agents.xml')/records/record">
									<xsl:if test="title = $creator">
										<xsl:value-of select="type"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:text>"ref":</xsl:text>
							<xsl:choose>
								<xsl:when test="$ref = ''">
									<xsl:value-of select="concat($quot,$creator,$quot)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($quot,$ref,$quot)"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="parent::*/Corp_Name or parent::*/Pers_Fam_Name">
									<xsl:text>},</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>}</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="parent::*/Corp_Name">
							<xsl:for-each select="tokenize(parent::*/Corp_Name, ' --')">
								<xsl:variable name="corp">
									<xsl:value-of select="replace(.,'--',' ')"/>
								</xsl:variable>
								<xsl:variable name="ref">
									<xsl:for-each select="document('agents.xml')/records/record">
										<xsl:if test="title = $corp">
											<xsl:value-of select="uri"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>
								<xsl:variable name="model">
									<xsl:for-each select="document('agents.xml')/records/record">
										<xsl:if test="title = $corp">
											<xsl:value-of select="type"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>
								<xsl:text>{"role":"subject","ref":</xsl:text>
								<xsl:choose>
									<xsl:when test="$ref = ''">
										<xsl:value-of select="concat($quot,$corp,$quot)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($quot,$ref,$quot)"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="position() != last()">
									<xsl:text>},</xsl:text>
								</xsl:if>
							</xsl:for-each>
							<xsl:choose>
								<xsl:when test="parent::*/Pers_Fam_Name">
									<xsl:text>},</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>}</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="parent::*/Pers_Fam_Name">
							<xsl:for-each select="tokenize(parent::*/Pers_Fam_Name, ' --')">
								<xsl:variable name="persfam">
									<xsl:value-of select="replace(.,'--',' ')"/>
								</xsl:variable>
								<xsl:variable name="ref">
									<xsl:for-each select="document('agents.xml')/records/record">
										<xsl:if test="title = $persfam">
											<xsl:value-of select="uri"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>
								<xsl:variable name="model">
									<xsl:for-each select="document('agents.xml')/records/record">
										<xsl:if test="title = $persfam">
											<xsl:value-of select="type"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>
								<xsl:text>{"role":"subject","ref":</xsl:text>
								<xsl:choose>
									<xsl:when test="$ref = ''">
										<xsl:value-of select="concat($quot,$persfam,$quot)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($quot,$ref,$quot)"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="position() != last()">
									<xsl:text>},</xsl:text>
								</xsl:if>
							</xsl:for-each>
							<xsl:text>}</xsl:text>
						</xsl:if>
						<xsl:text>],</xsl:text>
						
						<!-- SUBJECTS -->
						<xsl:text>"subjects":[</xsl:text>
						<xsl:if test="parent::*/Topic_Term or parent::*/Geogr_Name or parent::*/Genre_Form 
							or parent::*/Occupation or parent::*/Function_Act.">
							<xsl:if test="parent::*/Topic_Term">
								<xsl:for-each select="tokenize(parent::*/Topic_Term, ' --')">
									<xsl:variable name="term">
										<xsl:variable name="n">
											<xsl:value-of select="replace(.,'--',' -- ')"/>
										</xsl:variable>
										<xsl:for-each select="document('subject.xml')/records/record">
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
							<xsl:if test="parent::*/Geogr_Name">
								<xsl:for-each select="tokenize(parent::*/Geogr_Name, ' --')">
									<xsl:variable name="term">
										<xsl:variable name="n">
											<xsl:value-of select="replace(.,'--',' -- ')"/>
										</xsl:variable>
										<xsl:for-each select="document('subject.xml')/records/record">
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
							<xsl:if test="parent::*/Genre_Form">
								<xsl:for-each select="tokenize(parent::*/Genre_Form, ' --')">
									<xsl:variable name="term">
										<xsl:variable name="n">
											<xsl:value-of select="replace(.,'--',' -- ')"/>
										</xsl:variable>
										<xsl:for-each select="document('subject.xml')/records/record">
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
							<xsl:if test="parent::*/Occupation">
								<xsl:for-each select="tokenize(parent::*/Occupation, ' --')">
									<xsl:variable name="term">
										<xsl:variable name="n">
											<xsl:value-of select="replace(.,'--',' -- ')"/>
										</xsl:variable>
										<xsl:for-each select="document('subject.xml')/records/record">
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
							<xsl:if test="parent::*/Function_Act.">
								<xsl:for-each select="tokenize(parent::*/Function_Act., ' --')">
									<xsl:variable name="term">
										<xsl:variable name="n">
											<xsl:value-of select="replace(.,'--',' -- ')"/>
										</xsl:variable>
										<xsl:for-each select="document('subject.xml')/records/record">
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
						<xsl:if test="parent::*/Arrang_Organiz or parent::*/Arrang_Organiz_Separated_Materials
							or parent::*/Bio_Org_History or parent::*/Notes or parent::*/Scope-Content or parent::*/Provenance
							or parent::*/Proc_By">
							<xsl:if test="parent::*/Arrang_Organiz">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"arrangement","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(parent::*/Arrang_Organiz,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Arrang_Organiz_Separated_Materials or parent::*/Bio_Org_History
										or parent::*/Notes or parent::*/Scope-Content or parent::*/Provenance or parent::*/Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent::*/Arrang_Organiz_Separated_Materials">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"separatedmaterial","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(parent::*/Arrang_Organiz_Separated_Materials,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Bio_Org_History or parent::*/Notes or parent::*/Scope-Content
										or parent::*/Provenance or parent::*/Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent::*/Bio_Org_History">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"bioghist","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":"</xsl:text>
								<xsl:if test="parent::*/Bio_Org_History_Biograph._History">
									<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Biograph._History,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
								</xsl:if>
								<xsl:if test="parent::*/Bio_Org_History_Bio._Expansion">
									<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Bio._Expansion,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
								</xsl:if>
								<xsl:if test="parent::*/Bio_Org_History_Organiz._History">
									<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Organiz._History,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
								</xsl:if>
								<xsl:if test="parent::*/Bio_Org_History_Org._Expansion">
									<xsl:value-of select="concat('&lt;p&gt;',replace(replace(replace(replace(Bio_Org_History_Org._Expansion,'&#10;&#10;','&#10;'),'&#10;','&lt;/p&gt;&lt;p&gt;'),'&#09;',''),$quot,$qrep),'&lt;/p&gt;')"/>
								</xsl:if>
								<xsl:text>","publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Notes or parent::*/Scope-Content or parent::*/Provenance
										or parent::*/Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent::*/Notes">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"odd","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(replace(replace(parent::*/Notes,'&#10;',' '),'&#09;',''),'\\','\\\\'),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Scope-Content or parent::*/Provenance or parent::*/Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent::*/Scope-Content">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"scopecontent","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(parent::*/Scope-Content,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Provenance or parent::*/Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent::*/Provenance">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"custodhist","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
								<xsl:value-of select="concat($quot,replace(replace(parent::*/Provenance,'&#10;',' '),$quot,$qrep),$quot)"/>
								<xsl:text>,"publish":true}]</xsl:text>
								<xsl:choose>
									<xsl:when test="parent::*/Proc_By">
										<xsl:text>},</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>}</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent::*/Proc_By">
								<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"processinfo","subnotes":[</xsl:text>
								<xsl:text>{"jsonmodel_type":"note_text","content":"</xsl:text>
								<xsl:value-of select="replace(replace(replace(substring-before(parent::*/Proc_By,' __'),'.$',''),'&#10;',' '),$quot,$qrep)"/>
								<xsl:value-of select="concat(', ',replace(replace(substring-after(parent::*/Proc_By,' __'),'&#10;',' '),$quot,$qrep),'.')"/>
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