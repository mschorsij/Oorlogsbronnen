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
    <spinque:attribute subject="{$record}" attribute="prov:wasDerivedFrom" value="Nationaal Archief, arch. nr. 2.13.208, inv. nr. 44" type="string"/>
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
    <xsl:variable name="endDate" select="su:parseDate(field[@name='Einddatum'], 'nl_nl', 'yyyy-MM-dd')"/>
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
    <spinque:attribute subject="{$person}" attribute="schema:alternateName" value="{field[@name='Bijnaam']}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:familyName" value="{su:normalizeWhiteSpace(concat(field[@name='Tussenvoegsels'], ' ', field[@name='Achternaam']))}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
    <xsl:if test="contains(field[@name='Gebeurtenis'], 'Gestorven') or contains(field[@name='Gebeurtenis'], 'Geëxecuteerd')">
      <spinque:attribute subject="{$person}" attribute="schema:deathDate" value="{$startDate}" type="date"/>
    </xsl:if>

    <xsl:for-each select="su:split(field[@name='Groepen_uris'], ';')">
      <xsl:variable name="memberOf" select="."/>
      <spinque:relation subject="{$person}" predicate="schema:memberOf" object="{$memberOf}"/>
    </xsl:for-each>
    <xsl:for-each select="su:split(field[@name='Groepen'], ';')">
      <xsl:variable name="memberOfText" select="."/>
      <spinque:attribute subject="{$person}" attribute="schema:memberOf" value="{$memberOfText}" type="string"/>
    </xsl:for-each>
    <xsl:for-each select="su:split(field[@name='Functie'], ';')">
      <xsl:variable name="role" select="."/>
      <spinque:attribute subject="{$person}" attribute="schema:roleName" value="{$role}" type="string"/>
    </xsl:for-each>

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
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Bevrijd')">
    		<xsl:variable name="liberated_event" select="su:uri($person, 'liberated')"/>
        <spinque:relation subject="{$liberated_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$liberated_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$liberated_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$liberated_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$liberated_event}" attribute="schema:name" value="Bevrijd" type="string"/>
        <spinque:attribute subject="{$liberated_event}" attribute="schema:date" value="{$startDate}" type="date"/>
      	<spinque:attribute subject="{$liberated_event}" attribute="schema:alternateName" value="{concat($name , ' is bevrijd.')}" type="string"/>
        <spinque:attribute subject="{$liberated_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' bevrijd.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Gearresteerd')">
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
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Geëxecuteerd')">
        <xsl:variable name="executed_event" select="su:uri($person, 'executed')"/>
        <spinque:relation subject="{$executed_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$executed_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$executed_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$executed_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$executed_event}" attribute="schema:name" value="Geëxecuteerd" type="string"/>
        <spinque:attribute subject="{$executed_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$executed_event}" attribute="schema:location" value="{$eventPlace}" type="string"/>
        <spinque:attribute subject="{$executed_event}" attribute="schema:alternateName" value="{concat($name , ' is geëxecuteerd', $eventPlaceLabel, '.')}" type="string"/>
        <spinque:attribute subject="{$executed_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' geëxecuteerd', $eventPlaceLabel, '.')}" type="string"/>
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
        <spinque:attribute subject="{$interned_event}" attribute="schema:alternateName" value="{concat($name , ' is geïnterneerd.')}" type="string"/>
        <spinque:attribute subject="{$interned_event}" attribute="schema:description" value="{concat('Op ${startDate} is ', $name , ' geïnterneerd.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Gestorven')">
        <xsl:variable name="death_event" select="su:uri($person, 'death')"/>
        <spinque:relation subject="{$death_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$death_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$death_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$death_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:name" value="Gestorven" type="string"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:alternateName" value="{concat($name , ' is gestorven.')}" type="string"/>
        <spinque:attribute subject="{$death_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' gestorven.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Gevlucht')">
        <xsl:variable name="escape_event" select="su:uri($person, 'escape')"/>
        <spinque:relation subject="{$escape_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$escape_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$escape_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$escape_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$escape_event}" attribute="schema:name" value="Gevlucht" type="string"/>
        <spinque:attribute subject="{$escape_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$escape_event}" attribute="schema:alternateName" value="{concat($name , ' is gevlucht.')}" type="string"/>
        <spinque:attribute subject="{$escape_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' gevlucht.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Ondergedoken')">
        <xsl:variable name="submerged_event" select="su:uri($person, 'submerged')"/>
        <spinque:relation subject="{$submerged_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$submerged_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$submerged_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$submerged_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$submerged_event}" attribute="schema:name" value="Ondergedoken" type="string"/>
        <spinque:attribute subject="{$submerged_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$submerged_event}" attribute="schema:alternateName" value="{concat($name , ' is ondergedoken.')}" type="string"/>
        <spinque:attribute subject="{$submerged_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' ondergedoken.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Ontsnapt')">
        <xsl:variable name="outbreak_event" select="su:uri($person, 'outbreak')"/>
        <spinque:relation subject="{$outbreak_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$outbreak_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$outbreak_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$outbreak_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$outbreak_event}" attribute="schema:name" value="Ontsnapt" type="string"/>
        <spinque:attribute subject="{$outbreak_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$outbreak_event}" attribute="schema:alternateName" value="{concat($name , ' is ontsnapt.')}" type="string"/>
        <spinque:attribute subject="{$outbreak_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' ontsnapt.')}" type="string"/>
      </xsl:when>
      <xsl:when test="contains(field[@name='Gebeurtenis'], 'Vrijgelaten')">
        <xsl:variable name="release_event" select="su:uri($person, 'release')"/>
        <spinque:relation subject="{$release_event}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$release_event}" predicate="rdf:type" object="{$eventType}"/>
        <spinque:relation subject="{$release_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$release_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$release_event}" attribute="schema:name" value="Vrijgelaten" type="string"/>
        <spinque:attribute subject="{$release_event}" attribute="schema:date" value="{$startDate}" type="date"/>
        <spinque:attribute subject="{$release_event}" attribute="schema:alternateName" value="{concat($name , ' is vrijgelaten.')}" type="string"/>
        <spinque:attribute subject="{$release_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' vrijgelaten.')}" type="string"/>
      </xsl:when>
    </xsl:choose>

	</xsl:template>

</xsl:stylesheet>
