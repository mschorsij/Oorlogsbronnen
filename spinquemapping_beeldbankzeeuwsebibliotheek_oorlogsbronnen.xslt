<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:su="com.spinque.tools.importStream.Utils"
	xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
	xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
	xmlns:ese="http://www.europeana.eu/schemas/ese/"
	xmlns:europeana="http://www.europeana.eu/schemas/ese/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>
	<!-- Datumafhandeling aangepast door Micon op 20-10-2022 -->

	<xsl:template match="recordlist | record | metadata">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="europeana:record">
		<xsl:if
			test="contains(su:lowercase(dc:subject), 'geschiedenis 1940-1945')">
			<xsl:variable name="subject" select="europeana:isShownAt"/>
			<!-- *** run generic Dublin Core ***-->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{su:replace(europeana:object, '640x480', '1000x1000')}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank Zeeuwse Bibliotheek" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_zeeuwsebibliotheek" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{europeana:isShownAt}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/397"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="ZB Planbureau en Bibliotheek van Zeeland" type="string"/>

		<xsl:choose>
			<xsl:when test="contains(europeana:rights, '/by-nc/')">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="https://creativecommons.org/licenses/by-nc/4.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="CC BY-NC 4.0"
					type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="https://rightsstatements.org/page/CNE/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="Copyright niet bekend"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<!--spinque:attribute
			subject="{$subject}"
			attribute="dc:title"
			value="{dc:description}"
			type="string"/-->

		<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:description))"/>

		<xsl:choose>
			<xsl:when test="string-length($title) &gt; 21">
				<xsl:variable name="titleLang"
					select="substring($title, 20, string-length($title))"/>
				<xsl:variable name="titleKort">
					<xsl:choose>
						<xsl:when test="contains($titleLang, ';')">
							<xsl:value-of select="substring-before($titleLang, ';')"/>
						</xsl:when>
						<xsl:when test="contains($titleLang, ',')">
							<xsl:value-of select="substring-before($titleLang, ',')"/>
						</xsl:when>
						<xsl:when test="contains($titleLang, '.')">
							<xsl:value-of select="substring-before($titleLang, '.')"/>
						</xsl:when>
						<!--xsl:when test="contains($titleLang, ' ')">
									<xsl:value-of select="substring-before($titleLang, ' ')"/>
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

		<xsl:apply-templates select="dc:creator">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:created">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:spatial">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dc:creator">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{.}" type="string"/>
	</xsl:template>

	<xsl:template match="dcterms:spatial">
		<xsl:param name="subject"/>
		<xsl:variable name="spatial" select="su:uri('http://data.oorlogsbronnen.nl/beeldbank_zeeuwsebibliotheek/spatial/', .)"/>
		<spinque:relation subject="{$subject}" predicate="schema:contentLocation" object="{$spatial}"/>
		<spinque:relation subject="{$spatial}" predicate="rdf:type" object="schema:Place"/>
		<spinque:attribute subject="{$spatial}" attribute="schema:name" value="{.}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{.}" type="string"/>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{su:lowercase(.)}" type="string"/>
	</xsl:template>

	<xsl:template match="dcterms:created">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="string-length(.) = 10 and contains(., '00')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{substring(., 1,4)}" type="integer"/>
			</xsl:when>
			<xsl:when test="string-length(.) = 10 and not(contains(., '00'))">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{su:parseDate(.,'yyyy-MM-dd')}" type="date"/>
			</xsl:when>
			<xsl:when test="string-length(.) = 7 or string-length(.) = 5">
				<spinque:attribute subject="{$subject}" attribute="dc:date" value="{substring(., 1,4)}" type="integer"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{.}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
