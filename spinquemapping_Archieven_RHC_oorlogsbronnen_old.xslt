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
        <xsl:variable name="subject"
            select="concat('https://www.groningerarchieven.nl/archieven?mivast=5&amp;mizig=210&amp;miadt=5&amp;micode=', ead:eadheader/ead:eadid)"/>
        <!--spinque:debug message="{$subject}"/-->
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
            object="niod:Organizations/121"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:publisher"
            value="RHC Groninger Archieven"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dcmit:Collection"
            value="RHC Groninger Archieven"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_groningerarchief"
            type="string"/>

        <xsl:apply-templates select="ead:eadheader/ead:filedesc">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:eadheader/ead:profiledesc">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:archdesc">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>


    <xsl:template match="ead:filedesc">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="http://purl.org/dc/terms/dateSubmitted"
            value="{su:parseDate(ead:publicationstmt/ead:date, 'nl-nl', 'yyyy')}"
            type="date"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:title"
            value="{ead:titlestmt/ead:titleproper}"
            type="string"/>

    </xsl:template>

    <xsl:template match="ead:profiledesc">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:language"
            value="{ead:langusage}"
            type="string"/>
    </xsl:template>



    <xsl:template match="ead:archdesc">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:title"
            value="{ead:did/ead:unittitle}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{ead:did/ead:note[@label='Beschrijving']/ead:p}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:relation"
            value="{ead:did/ead:note[@label='Behoort tot collectie']/ead:p}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="http://purl.org/dc/terms/issued"
            value="{ead:did/ead:note[@label='Laatste publicatie']/ead:p}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{ead:did/ead:note[@label='Bijzonderheden']/ead:p}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{ead:controlaccess/ead:controlaccess/ead:subject}"
            type="string"/>

        <xsl:variable name="date" select="ead:did/ead:unitdate/@normal"/>
        <xsl:choose>
            <xsl:when test="contains($date, '/')">
                <xsl:if test="($date != '0000/9999')">
                    <spinque:attribute
                        subject="{$subject}"
                        attribute="dc:date"
                        value="{su:parseDate(substring-before(ead:did/ead:unitdate/@normal,'/'), 'nl_NL', 'yyyy')}"
                        type="date"/>
                    <spinque:attribute
                        subject="{$subject}"
                        attribute="dc:startDate"
                        value="{su:parseDate(substring-before(ead:did/ead:unitdate/@normal,'/'), 'nl_NL', 'yyyy')}"
                        type="date"/>
                    <spinque:attribute
                        subject="{$subject}"
                        attribute="dc:endDate"
                        value="{su:parseDate(substring-after(ead:did/ead:unitdate/@normal,'/'), 'nl_NL', 'yyyy')}"
                        type="date"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($date != '0000')">
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:date"
                    value="{su:parseDate(ead:did/ead:unitdate/@normal, 'nl-NL', 'yyyy')}"
                    type="date"/>
            </xsl:when>
        </xsl:choose>

        <xsl:apply-templates select="ead:odd">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:bioghist">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="ead:dsc/ead:*[@level = 'series']">
            <xsl:with-param name="parent" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="ead:odd">
        <xsl:param name="parent"/>
        <!--spinque:debug message="{local-name(parent::node())} : {parent::node()/@*}"/-->
        <xsl:for-each select="ead:p">
            <xsl:choose>
                <xsl:when test="(position() = 1) and (../ead:head != '')">
                    <spinque:attribute
                        subject="{$parent}"
                        attribute="dc:description"
                        value="{su:stripTags(../ead:head)} : {su:stripTags(.)}"
                        type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute
                        subject="{$parent}"
                        attribute="dc:description"
                        value="{su:stripTags(.)}"
                        type="string"/>
                    <!--spinque:debug message="Pliep"/-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="ead:bioghist">
        <xsl:param name="subject"/>
    </xsl:template>

    <!-- hierarchische lagen -->
    <!-- series -->
    <xsl:template match="ead:*[@level = 'series'] | ead:*[@level = 'subseries']">
        <xsl:param name="parent"/>
        <xsl:param name="titel"/>

        <xsl:variable name="part" select="concat('https://data.niod.nl/Organizations/121/', ancestor::ead:archdesc/ead:did/ead:unitid, '/', ead:did/@id)"/>

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
            predicate="http://purl.org/dc/terms/isPartOf"
            object="{$parent}"/>
        <spinque:tree
            subject="{$part}"
            parent="{$parent}"
            tree="partOf"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:identifier"
            value="{ead:did/@id}"
            type="string"/>
        <!--spinque:attribute subject="{$part}" attribute="https://www.loc.gov/ead/archdesc/dsc/series_code" value="{ead:did/ead:unitid[@type='series_code']}" type="string"/-->
        <spinque:attribute
            subject="{$part}"
            attribute="dc:title"
            value="{ead:did/ead:unittitle}"
            type="string"/>
        <!--value="{ead:did/ead:unitid[@type='series_code']} {ead:did/ead:unitid} {ead:did/ead:unittitle}"-->

        <spinque:attribute
            subject="{$part}"
            attribute="dc:date"
            value="{su:replace(ead:did/ead:unitdate/@normal,'/','-')}"
            type="string"/>
        <!-- end -->
        <spinque:relation
            subject="{$part}"
            predicate="dc:publisher"
            object="niod:Organizations/121"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:publisher"
            value="RHC Groninger Archieven"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_groningerarchief"
            type="string"/>

        <xsl:apply-templates select="ead:*[not(self::ead:did)]">
            <xsl:with-param name="parent" select="$part"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- file -->
    <xsl:template match="ead:*[@level = 'file']">
        <xsl:param name="parent"/>
        <xsl:param name="titel"/>
        <xsl:variable name="part" select="ead:did/ead:unitid[@type = 'handle']"/>
        <!--xsl:variable name="person" select="concat($part, '/person')"/>
        <xsl:variable name="birthDate" select="ead:odd[@type = 'GEBOREN']"/>
        <xsl:variable name="deathDate" select="ead:odd[@type = 'OVERLEDEN']"/>
        <xsl:variable name="achternaam" select="substring-before(ead:odd[@type = 'NAAM']/ead:p, ',')"/>
        <xsl:variable name="voornaam" select="substring-after(ead:odd[@type = 'NAAM']/ead:p, ',')"/>
        <xsl:variable name="naam" select="concat($voornaam, ' ', $achternaam)"/-->

        <xsl:if test="$parent = ''">
            <xsl:if test="parent::node()/ead:did/ead:unitid[@type = 'handle'] != ''">
                <xsl:variable name="parent"
                    select="parent::node()/ead:did/ead:unitid[@type = 'handle']"/>
            </xsl:if>
        </xsl:if>

        <spinque:relation
            subject="{$part}"
            predicate="rdf:type"
            object="niod:ArchiveFile"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:type"
            value="archiefbestand"
            type="string"/>

        <xsl:if test="$parent != ''">
            <spinque:relation
                subject="{$part}"
                predicate="http://purl.org/dc/terms/isPartOf"
                object="{$parent}"/>
            <spinque:tree
                subject="{$part}"
                parent="{$parent}"
                tree="partOf"/>
        </xsl:if>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:identifier"
            value="{ead:did/@id}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:source"
            value="{$part}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:title"
            value="{ead:did/ead:unittitle}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:date"
            value="{su:replace(ead:did/ead:unitdate/@normal,'/','-')}"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:format"
            value="{ead:did/ead:physdesc}"
            type="string"/>
        <!-- *** Link Publisher *** -->
        <spinque:relation
            subject="{$part}"
            predicate="dc:publisher"
            object="niod:Organizations/121"/>
        <spinque:attribute
            subject="{$part}"
            attribute="dc:publisher"
            value="RHC Groninger Archieven"
            type="string"/>
        <spinque:attribute
            subject="{$part}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set archieven_groningerarchief"
            type="string"/>
        <!--Persoon-->
        <!--xsl:if test="(ead:odd[@type = 'NAAM']/ead:p != '')">
            <spinque:relation
                subject="{$part}"
                predicate="schema:name"
                object="{$person}"/>
            <spinque:relation
                subject="{$person}"
                predicate="rdf:type"
                object="schema:Person"/>
            <spinque:attribute
                subject="{$person}"
                attribute="dc:title"
                value="{$naam}"
                type="string"/>
            <xsl:choose>
                <xsl:when test="string-length(ead:odd[@type = 'GEBOREN']/ead:p) &gt; 0 and string-length(ead:odd[@type = 'GEBOREN']/ead:p) &lt; 11">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:birthDate"
                        value="{su:parseDate($birthDate, 'nl_NL', 'yyyy' , 'yyyy-MM-dd')}"
                        type="date"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="(ead:odd[@type = 'OVERLEDEN']/ead:p != '')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:deathDate"
                        value="{su:parseDate($deathDate, 'nl_NL', 'yyyy', 'yyyy-MM-dd')}"
                        type="date"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="contains($voornaam, ' van')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:givenName"
                        value="{substring-before($voornaam, ' van')}"
                        type="string"/>
                </xsl:when>
                <xsl:when test="contains($voornaam, ' de')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:givenName"
                        value="{substring-before($voornaam, ' de')}"
                        type="string"/>
                </xsl:when>
                <xsl:when test="contains($voornaam, ' v.d.')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:givenName"
                        value="{substring-before($voornaam, ' v.d.')}"
                        type="string"/>
                </xsl:when>
                <xsl:when test="contains($voornaam, ' te')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:givenName"
                        value="{substring-before($voornaam, ' te')}"
                        type="string"/>
                </xsl:when>
                <xsl:when test="contains($voornaam, ' dr')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:givenName"
                        value="{substring-after($voornaam, ' dr')}"
                        type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:givenName"
                        value="{$voornaam}"
                        type="string"/>
                </xsl:otherwise>
            </xsl:choose>

            <spinque:attribute
                subject="{$person}"
                attribute="schema:additionalName"
                value="{ead:odd[@type='SCHUILNAMEN']/ead:p}"
                type="string"/>
            <xsl:choose>
                <xsl:when test="contains(ead:odd[@type = 'STANDPLAATS']/ead:p, ',')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:address"
                        value="{concat(substring-after(ead:odd[@type='STANDPLAATS']/ead:p, ', '), ', ', substring-before(ead:odd[@type='STANDPLAATS']/ead:p, ', '))}"
                        type="string"/>
                    <spinque:attribute
                        subject="{$part}"
                        attribute="schema:contentLocation"
                        value="{concat(substring-after(ead:odd[@type='STANDPLAATS']/ead:p, ', '), ', ', substring-before(ead:odd[@type='STANDPLAATS']/ead:p, ', '))}"
                        type="string"/>
                </xsl:when>
                <xsl:when test="contains(ead:odd[@type = 'STANDPLAATS']/ead:p, ';')">
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:address"
                        value="{substring-before(ead:odd[@type='STANDPLAATS']/ead:p, ';')}"
                        type="string"/>
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:address"
                        value="{substring-after(ead:odd[@type='STANDPLAATS']/ead:p, '; ')}"
                        type="string"/>
                    <spinque:attribute
                        subject="{$part}"
                        attribute="schema:contentLocation"
                        value="{substring-before(ead:odd[@type='STANDPLAATS']/ead:p, ';')}"
                        type="string"/>
                    <spinque:attribute
                        subject="{$part}"
                        attribute="schema:contentLocation"
                        value="{substring-after(ead:odd[@type='STANDPLAATS']/ead:p, '; ')}"
                        type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute
                        subject="{$person}"
                        attribute="schema:address"
                        value="{ead:odd[@type='STANDPLAATS']/ead:p}"
                        type="string"/>
                    <spinque:attribute
                        subject="{$part}"
                        attribute="schema:contentLocation"
                        value="{ead:odd[@type='STANDPLAATS']/ead:p}"
                        type="string"/>
                </xsl:otherwise>
            </xsl:choose>

            <spinque:attribute
                subject="{$person}"
                attribute="dc:title"
                value="{$naam}"
                type="string"/>
            <spinque:relation
                subject="{$person}"
                predicate="dc:rights"
                object="https://creativecommons.org/publicdomain/zero/1.0/"/>
            <spinque:attribute
                subject="{$person}"
                attribute="dc:rights"
                value="Publiek Domein"
                type="string"/>
            <spinque:attribute
                subject="{$person}"
                attribute="schema:memberOf"
                value="{ead:odd[@type='VERZETSGROEP']/ead:p}"
                type="string"/>
            <xsl:for-each select="ead:odd">
                <spinque:attribute
                    subject="{$person}"
                    attribute="dc:description"
                    value="{concat(su:lowercase(./@type), ': ', ead:p)}"
                    type="string"/>
                <spinque:attribute
                    subject="{$part}"
                    attribute="dc:description"
                    value="{concat(su:lowercase(./@type), ': ', ead:p)}"
                    type="string"/>
            </xsl:for-each>
            <spinque:attribute
                subject="{$person}"
                attribute="dc:source"
                value="{$part}"
                type="string"/>
            <spinque:relation
                subject="{$person}"
                predicate="dc:publisher"
                object="niod:Organizations/121"/>
            <spinque:attribute
                subject="{$person}"
                attribute="dc:publisher"
                value="RHC Groninger Archieven"
                type="string"/>
            <spinque:attribute
                subject="{$person}"
                attribute="schema:disambiguatingDescription"
                value="In Oorlogsbronnen in set archieven_groningerarchief"
                type="string"/>
        </xsl:if-->

        <!-- end Persoon -->
        <xsl:apply-templates select="ead:*[not(self::ead:did) and not(self::ead:odd)]">
            <xsl:with-param name="part" select="$part"/>
            <xsl:with-param name="parent" select="$part"/>
            <!--xsl:with-param name="person" select="$person"/-->
        </xsl:apply-templates>

    </xsl:template>

    <!-- gekoppelde digitale bestanden -->
    <!-- simplified version by MH. Make thumbnails direct attributes of the parent. I do not see any other properties of a daogrp that are required, thus no extra object is required either. -->
    <xsl:template match="ead:daogrp">
        <xsl:param name="part"/>
        <!--xsl:param name="person"/-->
        <spinque:attribute
            subject="{$part}"
            attribute="dc:description"
            value="{ead:daodesc/ead:p}"
            type="string"/>
        <xsl:for-each select="ead:daoloc[@xlink:label = 'thumb']">
            <spinque:attribute
                subject="{$part}"
                attribute="schema:thumbnail"
                value="{su:replace(su:replace(@xlink:href, 'thumb','file'), 'http', 'https')}"
                type="string"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
