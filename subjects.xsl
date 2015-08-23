<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:json="http://json.org">

	<!--
		subjects.xsl -- transforms authority terms in Re:Discovery into ArchivesSpace JSON

		Within Re:Discovery we have nine Term Types that need to be migrated to ArchivesSpace, in one way or another.
		Seven of these are handled through this XSLT.
		Corporate, personal, and meeting names are considered to be Agents and are handled through the agents.xsl file.

		Resulting JSON documents are then posted to ArchivesSpace via the API.

		I could probably clean this up quite a bit; I feel like it might be unnecessarily repetitive

	-->

	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="NewDataSet">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="RediscoveryExport">
		<xsl:variable name="id" select="ID"/>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:result-document href="subjects/{$id}.json" method="text">
			<xsl:text>{"jsonmodel_type":"subject","source":</xsl:text>
			<xsl:variable name="source">
				<xsl:choose>
					<xsl:when test="Term_Type = 'Function'">
						<xsl:choose>
							<xsl:when test="Function_Act._Thesaurus">
								<xsl:if test="Function_Act._Thesaurus = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Function_Act._Thesaurus) and User_1">
								<xsl:choose>
									<xsl:when test="User_1 = 'lcsh' or User_1 = 'lcnaf'">
										<xsl:text>"lcsh"</xsl:text>
									</xsl:when>
									<xsl:when test="User_1 = 'aat'">
										<xsl:text>"aat"</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>"local"</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="not(Function_Act._Thesaurus) and not(User_1) and Function_Act._Term_Source">
								<xsl:choose>
									<xsl:when test="Function_Act._Term_Source = 'aat'">
										<xsl:text>"aat"</xsl:text>
									</xsl:when>
									<xsl:when test="Function_Act._Term_Source = 'lcsh'">
										<xsl:text>"lcsh"</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>"local"</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"local"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="Term_Type = 'Genre/Form'">
						<xsl:choose>
							<xsl:when test="Genre_Form_Thesaurus">
								<xsl:if test="Genre_Form_Thesaurus = 'lcnaf' or Genre_Form_Thesaurus = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Genre_Form_Thesaurus = 'provisional' or Genre_Form_Thesaurus = 'Source not specified'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
								<xsl:if test="Genre_Form_Thesaurus = 'Source specified in Term Source'">
									<xsl:if test="Genre_Form_Term_Source = 'aat'">
										<xsl:text>"aat"</xsl:text>
									</xsl:if>
									<xsl:if test="Genre_Form_Term_Source = 'lcgft'">
										<xsl:text>"lcgft"</xsl:text>
									</xsl:if>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Genre_Form_Thesaurus) and User_1">
								<xsl:choose>
									<xsl:when test="User_1 = 'lcnaf' or User_1 = 'lcsh'">
										<xsl:text>"lcsh"</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>"local"</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"local"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="Term_Type = 'Geographic term'">
						<xsl:choose>
							<xsl:when test="Geographic_Term_Thesaurus">
								<xsl:if test="Geographic_Term_Thesaurus = 'lcnaf' or Geographic_Term_Thesaurus = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Geographic_Term_Thesaurus = 'provisional' or Geographic_Term_Thesaurus = 'local' or Geographic_Term_Thesaurus = 'local--name'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
								<xsl:if test="Geographic_Term_Thesaurus = 'Source specified in Term Source'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Geographic_Term_Thesaurus) and User_1">
								<xsl:choose>
									<xsl:when test="User_1 = 'lcnaf' or User_1 = 'lcsh'">
										<xsl:text>"lcsh"</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>"local"</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="not(Geographic_Term_Thesaurus) and not(User_1) and Geographic_Term_Term_Source">
								<xsl:choose>
									<xsl:when test="Geographic_Term_Term_Source = 'lcnaf' or Geographic_Term_Term_Source = 'lcsh'">
										<xsl:text>"lcsh"</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>"local"</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"local"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="Term_Type = 'Occupation'">
						<xsl:choose>
							<xsl:when test="Occupation_Thesaurus">
								<xsl:if test="Occupation_Thesaurus = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Occupation_Thesaurus = 'Source specified in Term Source'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Occupation_Thesaurus) and User_1">
								<xsl:if test="User_1 = 'lcsh' or User_1 = 'lcnaf'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="User_1 = 'cross reference' or User_1 = 'local' or User_1 = 'provisional'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Occupation_Thesaurus) and not(User_1) and Occupation_Term_Source">
								<xsl:if test="Occupation_Term_Source = 'lcsh' or Occupation_Term_Source = 'lcnaf'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Occupation_Term_Source = 'tucua'">
									<xsl:text>"tucua"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"local"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="Term_Type = 'Topic term'">
						<xsl:choose>
							<xsl:when test="Topic_Term_Thesaurus">
								<xsl:if test="Topic_Term_Thesaurus = 'lcsh' or Topic_Term_Thesaurus = 'lcnaf' or Topic_Term_Thesaurus = 'naf'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Topic_Term_Thesaurus = 'local--name' or Topic_Term_Thesaurus = 'provisional'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
								<xsl:if test="Topic_Term_Thesaurus = 'Source specified in Term Source'">
									<xsl:text>"</xsl:text>
									<xsl:value-of select="Topic_Term_Term_Source"/>
									<xsl:text>"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Topic_Term_Thesaurus) and User_1">
								<xsl:if test="User_1 = 'lcnaf' or User_1 = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="User_1 = 'cross reference' or User_1 = 'provisional'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
								<xsl:if test="User_1 = 'tucua'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(Topic_Term_Thesaurus) and not(User_1) and Topic_Term_Term_Source">
								<xsl:if test="Topic_Term_Term_Source = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Topic_Term_Term_Source = 'tucua'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"local"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="Term_Type = 'Uniform title' or Term_Type = 'Uniform Title'">
						<xsl:choose>
							<xsl:when test="Uniform_Title_Thesaurus">
								<xsl:if test="Uniform_Title_Thesaurus = 'lcnaf' or Uniform_Title_Thesaurus = 'lcsh'">
									<xsl:text>"lcsh"</xsl:text>
								</xsl:if>
								<xsl:if test="Uniform_Title_Thesaurus = 'local--name'">
									<xsl:text>"local"</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>"local"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="concat($source,',')"/>
			<xsl:if test="User_2 or Public_Note or See_From or Non_Public_Note or Bio_Hist or Scope_Note or Source__Found_ or See_Also_From">
				<xsl:variable name="scope">
					<xsl:text>"scope_note":"</xsl:text>
					<xsl:if test="User_2">
						<xsl:value-of select="concat('User 2: ',replace(replace(replace(User_2,$quot,$qrep),'\n',' '),'\t',''))"/>
					</xsl:if>
					<xsl:if test="Public_Note">
						<xsl:value-of select="concat('Public Note: ',replace(replace(Public_Note,$quot,$qrep),'\n',' '))"/>
					</xsl:if>
					<xsl:if test="See_From">
						<xsl:value-of select="concat('See From: ',replace(replace(See_From,$quot,$qrep),'\n',' '))"/>
					</xsl:if>
					<xsl:if test="Non_Public_Note">
						<xsl:value-of select="concat('Private Note: ',replace(replace(Non_Public_Note,$quot,$qrep),'\n',' '))"/>
					</xsl:if>
					<xsl:if test="Bio_Hist">
						<xsl:value-of select="concat('Bio/Hist: ',replace(replace(replace(Bio_Hist,$quot,$qrep),'__',''),'\n',' '))"/>
					</xsl:if>
					<xsl:if test="Scope_Note">
						<xsl:value-of select="concat('Scope Note: ',replace(replace(Scope_Note,$quot,$qrep),'\n',' '))"/>
					</xsl:if>
					<xsl:if test="Source__Found_">
						<xsl:value-of select="concat('Source: ',replace(replace(Source__Found_,$quot,$qrep),'\n',' '))"/>
					</xsl:if>
					<xsl:if test="See_Also_From">
						<xsl:value-of select="concat('See Also From: ',replace(replace(See_Also_From,$quot,$qrep),'\n',' '))"/>
					</xsl:if>
					<xsl:text>",</xsl:text>
				</xsl:variable>
				<xsl:value-of select="$scope"/>
			</xsl:if>
			<xsl:text>"terms":[{"jsonmodel_type":"term","term":"</xsl:text>
			<xsl:choose>

			<!-- Function terms -->
				<xsl:when test="Term_Type = 'Function'">
					<xsl:value-of select="Function_Act._Function"/>
					<xsl:text>","term_type":"function","vocabulary":"/vocabularies/1"}</xsl:text>
					<xsl:if test="Function_Act._Geogr_Subdiv__z">
						<xsl:choose>
							<xsl:when test="contains(Function_Act._Geogr_Subdiv__z,' --')">
								<xsl:for-each select="tokenize(Function_Act._Geogr_Subdiv__z,' --')">
									<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
									<xsl:value-of select="."/>
									<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
								<xsl:value-of select="Function_Act._Geogr_Subdiv__z"/>
								<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:when>

			<!-- Genre/Form terms -->
				<xsl:when test="Term_Type = 'Genre/Form'">
					<xsl:value-of select="Genre_Form_Genre-Form"/>
					<xsl:text>","term_type":"genre_form","vocabulary":"/vocabularies/1"}</xsl:text>
				</xsl:when>

			<!-- Geographic terms -->
				<xsl:when test="Term_Type = 'Geographic term'">
					<xsl:value-of select="Geographic_Term_Geogr_Name"/>
					<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
					<xsl:if test="Geographic_Term_Form_Subdiv__v">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Geographic_Term_Form_Subdiv__v"/>
						<xsl:text>","term_type":"genre_form","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Geographic_Term_General_Subdiv__x">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Geographic_Term_General_Subdiv__x"/>
						<xsl:text>","term_type":"topical","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Geographic_Term_Geogr_Subdiv__z">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Geographic_Term_Geogr_Subdiv__z"/>
						<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Geographic_Term_Chrono_Subdiv__y">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Geographic_Term_Chrono_Subdiv__y"/>
						<xsl:text>","term_type":"temporal","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
				</xsl:when>

			<!-- Occupational terms -->
				<xsl:when test="Term_Type = 'Occupation'">
					<xsl:choose>
						<xsl:when test="contains(Browse_Term,'--')">
							<xsl:value-of select="substring-before(Browse_Term,'--')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="Browse_Term"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>","term_type":"occupation","vocabulary":"/vocabularies/1"}</xsl:text>
					<xsl:if test="Occupation_Geogr_Subdiv__z">
						<xsl:choose>
							<xsl:when test="contains(Occupation_Geogr_Subdiv__z,' --')">
								<xsl:for-each select="tokenize(Occupation_Geogr_Subdiv__z,' --')">
									<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
									<xsl:value-of select="."/>
									<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
								<xsl:value-of select="Occupation_Geogr_Subdiv__z"/>
								<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Occupation_Form_Subdiv__v">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Occupation_Form_Subdiv__v"/>
						<xsl:text>","term_type":"genre_form","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Occupation_General_Subdiv__x">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Occupation_General_Subdiv__x"/>
						<xsl:text>","term_type":"topical","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
				</xsl:when>

			<!-- Topical terms -->
				<xsl:when test="Term_Type = 'Topic term'">
					<xsl:choose>
						<xsl:when test="contains(Browse_Term,'--')">
							<xsl:value-of select="substring-before(Browse_Term,'--')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="Browse_Term"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>","term_type":"topical","vocabulary":"/vocabularies/1"}</xsl:text>
					<xsl:if test="Topic_Term_General_Subdiv__x">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Topic_Term_General_Subdiv__x"/>
						<xsl:text>","term_type":"topical","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Topic_Term_Chrono_Subdiv__y">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Topic_Term_Chrono_Subdiv__y"/>
						<xsl:text>","term_type":"temporal","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Topic_Term_Geogr_Subdiv__z">
						<xsl:choose>
							<xsl:when test="contains(Topic_Term_Geogr_Subdiv__z,' --')">
								<xsl:for-each select="tokenize(Topic_Term_Geogr_Subdiv__z,' --')">
									<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
									<xsl:value-of select="."/>
									<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
								<xsl:value-of select="Topic_Term_Geogr_Subdiv__z"/>
								<xsl:text>","term_type":"geographic","vocabulary":"/vocabularies/1"}</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="Topic_Term_Subdiv_Form">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Topic_Term_Subdiv_Form"/>
						<xsl:text>","term_type":"genre_form","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Topic_Term_Dates">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Topic_Term_Dates"/>
						<xsl:text>","term_type":"temporal","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
				</xsl:when>

			<!-- Uniform titles -->
				<xsl:when test="Term_Type = 'Uniform title' or Term_Type = 'Uniform Title'">
					<xsl:choose>
						<xsl:when test="contains(Browse_Term,'--')">
							<xsl:value-of select="substring-before(Browse_Term,'--')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="Browse_Term"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>","term_type":"uniform_title","vocabulary":"/vocabularies/1"}</xsl:text>
					<xsl:if test="Uniform_Title_Part_Name">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Uniform_Title_Part_Name"/>
						<xsl:text>","term_type":"uniform_title","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Uniform_Title_Language">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Uniform_Title_Language"/>
						<xsl:text>","term_type":"topical","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
					<xsl:if test="Uniform_Title_Misc_Info">
						<xsl:text>,{"jsonmodel_type":"term","term":"</xsl:text>
						<xsl:value-of select="Uniform_Title_Misc_Info"/>
						<xsl:text>","term_type":"topical","vocabulary":"/vocabularies/1"}</xsl:text>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<xsl:text>],"vocabulary":"/vocabularies/1","authority_id":"codu:</xsl:text>
			<xsl:value-of select="ID"/>
			<xsl:text>","publish":true}</xsl:text>
		</xsl:result-document>
	</xsl:template>

</xsl:stylesheet>
