<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:ese="http://www.europeana.eu/schemas/ese/"
    xmlns:europeana="http://www.europeana.eu/schemas/ese/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="row">
        <xsl:variable name="subject"
            select="concat('https://www.ihlia.nl/search/?q:search=ID:', field[@name = 'ID'])"/>
        <xsl:variable name="onderwerp" select="su:split(field[@name = 'VD'], '#')"/>
        <xsl:variable name="achternaam" select="substring-before($onderwerp, ',')"/>
        <xsl:variable name="voornaam" select="substring-after($onderwerp, ',')"/>
        <xsl:variable name="naam" select="concat($voornaam, ' ', $achternaam)"/>

        <xsl:choose>
            <xsl:when test="contains(field[@name = 'W1'], 'boeken')">
                <spinque:relation subject="{$subject}"
                    predicate="rdf:type"
                    object="schema:Book"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:relation subject="{$subject}"
                    predicate="rdf:type"
                    object="schema:Article"/>
            </xsl:otherwise>
        </xsl:choose>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:title"
            value="{field[@name='TI']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{field[@name='A1']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{field[@name='A2']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{field[@name='A3']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{field[@name='S1']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{field[@name='S2']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:creator"
            value="{field[@name='S3']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:type"
            value="{field[@name='VO']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:type"
            value="{field[@name='W1']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:language"
            value="{field[@name='TA']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:date"
            value="{field[@name='JA']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dcmit:Collection"
            value="IHLIA"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set boeken_ihlia"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:identifier"
            value="{field[@name='ID']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="http://purl.org/dc/terms/spatial"
            value="{field[@name='GE']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{field[@name='IR']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{field[@name='AN']}"
            type="string"/>
        <spinque:relation
            subject="{$subject}"
            predicate="dc:rights"
            object="http://rightsstatements.org/vocab/InC/1.0/"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:rights"
            value="Copyright niet bekend"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:source"
            value="{$subject}" type="string"/>
        <spinque:relation
            subject="{$subject}"
            predicate="dc:publisher"
            object="niod:Organizations/796"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:place"
            value="{field[@name='PL']}"
            type="string"/>
        <!--spinque:attribute
            subject="{$subject}"
            attribute="dc:title"
            value="{field[@name='TI']}"
            type="string"/-->

        <xsl:variable name="title" select="su:normalizeWhiteSpace(field[@name='TI'])"/>

        <xsl:choose>
            <xsl:when test="string-length($title) &gt; 21">

                <xsl:variable name="titleLang"
                    select="substring($title, 20, string-length($title))"/>
                <xsl:variable name="titleKort">
                    <xsl:choose>
                        <xsl:when test="contains($titleLang, ':')">
                            <xsl:value-of select="substring-before($titleLang, ':')"/>
                        </xsl:when>
                        <!--xsl:when test="contains($titleLang, ';')">
                            <xsl:value-of select="substring-before($titleLang, ';')"/>
                        </xsl:when-->
                        <!--xsl:when test="contains($titleLang, '.')">
							<xsl:value-of select="substring-before($titleLang, '.')"/>
						</xsl:when-->
                        <!--xsl:when test="contains($titleLang, ' ')">
                            <xsl:value-of select="substring-before($titleLang, ' ')"/>
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
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:description"
                    value="{$title}"
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
            value="{field[@name='PA']}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:subject"
            value="{$naam}"
            type="string"/>

        <xsl:choose>
            <xsl:when test="field[@name = 'ISBN'] != ''">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:identifier"
                    value="{concat('ISBN',field[@name='IB'])}" type="string"/>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'OR'], '# '))">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject"
                    value="{field[@name='Organisatiedescriptoren']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'OR'], '#')">
                    <spinque:attribute subject="{$subject}"
                        attribute="dc:subject" value="{.}"
                        type="string"/>
                    <!--spinque:debug message="{.}"/-->
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when
                test="not(contains(field[@name = 'VD'], '# ')) and not(contains(field[@name = 'VD'], ','))">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject"
                    value="{field[@name='Vrije Descriptoren']}" type="string"/>

            </xsl:when>

            <xsl:when
                test="contains(field[@name = 'VD'], '#') and not(contains(field[@name = 'VD'], ','))">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject"
                    value="{su:split(field[@name='VD'], '#')}" type="string"/>
            </xsl:when>

            <!--
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name='Vrije Descriptoren'], '#')">
                    <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
                </xsl:for-each>
            </xsl:otherwise>

            -->

        </xsl:choose>

        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'DE'], '# '))">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject"
                    value="{field[@name='Descriptoren Homosaurus']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'DE'], '#')">
                    <spinque:attribute subject="{$subject}"
                        attribute="dc:subject" value="{.}"
                        type="string"/>
                    <!--spinque:debug message="{.}"/-->
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'TH'], '# '))">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject"
                    value="{field[@name='Thema']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'TH'], '#')">
                    <spinque:attribute subject="{$subject}"
                        attribute="dc:subject" value="{.}"
                        type="string"/>
                    <!--spinque:debug message="{.}"/-->
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'WE'], '# '))">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject"
                    value="{field[@name='Wetenschapsbenadering']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'WE'], '#')">
                    <spinque:attribute subject="{$subject}"
                        attribute="dc:subject" value="{.}"
                        type="string"/>
                    <!--spinque:debug message="{.}"/-->
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
