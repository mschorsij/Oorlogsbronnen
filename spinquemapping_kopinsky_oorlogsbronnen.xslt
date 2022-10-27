<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:ese="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
    extension-element-prefixes="spinque">

    <!-- Bijgewerkt door Micon op 20-10-2022 -->

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="result/items/node/item">
        <xsl:variable name="subject" select="fields/europeana_isShownAt/node"/>
        <xsl:call-template name="dc_record">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dc_record">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{fields/icn_deepzoomURL/node}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="{fields/europeana_dataProvider/node}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set collectie_kopinsky" type="string"/>
        <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:CreativeWork"/>
        <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:VisualArtwork"/>
        <spinque:attribute subject="{$subject}" attribute="dc:type" value="kunstwerk"  type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:creator" value="{fields/dc_creator/node}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{doc_id}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:title" value="{fields/dc_title/node}" type="string"/>
        <!-- Er bestaat wel een description van de objecten bij de bron, maar die heeft Collectie Nederland niet -->
        <!-- <spinque:attribute subject="{$subject}" attribute="dc:description" value="{summary/title}" type="string"/> -->
        <xsl:choose>
            <!-- jaar - jaar -->
            <xsl:when test="su:matches(fields/dc_date/node, '\d{4}\s*-\s*\d{4}')">
              <spinque:attribute subject="{$subject}" attribute="schema:startDate" value="{substring(fields/dc_date/node, 1,4)}" type="integer"/>
              <spinque:attribute subject="{$subject}" attribute="schema:endDate" value="{su:trim(substring(fields/dc_date/node, string-length(fields/dc_date/node)-4))}" type="integer"/>
            </xsl:when>
            <!-- jaar -->
            <xsl:when test="su:matches(fields/dc_date/node, '\d{4}\s*-\s*')">
                <spinque:attribute subject="{$subject}" attribute="dc:date" value="{substring(fields/dc_date/node, 1,4)}" type="integer"/>
            </xsl:when>
        </xsl:choose>
        <!-- subject, type, materiaal en techniek zijn wel bij de bron aanwezig, maar niet bij Collectie Nederland -->
        <spinque:attribute subject="{$subject}" attribute="dc:subject" value="kunst" type="string"/>
        <!-- <spinque:attribute subject="{$subject}" attribute="http://purl.org/dc/terms/format" value="{}" type="string"/> -->
        <spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/984"/>
        <spinque:attribute subject="{$subject}" attribute="dc:publisher" value="fields/europeana_dataProvider/node" type="string"/>
        <spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/vocab/InC/1.0/"/>
        <spinque:attribute subject="{$subject}" attribute="dc:rights" value="In Copyright" type="string"/>
    </xsl:template>
</xsl:stylesheet>
