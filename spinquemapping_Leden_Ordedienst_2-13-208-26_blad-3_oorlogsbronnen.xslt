<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:schema="http://schema.org/"
    extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<xsl:variable name="base">https://www.oorlogslevens.nl/</xsl:variable>

  <xsl:template match="row">
  	<xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="field[@name='Voornaam'] != '' ">
          <xsl:value-of select="su:normalizeWhiteSpace(concat(field[@name='Voornaam'], ' ', field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam']))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="su:normalizeWhiteSpace(concat(field[@name='Voorletters'], ' ', field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam']))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nameId">
      <xsl:choose>
        <xsl:when test="field[@name='Voornaam'] != '' ">
          <xsl:value-of select="su:replace(su:normalizeWhiteSpace(concat(field[@name='Voornaam'], ' ', field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam'])),' ','_')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="su:replace(su:normalizeWhiteSpace(concat(field[@name='Voorletters'], ' ', field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam'])),' ','_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  	<xsl:variable name="organizationId">113</xsl:variable>
  	<xsl:variable name="id" select="./@line"/>
    <xsl:variable name="record" select="su:uri('https://www.oorlogslevens.nl/record', $nameId, $organizationId, $id)"/>
    <xsl:variable name="person" select="su:uri('https://www.oorlogslevens.nl/person', $nameId, $organizationId, $id)"/>

    <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
   	<spinque:relation subject="{$record}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/leden_ordedienst_na" />
    <spinque:attribute subject="{$record}" attribute="prov:wasDerivedFrom" value="Nationaal Archief, arch. nr. 2.13.208, inv. nr. 26" type="string"/>
    <spinque:attribute subject="{$record}" attribute="schema:description" value="{field[@name='Bron']}" type="string"/>

    <xsl:call-template name="person">
     	<xsl:with-param name="person" select="$person"/>
      	<xsl:with-param name="record" select="$record"/>
      	<xsl:with-param name="name" select="$name"/>
    </xsl:call-template>

  </xsl:template>

	<xsl:template name="person">
		<xsl:param name="person"/>
    <xsl:param name="record"/>
    <xsl:param name="name"/>

    <xsl:variable name="birthDate" select="su:parseDate(field[@name='geboortedatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="birthPlace" select="field[@name='Geboorteplaats']"/>
    <xsl:variable name="startDate" select="su:parseDate(field[@name='Startdatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="endDate" select="su:parseDate(field[@name='Einddatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="eventType" select="field[@name='Gebeurtenislink']"/>
    <xsl:variable name="fromPlace" select="field[@name='Startlocatie']"/>
    <xsl:variable name="eventPlaceLabel">
    <xsl:if test="$fromPlace != ''">
       <xsl:value-of select="concat(' in ', $fromPlace)"/>
    </xsl:if>
    </xsl:variable>

   	<spinque:relation subject="{$person}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/leden_ordedienst_na" />
  	<spinque:relation subject="{$person}" predicate="rdf:type" object="schema:Person"/>
  	<spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>
    <spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:name" value="{$name}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='Voorletters']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='Voornaam']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:familyName" value="{su:normalizeWhiteSpace(concat(field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam']))}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
    <spinque:attribute subject="{$person}" attribute="schema:birthPlace" value="{$birthPlace}" type="string"/>

    <xsl:if test="$birthDate != ''">
      <xsl:variable name="birth_event" select="su:uri($person, 'birth')"/>
      <spinque:attribute subject="{$birth_event}" attribute="schema:name" value="Geboren" type="string"/>
      <spinque:attribute subject="{$birth_event}" attribute="schema:alternateName" value="{concat($name , ' is geboren.')}" type="string"/>
      <spinque:attribute subject="{$birth_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' geboren.')}" type="string"/>
      <spinque:relation subject="{$birth_event}" predicate="rdf:type" object="schema:Event"/>
      <spinque:relation subject="{$birth_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6360"/>
      <spinque:relation subject="{$birth_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
      <spinque:relation subject="{$birth_event}" predicate="schema:actor" object="{$person}"/>
      <spinque:attribute subject="{$birth_event}" attribute="schema:date" value="{$birthDate}" type="date"/>
      <spinque:attribute subject="{$birth_event}" attribute="schema:location" value="{$birthPlace}" type="string"/>
    </xsl:if>

    <xsl:if test="field[@name='Adres'] != '' or field[@name='Woonplaats'] != ''">
        <xsl:variable name="residence" select="su:uri($person, 'residence')"/>
        <spinque:relation subject="{$residence}" predicate="rdf:type" object="schema:Residence"/>
        <spinque:attribute subject="{$residence}" attribute="rdfs:label" value="Adres" type="string"/>
        <spinque:relation subject="{$residence}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$residence}" predicate="schema:actor" object="{$person}"/>
      <xsl:variable name="residenceLabel">
        <xsl:choose>
          <xsl:when test="field[@name='Adres'] != ''">
            <xsl:value-of select="concat(field[@name='Adres'], ', ', field[@name='Woonplaats'])"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="field[@name='Woonplaats']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <spinque:attribute subject="{$residence}" attribute="schema:address" value="{field[@name='Adres']}" type="string"/>
      <spinque:attribute subject="{$residence}" attribute="schema:addressLocality" value="{field[@name='Woonplaats']}" type="string"/>
      <spinque:attribute subject="{$residence}" attribute="schema:location" value="{$residenceLabel}" type="string"/>
      <spinque:attribute subject="{$residence}" attribute="schema:alternateName" value="{concat($name, ' had als laatst bekende adres ', $residenceLabel,'.')}" type="string"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Gearresteerd')">
        <xsl:variable name="arrested_event" select="su:uri($person, 'arrested')"/>
        <spinque:relation subject="{$arrested_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$arrested_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$arrested_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$arrested_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:name" value="Gearresteerd" type="string"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:location" value="{$fromPlace}" type="string"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:alternateName" value="{concat($name , ' is gearresteerd', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' gearresteerd', $eventPlaceLabel, '.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Geïnterneerd')">
        <xsl:variable name="interned_event" select="su:uri($person, 'interned')"/>
        <spinque:relation subject="{$interned_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$interned_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$interned_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$interned_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:name" value="Geïnterneerd" type="string"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:startDate" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:endDate" value="{$endDate}" type="date"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:location" value="{$fromPlace}" type="string"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:alternateName" value="{concat($name , ' is geïnterneerd', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' geïnterneerd', $eventPlaceLabel, '.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Getransporteerd')">
        <xsl:variable name="transported_event" select="su:uri($person, 'transported')"/>
        <spinque:relation subject="{$transported_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$transported_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$transported_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$transported_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$transported_event}" attribute="schema:name" value="Getransporteerd" type="string"/>
        <spinque:attribute subject="{$transported_event}" attribute="schema:startDate" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$transported_event}" attribute="schema:fromLocation" value="{$fromPlace}" type="string"/>
        <spinque:attribute subject="{$transported_event}" attribute="schema:alternateName" value="{concat($name , ' is getransporteerd', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$transported_event}" attribute="schema:description" value="{concat('Op ${startDate} is ', $name , ' getransporteerd', $eventPlaceLabel, '.')}" type="string"/>
      </xsl:when>
    </xsl:choose>

	</xsl:template>

</xsl:stylesheet>
