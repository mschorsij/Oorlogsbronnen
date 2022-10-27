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
        <xsl:when test="field[@name='voornaam'] != '' ">
          <xsl:value-of select="su:normalizeWhiteSpace(concat(field[@name='voornaam'], ' ', field[@name='tussenvoegsels'], ' ', field[@name='achternaam']))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="su:normalizeWhiteSpace(concat(field[@name='voorvoegsels'], ' ', field[@name='tussenvoegsels'], ' ', field[@name='achternaam']))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nameId">
      <xsl:choose>
        <xsl:when test="field[@name='voornaam'] != '' ">
          <xsl:value-of select="su:replace(su:normalizeWhiteSpace(concat(field[@name='voornaam'], ' ', field[@name='tussenvoegsels'], ' ', field[@name='achternaam'])),' ','_')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="su:replace(su:normalizeWhiteSpace(concat(field[@name='voorletters'], ' ', field[@name='tussenvoegsels'], ' ', field[@name='achternaam'])),' ','_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  	<xsl:variable name="organizationId">113</xsl:variable>
  	<xsl:variable name="id" select="./@line"/>
    <xsl:variable name="record" select="su:uri('https://www.oorlogslevens.nl/record', $nameId, $organizationId, $id)"/>
    <xsl:variable name="person" select="su:uri('https://www.oorlogslevens.nl/person', $nameId, $organizationId, $id)"/>

    <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
   	<spinque:relation subject="{$record}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/leden_ordedienst_na" />
    <spinque:attribute subject="{$record}" attribute="prov:wasDerivedFrom" value="Nationaal Archief, arch. nr. 2.13.208, inv. nr. 2610" type="string"/>
    <spinque:attribute subject="{$record}" attribute="schema:description" value="{field[@name='bron']}" type="string"/>

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
    <xsl:variable name="startDate" select="su:parseDate(field[@name='gebeurtenis_startdatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="endDate" select="su:parseDate(field[@name='gebeurtenis_einddatum'], 'nl_nl', 'yyyy-MM-dd')"/>
    <xsl:variable name="eventType" select="field[@name='gebeurtenislink']"/>
    <xsl:variable name="eventPlace" select="field[@name='locatie']"/>
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
    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='voorvoegsels']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='voornaam']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:familyName" value="{field[@name='achternaam']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
    <xsl:if test="contains(field[@name='gebeurtenis'], 'Omgekomen')">
        <spinque:attribute subject="{$person}" attribute="schema:deathDate" value="{$startDate}" type="date"/>
    </xsl:if>
    <xsl:for-each select="su:split(field[@name='groepen_URI'], ';')">
     <xsl:variable name="memberOf" select="."/>
     <spinque:relation subject="{$person}" predicate="schema:memberOf" object="{$memberOf}"/>
    </xsl:for-each>
    <xsl:for-each select="su:split(field[@name='groepen'], ';')">
     <xsl:variable name="memberOfText" select="."/>
     <spinque:attribute subject="{$person}" attribute="schema:memberOf" value="{$memberOfText}" type="string"/>
    </xsl:for-each>
    <spinque:attribute subject="{$person}" attribute="schema:roleName" value="{field[@name='functie']}" type="string"/>

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
    </xsl:if>

    <xsl:choose>
      <xsl:when test="contains(field[@name='gebeurtenis'], 'Lid geworden')">
        <xsl:variable name="member_event" select="su:uri($person, 'member')"/>
        <spinque:relation subject="{$member_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$member_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$member_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$member_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$member_event}" attribute="schema:name" value="Lid geworden" type="string"/>
        <spinque:attribute subject="{$member_event}" attribute="schema:startDate" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$member_event}" attribute="schema:endDate" value="{$endDate}" type="date"/>
        <spinque:attribute subject="{$member_event}" attribute="schema:location" value="{$eventPlace}" type="string"/>
        <spinque:attribute subject="{$member_event}" attribute="schema:alternateName" value="{concat($name , ' is lid geworden van de Binnenlandse Strijdkrachten', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$member_event}" attribute="schema:description" value="{concat('Op ${startDate} is ', $name , ' lid geworden van de Binnenlandse Strijdkrachten', $eventPlaceLabel, '.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='gebeurtenis'], 'Gearresteerd')">
        <xsl:variable name="arrested_event" select="su:uri($person, 'arrested')"/>
        <spinque:relation subject="{$arrested_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$arrested_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$arrested_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$arrested_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:name" value="Gearresteerd" type="string"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:location" value="{$eventPlace}" type="string"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:alternateName" value="{concat($name , ' is gearresteerd', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$arrested_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' gearresteerd', $eventPlaceLabel, '.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='gebeurtenis'], 'Omgekomen')">
        <xsl:variable name="death_event" select="su:uri($person, 'killed')"/>
        <spinque:relation subject="{$death_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$death_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$death_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$death_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:name" value="Omgekomen" type="string"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:location" value="{$eventPlace}" type="string"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:alternateName" value="{concat($name , ' is omgekomen', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' omgekomen', $eventPlaceLabel, '.')}" type="string"/>
      </xsl:when>
    </xsl:choose>

	</xsl:template>

</xsl:stylesheet>
