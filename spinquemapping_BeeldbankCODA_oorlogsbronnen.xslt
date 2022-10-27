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

    <!-- Datumafhandeling aangepast door Micon op 20-10-2022 -->

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

        <spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{europeana:isShownBy}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank CODA" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_coda" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:source" value="{europeana:isShownAt}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
        <spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/193"/>
        <spinque:attribute subject="{$subject}" attribute="dc:publisher" value="{dc:publisher}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>
        <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
        <spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>

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
                <xsl:variable name="titleLang" select="substring($title, 20, string-length($title))"/>
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
                <spinque:attribute subject="{$subject}" attribute="dc:title" value="{concat(substring($title, 1,19), $titleKort)}" type="string"/>
                <spinque:attribute subject="{$subject}" attribute="dc:description" value="{$title}" type="string"/>
                <!--spinque:debug message="ORG: {$title}"/-->
                <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                <!--spinque:debug message="KORT: {$titleKort}"/-->
                <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$subject}" attribute="dc:title" value="{$title}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates select="dc:subject">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc:date">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="dc:date">
        <xsl:param name="subject"/>
        <xsl:choose>
            <!-- dag/maand/jaar -->
            <xsl:when test="su:matches(., '\d{1,2}/\d{1,2}/\d{4}')">
                <spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'nl-nl', 'dd/M/yyyy', 'd/M/yyyy', 'd/MM/yyyy', 'dd/M/yyyy')}"/>
            </xsl:when>
            <!-- maand/jaar -->
            <xsl:when test="su:matches(., '\d{1,2}/\d{4}')">
                <spinque:attribute subject="{$subject}" attribute="dc:date" value="{su:trim(substring(., string-length(.)-3))}" type="integer"/>
            </xsl:when>
            <!-- jaar -->
            <xsl:when test="su:matches(., '\d{4}')">
                <spinque:attribute subject="{$subject}" attribute="dc:date" value="{.}" type="integer"/>
            </xsl:when>
            <!-- Alle andere situaties -->
            <xsl:otherwise>
                <spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{.}" type="string"/>
            </xsl:otherwise>
          </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:subject">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
    </xsl:template>

</xsl:stylesheet>
