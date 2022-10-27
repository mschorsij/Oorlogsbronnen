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
	<!-- Datumafhandeling aangepast door Micon 06-10-2022 -->

	<xsl:template match="recordlist | record | metadata">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="oai_dc:record">
		<!-- <xsl:if test="contains(dc:subject, 'oorlog')"> -->
			<xsl:variable name="subject" select="dcterms:hasVersion"/>
			<!-- *** run generic Dublin Core *** -->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
		<!-- </xsl:if> -->
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{dc:relation[1]}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Boeken BHIC" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription"
			value="In Oorlogsbronnen in set boeken_bhic" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/95"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Brabants Historisch Informatie Centrum" type="string"/>

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

		<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:title}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Book"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="boek" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>

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
		<xsl:if test=". != '' and not(contains(., 'z.j.'))">
			<xsl:variable name="datering">
				<xsl:choose>
					<xsl:when test="contains(., ',')">
						<xsl:value-of select="su:trim(su:substringAfterLast(., ', '))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="su:trim(.)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
  		<xsl:choose>
				<!-- dag-maand-jaar -->
				<xsl:when test="su:matches($datering, '.*\d{1,2}-\d{1,2}-\d{4}.*')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate($datering, 'nl-nl', 'dd-MM-yyyy', 'd-M-yyyy', 'd-MM-yyyy', 'dd-M-yyyy')}"/>
				</xsl:when>
				<!-- jaar -->
				<xsl:when test="su:matches($datering, '\d{4}')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{$datering}" type="integer"/>
				</xsl:when>
				<!-- Alle andere situaties -->
				<xsl:otherwise>
						<spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{$datering}" type="string"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:subject"
			value="{.}" type="string"/>
	</xsl:template>

</xsl:stylesheet>
