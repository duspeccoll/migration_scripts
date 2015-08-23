<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:json="http://json.org" xmlns:marc="http://www.loc.gov/MARC21/slim">

	<!--
	  agents.xsl -- converts named entity term types to ArchivesSpace Agents

		Within Re:Discovery there are nine Term Types.
		Corporate, personal, and meeting names are handled through this XSLT.
		All other term types are considered to be Subjects and are handled through the subjects.xsl file.

	-->

	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="NewDataSet">

		<!-- variables to escape quotation marks in the metadata -->
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>

		<xsl:for-each select="RediscoveryExport">
			<!-- set a variable for names that we use to name JSON objects -->
			<xsl:variable name="fname">
				<xsl:choose>
					<xsl:when test="Term_Type = 'Corporate name' or Term_Type = 'Meeting name'">
						<xsl:value-of select="concat('agents/corp/',ID,'.json')"/>
					</xsl:when>
					<xsl:when test="Term_Type = 'Personal name' and Personal_Name_Pers_Name_Type = 'Family name'">
						<xsl:value-of select="concat('agents/family/',ID,'.json')"/>
					</xsl:when>
					<xsl:when test="Term_Type = 'Personal name' and Personal_Name_Pers_Name_Type != 'Family name'">
						<xsl:value-of select="concat('agents/person/',ID,'.json')"/>
					</xsl:when>
					<xsl:when test="Term_Type = 'Personal name' and not(Personal_Name_Pers_Name_Type)">
						<xsl:value-of select="concat('agents/person/',ID,'.json')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:result-document href="{$fname}" method="text">

				<!-- Further down the XSLT there is a template called "write_value" where most of the JSON is written out -->

				<!--
				  choose/when for separating out corporate names from personal names
					Additionally, Re:D stores family names as personal names, so we have to have a
					choose/when within this choose/when to separate *them* out
				-->
				<xsl:choose>
					<xsl:when test="Term_Type = 'Personal name'">
						<xsl:choose>
							<xsl:when test="Personal_Name_Pers_Name_Type = 'Family name'">
								<xsl:text>{"jsonmodel_type":"agent_family","agent_type":"agent_family",</xsl:text>
								<xsl:text>"names":[{</xsl:text>
								<xsl:text>"jsonmodel_type":"name_family","family_name":</xsl:text>
								<xsl:call-template name="write_value">
									<xsl:with-param name="value" select="Browse_Term"/>
								</xsl:call-template>
							</xsl:when>

							<xsl:otherwise>
								<xsl:variable name="persname">
									<xsl:choose>
										<xsl:when test="contains(Personal_Name,' __')">
											<xsl:value-of select="substring-before(Personal_Name,' __')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="Personal_Name"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:text>{"jsonmodel_type":"agent_person","agent_type":"agent_person",</xsl:text>
								<xsl:text>"names":[{</xsl:text>
								<xsl:text>"jsonmodel_type":"name_person","primary_name":</xsl:text>
								<xsl:choose>
									<xsl:when test="Personal_Name_Pers_Name_Type = 'Surname' or not(Personal_Name_Pers_Name_Type)">
										<xsl:if test="not(contains($persname,','))">
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="$persname"/>
											</xsl:call-template>
										</xsl:if>
										<xsl:if test="contains($persname,',')">
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="substring-before($persname,',')"/>
											</xsl:call-template>
										</xsl:if>
									</xsl:when>
									<xsl:when test="Personal_Name_Pers_Name_Type = 'Forename'">
										<xsl:call-template name="write_value">
											<xsl:with-param name="value" select="$persname"/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
								<xsl:if test="Personal_Name_Pers_Name_Type = 'Surname' or not(Personal_Name_Pers_Name_Type)">
									<xsl:text>,"rest_of_name":</xsl:text>
									<xsl:variable name="rest" select="replace(substring-after($persname,', '),',$','')"/>
									<xsl:choose>
										<xsl:when test="contains($rest,'--')">
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="substring-before($rest,'--')"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="$rest"/>
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:if test="Personal_Name_Fuller_Form">
									<xsl:text>,"fuller_form":</xsl:text>
									<xsl:analyze-string select="Personal_Name_Fuller_Form" regex="\((.+?)\),">
										<xsl:matching-substring>
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="replace(regex-group(1),'(\(|\)','')"/>
											</xsl:call-template>
										</xsl:matching-substring>
										<xsl:non-matching-substring>
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="."/>
											</xsl:call-template>
										</xsl:non-matching-substring>
									</xsl:analyze-string>
								</xsl:if>
								<xsl:if test="Personal_Name_Numeration">
									<xsl:text>,"number":</xsl:text>
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="Personal_Name_Numeration"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="Personal_Name_Title">
									<xsl:variable name="title">
										<xsl:value-of select="replace(Personal_Name_Title,',$','')"/>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$title = 'King of England' or $title = 'vicomte de'">
											<xsl:text>,"title":</xsl:text>
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="$title"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>,"prefix":</xsl:text>
											<xsl:choose>
												<xsl:when test="contains($title,'--')">
													<xsl:call-template name="write_value">
														<xsl:with-param name="value" select="replace($title,'--','')"/>
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="write_value">
														<xsl:with-param name="value" select="$title"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:if test="Personal_Name_Pers_Name_Type != 'Family name' or not(Personal_Name_Pers_Name_Type)">
									<xsl:text>,"name_order":</xsl:text>
									<xsl:choose>
										<xsl:when test="Personal_Name_Pers_Name_Type = 'Surname' or not(Personal_Name_Pers_Name_Type)">
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="'inverted'"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="Personal_Name_Pers_Name_Type = 'Forename'">
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="'direct'"/>
											</xsl:call-template>
										</xsl:when>
									</xsl:choose>
								</xsl:if>
								<xsl:if test="Personal_Name_Dates">
									<xsl:text>,"dates":</xsl:text>
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="Personal_Name_Dates"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>,"source":</xsl:text>
						<xsl:choose>
							<xsl:when test="Personal_Name_Thesaurus">
								<xsl:if test="Personal_Name_Thesaurus = 'lcnaf' or Personal_Name_Thesaurus = 'lcsh' or Personal_Name_Thesaurus = 'naf'">
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="'naf'"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="Personal_Name_Thesaurus = 'local--name' or Personal_Name_Thesaurus = 'provisional'">
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="'local'"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Personal_Name_Thesaurus) and User_1">
								<xsl:if test="User_1 = 'lcnaf' or User_1 = 'lcsh' or User_1 = 'lcgft'">
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="'naf'"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="User_1 = 'cross reference' or User_1 = 'local' or User_1 = 'provisional'">
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="'local'"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Personal_Name_Thesaurus) and not(User_1)">
								<xsl:call-template name="write_value">
									<xsl:with-param name="value" select="'local'"/>
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</xsl:when>

					<!-- Corporate and Meeting Names -->
					<xsl:when test="Term_Type = 'Corporate name' or Term_Type = 'Meeting name'">
						<xsl:text>{"jsonmodel_type":"agent_corporate_entity","agent_type":"agent_corporate_entity",</xsl:text>
						<xsl:text>"names":[{</xsl:text>
						<xsl:text>"jsonmodel_type":"name_corporate_entity","primary_name":</xsl:text>
						<xsl:choose>
							<xsl:when test="Term_Type = 'Corporate name'">
								<xsl:call-template name="write_value">
									<xsl:with-param name="value" select="replace(Corporate_Name_Corp-Juris_Name,'\.$','')"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="Term_Type = 'Meeting name'">
								<xsl:call-template name="write_value">
									<xsl:with-param name="value" select="Meeting_Name_Mtg-Juris_Name"/>
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
						<xsl:if test="Meeting_Name_Mtg_Date">
							<xsl:text>,"subordinate_name_1":</xsl:text>
							<xsl:call-template name="write_value">
								<xsl:with-param name="value" select="concat(Meeting_Name_Mtg_Date,Meeting_Name_Meeting_Loc)"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="Corporate_Name_Subord_Unit">
							<xsl:choose>
								<xsl:when test="count(tokenize(Corporate_Name_Subord_Unit,' --')) = 1">
									<xsl:text>,"subordinate_name_1":</xsl:text>
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="Corporate_Name_Subord_Unit"/>
									</xsl:call-template>
									<xsl:if test="Corporate_Name_Part-Sec-Mts__">
										<xsl:text>,"subordinate_name_2":</xsl:text>
										<xsl:call-template name="write_value">
											<xsl:with-param name="value" select="concat(Corporate_Name_Part-Sec-Mts__,' ',Corporate_Name_Mtg-Treaty_Date,' ',Corporate_Name_Meeting_Loc)"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:when>
								<xsl:when test="count(tokenize(Corporate_Name_Subord_Unit,' --')) >= 2">
									<xsl:variable name="subord" select="tokenize(Corporate_Name_Subord_Unit,' --')"/>
									<xsl:text>,"subordinate_name_1":</xsl:text>
									<xsl:call-template name="write_value">
										<xsl:with-param name="value" select="substring-before($subord[1],'.')"/>
									</xsl:call-template>
									<xsl:text>,"subordinate_name_2":</xsl:text>
									<xsl:choose>
										<xsl:when test="$subord[3]">
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="concat($subord[2],' ',$subord[3])"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="write_value">
												<xsl:with-param name="value" select="$subord[2]"/>
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="Corporate_Name_General_Subdiv__x">
							<xsl:choose>
								<xsl:when test="not(Corporate_Name_Subord_Unit)">
									<xsl:text>,"subordinate_name_1":</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>,"subordinate_name_2":</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:call-template name="write_value">
								<xsl:with-param name="value" select="Corporate_Name_General_Subdiv__x"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="Corporate_Name_Form_Subdiv">
							<xsl:choose>
								<xsl:when test="not(Corporate_Name_General_Subdiv__x)">
									<xsl:text>,"subordinate_name_1":</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>,"subordinate_name_2":</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:call-template name="write_value">
								<xsl:with-param name="value" select="Corporate_Name_Form_Subdiv"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="Corporate_Name_Part-Sec-Mts__"> <!-- adding this to account for the one record that has it -->
							<xsl:text>,"subordinate_name_2":</xsl:text>
							<xsl:call-template name="write_value">
								<xsl:with-param name="value" select="concat(Corporate_Name_Part-Sec-Mts__,Corporate_Name_Mtg-Treaty_Date,Corporate_Name_Meeting_Loc)"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="Corporate_Name_Title_of_Work"> <!-- adding this to account for the one record that has it -->
							<xsl:text>,"subordinate_name_2":</xsl:text>
							<xsl:call-template name="write_value">
								<xsl:with-param name="value" select="Corporate_Name_Title_of_Work"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:text>,"source":</xsl:text>
						<xsl:choose>
							<xsl:when test="Corporate_Name_Thesaurus">
								<xsl:choose>
									<xsl:when test="Corporate_Name_Thesaurus = 'lcnaf' or Corporate_Name_Thesaurus = 'naf' or Corporate_Name_Thesaurus = 'lcsh'">
										<xsl:call-template name="write_value">
											<xsl:with-param name="value" select="'naf'"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="write_value">
											<xsl:with-param name="value" select="'local'"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="User_1 = 'lcnaf' or User_1 = 'lcsh' or (not(User_1) and Corporate_Name_Term_Source = 'lcnaf')">
										<xsl:call-template name="write_value">
											<xsl:with-param name="value" select="'naf'"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="write_value">
											<xsl:with-param name="value" select="'local'"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>

			  <!--
				  We wrote the old Re:Discovery ID in as the authority ID.
					At the time it seemed like a good idea (I thought we could use it for linking if we accidentally left any metadata behind)
					It actually wasn't that useful and you could probably do without it.
				-->
				<xsl:text>,"authority_id":</xsl:text>
				<xsl:call-template name="write_value">
					<xsl:with-param name="value" select="concat('codu:',ID)"/>
				</xsl:call-template>

				<!-- setting rules to 'local' because I couldn't guarantee everything was DACS or RDA -->
				<xsl:text>,"rules":"local","sort_name_auto_generate":true}]</xsl:text>

				<!--
				  Here are all of the notes.
					Notes are more restrictive in Agents than they are elsewhere in the application, since everything has to be a <bioghist>
					This is one of the data cleanup issues we decided to deal with post-migration.
				-->
				<xsl:if test="Bio_Hist or Source_Found_ or Scope_Note or See_From or See_Also_From or Public_Note or Non_Public_Note">
					<xsl:text>,"notes":[</xsl:text>

					<!-- set Re:D Bio_Hist to notes.note_bioghist -->
					<xsl:if test="Bio_Hist">
						<xsl:text>{"jsonmodel_type":"note_bioghist"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(Bio_Hist,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":true}</xsl:text>
						<xsl:choose>
							<xsl:when test="Source_Found_ or Scope_Note or See_From or See_Also_From or Public_Note or Non_Public_Note">
								<xsl:text>]},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>],</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- set Re:D Source/Found to notes.note_bioghist w/ label "Source" -->
					<xsl:if test="Source_Found_">
						<xsl:text>{"jsonmodel_type":"note_bioghist","label":"Source"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(Source_Found_,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":true}</xsl:text>
						<xsl:choose>
							<xsl:when test="Scope_Note or See_From or See_Also_From or Public_Note or Non_Public_Note">
								<xsl:text>]},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>],</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- set Re:D Scope Note to notes.note_bioghist with label "Scope Note" -->
					<xsl:if test="Scope_Note">
						<xsl:text>{"jsonmodel_type":"note_bioghist","label":"Scope Note"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(Scope_Note,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":true}</xsl:text>
						<xsl:choose>
							<xsl:when test="See_From or See_Also_From or Public_Note or Non_Public_Note">
								<xsl:text>]},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>],</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- set Re:D See From to notes.note_bioghist with label "See From:" -->
					<xsl:if test="See_From">
						<xsl:text>{"jsonmodel_type":"note_bioghist","label":"See From:"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(See_From,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":true}</xsl:text>
						<xsl:choose>
							<xsl:when test="See_Also_From or Public_Note or Non_Public_Note">
								<xsl:text>]},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>],</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- set Re:D See Also From to notes.note_bioghist with label "See From:" -->
					<xsl:if test="See_Also_From">
						<xsl:text>{"jsonmodel_type":"note_bioghist","label":"See From:"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(See_Also_From,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":true}</xsl:text>
						<xsl:choose>
							<xsl:when test="Public_Note or Non_Public_Note">
								<xsl:text>]},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>],</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- set Re:D Public Note to notes.note_bioghist with label "See From:" -->
					<xsl:if test="Public_Note">
						<xsl:text>{"jsonmodel_type":"note_bioghist","label":"See From:"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(Public_Note,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":true}</xsl:text>
						<xsl:choose>
							<xsl:when test="Non_Public_Note">
								<xsl:text>]},</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>],</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- set Re:D Non-Public Note to notes.note_bioghist with label "See From:"; don't publish it -->
					<xsl:if test="Non_Public_Note">
						<xsl:text>{"jsonmodel_type":"note_bioghist","label":"See From:"</xsl:text>
						<xsl:text>,"subnotes":[{"jsonmodel_type":"note_text","content":"</xsl:text>
						<xsl:value-of select="replace(replace(replace(Non_Public_Note,'\t',' '),'\n',' '),$quot,$qrep)"/>
						<xsl:text>","publish":false}],</xsl:text>
					</xsl:if>
					<xsl:text>"publish":true}]</xsl:text>
				</xsl:if>

				<xsl:text>,"publish":true}</xsl:text>

			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

  <!--
	  All this does is writes whatever string you pass to it into the JSON, with quotation marks escaped.
		I made it a template because otherwise these same four lines of code would show up like ten times.
  -->
	<xsl:template name="write_value">
		<xsl:param name="value"/>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:value-of select="concat($quot,replace($value,$quot,$qrep),$quot)"/>
	</xsl:template>

</xsl:stylesheet>
