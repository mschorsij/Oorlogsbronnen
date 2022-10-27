<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:su="com.spinque.tools.importStream.Utils"
	xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
	xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
	xmlns:ese="http://www.europeana.eu/schemas/ese/"
	xmlns:europeana="http://www.europeana.eu/schemas/ese/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<!-- Datumafhandeling en afhandeling europeana:rights en dc:rights aangepast door Micon op 19-10-2022 -->

	<xsl:template match="recordlist | record | metadata">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- *** Entry point for OAI-DC records  *** -->
	<xsl:template match="europeana:record">
		<xsl:if
			test="
				contains(su:lowercase(dc:description), 'oorlog')
				or contains(dc:description, '1940')
				or contains(dc:description, '1941')
				or contains(dc:description, '1942')
				or contains(dc:description, '1943')
				or contains(dc:description, '1944')
				or contains(dc:description, '1945')
				or contains(dcterms:created, '1940')
				or contains(dcterms:created, '1941')
				or contains(dcterms:created, '1942')
				or contains(dcterms:created, '1943')
				or contains(dcterms:created, '1944')
				or contains(dcterms:created, '1945')">
			<xsl:variable name="subject" select="europeana:isShownAt"/>
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">

		<xsl:param name="subject"/>
		<!--spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:title}" type="string"/-->
		<spinque:attribute
			subject="{$subject}" attribute="schema:thumbnail" value="{su:replace(europeana:object,'250x250', '1000x1000')}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{europeana:isShownAt}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/95"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Brabants Historisch Informatie Centrum" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank Brabants Historisch Informatie Centrum" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_bhic" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>
    <spinque:relation subject="{$subject}" predicate="dc:rights" object="{europeana:rights}"/>
		<spinque:attribute subject="{$subject}" attribute="dc:rights" value="{dc:rights}" type="string"/>

		<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:description))"/>

		<xsl:choose>
			<xsl:when test="string-length($title) &gt; 21">
				<xsl:variable name="titleLang" select="substring($title, 20, string-length($title))"/>
				<xsl:variable name="titleKort">
					<xsl:choose>
						<!--xsl:when test="contains($titleLang, '(')">
									<xsl:value-of select="substring-before($titleLang, '(')"/>
								</xsl:when-->
						<xsl:when test="contains($titleLang, ',')">
							<xsl:value-of select="substring-before($titleLang, ',')"/>
						</xsl:when>
						<xsl:when test="contains($titleLang, '.')">
							<xsl:value-of select="substring-before($titleLang, '.')"/>
						</xsl:when>
						<!--xsl:when test="contains($titleLang, ';')">
                <xsl:value-of select="substring-before($titleLang, ';')"/>
            </xsl:when-->
						<xsl:otherwise>
							<xsl:value-of select="$titleLang"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{concat(substring($title, 1,19), $titleKort)}" type="string"/>
				<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
				<!--spinque:debug message="ORG: {$title}"/-->
				<!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
				<!--spinque:debug message="KORT: {$titleKort}"/-->
				<!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{$title}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="dcterms:created">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="europeana:unstored">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dcterms:created">
		<xsl:param name="subject"/>
		<xsl:choose>
				<!-- jaar-maand-dag -->
				<xsl:when test="su:matches(., '\d{4}-\d{2}-\d{2}') and not(contains(., '00'))">
						<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'nl-nl', 'yyyy-MM-dd')}"/>
				</xsl:when>
				<!-- jaar -->
				<xsl:when test="su:matches(., '\d{4}-\d{2}-\d{2}') and contains(., '00')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{substring(., 1,4)}" type="integer"/>
				</xsl:when>
				<xsl:when test="su:matches(., '\d{4}')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{.}" type="integer"/>
				</xsl:when>
				<!-- Alle andere situaties -->
				<xsl:otherwise>
						<spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{.}" type="string"/>
				</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="europeana:unstored">
		<xsl:param name="subject"/>
		<xsl:variable name="arrayOfItems" select="su:split(., ';', 3)"/>
		<!--xsl:variable name="place" select="su:normalizeWhiteSpace(concat($arrayOfItems[2], ', ', $arrayOfItems[1]))"/-->
		<xsl:if test="($arrayOfItems[1] != '') or ($arrayOfItems[1] = '?')">
			<!--xsl:variable name="spatial" select="su:uri($subject, 'place')"/>
			<spinque:relation subject="{$subject}" predicate="schema:contentLocation" object="{$spatial}"/>
			<spinque:relation subject="{$spatial}" predicate="rdf:type" object="schema:Place"/>
			<spinque:attribute subject="{$spatial}" attribute="schema:name" value="{$arrayOfItems[1]}" type="string"/-->
			<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{$arrayOfItems[1]}" type="string"/>
			<xsl:if test="$arrayOfItems[2] != ''">
				<spinque:attribute subject="{$subject}" attribute="schema:address" value="{$arrayOfItems[2]}" type="string"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
