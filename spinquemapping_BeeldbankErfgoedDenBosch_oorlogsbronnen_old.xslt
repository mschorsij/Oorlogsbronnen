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
<identifier>14433733</identifier>
<datestamp>2016-05-19T13:08:58Z</datestamp>
<setSpec>Beelddocument</setSpec>
</header>
<metadata>
<europeana:record xmlns:europeana="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/">
<dc:title xml:lang="nl">
Duitse militaire begrafenis tijdens de Duitse bezetting op het kerkhof te Orthen. Begrafenis van Oberschütze Karl-Hermann Heidt (geboren op 4 januari 1925 in Domäne Schafhof), gesneuveld in een maïsveld op het terrein van Coudewater 3 oktober 1944. Hij is begraven op Ehrenfriedhof Orthen en op 23 december 1949 herbegraven in Ysselsteyn .
</dc:title>
<dc:creator xml:lang="nl">Zuiden, Fotopersbureau Het</dc:creator>
<dc:subject xml:lang="nl">Begraafplaatsen</dc:subject>
<dc:subject xml:lang="nl">Begraven</dc:subject>
<dc:subject xml:lang="nl">Engelse militairen</dc:subject>
<dc:subject xml:lang="nl">Begrafenissen</dc:subject>
<dc:subject xml:lang="nl">Tweede Wereldoorlog</dc:subject>
<dc:coverage xml:lang="nl">'s-Hertogenbosch;Orthen</dc:coverage>
<dc:publisher xml:lang="nl">Stadsarchief 's-Hertogenbosch</dc:publisher>
<dc:publisher>http://www.stadsarchief.nl/</dc:publisher>
<dc:date>4/10/1944</dc:date>
<dc:type>Foto</dc:type>
<dcterms:hasFormat>
http://denbosch.hosting.deventit.net/HttpHandler/icoon.ico?icoonfromxmlbeschr=14433733
</dcterms:hasFormat>
<dc:identifier xml:lang="nl">0014968</dc:identifier>
<dc:language>nl</dc:language>
<dcterms:medium>Foto</dcterms:medium>
<europeana:provider>DEVENTit B.V.</europeana:provider>
<europeana:object>
http://denbosch.hosting.deventit.net/HttpHandler/icoon.ico?file=21037593
</europeana:object>
<europeana:type>IMAGE</europeana:type>
<europeana:rights>http://creativecommons.org/licenses/by-sa/3.0/nl/</europeana:rights>
<europeana:dataProvider>Stadsarchief 's-Hertogenbosch</europeana:dataProvider>
<europeana:isShownBy>
http://denbosch.hosting.deventit.net/HttpHandler/icoon.ico?file=21037593
</europeana:isShownBy>
<europeana:isShownAt>
http://denbosch.hosting.deventit.net/AtlantisPubliek/detail.aspx?xmldescid=14433733
</europeana:isShownAt>
</europeana:record>
</metadata>
<about>
<provenance xmlns="http://www.openarchives.org/OAI/2.0/provenance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/provenance http://www.openarchives.org/OAI/2.0/provenance.xsd">
<originDescription altered="true" harvestDate="">
<baseURL>
http://denbosch.hosting.deventit.net/atlantispubliek/oai.axd?verb=Identify
</baseURL>
<identifier>14433733</identifier>
<datestamp>2016-05-19T13:08:58Z</datestamp>
<metadataNamespace>
http://denbosch.hosting.deventit.net/atlantispubliek/oai.axd?verb=Identify
</metadataNamespace>
</originDescription>
</provenance>
</about>
</record>
-->

	<xsl:template match="recordlist | oai:record | oai:metadata">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="europeana:record">
		<xsl:if
			test="(dc:subject = 'Tweede Wereldoorlog')
			or contains(dc:title, 'Tweede Wereldoorlog')
			or contains(dc:date, '1940')
			or contains(dc:date, '1941')
			or contains(dc:date, '1942')
			or contains(dc:date, '1943')
			or contains(dc:date, '1944')
			or contains(dc:date, '1945')">
			<xsl:variable name="subject" select="europeana:isShownAt"/>
			<!-- *** run generic Dublin Core *** -->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<spinque:attribute
			subject="{$subject}"
			attribute="schema:thumbnail"
			value="{dcterms:hasFormat}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:language"
			value="nl"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dcmit:Collection"
			value="Beeldbank Erfgoed 's-Hertogenbosch"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:disambiguatingDescription"
			value="In Oorlogsbronnen in set beeldbank_denbosch"
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
		<!-- *** Link Publisher *** -->
		<spinque:relation
			subject="{$subject}"
			predicate="dc:publisher"
			object="niod:Organizations/234"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:publisher"
			value="Erfgoed 's-Hertogenbosch"
			type="string"/>
		<!-- end -->
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:creator"
			value="{dc:creator}"
			type="string"/>
		<xsl:choose>
			<xsl:when test="europeana:rights != ''">
				<xsl:choose>
					<xsl:when test="contains(europeana:rights, 'by-sa')">
						<spinque:relation
							subject="{$subject}"
							predicate="dc:rights"
							object="https://creativecommons.org/licenses/by-sa/3.0/nl/"/>
						<spinque:attribute
							subject="{$subject}"
							attribute="dc:rights"
							value="CC BY-SA"
							type="string"/>
					</xsl:when>
					<xsl:otherwise>
						<spinque:relation
							subject="{$subject}"
							predicate="dc:rights"
							object="http://rightsstatements.org/vocab/CNE/1.0/"/>
						<spinque:attribute
							subject="{$subject}"
							attribute="dc:rights"
							value="Copyright niet bekend"
							type="string"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="dc:creator != ''">
						<xsl:choose>
							<xsl:when test="contains(dc:creator, 'nbekend')">
								<spinque:relation
									subject="{$subject}"
									predicate="dc:rights"
									object="http://rightsstatements.org/page/CNE/1.0/"/>
								<spinque:attribute
									subject="{$subject}"
									attribute="dc:rights"
									value="Copyright niet bekend"
									type="string"/>
							</xsl:when>
							<xsl:otherwise>
								<spinque:relation
									subject="{$subject}"
									predicate="dc:rights"
									object="http://rightsstatements.org/vocab/InC/1.0/"/>
								<spinque:attribute
									subject="{$subject}"
									attribute="dc:rights"
									value="In Copyright"
									type="string"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<!--spinque:attribute
			subject="{$subject}"
			attribute="dc:title"
			value="{substring-before(dc:title, '.')}"
			type="string"/-->

		<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:title))"/>

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
			value="{dc:title}"
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

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:date">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:coverage">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>
	<!-- *** -->

	<!-- ******* -->

	<xsl:template match="dc:date">
		<xsl:param name="subject"/>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:date"
			type="date"
			value="{su:parseDate(., 'M/yyyy', 'MM/yyyy', 'yyyy')}"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:startDate"
			type="date"
			value="{su:parseDate(., 'M/yyyy', 'MM/yyyy', 'yyyy')}"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:endDate"
			type="date"
			value="{su:parseDate(., 'M/yyyy', 'MM/yyyy', 'yyyy')}"/>

	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:subject"
			value="{.}"
			type="string"/>

	</xsl:template>

	<xsl:template match="dc:coverage">

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
