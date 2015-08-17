<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:json="http://json.org" xmlns:marc="http://www.loc.gov/MARC21/slim">
	
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="NewDataSet">
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:for-each select="RediscoveryExport">
			<xsl:variable name="id" select="Record_Id"/>
			<xsl:result-document href="accessions/{$id}.json" method="text">
				<xsl:text>{"jsonmodel_type":"accession","title":</xsl:text>
				<xsl:value-of select="concat($quot,'Accession ',Accession,$quot,',')"/>
				<xsl:text>"id_0":</xsl:text>
				<xsl:value-of select="concat($quot,Accession,$quot,',')"/>
				<xsl:text>"accession_date":</xsl:text>
				<xsl:variable name="date">
					<xsl:choose>
						<xsl:when test="Accession_Date">
							<xsl:analyze-string select="substring-before(Accession_Date,' 12:00:00 AM')" regex="([0-9]+)/([0-9]+)/([0-9]+)">
								<xsl:matching-substring>
									<xsl:variable name="year" select="regex-group(3)"/>
									<xsl:variable name="month">
										<xsl:choose>
											<xsl:when test="string-length(regex-group(1)) = 1">
												<xsl:value-of select="concat('0',regex-group(1))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="regex-group(1)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="day">
										<xsl:choose>
											<xsl:when test="string-length(regex-group(2)) = 1">
												<xsl:value-of select="concat('0',regex-group(2))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="regex-group(2)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:value-of select="concat($year,'-',$month,'-',$day)"/>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<xsl:text/>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:when>
						<xsl:when test="not(Accession_Date) and Acq_Date">
							<xsl:analyze-string select="substring-before(Acq_Date,' 12:00:00 AM')" regex="([0-9]+)/([0-9]+)/([0-9]+)">
								<xsl:matching-substring>
									<xsl:variable name="year" select="regex-group(3)"/>
									<xsl:variable name="month">
										<xsl:choose>
											<xsl:when test="string-length(regex-group(1)) = 1">
												<xsl:value-of select="concat('0',regex-group(1))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="regex-group(1)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="day">
										<xsl:choose>
											<xsl:when test="string-length(regex-group(2)) = 1">
												<xsl:value-of select="concat('0',regex-group(2))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="regex-group(2)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:value-of select="concat($year,'-',$month,'-',$day)"/>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<xsl:text/>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>2014-07-29</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="concat($quot,$date,$quot,',')"/>
				<xsl:if test="Description">
					<xsl:text>"content_description":</xsl:text>
					<xsl:value-of select="concat($quot,replace(replace(replace(Description,'&#10;','; '),'&#09;',', '),$quot,$qrep),$quot,',')"/>
				</xsl:if>
				<xsl:if test="Action_Reqd">
					<xsl:text>"condition_description":</xsl:text>
					<xsl:value-of select="concat($quot,replace(replace(replace(Action_Reqd,'&#10;','; '),'&#09;',', '),$quot,$qrep),$quot,',')"/>
				</xsl:if>
				<xsl:if test="Archival_Appraisal">
					<xsl:text>"disposition":</xsl:text>
					<xsl:value-of select="concat($quot,replace(replace(replace(Archival_Appraisal,'&#10;','; '),'&#09;',', '),$quot,$qrep),$quot,',')"/>
				</xsl:if>
				<xsl:if test="Provenance">
					<xsl:text>"provenance":</xsl:text>
					<xsl:value-of select="concat($quot,replace(replace(replace(Provenance,'&#10;','; '),'&#09;',', '),$quot,$qrep),$quot,',')"/>
				</xsl:if>
				<xsl:if test="Acq_Method">
					<xsl:choose>
						<xsl:when test="Acq_Method = 'Bequest' or Acq_Method = 'Gift'">
							<xsl:text>"acquisition_type":"gift",</xsl:text>
						</xsl:when>
						<xsl:when test="Acq_Method = 'Purchase'">
							<xsl:text>"acquisition_type":"purchase",</xsl:text>
						</xsl:when>
						<xsl:when test="Acq_Method = 'Transfer'">
							<xsl:text>"acquisition_type":"transfer",</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
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
						<xsl:value-of select="concat($quot,replace(replace(replace($ext_note,'&#10;','; '),'&#09;',', '),$quot,$qrep),$quot)"/>
						<xsl:text>}</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>{"jsonmodel_type":"extent","portion":"whole","number":"0","extent_type":"linear_feet"}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>]</xsl:text>
				<xsl:if test="Acq_Status">
					<xsl:text>,"collection_management":{"jsonmodel_type":"collection_management",</xsl:text>
					<xsl:choose>
						<xsl:when test="Acq_Status = 'Complete'">
							<xsl:text>"processing_status":"completed"</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>"processing_status":"in_progress"</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>}</xsl:text>
				</xsl:if>
				<xsl:if test="Approv_By or Approv_Date or Contact_Name or Credit_Line or Note_s_ or Source or Title_Status">
					<xsl:text>,"general_note":</xsl:text>
					<xsl:variable name="note">
						<xsl:if test="Approv_By or Approv_Date">
							<xsl:if test="Approv_By">
								<xsl:value-of select="concat('Approved by ',Approv_By)"/>
								<xsl:choose>
									<xsl:when test="Approv_Date">
										<xsl:text>, </xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>. </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="Approv_Date">
								<xsl:if test="not(Approv_By)">
									<xsl:text>Approved </xsl:text>
								</xsl:if>
								<xsl:value-of select="concat(replace(Approv_Date,' 12:00:00 AM',''),'. ')"/>
							</xsl:if>
						</xsl:if>
						<xsl:if test="Contact_Name">
							<xsl:value-of select="concat('Contact: ',Contact_Name,'. ')"/>
						</xsl:if>
						<xsl:if test="Credit_Line">
							<xsl:value-of select="concat('Credit: ',Credit_Line,'. ')"/>
						</xsl:if>
						<xsl:if test="Note_s_">
							<xsl:value-of select="concat('Note: ',Note_s_,'. ')"/>
						</xsl:if>
						<xsl:if test="Source">
							<xsl:value-of select="concat('Source: ',Source,'. ')"/>
						</xsl:if>
						<xsl:if test="Title_Status">
							<xsl:value-of select="concat('Title Status: ',Title_Status,'. ')"/>
						</xsl:if>
					</xsl:variable>
					<xsl:value-of select="concat($quot,replace(replace(replace(replace($note,'&#10;','; '),'&#09;',', '),$quot,$qrep),'. $','.'),$quot)"/>
				</xsl:if>
				<xsl:if test="Acq_Price or Acq_Value">
					<xsl:text>,"user_defined":{"jsonmodel_type":"user_defined",</xsl:text>
					<xsl:if test="Acq_Price">
						<xsl:text>"real_1":</xsl:text>
						<xsl:value-of select="concat($quot,Acq_Price,$quot)"/>
						<xsl:if test="Acq_Value">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:if test="Acq_Value">
						<xsl:text>"real_2":</xsl:text>
						<xsl:value-of select="concat($quot,Acq_Value,$quot)"/>
					</xsl:if>
					<xsl:text>}</xsl:text>
				</xsl:if>
				<xsl:text>,"publish":false}</xsl:text>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>


</xsl:stylesheet>

