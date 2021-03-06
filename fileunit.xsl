<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	
	<xsl:output method="text"/>
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="records">
		<xsl:for-each select="record">
			<xsl:variable name="id" select="id"/>
			<xsl:variable name="uri" select="uri"/>
			<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
			<xsl:variable name="comp" select="tokenize($id,'\.')"/>
			<xsl:variable name="coll" select="$comp[1]"/>
			<xsl:variable name="series">
				<xsl:if test="string-length($comp[2]) = 2">
					<xsl:choose>
						<xsl:when test="string-length($comp[3]) = 2">
							<xsl:value-of select="concat($comp[2],'.',$comp[3])"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$comp[2]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:variable>
			<xsl:variable name="box">
				<xsl:choose>
					<xsl:when test="string-length($comp[2]) != 2">
						<xsl:value-of select="$comp[2]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string-length($comp[3]) = 2">
								<xsl:value-of select="$comp[4]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$comp[3]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="match">
				<xsl:value-of select="$coll"/>
				<xsl:if test="$series != ''">
					<xsl:value-of select="concat('.',$series)"/>
				</xsl:if>
				<xsl:if test="$box != ''">
					<xsl:value-of select="concat('.',$box)"/>
				</xsl:if>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="$series = '' and $box = ''">
					<xsl:if test="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][not(Series_Nbr)][not(matches(File_Unit_Nbr,'\.'))]">
						<!--<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][not(Series_Nbr)][not(matches(File_Unit_Nbr,'\.'))]">
							<xsl:value-of select="concat('Folder: ',Collection_Nbr,'.',File_Unit_Nbr,'&#10;')"/>
						</xsl:for-each>-->
						<xsl:result-document href="children/fileunit/{$path}.json" method="text">
							<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
							<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][not(Series_Nbr)][not(matches(File_Unit_Nbr,'\.'))]">
								<xsl:call-template name="child">
									<xsl:with-param name="parent" select="$id"/>
									<xsl:with-param name="component_id" select="concat(Collection_Nbr,'.',File_Unit_Nbr)"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:text>]}</xsl:text>
						</xsl:result-document>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$series != '' and $box = ''">
					<xsl:if test="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][Series_Nbr = $series][not(matches(File_Unit_Nbr,'\.'))]">
						<!--<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][Series_Nbr = $series][not(matches(File_Unit_Nbr,'\.'))]">
							<xsl:value-of select="concat('Folder: ',Collection_Nbr,'.',Series_Nbr,'.',File_Unit_Nbr,'&#10;')"/>
						</xsl:for-each>-->
						<xsl:result-document href="children/fileunit/{$path}.json" method="text">
							<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
							<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][Series_Nbr = $series][not(matches(File_Unit_Nbr,'\.'))]">
								<xsl:call-template name="child">
									<xsl:with-param name="parent" select="$id"/>
									<xsl:with-param name="component_id" select="concat(Collection_Nbr,'.',Series_Nbr,'.',File_Unit_Nbr)"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:text>]}</xsl:text>
						</xsl:result-document>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$series = '' and $box != ''">
					<xsl:if test="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][not(Series_Nbr)][matches(File_Unit_Nbr,concat($box,'.'))]">
						<!--<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][not(Series_Nbr)][matches(File_Unit_Nbr,concat($box,'.'))]">
							<xsl:value-of select="concat('Folder: ',Collection_Nbr,'.',File_Unit_Nbr,'&#10;')"/>
						</xsl:for-each>-->
						<xsl:result-document href="children/fileunit/{$path}.json" method="text">
							<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
							<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][not(Series_Nbr)][matches(File_Unit_Nbr,concat($box,'.'))]">
								<xsl:call-template name="child">
									<xsl:with-param name="parent" select="$id"/>
									<xsl:with-param name="component_id" select="concat(Collection_Nbr,'.',File_Unit_Nbr)"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:text>]}</xsl:text>
						</xsl:result-document>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][Series_Nbr = $series][matches(File_Unit_Nbr,concat($box,'.'))]">
						<!--<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][Series_Nbr = $series][matches(File_Unit_Nbr,concat($box,'.'))]">
							<xsl:value-of select="concat('Folder: ',Collection_Nbr,'.',Series_Nbr,'.',File_Unit_Nbr,'&#10;')"/>
						</xsl:for-each>-->
						<xsl:result-document href="children/fileunit/{$path}.json" method="text">
							<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
							<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Category = 'FILEUNIT'][Collection_Nbr = $coll][Series_Nbr = $series][matches(File_Unit_Nbr,concat($box,'.'))]">
								<xsl:call-template name="child">
									<xsl:with-param name="parent" select="$id"/>
									<xsl:with-param name="component_id" select="concat(Collection_Nbr,'.',Series_Nbr,'.',File_Unit_Nbr)"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:text>]}</xsl:text>
						</xsl:result-document>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="child">
		<xsl:param name="parent"/>
		<xsl:param name="component_id"/>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		
		<xsl:text>{"jsonmodel_type":"archival_object","title":</xsl:text>
		<xsl:choose>
			<xsl:when test="not(Title)">
				<xsl:variable name="x" select="replace(File_Unit_Nbr,'^0+','')"/>
				<xsl:value-of select="concat($quot,'Folder ',$x,$quot)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($quot,replace(replace(Title,$quot,$qrep),'&#09;',''),$quot)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>,"component_id":</xsl:text>
		<xsl:value-of select="concat($quot,$component_id,$quot)"/>
		<xsl:text>,"level":"series","publish":true,</xsl:text>
				
		<!-- DATES -->
		<xsl:text>"dates":[</xsl:text>
		<xsl:if test="Incl_Dates">
			<xsl:text>{"jsonmodel_type":"date","label":"creation","date_type":"inclusive","expression":</xsl:text>
			<xsl:value-of select="concat($quot,Incl_Dates,$quot)"/>
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
					<xsl:call-template name="roles">
						<xsl:with-param name="role" select="Creator_Role"/>
					</xsl:call-template>
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
				<xsl:variable name="model">
					<xsl:for-each select="document('tables/agents.xml')/records/record">
						<xsl:if test="title = $corp">
							<xsl:value-of select="type"/>
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
		<xsl:if test="Added_Entry">
			<xsl:for-each select="tokenize(Added_Entry, ' \|\|')">
				<xsl:variable name="entry">
					<xsl:value-of select="replace(substring-before(.,' __'),'--',' ')"/>
				</xsl:variable>
				<xsl:variable name="ref">
					<xsl:for-each select="document('tables/agents.xml')/records/record">
						<xsl:if test="title = $entry">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$ref != ''">
					<xsl:text>{"role":"subject",</xsl:text>
					<xsl:if test="substring-after(.,' __')">
						<xsl:call-template name="roles">
							<xsl:with-param name="role" select="substring-after(.,' __')"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:text>"ref":</xsl:text>
					<xsl:value-of select="concat($quot,$ref,$quot)"/>
					<xsl:text>},</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:text>],</xsl:text>
						
		<!-- SUBJECTS -->
		<xsl:text>"subjects":[</xsl:text>
		<xsl:if test="Topic_Term or Geogr_Name or Genre_Form 
								or Form_Genre or Occupation or Function_Act
								or Meeting_Name or Uniform_Title">
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
			<xsl:if test="Form_Genre">
				<xsl:for-each select="tokenize(Form_Genre, ' --')">
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
			<xsl:if test="Function_Act">
				<xsl:for-each select="tokenize(Function_Act, ' --')">
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
			<xsl:if test="Uniform_Title">
				<xsl:for-each select="tokenize(Uniform_Title, ' --')">
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
		<xsl:text>"notes":[</xsl:text>
		<xsl:if test="Description or Handling_Inst or Notes">
			<xsl:if test="Description">
				<xsl:text>{"jsonmodel_type":"note_singlepart","publish":true,"type":"abstract","content":[</xsl:text>
				<xsl:value-of select="concat($quot,replace(replace(Description,'&#10;',' '),$quot,$qrep),$quot)"/>
				<xsl:text>]</xsl:text>
				<xsl:choose>
					<xsl:when test="Handling_Inst or Notes">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Handling_Inst">
				<xsl:text>{"jsonmodel_type":"note_singlepart","publish":true,"type":"materialspec","content":[</xsl:text>
				<xsl:value-of select="concat($quot,replace(replace(Handling_Inst,'&#10;',' '),$quot,$qrep),$quot)"/>
				<xsl:text>]</xsl:text>
				<xsl:choose>
					<xsl:when test="Notes">
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
				<xsl:text>,"publish":true}]}</xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:text>],</xsl:text>
				
		<!-- INSTANCES: -->
		<xsl:text>"instances":[{"instance_type":"mixed_materials","container":{"jsonmodel_type":"container",</xsl:text>
		<xsl:choose>
			<xsl:when test="Category = 'CONTAINER'">
				<xsl:text>"type_1":"box",</xsl:text>
			</xsl:when>
			<xsl:when test="Category = 'FILEUNIT'">
				<xsl:text>"type_1":"folder",</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>"indicator_1":</xsl:text>
		<xsl:value-of select="concat($quot,$component_id,$quot)"/>
		<xsl:if test="Barcode or Barcode_1">
			<xsl:text>,"barcode_1":</xsl:text>
			<xsl:choose>
				<xsl:when test="Barcode">
					<xsl:value-of select="concat($quot,Barcode,$quot)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($quot,Barcode_1,$quot)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:text>}}]</xsl:text>
		<xsl:choose>
			<xsl:when test="position() != last()">
				<xsl:text>},</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>}</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="roles">
		<xsl:param name="role"/>
		<xsl:choose>
			<xsl:when test="$role = 'Artist'">
				<xsl:text>"relator":"art",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Author'">
				<xsl:text>"relator":"aut",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Composer'">
				<xsl:text>"relator":"cmp",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Contributor'">
				<xsl:text>"relator":"ctb",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Designer'">
				<xsl:text>"relator":"dsr",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Editor'">
				<xsl:text>"relator":"edt",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Film editor'">
				<xsl:text>"relator":"flm",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Funder'">
				<xsl:text>"relator":"fnd",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Interviewee'">
				<xsl:text>"relator":"ive",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Interviewer'">
				<xsl:text>"relator":"ivr",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Narrator'">
				<xsl:text>"relator":"nrt",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Photographer' or $role = 'PhotogrSchwaberow, Jamie'">
				<xsl:text>"relator":"pht",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Producer'">
				<xsl:text>"relator":"pro",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Recipient'">
				<xsl:text>"relator":"rcp",</xsl:text>
			</xsl:when>
			<xsl:when test="$role = 'Speaker'">
				<xsl:text>"relator":"spk",</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="find_links">
		<xsl:param name="parent"/>
		<xsl:variable name="component_id" select="concat($parent,'.',File_Unit_Nbr)"/>
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
			<xsl:if test="$ref = ''">
				<xsl:value-of select="concat($component_id,': missing agent: ',$n,'&#10;')"/>
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
				<xsl:if test="$ref = ''">
					<xsl:value-of select="concat($component_id,': missing agent: ',$n,'&#10;')"/>
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
				<xsl:if test="$ref = ''">
					<xsl:value-of select="concat($component_id,': missing agent: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Added_Entry">
			<xsl:for-each select="tokenize(Added_Entry, ' \|\|')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(substring-before(.,' __'),'--',' ')"/>
				</xsl:variable>
				<xsl:variable name="ref">
					<xsl:for-each select="document('tables/agents.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$ref = ''">
					<xsl:value-of select="concat($component_id,': missing agent: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Meeting_Name">
			<xsl:for-each select="tokenize(Meeting_Name, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(substring-before(.,' __'),'--',' ')"/>
				</xsl:variable>
				<xsl:variable name="ref">
					<xsl:for-each select="document('tables/agents.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$ref = ''">
					<xsl:value-of select="concat($component_id,': missing agent: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Topic_Term">
			<xsl:for-each select="tokenize(Topic_Term, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(.,'--',' -- ')"/>
				</xsl:variable>
				<xsl:variable name="term">
					<xsl:for-each select="document('tables/subjects.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$term = ''">
					<xsl:value-of select="concat($component_id,': missing subject: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Geogr_Name">
			<xsl:for-each select="tokenize(Geogr_Name, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(.,'--',' -- ')"/>
				</xsl:variable>
				<xsl:variable name="term">
					<xsl:for-each select="document('tables/subjects.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$term = ''">
					<xsl:value-of select="concat($component_id,': missing subject: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Genre_Form">
			<xsl:for-each select="tokenize(Genre_Form, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(.,'--',' -- ')"/>
				</xsl:variable>
				<xsl:variable name="term">
					<xsl:for-each select="document('tables/subjects.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$term = ''">
					<xsl:value-of select="concat($component_id,': missing subject: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Occupation">
			<xsl:for-each select="tokenize(Occupation, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(.,'--',' -- ')"/>
				</xsl:variable>
				<xsl:variable name="term">
					<xsl:for-each select="document('tables/subjects.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$term = ''">
					<xsl:value-of select="concat($component_id,': missing subject: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Function_Act">
			<xsl:for-each select="tokenize(Function_Act, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(.,'--',' -- ')"/>
				</xsl:variable>
				<xsl:variable name="term">
					<xsl:for-each select="document('tables/subjects.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$term = ''">
					<xsl:value-of select="concat($component_id,': missing subject: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="Uniform_Title">
			<xsl:for-each select="tokenize(Uniform_Title, ' --')">
				<xsl:variable name="n">
					<xsl:value-of select="replace(.,'--',' -- ')"/>
				</xsl:variable>
				<xsl:variable name="term">
					<xsl:for-each select="document('tables/subjects.xml')/records/record">
						<xsl:if test="title = $n">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$term = ''">
					<xsl:value-of select="concat($component_id,': missing subject: ',$n,'&#10;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>