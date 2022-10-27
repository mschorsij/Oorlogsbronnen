<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:ese="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template
    match="property[@name='items']/array/object">
        <xsl:variable
        name="subject"
        select="property[@name='meta']/object/property[@name='entryURI']"/>

        <xsl:call-template
        name="dc_record">
            <xsl:with-param
            name="subject"
            select="$subject"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dc_record">
        <xsl:param name="subject"/>
        <!--spinque:debug message="{$subject}"/-->

        <spinque:attribute
        subject="{$subject}"
        attribute="schema:thumbnail"
        value="{object/property[@name='fields']/object/property[@name='edm_isShownBy']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:language"
        value="nl"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dcmit:Collection"
        value="{object/property[@name='fields']/object/property[@name='edm_dataProvider']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="schema:disambiguatingDescription"
        value="In Oorlogsbronnen in set collectie_kopinsky"
        type="string"/>

    <!--spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:CreativeWork"/-->
    <spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
    <spinque:attribute subject="{$subject}" attribute="dc:type" value="kunstwerk"  type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:creator"
        value="{object/property[@name='fields']/object/property[@name='dc_creator']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute subject="{$subject}"
        attribute="dc:source"
        value="{$subject}"
        type="string"/>

        <spinque:attribute subject="{$subject}"
        attribute="dc:identifier"
        value="{object/property[@name='fields']/object/property[@name='hubID']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:title"
        value="{object/property[@name='fields']/object/property[@name='dc_title']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:description"
        value="{object/property[@name='fields']/object/property[@name='dc_title']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:date"
        value="{object/property[@name='fields']/object/property[@name='dcterms_created']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:date"
        value="{object/property[@name='fields']/object/property[@name='dcterms_created']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:subject"
        value="kunst"
        type="string"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="http://purl.org/dc/terms/format"
        value="{object/property[@name='fields']/object/property[@name='dc_type']/array/object/property[@name='value']}"
        type="string"/>

        <spinque:relation
        subject="{$subject}"
        predicate="dc:publisher"
        object="niod:Organizations/984"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:publisher"
        value="Museum Flehite"
        type="string"/>

        <spinque:relation
        subject="{$subject}"
        predicate="dc:rights"
        object="http://rightsstatements.org/vocab/InC/1.0/"/>

        <spinque:attribute
        subject="{$subject}"
        attribute="dc:rights"
        value="In Copyright"
        type="string"/>

    </xsl:template>
</xsl:stylesheet>
