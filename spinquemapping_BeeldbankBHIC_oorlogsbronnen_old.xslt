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

	<!--
	<record xmlns="http://www.openarchives.org/OAI/2.0/">
      <header>
        <identifier>oai:f5fef8a2-45f9-11e3-823a-dfbbe601e8fe:dc3fc860-950b-11e1-bca0-3860770ffe72</identifier>
        <datestamp>2013-11-05T11:25:39Z</datestamp>
        <setSpec>4504c8f0-951b-11e1-992f-3860770ffe72</setSpec>
        <setSpec>4504c8f0-951b-11e1-992f-3860770ffe72:dc3fc860-950b-11e1-bca0-3860770ffe72</setSpec>
        <setSpec>4504c8f0-951b-11e1-992f-3860770ffe72:dc3fc860-950b-11e1-bca0-3860770ffe72:9cd8653e-3f70-2fbd-1103-c6e2b75bf9ea</setSpec>
      </header>
      <metadata>
        <europeana:record xmlns:europeana="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
          <dc:identifier>KAT0092</dc:identifier>
          <dc:description>Herdenking van de Tweede Wereldoorlog met op de achtergrond het monument.</dc:description>
          <dc:coverage>Katwijk</dc:coverage>
          <dc:coverage/>
          <dc:creator>Fotopersbureau Het Zuiden</dc:creator>
          <dc:rights>Brabants Historisch Informatie Centrum</dc:rights>
          <europeana:rights>http://www.europeana.eu/rights/rr-f/</europeana:rights>
          <dc:type>Foto</dc:type>
          <europeana:type>IMAGE</europeana:type>
          <europeana:isShownAt>http://www.bhic.nl/foto/f5fef8a2-45f9-11e3-823a-dfbbe601e8fe</europeana:isShownAt>
          <europeana:object>https://images.memorix.nl/bhic/thumb/250x250/67e1fd27-d3a4-5500-299b-979e210acce3.jpg</europeana:object>
          <europeana:dataProvider>Brabants Historisch Informatie Centrum</europeana:dataProvider>
          <europeana:provider>Brabants Historisch Informatie Centrum</europeana:provider>
          <europeana:unstored>Katwijk;;;</europeana:unstored>
        </europeana:record>
      </metadata>
    </record>
    -->

	<xsl:template match="recordlist | record | metadata">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="header">
		<!-- do nothing -->
	</xsl:template>

	<!-- *** Entry point for OAI-DC records  *** -->
	<xsl:template match="europeana:record">
		<xsl:if
			test="
				contains(su:lowercase(dc:description), 'oorlog')
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
			subject="{$subject}"
			attribute="schema:thumbnail"
			value="{su:replace(europeana:object,'250x250', '1000x1000')}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:source"
			value="{europeana:isShownAt}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:identifier"
			value="{dc:identifier}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:creator"
			value="{dc:creator}"
			type="string"/>
		<!-- *** waarde hard vast geprogrammeerd *** -->
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
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:language"
			value="nl"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dcmit:Collection"
			value="Beeldbank Brabants HIC"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:disambiguatingDescription"
			value="In Oorlogsbronnen in set beeldbank_bhic"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="http://purl.org/dc/terms/identifier"
			value="{dc:identifier}"
			type="string"/>
		<spinque:relation
			subject="{$subject}"
			predicate="rdf:type"
			object="schema:Photograph"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:type"
			value="foto"
			type="string"/>
		<xsl:choose>
			<xsl:when test="contains(europeana:rights, 'rr-f/')">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/vocab/InC/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="In Copyright"
					type="string"/>
			</xsl:when>
			<xsl:when test="contains(europeana:rights, 'by-nd')">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="https://creativecommons.org/licenses/by-nd/4.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="CC BY-NC-ND"
					type="string"/>
			</xsl:when>
			<xsl:when test="dc:creator != ''">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/vocab/InC/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="In Copyright"
					type="string"/>
			</xsl:when>
			<xsl:when test="string-length(europeana:rights) != 0">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/vocab/InC/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="In Copyright"
					type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/page/CNE/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="Copyright niet bekend"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:description))"/>

		<xsl:choose>
			<xsl:when test="string-length($title) &gt; 21">
				<xsl:variable name="titleLang"
					select="substring($title, 20, string-length($title))"/>
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
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:title"
					value="{concat(substring($title, 1,19), $titleKort)}"
					type="string"/>
				<!--spinque:debug message="ORG: {$title}"/-->
				<!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
				<!--spinque:debug message="KORT: {$titleKort}"/-->
				<!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:title"
					value="{$title}"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:description"
			value="{dc:description}"
			type="string"/>

		<xsl:apply-templates select="dcterms:created">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="europeana:unstored">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>

	<!-- ******* -->

	<xsl:template match="dcterms:created">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:date"
			value="{.}" type="string"/>
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
