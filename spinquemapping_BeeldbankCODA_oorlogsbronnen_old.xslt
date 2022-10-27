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
 <identifier>3413</identifier>
 <datestamp>2009-01-15T12:29:00Z</datestamp>
 <setSpec>Beelddocumenten_CODA</setSpec>
 </header>
 <metadata>
 <europeana:record xmlns:europeana="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/">
 <dc:title xml:lang="nl">
 Optreden van de "Bugle Band" van het Royal Canadian Regiment na de bevrijding van Apeldoorn ter hoogte van de Langeweg.
 </dc:title>
 <dc:creator xml:lang="nl">Gilroy, G.B.</dc:creator>
 <dc:subject xml:lang="nl">Evenementen</dc:subject>
 <dc:subject xml:lang="nl">Militairen</dc:subject>
 <dc:subject xml:lang="nl">Bevrijding</dc:subject>
 <dc:subject xml:lang="nl">Muziek</dc:subject>
 <dc:publisher xml:lang="nl">CODA Apeldoorn</dc:publisher>
 <dc:publisher>http://www.coda-apeldoorn.nl/</dc:publisher>
 <dc:date>18/4/1945</dc:date>
 <dc:type>Foto</dc:type>
 <dcterms:extent>foto_zwartwit</dcterms:extent>
 <dcterms:hasFormat>
 http://deventit.coda-apeldoorn.nl/HttpHandler/icoon.ico?icoonfromxmlbeschr=3413
 </dcterms:hasFormat>
 <dc:identifier xml:lang="nl">P-003269</dc:identifier>
 <dc:language>nl</dc:language>
 <dcterms:medium>Foto</dcterms:medium>
 <europeana:provider>DEVENTit B.V.</europeana:provider>
 <europeana:object>
 http://deventit.coda-apeldoorn.nl/HttpHandler/icoon.ico?file=565451
 </europeana:object>
 <europeana:type>IMAGE</europeana:type>
 <europeana:rights>http://creativecommons.org/licenses/by-sa/3.0/nl/</europeana:rights>
 <europeana:dataProvider>CODA Apeldoorn</europeana:dataProvider>
 <europeana:isShownBy>
 http://deventit.coda-apeldoorn.nl/HttpHandler/icoon.ico?file=565451
 </europeana:isShownBy>
 <europeana:isShownAt>
 http://codapubliek.hosting.deventit.net/detail.php?id=3413
 </europeana:isShownAt>
 </europeana:record>
 </metadata>
 <about>
 <provenance xmlns="http://www.openarchives.org/OAI/2.0/provenance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/provenance http://www.openarchives.org/OAI/2.0/provenance.xsd">
 <originDescription altered="true" harvestDate="">
 <baseURL>
 http://deventit.coda-apeldoorn.nl/atlantispubliek/oai.axd?verb=Identify
 </baseURL>
 <identifier>3413</identifier>
 <datestamp>2009-01-15T12:29:00Z</datestamp>
 <metadataNamespace>
 http://deventit.coda-apeldoorn.nl/atlantispubliek/oai.axd?verb=Identify
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
            test="
                (dc:subject = 'Tweede Wereldoorlog')
                or contains(dc:title, 'Tweede Wereldoorlog')
                or contains(dc:date, '1940')
                or contains(dc:date, '1941')
                or contains(dc:date, '1942')
                or contains(dc:date, '1943')
                or contains(dc:date, '1944')
                or contains(dc:date, '1945')">
            <xsl:variable name="subject" select="su:replace(europeana:isShownAt, 'http://codapubliek.hosting.deventit.net/', 'https://archieven.coda-apeldoorn.nl/')"/>
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
            value="{europeana:isShownBy}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:language"
            value="nl"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dcmit:Collection"
            value="Beeldbank CODA"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set beeldbank_coda"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:source"
            value="{su:replace(europeana:isShownAt,'http://codapubliek.hosting.deventit.net/', 'https://archieven.coda-apeldoorn.nl/')}"
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
            object="niod:Organizations/193"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:publisher"
            value="CODA"
            type="string"/>
        <!-- end -->
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{dc:creator}"
            type="string"/>
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

        <!--spinque:attribute
            subject="{$subject}"
            attribute="dc:title"
            value="{dc:title}"
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
                        <!--xsl:when test="contains($titleLang, '.')">
                            <xsl:value-of select="substring-before($titleLang, '.')"/>
                        </xsl:when-->
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


    </xsl:template>
    <!-- *** -->

    <!-- ******* -->

    <xsl:template match="dc:date">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:date"
            type="date"
            value="{su:parseDate(.,'nl-nl', 'dd/MM/yyyy', 'd/MM/yyyy', 'dd/M/yyyy', 'MM/yyyy', 'M/yyyy', 'yyyy')}"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:startDate"
            type="date"
            value="{su:parseDate(.,'nl-nl', 'dd/MM/yyyy', 'd/MM/yyyy', 'dd/M/yyyy', 'MM/yyyy', 'M/yyyy', 'yyyy')}"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:endDate"
            type="date"
            value="{su:parseDate(. + 1,'nl-nl', 'dd/MM/yyyy', 'd/MM/yyyy', 'dd/M/yyyy', 'MM/yyyy', 'M/yyyy', 'yyyy')}"/>
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
