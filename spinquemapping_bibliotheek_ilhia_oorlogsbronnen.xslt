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

    <!-- Bijgewerkt door Micon op 28-09-2022 -->

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="row">
        <xsl:variable name="subject" select="concat('https://www.ihlia.nl/search/?q:search=ID:', field[@name = 'ID'])"/>
        <xsl:choose>
            <xsl:when test="contains(field[@name='VD'], '#')">
                <xsl:for-each select="su:split(field[@name='VD'], '#')">
                    <xsl:value-of select="."/>
                    <xsl:variable name="achternaam" select="su:replace(substring-before(., ','), '_', ' ')"/>
                    <xsl:variable name="voornaam" select="su:replace(substring-after(., ','), '_', ' ')"/>
                    <xsl:variable name="naam" select="su:normalizeWhiteSpace(concat(su:capitalize($voornaam, 'titlecase'), ' ', su:capitalize($achternaam, 'titlecase')))"/>
                    <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$naam}" type="string"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="achternaam" select="su:replace(substring-before(field[@name='VD'], ','), '_', ' ')"/>
              <xsl:variable name="voornaam" select="su:replace(substring-after(field[@name='VD'], ','), '_', ' ')"/>
              <xsl:variable name="naam" select="su:normalizeWhiteSpace(concat(su:capitalize($voornaam, 'titlecase'), ' ', su:capitalize($achternaam, 'titlecase')))"/>
                <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$naam}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="thumbnail" select="su:normalizeWhiteSpace(concat('https://ihlia.nl/search/covers/', field[@name='ID'], '_1.jpg'))"/>
        <xsl:choose>
            <xsl:when test="contains(field[@name = 'W1'], 'boeken')">
                <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Book"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Article"/>
            </xsl:otherwise>
        </xsl:choose>
        <spinque:attribute subject="{$subject}" attribute="dc:title" value="{field[@name='TI']}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:creator" value="{su:substringBeforeLast(field[@name='AU'], '.')}" type="string"/>
        <xsl:for-each select="su:split(field[@name = 'VO'], '#')">
            <spinque:attribute subject="{$subject}" attribute="dc:type" value="{.}" type="string"/>
        </xsl:for-each>
        <spinque:attribute subject="{$subject}" attribute="dc:type" value="{field[@name='W1']}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:language" value="{su:capitalize(field[@name='TA'], 'titlecase')}" type="string"/>
        <xsl:choose>
            <xsl:when test="field[@name = 'DA'] != ''">
                <spinque:attribute subject="{$subject}" attribute="dc:date" value="{su:parseDate(field[@name='DA'], 'dd/MM/yyyy')}" type="date"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$subject}" attribute="dc:date" value="{field[@name='JA']}" type="integer"/>
            </xsl:otherwise>
        </xsl:choose>
        <spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Bibliotheek IHLIA" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set boeken_ihlia" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{field[@name='ID']}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:place" value="{su:normalizeWhiteSpace(su:capitalize(su:replace(field[@name='GE'], '_', ' '), 'titlecase'))}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:description" value="{field[@name='IR']}" type="string"/>
        <!-- Onderstaande Rights declarations zijn niet met elkaar in overeenstemming: -->
        <spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/vocab/InC/1.0/"/>
        <spinque:attribute subject="{$subject}" attribute="dc:rights" value="Copyright niet bekend" type="string"/>
        <!-- Waarom zou je deze triple naar zichzelf laten verwijzen: -->
        <spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
        <!-- Thumbnail url zelf geconstrueerd. Hoe gaat dit er uitzien als er geen thumbnail is? -->
        <xsl:if test="contains(field[@name = 'W1'], 'boeken')">
            <spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{$thumbnail}" type="string"/>
        </xsl:if>
        <spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/796"/>
        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'DE'], '# '))">
                <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{field[@name='DE']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'DE'], '#')">
                  <xsl:choose>
                    <xsl:when test="su:matches(., '.*\d{4}_\d{4}.*')">
                      <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{su:replace(., '_', '-')}" type="string"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{su:replace(., '_', ' ')}" type="string"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'TH'], '# '))">
                <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{field[@name='TH']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'TH'], '#')">
                    <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="not(contains(field[@name = 'WE'], '# '))">
                <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{field[@name='WE']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="su:split(field[@name = 'WE'], '#')">
                    <spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
                    <!--spinque:debug message="{.}"/-->
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
