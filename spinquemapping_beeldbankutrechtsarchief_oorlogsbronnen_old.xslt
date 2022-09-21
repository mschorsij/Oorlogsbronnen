<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:su="com.spinque.tools.importStream.Utils"
	xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
	xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
	xmlns:ese="http://www.europeana.eu/schemas/ese/"
	xmlns:europeana="http://www.europeana.eu/schemas/ese/"
	xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
	xmlns:vvdu="com.spinque.tools.extraction.project.verteldverleden.IdentifyDate"
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>
	<!--
<record>
      <header>
        <identifier>{642FBF1E-4428-5C54-8F1B-178F4A974C52}</identifier>
        <datestamp>2020-03-21</datestamp>
        <setSpec>NOB_39</setSpec>
        <setSpec>NOB</setSpec>
      </header>
      <metadata>
        <oai_dc:record xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:creator>Hogeweg, J.P., fotograaf</dc:creator>
          <dc:title>Afbeelding van de Memorial D-Day Parade met militairen van de 3rd Canadian Infantry Division op de Neude te Utrecht; op de achtergrond de Voorstraat.</dc:title>
          <dc:description>Afbeelding van de Memorial D-Day Parade met militairen van de 3rd Canadian Infantry Division op de Neude te Utrecht; op de achtergrond de Voorstraat.</dc:description>
          <dc:format>breedte 36 mm (kleinbeeldnegatief)</dc:format>
          <dc:format>negatief (zwart-wit)</dc:format>
          <dc:identifier>BEELDBANK_FOT_DOC_4-831615</dc:identifier>
          <dc:rights>CC BY 4.0</dc:rights>
          <dc:rights>http://creativecommons.org/licenses/by/4.0/deed.nl</dc:rights>
          <dc:type>Foto</dc:type>
          <dcterms:isPartOf>Fotografische documenten 4 Negatieven</dcterms:isPartOf>
          <dcterms:hasVersion>https://www.hetutrechtsarchief.nl/onderzoek/resultaten/archieven?mivast=39&amp;miadt=39&amp;miaet=14&amp;micode=BEELDBANK_FOT_DOC_4&amp;minr=41642012&amp;miview=ldt</dcterms:hasVersion>
          <dc:relation>https://proxy.archieven.nl/thumb/39/642FBF1E44285C548F1B178F4A974C52</dc:relation>
          <dc:relation>https://proxy.archieven.nl/download/39/642FBF1E44285C548F1B178F4A974C52</dc:relation>
        </oai_dc:record>
      </metadata>
    </record>
-->

	<xsl:template match="recordlist | record | metadata">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="oai_dc:record">
		<xsl:if test="(dc:type = 'Foto')
			or contains(dc:type, 'Boek')
			or contains(dc:type, 'Krant')">
			<xsl:variable name="subject" select="dcterms:hasVersion"/>
			<!-- *** run generic Dublin Core *** -->
			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<xsl:if test="contains(dc:relation[1], 'thumb')">
			<!-- boeken hebben geen thumbnail-->
			<spinque:attribute
				subject="{$subject}"
				attribute="schema:thumbnail"
				value="{concat(dc:relation[1], '?dummy=dummy.png')}"
				type="string"/>
		</xsl:if>

		<spinque:attribute
			subject="{$subject}"
			attribute="dc:language"
			value="nl"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dcmit:Collection"
			value="Beeldbank Utrechts Archief"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="schema:disambiguatingDescription"
			value="In Oorlogsbronnen in set beeldbank_utrecht"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:source"
			value="{$subject}"
			type="string"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:identifier"
			value="{dc:identifier}"
			type="string"/>
		<!-- *** Link Publisher *** -->
		<spinque:relation
			subject="{$subject}"
			predicate="dc:publisher"
			object="niod:Organizations/128"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:publisher"
			value="Het Utrechts Archief"
			type="string"/>
		<!-- end -->

		<xsl:choose>
			<xsl:when
				test="contains(dc:rights[2], 'CC0')
				or contains(su:lowercase(dc:rights[2]), 'public domain')
				or contains(dc:rights[2], 'publicdomain')">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="https://creativecommons.org/publicdomain/zero/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="CC0"
					type="string"/>
			</xsl:when>
			<xsl:when
				test="contains(dc:rights[2], '/by/')">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="https://creativecommons.org/licenses/by/4.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="CC-BY"
					type="string"/>
			</xsl:when>
			<xsl:when
				test="contains(dc:rights[2], '/by-nc/')">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="https://creativecommons.org/licenses/by-nc/4.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="CC BY-NC"
					type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/vocab/CNE/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="Copyright niet bekend"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="dc:type = 'Boek'">
				<xsl:choose>
					<xsl:when test="contains(dc:title, '; /')">
						<spinque:attribute subject="{$subject}"
							attribute="dc:title"
							value="{substring-before(dc:title, '; /')}" type="string"/>
					</xsl:when>
					<xsl:otherwise>
						<!--spinque:attribute subject="{$subject}"
							attribute="dc:title" value="{dc:title}"
							type="string"/-->

						<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:title))"/>

						<xsl:choose>
							<xsl:when test="string-length($title) &gt; 21">
								<xsl:variable name="titleLang"
									select="substring($title, 20, string-length($title))"/>
								<xsl:variable name="titleKort">
									<xsl:choose>
										<xsl:when test="contains($titleLang, ',')">
		                                    <xsl:value-of select="substring-before($titleLang, ',')"/>
		                                </xsl:when>
										<xsl:when test="contains($titleLang, ';')">
											<xsl:value-of select="substring-before($titleLang, ';')"/>
										</xsl:when>
										<!--xsl:when test="contains($titleLang, '.')">
											<xsl:value-of select="substring-before($titleLang, '.')"/>
										</xsl:when-->
										<xsl:when test="contains($titleLang, ' ')">
											<xsl:value-of select="substring-before($titleLang, ' ')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$titleLang"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<spinque:attribute
									subject="{$subject}"
									attribute="dc:title"
									value="{concat(substring($title, 1,19), $titleKort, ' [...]')}"
									type="string"/>
								<spinque:attribute
									subject="{$subject}"
									attribute="dc:description"
									value="{$title}"
									type="string"/>
									<spinque:debug message="ORG: {$title}"/>
									<spinque:debug message="TIT: {substring($title, 1,19)}"/>
									<spinque:debug message="KORT: {$titleKort}"/>
									<spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort, ' [...]' )}"/>
							</xsl:when>
							<xsl:otherwise>
								<spinque:attribute
									subject="{$subject}"
									attribute="dc:title"
									value="{$title}"
									type="string"/>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!--spinque:attribute
					subject="{$subject}"
					attribute="dc:title"
					value="{dc:title}"
					type="string"/-->

				<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:title))"/>

				<xsl:choose>
					<xsl:when test="string-length($title) &gt; 21">
						<xsl:variable name="titleLang"
							select="substring($title, 20, string-length($title))"/>
						<xsl:variable name="titleKort">
							<xsl:choose>
								<xsl:when test="contains($titleLang, ';')">
									<xsl:value-of select="substring-before($titleLang, ';')"/>
								</xsl:when>
								<xsl:when test="contains($titleLang, ',')">
									<xsl:value-of select="substring-before($titleLang, ',')"/>
								</xsl:when>
								<xsl:when test="contains($titleLang, '.')">
									<xsl:value-of select="substring-before($titleLang, '.')"/>
								</xsl:when>
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
							value="{concat(substring($title, 1,19), $titleKort, ' [...]')}"
							type="string"/>
						<spinque:attribute
							subject="{$subject}"
							attribute="dc:description"
							value="{$title}"
							type="string"/>
						<spinque:debug message="ORG: {$title}"/>
						<spinque:debug message="TIT: {substring($title, 1,19)}"/>
						<spinque:debug message="KORT: {$titleKort}"/>
						<spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort, ' [...]' )}"/>
					</xsl:when>
					<xsl:otherwise>
						<spinque:attribute
							subject="{$subject}"
							attribute="dc:title"
							value="{$title}"
							type="string"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:description"
			value="{dc:description}"
			type="string"/>
		<xsl:choose>
			<xsl:when test="dc:type = 'Boek'">
				<spinque:relation
					subject="{$subject}"
					predicate="rdf:type"
					object="schema:Book"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:type"
					value="boek"
					type="string"/>
			</xsl:when>
			<xsl:when test="dc:type = 'Krant'">
				<spinque:relation
					subject="{$subject}"
					predicate="rdf:type"
					object="schema:Newspaper"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:type"
					value="krant"
					type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation
					subject="{$subject}"
					predicate="rdf:type"
					object="schema:Photograph"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:type"
					value="foto"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:creator"
			value="{dc:creator}"
			type="string"/>

		<xsl:apply-templates select="dc:publisher">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>


		<xsl:apply-templates select="dc:date">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>
	<!-- *** -->

	<!-- ******* -->

	<xsl:template match="dc:date">
		<xsl:param name="subject"/>
		<xsl:variable name="datum" select="concat('0', .)"/>
		<xsl:choose>
			<xsl:when test="string-length(.) = 4">
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:date"
					type="date"
					value="{su:parseDate(., 'yyyy')}"/>
			</xsl:when>
			<xsl:when test="string-length(.) = 6">
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:date"
					type="date"
					value="{su:parseDate($datum, 'MM/yyyy')}"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:subject"
			value="{.}"
			type="string"/>
	</xsl:template>

</xsl:stylesheet>
