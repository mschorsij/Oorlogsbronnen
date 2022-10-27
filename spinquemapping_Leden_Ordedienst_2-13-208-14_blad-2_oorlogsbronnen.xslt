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
  	<xsl:variable name="name" select="su:normalizeWhiteSpace(concat(field[@name='Voorletters'], ' ', field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam']))"/>
    <xsl:variable name="nameId" select="su:replace(su:normalizeWhiteSpace(concat(field[@name='Voorletters'], ' ', field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam'])),' ','_')"/>
  	<xsl:variable name="organizationId">113</xsl:variable>
  	<xsl:variable name="id" select="./@line"/>
    <xsl:variable name="record" select="su:uri('https://www.oorlogslevens.nl/record', $nameId, $organizationId, $id)"/>
    <xsl:variable name="person" select="su:uri('https://www.oorlogslevens.nl/person', $nameId, $organizationId, $id)"/>

    <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
   	<spinque:relation subject="{$record}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/leden_ordedienst_na" />
    <spinque:attribute subject="{$record}" attribute="prov:wasDerivedFrom" value="Nationaal Archief, arch. nr. 2.13.208, inv. nr. 14" type="string"/>
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

    <xsl:variable name="birthDate" select="su:parseDate(field[@name='Geboortedatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="startDate" select="su:parseDate(field[@name='Startdatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="eventType" select="field[@name='Gebeurtenislink']"/>
    <xsl:variable name="eventPlace" select="field[@name='Startlocatie']"/>
    <xsl:variable name="eventPlaceLabel">
        <xsl:if test="$eventPlace != ''">
            <xsl:value-of select="concat(' in ', $eventPlace)"/>
        </xsl:if>
    </xsl:variable>

   	<spinque:relation subject="{$person}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/leden_ordedienst_na" />
		<spinque:relation subject="{$person}" predicate="rdf:type" object="schema:Person"/>
	  <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>
    <spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:name" value="{$name}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='Voorletters']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:familyName" value="{su:normalizeWhiteSpace(concat(field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam']))}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
     <spinque:attribute subject="{$person}" attribute="schema:jobTitle" value="{field[@name='Rang']}" type="string"/>

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
      <spinque:attribute subject="{$birth_event}" attribute="schema:location" value="{field[@name='Geboorteplaats']}" type="string"/>
    </xsl:if>

    <xsl:if test="field[@name='Straat_laatstbekendeadres'] != '' or field[@name='Plaatslaatsbekendeadres'] != ''">
        <xsl:variable name="residence" select="su:uri($person, 'residence')"/>
        <spinque:relation subject="{$residence}" predicate="rdf:type" object="schema:Residence"/>
        <spinque:attribute subject="{$residence}" attribute="rdfs:label" value="Laatst bekende adres" type="string"/>
        <spinque:relation subject="{$residence}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$residence}" predicate="schema:actor" object="{$person}"/>
      <xsl:variable name="residenceLabel">
        <xsl:choose>
          <xsl:when test="field[@name='Straat_laatstbekendeadres'] != ''">
            <xsl:value-of select="concat(field[@name='Straat_laatstbekendeadres'], ', ', field[@name='Plaatslaatsbekendeadres'])"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="field[@name='Plaatslaatsbekendeadres']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <spinque:attribute subject="{$residence}" attribute="schema:address" value="{field[@name='Straat_laatstbekendeadres']}" type="string"/>
      <spinque:attribute subject="{$residence}" attribute="schema:addressLocality" value="{field[@name='Plaatslaatsbekendeadres']}" type="string"/>
      <spinque:attribute subject="{$residence}" attribute="schema:location" value="{$residenceLabel}" type="string"/>
      <spinque:attribute subject="{$residence}" attribute="schema:alternateName" value="{concat($name, ' had als laatst bekende adres ', $residenceLabel,'.')}" type="string"/>
    </xsl:if>

    <xsl:if test="contains(field[@name='Gebeurtenis'], 'Lid')">
  		<xsl:variable name="member_event" select="su:uri($person, 'member')"/>
      <spinque:relation subject="{$member_event}" predicate="rdf:type" object="schema:Event"/>
      <spinque:relation subject="{$member_event}" predicate="rdf:type" object="{$eventType}"/>
      <spinque:relation subject="{$member_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
      <spinque:relation subject="{$member_event}" predicate="schema:actor" object="{$person}"/>
      <spinque:attribute subject="{$member_event}" attribute="schema:name" value="Lid geworden" type="string"/>
      <spinque:attribute subject="{$member_event}" attribute="schema:date" value="{$startDate}" type="date"/>
      <spinque:attribute subject="{$member_event}" attribute="schema:location" value="{$eventPlace}" type="string"/>
    	<spinque:attribute subject="{$member_event}" attribute="schema:alternateName" value="{concat($name , ' is lid geworden', $eventPlaceLabel, '.')}" type="string"/>
      <spinque:attribute subject="{$member_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' lid geworden', $eventPlaceLabel, '.')}" type="string"/>
      <spinque:attribute subject="{$member_event}" attribute="schema:disambiguatingDescription" value="{field[@name='Opmerking']}" type="string"/>
    </xsl:if>

	</xsl:template>

</xsl:stylesheet>
