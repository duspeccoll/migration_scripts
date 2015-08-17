<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	
	<xsl:output method="text"/>
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="NewDataSet">
		<xsl:for-each select="RediscoveryExport[starts-with(Collection_Nbr,'M')]">
			<xsl:variable name="coll" select="Collection_Nbr"/>
			<xsl:for-each select="document('series.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll]">
				<xsl:variable name="series" select="Series_Nbr"/>
				<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][matches(File_Unit_Nbr,'^\d{4}$')]">
					<xsl:variable name="box" select="File_Unit_Nbr"/>
					<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][starts-with(File_Unit_Nbr,concat($box,'.'))]">
						<xsl:variable name="folder" select="substring-after(File_Unit_Nbr,'.')"/>
						<xsl:variable name="fileunit" select="File_Unit_Nbr"/>
						<xsl:if test="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][File_Unit_Nbr = $fileunit]">
							<xsl:variable name="parent" select="concat($coll,'.',$series,'.',$box,'.',$folder)"/>
							<xsl:variable name="uri">
								<xsl:for-each select="document('tables/objects.xml')/records/record[id = $parent]">
									<xsl:if test="position() = 1">
										<xsl:value-of select="uri"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
							<xsl:result-document href="children/item/{$path}.json" method="text">
								<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
								<xsl:for-each select="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][File_Unit_Nbr = $fileunit]">
									<xsl:variable name="item" select="Item_Nbr"/>
									<xsl:variable name="component_id" select="concat($coll,'.',$series,'.',$box,'.',$folder,'.',$item)"/>
									<xsl:call-template name="child">
										<xsl:with-param name="parent" select="$parent"/>
										<xsl:with-param name="uri" select="$uri"/>
										<xsl:with-param name="component_id" select="$component_id"/>
									</xsl:call-template>
								</xsl:for-each>
								<xsl:text>]}</xsl:text>
							</xsl:result-document>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][File_Unit_Nbr = $box]">
						<xsl:variable name="parent" select="concat($coll,'.',$series,'.',$box)"/>
						<xsl:variable name="uri">
							<xsl:for-each select="document('tables/objects.xml')/records/record[id = $parent]">
								<xsl:if test="position() = 1">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
						<xsl:result-document href="children/item/{$path}.json" method="text">
							<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
							<xsl:for-each select="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][File_Unit_Nbr = $box]">
								<xsl:variable name="item" select="Item_Nbr"/>
								<xsl:variable name="component_id" select="concat($coll,'.',$series,'.',$box,'.',$item)"/>
								<xsl:call-template name="child">
									<xsl:with-param name="parent" select="$parent"/>
									<xsl:with-param name="uri" select="$uri"/>
									<xsl:with-param name="component_id" select="$component_id"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:text>]}</xsl:text>
						</xsl:result-document>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][not(File_Unit_Nbr)]">
					<xsl:variable name="parent" select="concat($coll,'.',$series)"/>
					<xsl:variable name="uri">
						<xsl:for-each select="document('tables/objects.xml')/records/record[id = $parent]">
							<xsl:if test="position() = 1">
								<xsl:value-of select="uri"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
					<xsl:result-document href="children/item/{$path}.json" method="text">
						<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
						<xsl:for-each select="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][Series_Nbr = $series][not(File_Unit_Nbr)]">
							<xsl:variable name="item" select="Item_Nbr"/>
							<xsl:variable name="component_id" select="concat($coll,'.',$series,'.',$item)"/>
							<xsl:call-template name="child">
								<xsl:with-param name="parent" select="$parent"/>
								<xsl:with-param name="uri" select="$uri"/>
								<xsl:with-param name="component_id" select="$component_id"/>
							</xsl:call-template>
						</xsl:for-each>
						<xsl:text>]}</xsl:text>
					</xsl:result-document>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][matches(File_Unit_Nbr,'^\d{4}$')]">
				<xsl:variable name="box" select="File_Unit_Nbr"/>
				<xsl:for-each select="document('fileunit.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][starts-with(File_Unit_Nbr,concat($box,'.'))]">
					<xsl:variable name="folder" select="substring-after(File_Unit_Nbr,'.')"/>
					<xsl:variable name="fileunit" select="File_Unit_Nbr"/>
					<xsl:if test="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][File_Unit_Nbr = $fileunit]">
						<xsl:variable name="parent" select="concat($coll,'.',$box,'.',$folder)"/>
						<xsl:variable name="uri">
							<xsl:for-each select="document('tables/objects.xml')/records/record[id = $parent]">
								<xsl:if test="position() = 1">
									<xsl:value-of select="uri"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
						<xsl:result-document href="children/item/{$path}.json" method="text">
							<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
							<xsl:for-each select="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][File_Unit_Nbr = $fileunit]">
								<xsl:variable name="item" select="Item_Nbr"/>
								<xsl:variable name="component_id" select="concat($coll,'.',$box,'.',$folder,'.',$item)"/>
								<xsl:call-template name="child">
									<xsl:with-param name="parent" select="$parent"/>
									<xsl:with-param name="uri" select="$uri"/>
									<xsl:with-param name="component_id" select="$component_id"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:text>]}</xsl:text>
						</xsl:result-document>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][File_Unit_Nbr = $box]">
					<xsl:variable name="parent" select="concat($coll,'.',$box)"/>
					<xsl:variable name="uri">
						<xsl:for-each select="document('tables/objects.xml')/records/record[id = $parent]">
							<xsl:if test="position() = 1">
								<xsl:value-of select="uri"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
					<xsl:result-document href="children/item/{$path}.json" method="text">
						<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
						<xsl:for-each select="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][File_Unit_Nbr = $box]">
							<xsl:variable name="item" select="Item_Nbr"/>
							<xsl:variable name="component_id" select="concat($coll,'.',$box,'.',$item)"/>
							<xsl:call-template name="child">
								<xsl:with-param name="parent" select="$parent"/>
								<xsl:with-param name="uri" select="$uri"/>
								<xsl:with-param name="component_id" select="$component_id"/>
							</xsl:call-template>
						</xsl:for-each>
						<xsl:text>]}</xsl:text>
					</xsl:result-document>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][not(File_Unit_Nbr)]">
				<xsl:variable name="parent" select="$coll"/>
				<xsl:variable name="uri">
					<xsl:for-each select="document('tables/resources.xml')/records/record[id = $parent]">
						<xsl:if test="position() = 1">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="path" select="substring-after($uri,'/repositories/2/')"/>
				<xsl:result-document href="children/item/{$path}.json" method="text">
					<xsl:text>{"jsonmodel_type":"archival_record_children","children":[</xsl:text>
					<xsl:for-each select="document('item.xml')/NewDataSet/RediscoveryExport[Collection_Nbr = $coll][not(Series_Nbr)][not(File_Unit_Nbr)]">
						<xsl:variable name="item" select="Item_Nbr"/>
						<xsl:variable name="component_id" select="concat($coll,'.',$item)"/>
						<xsl:call-template name="child">
							<xsl:with-param name="parent" select="$parent"/>
							<xsl:with-param name="uri" select="$uri"/>
							<xsl:with-param name="component_id" select="$component_id"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:text>]}</xsl:text>
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
		
	<xsl:template name="child">
		<xsl:param name="parent"/>
		<xsl:param name="uri"/>
		<xsl:param name="component_id"/>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
				
		<!-- declare archival_record_children data model -->
		<xsl:text>{"jsonmodel_type":"archival_object",</xsl:text>
		<xsl:choose>
			<xsl:when test="matches($uri,'resources')">
				<xsl:text>"resource":{"ref":</xsl:text>
				<xsl:value-of select="concat($quot,$uri,$quot)"/>
				<xsl:text>},</xsl:text>
			</xsl:when>
			<xsl:when test="matches($uri,'archival_objects')">
				<xsl:variable name="r" select="tokenize($parent,'\.')"/>
				<xsl:text>"parent":{"ref":</xsl:text>
				<xsl:value-of select="concat($quot,$uri,$quot)"/>
				<xsl:text>},"resource":{"ref":</xsl:text>
				<xsl:variable name="ref">
					<xsl:for-each select="document('tables/resources.xml')/records/record">
						<xsl:if test="id = $r[1]">
							<xsl:value-of select="uri"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:value-of select="concat($quot,$ref,$quot)"/>
				<xsl:text>},</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>"title":</xsl:text>
		<xsl:choose>
			<xsl:when test="not(Title)">
				<xsl:variable name="x" select="replace(Item_Nbr,'^0+','')"/>
				<xsl:value-of select="concat($quot,'Item ',$x,$quot)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($quot,replace(replace(Title,$quot,$qrep),'&#09;',''),$quot)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>,"component_id":</xsl:text>
		<xsl:value-of select="concat($quot,$component_id,$quot)"/>
		<xsl:text>,"level":"item",</xsl:text>
		<xsl:if test="Language">
			<xsl:text>"language":</xsl:text>
			<xsl:value-of select="concat($quot,substring-after(Language,' __'),$quot,',')"/>
		</xsl:if>
		<xsl:text>"publish":true,</xsl:text>
				
		<!-- DATES -->
		<xsl:text>"dates":[</xsl:text>
		<xsl:if test="Dates">
			<xsl:text>{"jsonmodel_type":"date","label":"creation",</xsl:text>
			<xsl:choose>
				<xsl:when test="contains(Dates,'-')">
					<xsl:text>"date_type":"range",</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>"date_type":"single",</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>"expression":</xsl:text>
			<xsl:value-of select="concat($quot,Dates,$quot)"/>
			<xsl:text>}</xsl:text>
		</xsl:if>
		<xsl:text>],</xsl:text>
						
		<!-- EXTENTS -->
		<xsl:text>"extents":[</xsl:text>
		<xsl:if test="Extent">
			<xsl:variable name="ext" select="tokenize(Extent,' __')"/>
			<xsl:variable name="ext_number" select="$ext[1]"/>
			<xsl:variable name="ext_unit" select="$ext[2]"/>
			<xsl:variable name="ext_note" select="$ext[3]"/>
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
					<xsl:value-of select="concat($quot,replace($ext_unit,$quot,$qrep),$quot,',')"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>"container_summary":</xsl:text>
			<xsl:value-of select="concat($quot,replace($ext_note,$quot,$qrep),$quot)"/>
			<xsl:if test="Dimensions">
				<xsl:text>,"dimensions":</xsl:text>
				<xsl:value-of select="concat($quot,replace(Dimensions,$quot,$qrep),$quot)"/>
			</xsl:if>
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
		<xsl:if test="Meeting_Name">
			<xsl:for-each select="tokenize(Meeting_Name, ' --')">
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
				<xsl:if test="$term != ''">
					<xsl:text>{"ref":</xsl:text>
					<xsl:value-of select="concat($quot,$term,$quot)"/>
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
		<xsl:if test="Topic_Term or Geogr_Name or Genre_Form or Occupation or Function_Act. or Uniform_Title">
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
		<!-- (there are many different types of note) -->
		<xsl:text>"notes":[</xsl:text>
		<xsl:if test="Alternate_Title_s_ or Digital_Origin or Notes or Alternate_Format_s_ or Description
					or Language_Language_Code">
			<xsl:if test="Alternate_Title_s_ or Digital_Origin or Notes">
				<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"odd","subnotes":[</xsl:text>
				<xsl:if test="Alternate_Title_s_">
					<xsl:text>{"jsonmodel_type":"note_text","label":"Alternate Title","content":</xsl:text>
					<xsl:choose>
						<xsl:when test="contains(Alternate_Title_s_,' __')">
							<xsl:value-of select="concat($quot,replace(replace(replace(Alternate_Title_s_,' __',': '),'&#10;',' '),$quot,$qrep),$quot)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($quot,replace(replace(Alternate_Title_s_,'&#10;',' '),$quot,$qrep),$quot)"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>,"publish":true</xsl:text>
					<xsl:choose>
						<xsl:when test="Digital_Origin or Notes">
							<xsl:text>},</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>}</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="Digital_Origin">
					<xsl:text>{"jsonmodel_type":"note_text","label":"Digital Origin","content":</xsl:text>
					<xsl:value-of select="concat($quot,Digital_Origin,$quot)"/>
					<xsl:text>,"publish":true</xsl:text>
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
					<xsl:text>{"jsonmodel_type":"note_text","label":"Notes","content":</xsl:text>
					<xsl:value-of select="concat($quot,replace(replace(replace(replace(Notes,'&#10;',' '),'&#09;',''),'\\','\\\\'),$quot,$qrep),$quot)"/>
					<xsl:text>,"publish":true}</xsl:text>
				</xsl:if>
				<xsl:text>]</xsl:text>
				<xsl:choose>
					<xsl:when test="Alternate_Format_s_ or Description or Language_Language_Code">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Alternate_Format_s_">
				<xsl:text>{"jsonmodel_type":"note_multipart","publish":true,"type":"relatedmaterial","subnotes":[</xsl:text>
				<xsl:text>{"jsonmodel_type":"note_text","content":</xsl:text>
				<xsl:value-of select="concat($quot,replace(replace(replace(replace(Alternate_Format_s_,'&#10;',' '),'&#09;',''),'\\','\\\\'),$quot,$qrep),$quot)"/>
				<xsl:text>,"publish":true}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Description or Language_Language_Code">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Description">
				<xsl:text>{"jsonmodel_type":"note_singlepart","publish":true,"type":"abstract","content":[</xsl:text>
				<xsl:value-of select="concat($quot,replace(replace(Description,'&#10;',' '),$quot,$qrep),$quot)"/>
				<xsl:text>]</xsl:text>
				<xsl:choose>
					<xsl:when test="Language_Language_Code">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Language_Language_Code">
				<xsl:text>{"jsonmodel_type":"note_singlepart","publish":true,"type":"langmaterial","content":[</xsl:text>
				<xsl:value-of select="concat($quot,Language_Language_Code,$quot)"/>
				<xsl:text>]}</xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:text>],</xsl:text>
				
		<!-- LINKS OUT -->
		<xsl:text>"external_documents":[</xsl:text>
		<xsl:if test="Handle">
			<xsl:text>{"jsonmodel_type":"external_document","title":"Digital DU link","location":</xsl:text>
			<xsl:value-of select="concat($quot,'http:\/\/digitaldu.coalliance.org\/fedora\/repository\/',Handle,$quot)"/>
			<xsl:text>,"publish":true}</xsl:text>
		</xsl:if>
		<xsl:text>],</xsl:text>
				
				
		<!-- INSTANCES: -->
		<xsl:text>"instances":[{"jsonmodel_type":"instance",</xsl:text>
		<xsl:choose>
			<xsl:when test="Category">
				<xsl:call-template name="instance_type">
					<xsl:with-param name="category" select="Category"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>"instance_type":"mixed_materials",</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>"container":{"jsonmodel_type":"container","type_1":"object","indicator_1":</xsl:text>
		<xsl:value-of select="concat($quot,$component_id,$quot)"/>
		<xsl:if test="Barcode">
			<xsl:text>,"barcode_1":</xsl:text>
			<xsl:value-of select="concat($quot,Barcode,$quot)"/>
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
		
	<xsl:template name="instance_type">
		<xsl:param name="category"/>
		<xsl:choose>
			<xsl:when test="$category = 'GRAPHIC MATERIALS' or $category = 'still image'">
				<xsl:text>"instance_type":"graphic_materials",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'cartographic'">
				<xsl:text>"instance_type":"maps",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'mixed material'">
				<xsl:text>"instance_type":"mixed_materials",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'moving image'">
				<xsl:text>"instance_type":"moving_images",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'notated music'">
				<xsl:text>"instance_type":"notated_music",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'sound recording-musical' or $category = 'sound recording-nonmusical'">
				<xsl:text>"instance_type":"audio",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'text'">
				<xsl:text>"instance_type":"text",</xsl:text>
			</xsl:when>
			<xsl:when test="$category = 'three dimensional object'">
				<xsl:text>"instance_type":"realia",</xsl:text>
			</xsl:when>
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
</xsl:stylesheet>