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
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>
	<!--
    <record>
      <header>
        <identifier>{45F6DACB-13FE-4F38-AD84-D1DB2295A67D}</identifier>
        <datestamp>2019-11-30</datestamp>
        <setSpec>NOB_235</setSpec>
        <setSpec>NOB</setSpec>
      </header>
      <metadata>
        <oai_dc:record xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:title>Gids voor Boxtel / H.J.M. van der Velden, 1925</dc:title>
          <dc:subject>Monumenten</dc:subject>
          <dc:subject>Geografie</dc:subject>
          <dc:subject>Dorpsgeschiedenis</dc:subject>
          <dc:creator>H.J.M. van der Velden, J.P.C. van Hout</dc:creator>
          <dc:date>1925</dc:date>
          <dc:description>met advertenties;  kopie</dc:description>
          <dc:publisher>D.Y. Alta&apos;s Uitgeversbedrijf</dc:publisher>
          <dc:title>Gids voor Boxtel</dc:title>
          <dc:identifier>1806-1</dc:identifier>
          <dc:coverage>Boxtel</dc:coverage>
          <dc:type>Boek</dc:type>
          <dcterms:isPartOf>Documentatie Boxtel</dcterms:isPartOf>
          <dcterms:hasVersion>http://www.bhic.nl/integrated?mivast=235&amp;miadt=235&amp;miaet=1&amp;micode=1806&amp;minr=11136293&amp;miview=ldt</dcterms:hasVersion>
          <dc:relation></dc:relation>
          <dc:relation></dc:relation>
        </oai_dc:record>
      </metadata>
    </record>
-->

	<xsl:template match="recordlist | record | metadata">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="oai_dc:record">
		<xsl:if test="contains(dc:subject, 'oorlog')">
			<xsl:variable name="subject" select="dcterms:hasVersion"/>
			<!-- *** run generic Dublin Core *** -->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>
		<!--spinque:debug message="{dc:subject}"/-->
		<!--spinque:attribute
			subject="{$subject}"
			attribute="schema:thumbnail"
			value="{dc:relation[1]}"
			type="string"/-->
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:language"
			value="nl"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dcmit:Collection"
			value="Boeken BHIC"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:disambiguatingDescription"
			value="In Oorlogsbronnen in set boeken_bhic"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:source"
			value="{$subject}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:identifier"
			value="{dc:identifier}"
			type="string"/>
		<!-- *** Link Publisher *** -->
		<spinque:relation
			subject="{$subject}"
			predicate="dc:publisher"
			object="niod:Organizations/95"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:publisher"
			value="Brabants Historisch Informatie Centrum"
			type="string"/>
		<!-- end -->
		<!--spinque:relation
			subject="{$subject}"
			predicate="dc:rights"
			object="http://rightsstatements.org/page/CNE/1.0/"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:rights"
			value="Copyright niet bekend"
			type="string"/-->
		<!--xsl:choose>
			<xsl:when test="dc:rights = 'http://creativecommons.org/licenses/by-sa/3.0/nl/'">
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://creativecommons.org/licenses/by-sa/3.0/nl/"/>
				<spinque:attribute subject="{$subject}" attribute="dc:rights" value="CC BY-SA" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/page/CNE/1.0/"/>
				<spinque:attribute subject="{$subject}" attribute="dc:rights" value="Copyright niet bekend" type="string"/>
			</xsl:otherwise>
		</xsl:choose-->

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:title"
			value="{dc:title}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:description"
			value="{dc:description}"
			type="string"/>
		<spinque:relation
			subject="{$subject}"
			predicate="rdf:type"
			object="schema:Book"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:type"
			value="boek"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:creator"
			value="{dc:creator}"
			type="string"/>

		<xsl:apply-templates select="dc:publisher">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:date">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>
	<!-- *** -->

	<!-- ******* -->
	<xsl:template match="dc:publisher">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator"
			value="{.}" type="string"/>
	</xsl:template>

	<xsl:template match="dc:date">
		<xsl:param name="subject"/>
		<xsl:variable name="datering">
			<!--spinque:debug message="{.}"/-->
			<xsl:choose>
				<xsl:when test=". != '' or . != 'z.j.'">
					<xsl:choose>
						<xsl:when test="contains(., ', ')">
							<xsl:value-of select="substring-after(., ', ')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="su:lowercase(.)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!--xsl:otherwise>
				<xsl:value-of select="pling"/>
			</xsl:otherwise-->
			</xsl:choose>
		</xsl:variable>

		<spinque:attribute subject="{$subject}" attribute="dc:date"
			value="{su:parseDate($datering, 'nl-NL', 'yyyy', 'dd-MM-yyyy', 'dd.MM-yyyy','d-MM-yyyy', 'dd-M-yyyy', 'd-M-yyyy', 'yyyy - yyyy', 'd/M/yyyy - d/M/yyyy')}"
			type="date"/>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:subject"
			value="{.}" type="string"/>
	</xsl:template>

</xsl:stylesheet>
