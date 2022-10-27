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

	<!-- Datumafhandeling en afhandeling europeana:rights en dc:rights aangepast door Micon op 24-10-2022 -->

	<xsl:template match="europeana:record">
		<xsl:variable name="subject" select="europeana:isShownAt"/>
		<!-- <xsl:choose>
			<xsl:when
				test="contains(su:lowercase(dc:subject), 'tweede wereldoorlog') or contains(su:lowercase(dc:description), 'tweede wereldoorlog')"> -->
				<!-- *** run generic Dublin Core *** -->
				<xsl:call-template name="dc_record">
					<xsl:with-param name="subject" select="$subject"/>
				</xsl:call-template>
			<!-- </xsl:when>
		</xsl:choose> -->

	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<xsl:if test="(dc:creator != 'Egon Picker')">
			<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{su:replace(europeana:isShownBy,'640x480', '1000x1000')}" type="string"/>
		</xsl:if>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Stadsarchief Breda" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_breda" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{europeana:isShownAt}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/134"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Stadsarchief Breda" type="string"/>
		<xsl:choose>
			<xsl:when test="dc:creator != ''">
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/vocab/InC/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="In Copyright"
					type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation
					subject="{$subject}"
					predicate="dc:rights"
					object="http://rightsstatements.org/vocab/InC/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="Copyright niet bekend"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:description))"/>

		<xsl:choose>
			<xsl:when test="string-length($title) &gt; 21">
				<xsl:variable name="titleLang" select="substring($title, 20, string-length($title))"/>
				<xsl:variable name="titleKort">
					<xsl:choose>
						<xsl:when test="contains($titleLang, ',')">
							<xsl:value-of select="substring-before($titleLang, ',')"/>
						</xsl:when>
						<xsl:when test="contains($titleLang, '.')">
							<xsl:value-of select="substring-before($titleLang, '.')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$titleLang"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{concat(substring($title, 1,19), $titleKort)}" type="string"/>
				<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{$title}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="dc:creator">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="europeana:type">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:created">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:spatial">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>
	<!-- *** -->

	<!-- ******* -->
	<xsl:template match="dc:creator">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{.}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:creator" value="{.}" type="string"/>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
	</xsl:template>

	<xsl:template match="dcterms:spatial">
		<xsl:param name="subject"/>
		<xsl:variable name="arrayOfItems" select="su:split(., ',', 6)"/>
		<xsl:if test="($arrayOfItems[1] != '') or ($arrayOfItems[1] != ' onbekend') or ($arrayOfItems[1] != '-')">
			<!--<xsl:variable name="spatial" select="su:uri($subject, 'place')"/>
			<spinque:relation subject="{$subject}" predicate="schema:contentLocation" object="{$spatial}"/>
			<spinque:relation subject="{$spatial}" predicate="rdf:type" object="schema:Place"/>
			<spinque:attribute subject="{$spatial}" attribute="schema:name" value="{$arrayOfItems[1]}" type="string"/-->
			<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{$arrayOfItems[1]}" type="string"/>
			<xsl:if test="($arrayOfItems[5] != '') and ($arrayOfItems[5] != ' onbekend')">
				<spinque:attribute subject="{$subject}" attribute="schema:address" value="{$arrayOfItems[5]}" type="string"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="europeana:type">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when
				test="contains(su:lowercase(.), 'text') or contains(su:lowercase(.), 'krantknipsel') or contains(su:lowercase(.), 'tekst')">
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:Article"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="tekst" type="string"/>
			</xsl:when>
			<xsl:when
				test="su:lowercase(.) = 'image' or contains(su:lowercase(.), 'affiche') or contains(su:lowercase(.), 'still') or contains(su:lowercase(.), 'foto') or contains(su:lowercase(.), 'dia') or contains(su:lowercase(.), 'beeld') or contains(su:lowercase(.), 'photo') or contains(su:lowercase(.), 'negatief') or contains(su:lowercase(.), 'repro')">
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:Photograph"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="foto" type="string"/>
			</xsl:when>
			<xsl:when
				test="contains(su:lowercase(.), 'video') or contains(su:lowercase(.), 'tape') or contains(su:lowercase(.), 'film') or contains(su:lowercase(.), 'moving') or contains(su:lowercase(.), 'dvd')">
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:VideoObject"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="bewegend beeld"
					type="string"/>
			</xsl:when>
			<xsl:when
				test="contains(su:lowercase(.), 'audiocassette') or contains(su:lowercase(.), 'geluid')">
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:AudioObject"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="audio" type="string"/>
			</xsl:when>
			<xsl:when
				test="contains(su:lowercase(.), 'tekening') or contains(su:lowercase(.), 'prent') or contains(su:lowercase(.), 'aquarel')">
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:VisualArtwork"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="kunstwerk" type="string"
				/>
			</xsl:when>
			<xsl:when
				test="contains(su:lowercase(.), 'archief') or contains(su:lowercase(.), 'folder') or contains(su:lowercase(.), 'inventarisnummer')">
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="niod:Archive"/>
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:ArchiveComponent"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="archief" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation subject="{$subject}"
					predicate="rdf:type"
					object="schema:CreativeWork"/>
				<spinque:attribute subject="{$subject}"
					attribute="dc:type" value="voorwerp" type="string"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dcterms:created">
		<xsl:param name="subject"/>
		<xsl:choose>
				<!-- jaar-maand-dag -->
				<xsl:when test="su:matches(., '\d{4}-\d{2}-\d{2}') and not(contains(., '-00'))">
						<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'nl-nl', 'yyyy-MM-dd')}"/>
				</xsl:when>
				<!-- jaar -->
				<xsl:when test="su:matches(., '\d{4}-\d{2}-\d{2}') and contains(., '-00')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{substring(., 1,4)}" type="integer"/>
				</xsl:when>
				<xsl:when test="su:matches(., '\d{4}')">
						<spinque:attribute subject="{$subject}" attribute="dc:date" value="{.}" type="integer"/>
				</xsl:when>
				<!-- Alle andere situaties -->
				<xsl:otherwise>
						<spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{.}" type="string"/>
				</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
