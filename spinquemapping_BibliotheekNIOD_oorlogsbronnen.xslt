<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:su="com.spinque.tools.importStream.Utils"
	xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
	xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
	xmlns:ese="http://www.europeana.eu/schemas/ese/"
	xmlns:europeana="http://www.europeana.eu/schemas/ese/"
	xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
	xmlns:vvdu="com.spinque.tools.extraction.project.verteldverleden.IdentifyDate"
	xmlns:oclcterms="http://purl.org/oclc/terms/"
	xmlns:dcmitype="http://purl.org/dc/dcmitype/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<!-- Datumafhandeling aangepast door Micon op 26-10-2022 -->

	<xsl:template match="oclcdcq">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="oclcdcq">
		<xsl:variable name="subject" select="su:trim(oclcterms:recordIdentifier[@xsi:type='http://purl.org/oclc/terms/oclcrecordnumber'])"/>
			<!-- *** run generic Dublin Core *** -->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="concat('https://niod.on.worldcat.org/oclc/', $subject)"/>
			</xsl:call-template>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<spinque:attribute subject="{$subject}" attribute="dc:language" value="{dc:language}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="http://www.europeana.eu/schemas/edm/dataProvider" value="{oclcterms:recordContentSource}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Bibliotheek NIOD" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set ggc_niod" type="string"/>
    <xsl:choose>
    	<xsl:when test="contains($subject, 'ocm')">
    		<spinque:attribute subject="{$subject}" attribute="dc:source"
    			value="{concat('https://niod.on.worldcat.org/oclc/', su:substringAfter($subject, 'ocm'))}" type="string"/>
    	</xsl:when>
    	<xsl:when test="contains($subject, 'ocn')">
    		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{concat('https://niod.on.worldcat.org/oclc/', su:substringAfter($subject, 'ocn'))}" type="string"/>
    	</xsl:when>
    	<xsl:when test="contains($subject, 'on')">
    		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{concat('https://niod.on.worldcat.org/oclc/', su:substringAfterLast($subject, 'on'))}" type="string"/>
    	</xsl:when>
    </xsl:choose>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{oclcterms:recordOCLCControlNumberCross-Reference}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/116"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="NIOD" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:title}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dcterms:abstract}" type="string"/>
		<!-- <spinque:attribute subject="{$subject}" attribute="dc:description" value="{dcterms:extent}" type="string"/> -->
		<spinque:attribute subject="{$subject}" attribute="dc:contributor" value="{dc:contributor}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Book"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="boek" type="string"/>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:issued">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dcterms:issued">
		<xsl:param name="subject"/>
			<xsl:choose>
        <xsl:when test="su:matches(., '\d.*')">
					<spinque:attribute subject="{$subject}" attribute="dc:date" type="integer" value="{substring(., 1,4)}"/>
        </xsl:when>
        <xsl:when test="su:matches(., '©\d.*')">
					<spinque:attribute subject="{$subject}" attribute="dc:date" type="integer" value="{substring(su:substringAfter(., '©'),1,4)}"/>
        </xsl:when>
				<xsl:when test="su:matches(., '[\d.*')">
					<spinque:attribute subject="{$subject}" attribute="dc:date" type="integer" value="{substring(su:substringAfter(., '['),1,4)}"/>
        </xsl:when>
        <xsl:when test="su:matches(., '[\s\d.*')">
					<spinque:attribute subject="{$subject}" attribute="dc:date" type="integer" value="{substring(su:substringAfter(., ' '),1,4)}"/>
        </xsl:when>
				<xsl:otherwise>
					<spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{.}" type="string"/>
				</xsl:otherwise>
			</xsl:choose>
        <spinque:debug message="Year: {$issueYear}"/>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>

		<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>

	</xsl:template>

</xsl:stylesheet>
