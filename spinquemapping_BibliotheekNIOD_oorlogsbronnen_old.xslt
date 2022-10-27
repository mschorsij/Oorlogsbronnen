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
	<xsl:template match="oclcdcq">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="oclcdcq">
                <!-- DIT IS EEN TEST TEST TEST TEST -->
                <!--xsl:variable name="subject" select="su:trim(oclcterms:recordOCLCControlNumberCross-Reference)"/-->
		<xsl:variable name="subject" select="su:trim(oclcterms:recordIdentifier[@xsi:type='http://purl.org/oclc/terms/oclcrecordnumber'])"/>
			<!-- *** run generic Dublin Core *** -->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="concat('https://niod.on.worldcat.org/oclc/', $subject)"/>
			</xsl:call-template>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:language"
			value="{dc:language}"
			type="string"/>
		<spinque:attribute subject="{$subject}"
			attribute="http://www.europeana.eu/schemas/edm/dataProvider"
			value="Gemeenschappelijk Geautomatiseerde Catalogiseersysteem (GGC)" type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dcmit:Collection"
			value="Bibliotheek NIOD"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:disambiguatingDescription"
			value="In Oorlogsbronnen in set ggc_niod"
			type="string"/>
        <xsl:choose>
        	<xsl:when test="contains($subject, 'ocm')">
        		<spinque:attribute
        			subject="{$subject}"
        			attribute="dc:source"
        			value="{concat('https://niod.on.worldcat.org/oclc/', su:substringAfter($subject, 'ocm'))}"
        			type="string"/>
        	</xsl:when>
        	<xsl:when test="contains($subject, 'ocn')">
        		<spinque:attribute
        			subject="{$subject}"
        			attribute="dc:source"
        			value="{concat('https://niod.on.worldcat.org/oclc/', su:substringAfter($subject, 'ocn'))}"
        			type="string"/>
        	</xsl:when>
        	<xsl:when test="contains($subject, 'on')">
        		<spinque:attribute
        			subject="{$subject}"
        			attribute="dc:source"
        			value="{concat('https://niod.on.worldcat.org/oclc/', su:substringAfterLast($subject, 'on'))}"
        			type="string"/>
        	</xsl:when>
        </xsl:choose>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:identifier"
			value="{oclcterms:recordOCLCControlNumberCross-Reference}"
			type="string"/>
		<!-- *** Link Publisher *** -->
		<spinque:relation
			subject="{$subject}"
			predicate="dc:publisher"
			object="niod:Organizations/116"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:publisher"
			value="NIOD"
			type="string"/>
		<!-- end -->
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:creator"
			value="{dc:creator}"
			type="string"/>
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
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:description"
			value="{dcterms:abstract}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:description"
			value="{dcterms:extent}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:contributor"
			value="{dc:contributor}"
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

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:issued">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>
	<!-- *** -->

	<!-- ******* -->

	<xsl:template match="dcterms:issued">
		<xsl:param name="subject"/>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:date"
			type="date"
			value="{su:parseDate(., 'yyyy', '[yyyy]', '©yyyy')}"/>


	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:subject"
			value="{.}"
			type="string"/>

	</xsl:template>


</xsl:stylesheet>
