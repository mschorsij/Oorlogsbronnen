<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:europeana="http://www.europeana.eu/schemas/ese/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:schema="http://schema.org/"
    xmlns:rdaGr2="http://rdvocab.info/ElementsGr2/" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:ead="urn:isbn:1-931666-22-9" xmlns:eaddsc="https://www.loc.gov/ead/archdesc/dsc/"
    xmlns:xlink="http://www.w3.org/1999/xlink" extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="oai:record">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="oai:header">
        <!-- ignore -->
    </xsl:template>

    <xsl:template match="oai:metadata">
        <xsl:apply-templates select="ead:ead"/>
    </xsl:template>

    <xsl:template match="ead:ead">
        <xsl:variable name="subject">
            <xsl:value-of select="concat('http://www.archieven.nl/nl/search-modonly?mivast=298&amp;mizig=210&amp;miadt=298&amp;micode=',ead:eadheader/ead:eadid,'&amp;milang=nl&amp;miview=inv2')"/>
        </xsl:variable>

        <spinque:relation
            subject="{$subject}"
            predicate="rdf:type"
            object="niod:Archive"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:type"
            value="archief"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:identifier"
            value="{ead:eadheader/ead:eadid}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:source"
            value="{$subject}"
            type="string"/>
        <spinque:relation
            subject="{$subject}"
            predicate="dc:publisher"
            object="niod:Organizations/116"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:publisher"
            value="NIOD"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:language"
            value="nl"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dcmit:Collection"
            value="Archieven NIOD"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_niod"
            type="string"/>

        <xsl:apply-templates select="ead:archdesc">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ead:archdesc -->
    <xsl:template match="ead:archdesc">
        <xsl:param name="subject"/>

        <!--<archdesc level="fonds" type="inventory">
      <did id="MF2145159">
        <unittitle>Bijzondere Rechtspleging</unittitle>
        <unitid countrycode="NL" repositorycode="NL-AsdNIOD">270a</unitid>
        <unitdate calendar="gregorian" era="ce" normal="1940/1949">(1940) 1945-1949</unitdate>
        <note label="Over het archief">
          <p>De collectie Bijzondere Rechtspleging bevat onder meer stukken over het Directoraat-Generaal voor Bijzondere Rechtspleging, verscheidene Politieke Recherche Afdelingen, bijzondere gerechtshoven en tribunalen.</p>
        </note>
        <note label="Openbaarheid">
          <p>Enkele inventarisnummers van dit archief zijn beperkt openbaar. Details staan vermeld in de rubriek "openbaarheid".</p>
        </note>
        <physdesc>1,0 meter (242 inventarisnummers)</physdesc>
      </did>-->

        <!--spinque:attribute
            subject="{$subject}"
            attribute="dc:title"
            value="{ead:did/ead:unittitle} [{ead:did/ead:unitid}]"
            type="string"/-->

        <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(ead:did/ead:unittitle))"/>

        <xsl:choose>
            <xsl:when test="string-length($title) &gt; 21">
                <xsl:variable name="titleLang"
                    select="substring($title, 20, string-length($title))"/>
                <xsl:variable name="titleKort">
                    <xsl:choose>
                        <xsl:when test="contains($titleLang, ',')">
                            <xsl:value-of select="substring-before($titleLang, ',')"/>
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
                <!--spinque:debug message="ORG: {$title}"/-->
                <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                <!--spinque:debug message="KORT: {$titleKort}"/-->
                <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:description"
                    value="{$title}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:title"
                    value="{$title}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when test="ead:did/ead:unitdate/@normal = '0000/9999'">
                    <xsl:value-of select="'1900/2010'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ead:did/ead:unitdate/@normal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:date"
            value="{su:parseDate($date,'nl-nl','yyyy', 'yyyy/yyyy')}"
            type="date"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:format"
            value="{ead:did/ead:physdesc}"
            type="string"/>

        <xsl:for-each select="ead:did/ead:note">
            <xsl:choose>
                <xsl:when test="./@label != ''">
                    <spinque:attribute
                        subject="{$subject}"
                        attribute="dc:description"
                        value="{./@label}: {su:stripTags(.)}"
                        type="string"/>
                    <!--spinque:debug message="{./@label}: {su:stripTags(.)}"/-->
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute
                        subject="{$subject}"
                        attribute="dc:description"
                        value="{su:stripTags(.)}"
                        type="string"/>
                    <!--spinque:debug message="{su:stripTags(.)}"/-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:apply-templates select="ead:controlaccess/ead:controlaccess">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:did">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:odd/ead:odd">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:descgrp">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:dsc/ead:*[@level = 'series']">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:bioghist">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- ead:cotrolaccess -->
    <xsl:template match="ead:controlaccess">
        <xsl:param name="parent"/>

        <!-- <xsl:for-each select="ancestor::*">
            <spinque:debug message="{local-name(.)} : {./@*}"/>
        </xsl:for-each>-->

        <xsl:for-each select="child::*">
            <xsl:choose>
                <xsl:when test="contains(., ',')">
                    <xsl:for-each select="su:split(., '\s*,\s*')">
                        <!--spinque:debug message="{su:stripTags(.)}"/-->
                        <spinque:attribute
                            subject="{$parent}"
                            attribute="dc:subject"
                            value="{su:stripTags(.)}"
                            type="string"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute
                        subject="{$parent}"
                        attribute="dc:subject"
                        value="{su:stripTags(.)}"
                        type="string"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:for-each>
    </xsl:template>

    <!-- ead:did -->

    <!--xsl:choose>
        <xsl:when test="$parent !=''">
        </xsl:when>
        <xsl:otherwise>
           <xsl:for-each select="ancestor::*">
            <spinque:debug message="{local-name(.)} : {./@*}"/>
        </xsl:for-each>
               </xsl:otherwise>
           </xsl:choose-->

    <!-- EAD ODD set -->
    <xsl:template match="ead:odd">
        <xsl:param name="parent"/>

        <xsl:if test="((ead:head != 'Openbaarheid')
            and (ead:head != 'citeer en aanvraaginstructie')
            and (ead:head != 'omvang')
            and (ead:head != 'bewerking')
            and (ead:head != 'archiefvormer')
            and (ead:head != 'titel archief'))">
            <!--spinque:debug message="{ead:head}: {ead:p}"/-->
            <spinque:attribute
                subject="{$parent}"
                attribute="dc:description"
                value="{ead:head}: {ead:p}"
                type="string"/>
        </xsl:if>
    </xsl:template>


    <!-- ead:descgrp -->
    <xsl:template match="ead:descgrp">
        <xsl:param name="parent"/>
        <xsl:apply-templates select="ead:custodhist">
            <xsl:with-param name="parent" select="$parent"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:scopecontent">
            <xsl:with-param name="parent" select="$parent"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="ead:custodhist">
        <xsl:param name="parent"/>

        <spinque:attribute
            subject="{$parent}"
            attribute="dc:description"
            value="{su:flatten(.)}"
            type="string"/>

    </xsl:template>

    <xsl:template match="ead:bioghist">
        <xsl:param name="parent"/>

        <spinque:attribute
            subject="{$parent}"
            attribute="dc:description"
            value="{su:flatten(.)}"
            type="string"/>

    </xsl:template>

    <xsl:template match="ead:scopecontent">
        <xsl:param name="parent"/>
        <xsl:if test="$parent != ''">
            <!--spinque:debug message="{local-name(parent::node())} : {parent::node()/@*}"/-->

            <spinque:attribute
                subject="{$parent}"
                attribute="dc:description"
                value="{ead:p}"
                type="string"/>

        </xsl:if>
    </xsl:template>

    <!-- hierarchische lagen -->
    <!--
  	series
   -->
    <xsl:template match="ead:*[@level = 'series']">
        <xsl:param name="parent"/>

        <xsl:variable name="part" select="concat('http://www.archieven.nl/nl/search-modonly?mivast=298&amp;mizig=210&amp;miadt=298&amp;series=', ead:did/@id,'&amp;',  ead:did/ead:unitid)"/>
        <!--spinque:debug message="ArchSeries: {$part}" /-->

        <spinque:relation
            subject="{$part}"
            predicate="rdf:type"
            object="niod:ArchiveSeries"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:type"
            value="dossier"
            type="string"/>
        <spinque:relation
            subject="{$part}"
            predicate="dct:isPartOf"
            object="{$parent}"/>
        <spinque:tree
            subject="{$part}"
            parent="{$parent}"
            tree="partOf"/>

        <xsl:if test="ead:did/ead:unitid != ''">
            <spinque:relation
                subject="{$part}"
                predicate="rdf:type"
                object="niod:ArchiveSeries"/>
            <spinque:attribute
                subject="{$part}"
                attribute="dc:type"
                value="dossier"
                type="string"/>
            <spinque:relation
                subject="{$part}"
                predicate="dct:isPartOf"
                object="{$parent}"/>
            <spinque:tree
                subject="{$part}"
                parent="{$parent}"
                tree="partOf"/>
            <spinque:attribute
                subject="{$part}"
                attribute="dc:identifier"
                value="{ead:did/ead:unitid}"
                type="string"/>
            <!--spinque:attribute
                subject="{$part}"
                attribute="dc:title"
                value="{ead:did/ead:unitid} {ead:did/ead:unittitle}"
                type="string"/-->

            <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(ead:did/ead:unittitle))"/>

            <xsl:choose>
                <xsl:when test="string-length($title) &gt; 21">
                    <xsl:variable name="titleLang"
                        select="substring($title, 20, string-length($title))"/>
                    <xsl:variable name="titleKort">
                        <xsl:choose>
                            <xsl:when test="contains($titleLang, '(')">
                                <xsl:value-of select="substring-before($titleLang, '(')"/>
                            </xsl:when>
                            <!--xsl:when test="contains($titleLang, '.')">
                            <xsl:value-of select="substring-before($titleLang, '.')"/>
                        </xsl:when-->
                            <!--xsl:when test="contains($titleLang, '[')">
                            <xsl:value-of select="substring-before($titleLang, '[')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, ';')">
                            <xsl:value-of select="substring-before($titleLang, ';')"/>
                        </xsl:when-->
                            <xsl:otherwise>
                                <xsl:value-of select="$titleLang"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <spinque:attribute
                        subject="{$part}"
                        attribute="dc:title"
                        value="{concat(substring($title, 1,19), $titleKort)}"
                        type="string"/>
                    <!--spinque:debug message="ORG: {$title}"/-->
                    <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                    <!--spinque:debug message="KORT: {$titleKort}"/-->
                    <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
                    <spinque:attribute
                        subject="{$part}"
                        attribute="dc:description"
                        value="{$title}"
                        type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute
                        subject="{$part}"
                        attribute="dc:title"
                        value="{$title}"
                        type="string"/>
                </xsl:otherwise>
            </xsl:choose>


            <xsl:variable name="date">
                <xsl:choose>
                    <xsl:when test="ead:did/ead:unitdate/@normal = '0000/9999'">
                        <xsl:value-of select="'1900/2010'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ead:did/ead:unitdate/@normal"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <spinque:attribute
                subject="{$part}"
                attribute="dc:date"
                value="{su:parseDate($date,'nl-nl','yyyy', 'yyyy/yyyy')}"
                type="date"/>
            <spinque:relation
                subject="{$part}"
                predicate="dc:publisher"
                object="niod:Organizations/116"/>
            <spinque:attribute
                subject="{$part}"
                attribute="dc:publisher"
                value="NIOD"
                type="string"/>
            <spinque:attribute
                subject="{$part}"
                attribute="schema:disambiguatingDescription"
                value="In Oorlogsbronnen in set archieven_niod"
                type="string"/>

            <xsl:apply-templates select="ead:*[not(self::ead:did)]">
                <xsl:with-param name="parent" select="$part"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!--
      subseries
     -->
    <xsl:template match="ead:*[@level = 'subseries']">
        <xsl:param name="parent"/>
        <xsl:variable name="part" select="concat('http://www.archieven.nl/nl/search-modonly?mivast=298&amp;mizig=210&amp;miadt=298&amp;subseries=', ead:did/@id,'&amp;',  ead:did/ead:unitid)"/>
        <!--spinque:debug message="ArchSeries (subseries): {$part}" /-->
        <spinque:relation
            subject="{$part}"
            predicate="rdf:type"
            object="niod:ArchiveSeries"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:type"
            value="dossier"
            type="string"/>
        <spinque:relation
            subject="{$part}"
            predicate="dct:isPartOf"
            object="{$parent}"/>
        <spinque:tree
            subject="{$part}"
            parent="{$parent}"
            tree="partOf"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:identifier"
            value="{ead:did/ead:unitid}"
            type="string"/>
        <!--spinque:attribute
            subject="{$part}"
            attribute="dc:title"
            value="{ead:did/ead:unitid} {ead:did/ead:unittitle}"
            type="string"/-->

        <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(ead:did/ead:unittitle))"/>

        <xsl:choose>
            <xsl:when test="string-length($title) &gt; 21">
                <xsl:variable name="titleLang"
                    select="substring($title, 20, string-length($title))"/>
                <xsl:variable name="titleKort">
                    <xsl:choose>
                        <xsl:when test="contains($titleLang, '(')">
                            <xsl:value-of select="substring-before($titleLang, '(')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, '/')">
                            <xsl:value-of select="substring-before($titleLang, '/')"/>
                        </xsl:when>
                        <!--xsl:when test="contains($titleLang, '[')">
                            <xsl:value-of select="substring-before($titleLang, '[')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, ';')">
                            <xsl:value-of select="substring-before($titleLang, ';')"/>
                        </xsl:when-->
                        <xsl:otherwise>
                            <xsl:value-of select="$titleLang"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:title"
                    value="{concat(substring($title, 1,19), $titleKort)}"
                    type="string"/>
                <!--spinque:debug message="ORG: {$title}"/-->
                <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                <!--spinque:debug message="KORT: {$titleKort}"/-->
                <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:description"
                    value="{$title}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:title"
                    value="{$title}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when test="ead:did/ead:unitdate/@normal = '0000/9999'">
                    <xsl:value-of select="'1900/2010'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ead:did/ead:unitdate/@normal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <spinque:attribute
            subject="{$part}"
            attribute="dc:date"
            value="{su:parseDate($date,'nl-nl','yyyy', 'yyyy/yyyy')}"
            type="date"/>
        <spinque:relation
            subject="{$part}"
            predicate="dc:publisher"
            object="niod:Organizations/116"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:publisher"
            value="NIOD"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_niod"
            type="string"/>

        <xsl:apply-templates select="ead:*[not(self::ead:did)]">
            <xsl:with-param name="parent" select="$part"/>
        </xsl:apply-templates>
    </xsl:template>

    <!--
      filegrp
     -->
    <xsl:template match="ead:*[@level = 'otherlevel' and @otherlevel = 'filegrp']">
        <xsl:param name="parent"/>

        <xsl:variable name="handle" select="ead:did/ead:unitid[@type = 'handle']"/>

        <xsl:variable name="part">
        <xsl:choose>
          <xsl:when test="$handle != ''">
            <xsl:value-of select="su:uri($handle, '#', ead:did/@id)"/>
            <!--xsl:variable name="part" select="su:uri('http://data.oorlogsbronnen.nl/niod/filegrp/', ead:did/@id)"/-->
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="su:uri('http://data.oorlogsbronnen.nl/niod/filegrp/', ead:did/@id)"/>
            <!--xsl:variable name="part" select="su:uri(ead:did/ead:unitid[@type = 'handle'], '#', ead:did/@id)"/-->
          </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>

        <!--spinque:debug message="filegrp: {$part}"/-->
        <spinque:relation
            subject="{$part}"
            predicate="rdf:type"
            object="niod:ArchiveSeries"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:type"
            value="dossier"
            type="string"/>
        <spinque:relation
            subject="{$part}"
            predicate="dct:isPartOf"
            object="{$parent}"/>
        <spinque:tree
            subject="{$part}"
            parent="{$parent}"
            tree="partOf"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:identifier"
            value="{ead:did/ead:unitid}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:source"
            value="{$part}"
            type="string"/>
        <!--spinque:attribute
            subject="{$part}"
            attribute="dc:title"
            value="{ead:did/ead:unitid} {ead:did/ead:unittitle}"
            type="string"/-->

        <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(ead:did/ead:unittitle))"/>

        <xsl:choose>
            <xsl:when test="string-length($title) &gt; 21">
                <xsl:variable name="titleLang"
                    select="substring($title, 20, string-length($title))"/>
                <xsl:variable name="titleKort">
                    <xsl:choose>
                        <xsl:when test="contains($titleLang, ',')">
                            <xsl:value-of select="substring-before($titleLang, ',')"/>
                        </xsl:when>
                        <!--xsl:when test="contains($titleLang, '.')">
                            <xsl:value-of select="substring-before($titleLang, '.')"/>
                        </xsl:when-->
                        <!--xsl:when test="contains($titleLang, '[')">
                            <xsl:value-of select="substring-before($titleLang, '[')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, ';')">
                            <xsl:value-of select="substring-before($titleLang, ';')"/>
                        </xsl:when-->
                        <xsl:otherwise>
                            <xsl:value-of select="$titleLang"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:title"
                    value="{concat(substring($title, 1,19), $titleKort)}"
                    type="string"/>
                <!--spinque:debug message="ORG: {$title}"/-->
                <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                <!--spinque:debug message="KORT: {$titleKort}"/-->
                <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:description"
                    value="{$title}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:title"
                    value="{$title}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when test="ead:did/ead:unitdate/@normal = '0000/9999'">
                    <xsl:value-of select="'1900/2010'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ead:did/ead:unitdate/@normal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <spinque:attribute
            subject="{$part}"
            attribute="dc:date"
            value="{su:parseDate($date,'nl-nl','yyyy', 'yyyy/yyyy')}"
            type="date"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:format"
            value="{ead:did/ead:physdesc}"
            type="string"/>
        <spinque:relation
            subject="{$part}"
            predicate="dc:publisher"
            object="niod:Organizations/116"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:publisher"
            value="NIOD"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_niod"
            type="string"/>
        <xsl:apply-templates select="ead:*[not(self::ead:did)]">
            <xsl:with-param name="parent" select="$part"/>
        </xsl:apply-templates>
    </xsl:template>

    <!--
      file
     -->
    <xsl:template match="ead:*[@level = 'file']">
        <xsl:param name="parent"/>

        <!-- Wouter (2017-09-27) archive 'file'-objects don't always have unique handles..., but combined with their @id they seem to do. (example: Aalten-Borculo, 20170712/data/oai_ead3260.xml:65864) -->
        <!--xsl:variable name="part" select="su:uri(ead:did/ead:unitid[@type = 'handle'], '#', ead:did/@id)"/-->
        <xsl:variable name="part">
       	<xsl:choose>
       	  <xsl:when test="ead:did/ead:unitid[@type = 'handle'] = ''">
       	    <xsl:value-of select="su:uri('http://data.oorlogsbronnen.nl/niod/file/', ead:did/@id)"/>
       	  </xsl:when>
       	  <xsl:otherwise>
            <xsl:value-of select="su:uri(ead:did/ead:unitid[@type = 'handle'], '#', ead:did/@id)"/>
       	  </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>

        <!--spinque:debug message="File: {concat(ead:did/ead:unitid[@type='handle'], '#', ead:did/@id)}"/-->
        <!--spinque:debug message="{$part}"/-->
        <spinque:relation
            subject="{$part}"
            predicate="rdf:type"
            object="niod:ArchiveFile"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:type"
            value="archiefbestand"
            type="string"/>
        <spinque:relation
            subject="{$part}"
            predicate="dct:isPartOf"
            object="{$parent}"/>
        <spinque:tree
            subject="{$part}"
            parent="{$parent}"
            tree="partOf"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:identifier"
            value="{ead:did/ead:unitid[@type='handle']}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:source"
            value="{ead:did/ead:unitid[@type='handle']}"
            type="string"/>
        <!--spinque:attribute
            subject="{$part}" attribute="dc:title"
            value="{ead:did/ead:unittitle}"
            type="string"/-->

        <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(ead:did/ead:unittitle))"/>

        <xsl:choose>
            <xsl:when test="string-length($title) &gt; 21">
                <xsl:variable name="titleLang"
                    select="substring($title, 20, string-length($title))"/>
                <xsl:variable name="titleKort">
                    <xsl:choose>
                        <xsl:when test="contains($titleLang, ',')">
                            <xsl:value-of select="substring-before($titleLang, ',')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, '.')">
                            <xsl:value-of select="substring-before($titleLang, '.')"/>
                        </xsl:when>
                        <!--xsl:when test="contains($titleLang, '[')">
                            <xsl:value-of select="substring-before($titleLang, '[')"/>
                        </xsl:when>
                        <xsl:when test="contains($titleLang, ';')">
                            <xsl:value-of select="substring-before($titleLang, ';')"/>
                        </xsl:when-->
                        <xsl:otherwise>
                            <xsl:value-of select="$titleLang"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:title"
                    value="{concat(substring($title, 1,19), $titleKort)}"
                    type="string"/>
                <!--spinque:debug message="ORG: {$title}"/-->
                <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                <!--spinque:debug message="KORT: {$titleKort}"/-->
                <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:description"
                    value="{$title}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:title"
                    value="{$title}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <!--spinque:attribute subject="{$part}" attribute="dc:description" value="{ead:did/ead:unittitle}" type="string"/-->
        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when test="ead:did/ead:unitdate/@normal = '0000/9999'">
                    <xsl:value-of select="'1900/2010'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ead:did/ead:unitdate/@normal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <spinque:attribute
            subject="{$part}"
            attribute="dc:date"
            value="{su:parseDate($date,'nl-nl','yyyy', 'yyyy/yyyy')}"
            type="date"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:format"
            value="{ead:did/ead:physdesc}"
            type="string"/>
        <spinque:relation
            subject="{$part}"
            predicate="dc:publisher"
            object="niod:Organizations/116"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:publisher"
            value="NIOD"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_niod"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dct:accessRights"
            value="{su:flatten(ead:odd[@type='OPENBAARHEID'])}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:format"
            value="{su:flatten(ead:odd[@type='ONTWIKKELINGSSTADIUM'])}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:description"
            value="{su:flatten(ead:scopecontent)}"
            type="string"/>

        <xsl:apply-templates select="ead:daogrp">
            <xsl:with-param name="parent" select="$part"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- gekoppelde digitale bestanden -->
    <!-- simplified version by MH. Make thumbnails direct attributes of the parent. I do not see any other properties of a daogrp that are required, thus no extra object is required either. -->
    <xsl:template match="ead:daogrp">
        <xsl:param name="parent"/>
        <!-- lang verhaal kort: er zijn c niveaus zonder qualifier. Op dit niveau veroorzaken ze een fout omdat ze ook geen identifier hebben.
        Deze C niveaus bevatten verwijzingen naar plaatjes. Dit zijn zijn illustratieve plaatjes die het NIOD aan archieven gehangen heeft. De plaatjes vormen geen onderdeel van het archief maar zijn illustraties. Ik laat deze plaatjes weg want ze hebben geen status -->
        <xsl:if test="$parent != ''">
            <xsl:for-each select="ead:daoloc[@xlink:label = 'thumb']">
                <spinque:attribute subject="{$parent}" attribute="schema:thumbnail"
                    value="{su:replace(@xlink:href, 'thumb','file')}" type="string"/>
                <!--spinque:attribute subject="{$parent}" attribute="schema:thumbnail" value="{@xlink:href}" type="string"/-->
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
