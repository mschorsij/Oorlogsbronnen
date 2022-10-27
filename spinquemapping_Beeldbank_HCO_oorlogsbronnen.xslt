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
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:ore="http://www.openarchives.org/ore/terms/" extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <!-- Datumafhandeling en filter 'oorlog' aangepast door Micon op 06-10-2022 -->

    <xsl:template match="recordlist | record | metadata">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- *** Entry point for OAI-DC records  *** -->
    <xsl:template match="rdf:RDF">
      <xsl:if test="edm:ProvidedCHO/dc:type != 'Film'">
        <xsl:if test="contains(su:lowercase(edm:ProvidedCHO/dc:type), 'foto')
        and contains(su:lowercase(edm:ProvidedCHO/dc:title), 'tweede wereldoorlog')">
          <xsl:variable name="subject" select="ore:Aggregation/edm:isShownAt/@rdf:resource"/>
          <xsl:call-template name="dc_record">
            <xsl:with-param name="subject" select="$subject"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:template>

    <!-- *** generic Dublin Core parser *** -->
    <xsl:template name="dc_record">
        <xsl:param name="subject"/>

        <spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{edm:ProvidedCHO/dcterms:hasFormat}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{edm:ProvidedCHO/dc:identifier}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:title" value="{edm:ProvidedCHO/dc:description}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:description" value="{edm:ProvidedCHO/dc:title}" type="string"/>
        <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
        <spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>
        <spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/13"/>
        <spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Mijn Stad Mijn Dorp" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Fotografische Documenten Overijssel" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_hco" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>

        <!-- <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(edm:ProvidedCHO/dc:title))"/>
        <xsl:choose>
            <xsl:when test="string-length($title) &gt; 21">
                <xsl:variable name="titleLang"
                    select="substring($title, 20, string-length($title))"/>
                <xsl:variable name="titleKort">
                    <xsl:choose>
                        <xsl:when test="contains($titleLang, '.')">
                            <xsl:value-of select="substring-before($titleLang, '.')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, ' ')">
                            <xsl:value-of select="substring-before($titleLang, ' ')"/>
                        </xsl:when>
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
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:description"
                    value="{edm:ProvidedCHO/dc:title}"
                    type="string"/>
                <spinque:debug message="ORG: {$title}"/>
                <spinque:debug message="TIT: {substring($title, 1,19)}"/>
                <spinque:debug message="KORT: {$titleKort}"/>
                <spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:title"
                    value="{$title}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose> -->

        <xsl:choose>
            <xsl:when
                test="contains(ore:Aggregation/edm:rights/@rdf:resource, 'InC')">
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

        <xsl:apply-templates select="edm:ProvidedCHO/dc:date">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dcterms:spatial">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc:format">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc:creator">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc:subject">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc:relation">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- ******* -->
    <xsl:template match="dc:creator">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:creator" value="{.}" type="string"/>
    </xsl:template>

    <xsl:template match="edm:ProvidedCHO/dc:date">
        <xsl:param name="subject"/>
        <xsl:choose>
            <!-- dag-maand-jaar -->
            <xsl:when test="su:matches(., '\d{1,2}\/\d{1,2}\/\d{4}')">
                <spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'nl-nl', 'dd/MM/yyyy', 'd/M/yyyy', 'd/MM/yyyy', 'dd/M/yyyy')}"/>
            </xsl:when>
            <!-- jaar -->
            <xsl:when test="su:matches(., '\d{4}')">
                <spinque:attribute subject="{$subject}" attribute="dc:date" value="{.}" type="integer"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{.}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:subject">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
    </xsl:template>

    <xsl:template match="dcterms:spatial">
        <xsl:param name="subject"/>
        <!--	Add by Michiel -->
        <xsl:variable name="place" select="."/>
        <!--<xsl:variable name="spatial" select="su:uri('http://data.oorlogsbronnen.nl/beeldbank_hco/spatial/', $place)"/>
        <spinque:relation
            subject="{$subject}"
            predicate="schema:contentLocation"
            object="{$spatial}"/>
        <spinque:relation
            subject="{$spatial}"
            predicate="rdf:type"
            object="schema:Place"/>
        <spinque:attribute
            subject="{$spatial}"
            attribute="schema:name"
            value="{$place}"
            type="string"/>-->
        <spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{$place}" type="string"/>
    </xsl:template>

    <xsl:template match="dc:format">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:format"
            value="{.}" type="string"/>
    </xsl:template>

    <!-- In de collectie zwolle wordt dit veld gebruikt om de lokale identifier op te slaan -->
    <xsl:template match="dc:relation">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}"
            attribute="dc:identifier" value="{.}" type="string"/>
    </xsl:template>

</xsl:stylesheet>
