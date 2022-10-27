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


	<xsl:template match="europeana:record">
		<xsl:variable name="subject" select="europeana:isShownAt"/>
		<!-- *** run generic Dublin Core *** -->
		<xsl:call-template name="dc_record">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:call-template>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{europeana:isShownBy}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:language"	value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank Regionaal Archief Alkmaar" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_alkmaar" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{europeana:isShownAt}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>

		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>
		<!-- *** Link Publisher *** -->
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/3"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Regionaal Archief Alkmaar" type="string"/>
		<!-- end -->

		<xsl:choose>
			<xsl:when test="europeana:rights = 'https://creativecommons.org/publicdomain/zero/1.0/'">
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="https://creativecommons.org/publicdomain/zero/1.0/"/>
				<spinque:attribute subject="{$subject}" attribute="dc:rights" value="CC0" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length(europeana:rights) != 0">
						<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/vocab/InC/1.0/"/>
						<spinque:attribute subject="{$subject}" attribute="dc:rights" value="In Copyright" type="string"/>
					</xsl:when>
					<xsl:otherwise>
						<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/page/CNE/1.0/"/>
						<spinque:attribute subject="{$subject}" attribute="dc:rights" value="Copyright niet bekend" type="string"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="dc:title != ''">
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:title}" type="string"/>
			</xsl:when>
			<xsl:when test="dc:description != ''">
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:description}" type="string"/>
			</xsl:when>
		</xsl:choose>

		<xsl:apply-templates select="dc:creator">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:date">
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
		<spinque:attribute
			subject="{$subject}"
			attribute="dc:creator"
			value="{.}"
			type="string"/>
	</xsl:template>


	<xsl:template match="dcterms:spatial">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(., '/')">

				<xsl:if test="(substring-before(.,'/') != 'Nederland')">
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{substring-before(.,'/')}" type="string"/>
				</xsl:if>
				<xsl:if test="(substring-after(.,'/') != 'Nederland')">
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{substring-after(.,'/')}" type="string"/>
				</xsl:if>

			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="(. != 'Nederland')">
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{.}" type="string"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dc:date">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(., '-00-00')">
				<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(su:replace(., '-00-00','-01-01'), 'nl-nl', 'yyyy-MM-dd')}"/>
				<spinque:attribute subject="{$subject}" attribute="schema:startDate" type="date" value="{su:parseDate(su:replace(., '-00-00','-01-01'), 'nl-nl', 'yyyy-MM-dd')}"/>
				<spinque:attribute subject="{$subject}" attribute="schema:endDate" type="date" value="{su:parseDate(su:replace(., '-00-00','-12-31'), 'nl-nl', 'yyyy-MM-dd')}"/>
			</xsl:when>
			<xsl:when test="contains(., '-00')">
				<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(su:replace(., '-00','-01'), 'nl-nl', 'yyyy-MM-dd')}"/>
				<spinque:attribute subject="{$subject}" attribute="schema:startDate" type="date" value="{su:parseDate(su:replace(., '-00','-01'), 'nl-nl', 'yyyy-MM-dd')}"/>
				<spinque:attribute subject="{$subject}" attribute="schema:endDate" type="date" value="{su:parseDate(su:replace(., '-00','-30'), 'nl-nl', 'yyyy-MM-dd')}"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'yyyy-MM-dd')}"/>
				<spinque:attribute subject="{$subject}" attribute="schema:startDate" type="date" value="{su:parseDate(., 'yyyy-MM-dd')}"/>
				<spinque:attribute subject="{$subject}" attribute="schema:endDate" type="date" value="{su:parseDate(., 'yyyy-MM-dd')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
