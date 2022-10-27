<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:ese="http://www.europeana.eu/schemas/ese/"
    xmlns:europeana="http://www.europeana.eu/schemas/ese/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:schema="http://schema.org/"
    xmlns:vvdu="com.spinque.tools.extraction.project.verteldverleden.IdentifyDate"
    extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<xsl:template match="recordlist|record|metadata">
	  <xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="oai_dc:record">
		<xsl:if test="contains(dc:date,'1940') or contains(dc:date,'1941') or contains(dc:date,'1942') or contains(dc:date,'1943') or contains(dc:date,'1944') or contains(dc:date,'1945')">
			<xsl:variable name="subject" select="dcterms:hasVersion"/>
			<!--spinque:debug message="{$subject}"/-->
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
			<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{dc:relation[1]}?dummy=dummy.png" type="string"/>
		</xsl:if>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank Rijckheyt - Centrum voor Regionale Geschiedenis" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<xsl:choose>
			<xsl:when test="contains(dc:title,',') and (dc:type='Bidprentje')">
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{concat(substring-after(dc:title,', '),' ', substring-before(dc:title,','))}" type="string"/>
				<spinque:attribute subject="{$subject}" attribute="schema:about" value="{concat(substring-after(dc:title,', '),' ', substring-before(dc:title,','))}" type="string"/>
			</xsl:when>
 			<xsl:otherwise>
 				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:title}" type="string"/>
 			</xsl:otherwise>
 		</xsl:choose>
 		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>

    	<!-- *** Link Publisher *** -->
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/118"/>
		<!--spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Rijckheyt - Centrum voor Regionale Geschiedenis" type="string"/-->
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_rijckheyt" type="string"/>

		<xsl:choose>
			<xsl:when test="dc:creator != ''">
				<xsl:choose>
					<xsl:when test="contains(dc:creator, 'nbekend')">
						<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/page/CNE/1.0/"/>
						<spinque:attribute subject="{$subject}" attribute="dc:rights" value="Copyright niet bekend" type="string"/>
					</xsl:when>
					<xsl:otherwise>
						<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>
						<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/vocab/InC/1.0/"/>
						<spinque:attribute subject="{$subject}" attribute="dc:rights" value="In Copyright" type="string"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/page/CNE/1.0/"/>
				<spinque:attribute subject="{$subject}" attribute="dc:rights" value="Copyright niet bekend" type="string"/>
			</xsl:otherwise>
		</xsl:choose>

        <xsl:if test="dc:coverage != ''">
        	<xsl:choose>
				<xsl:when test="contains(dc:coverage[1], ', ')">
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{substring-before(dc:coverage[1],',')}" type="string"/>
					<spinque:attribute subject="{$subject}" attribute="schema:address" value="{substring-after(dc:coverage[1],', ')}" type="string"/>
				</xsl:when>
				<xsl:when test="contains(dc:coverage[2], ', ')">
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{substring-before(dc:coverage[2],',')}" type="string"/>
					<spinque:attribute subject="{$subject}" attribute="schema:address" value="{substring-after(dc:coverage[2],', ')}" type="string"/>
				</xsl:when>
				<xsl:otherwise>
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{dc:coverage[1]}" type="string"/>
					<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{dc:coverage[2]}" type="string"/>
				</xsl:otherwise>
			</xsl:choose>
        </xsl:if>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param  name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:type">
			<xsl:with-param  name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:date">
			<xsl:with-param  name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>
<!-- *** -->


	<xsl:template match="dc:date">
		<xsl:param name="subject"/>
		<xsl:if test="contains(.,'-')">
			<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'nl-nl', 'yyyy-yyyy', '??-MM-yyyy', 'dd-MM-yyyy')}"/>
		</xsl:if>
	</xsl:template>

  	<xsl:template match="dc:subject">
    	<xsl:param name="subject"/>
    	<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
    </xsl:template>

      	<xsl:template match="dc:type">
    	<xsl:param name="subject"/>
    	<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
    </xsl:template>

</xsl:stylesheet>
