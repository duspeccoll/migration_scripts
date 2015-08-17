<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

	<xsl:output method="text"/>

	<xsl:template name="escape">
		<xsl:param name="field"/>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:variable name="nl">\n</xsl:variable>
		<xsl:variable name="nlrep">\\n</xsl:variable>
		<xsl:variable name="result">
			<xsl:value-of select="replace(replace(replace($field,$quot,$qrep),$nl,$nlrep),'__','')"/>
		</xsl:variable>
		<xsl:value-of select="concat($quot,$result,$quot)"/>
	</xsl:template>
	
	<xsl:template match="/NewDataSet">
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="qrep">\\"</xsl:variable>
		<xsl:text>{"records":[</xsl:text>
		<xsl:for-each select="RediscoveryExport">
			<xsl:variable name="id">
				<xsl:value-of select="Collection_Nbr"/>
				<xsl:if test="Series_Nbr">
					<xsl:value-of select="concat('.',Series_Nbr)"/>
				</xsl:if>
				<xsl:value-of select="concat('.',File_Unit_Nbr,'.',Item_Nbr)"/>
			</xsl:variable>
			<xsl:variable name="uri">
				<xsl:for-each select="document('archives/tables/objects.xml')/records/record[id = $id]">
					<xsl:value-of select="uri"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:text>{"uri":</xsl:text>
			<xsl:choose>
				<xsl:when test="$uri != ''">
					<xsl:value-of select="concat($quot,$uri,$quot)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($quot,$id,$quot)"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>,"notes":[</xsl:text>
			<xsl:if test="Drawing_Nbr">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"odd","label":"Drawing Number","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Drawing_Nbr"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Inscr_Marks or Item_Status or Map_Source or Phys_Char or Provenance or Rights_Usage or Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Inscr_Marks">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"odd","label":"Inscription and Marks","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Inscr_Marks"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Item_Status or Map_Source or Phys_Char or Provenance or Rights_Usage or Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Item_Status">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"odd","label":"Item Status","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Item_Status"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Map_Source or Phys_Char or Provenance or Rights_Usage or Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Map_Source">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"odd","label":"Map Source","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Map_Source"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Phys_Char or Provenance or Rights_Usage or Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Phys_Char">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"phystech","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Phys_Char"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Provenance or Rights_Usage or Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Provenance">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"custodhist","label":"Provenance","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Provenance"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Rights_Usage or Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Rights_Usage">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"userestrict","label":"Rights and Usage Statement","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Rights_Usage"/>
				</xsl:call-template>
				<xsl:text>}]</xsl:text>
				<xsl:choose>
					<xsl:when test="Summary_Note">
						<xsl:text>},</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Summary_Note">
				<xsl:text>{"jsonmodel_type":"note_multipart","type":"odd","label":"Summary Note","publish":true,"subnotes":[{"jsonmodel_type":"note_text","publish":true,"content":</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="field" select="Summary_Note"/>
				</xsl:call-template>
				<xsl:text>}]}</xsl:text>
			</xsl:if>
			<xsl:text>]}</xsl:text>
			<xsl:if test="position() != last()">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>]}</xsl:text>
	</xsl:template>
</xsl:stylesheet>
