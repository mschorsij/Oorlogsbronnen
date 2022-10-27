<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:su="com.spinque.tools.importStream.Utils"
	xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
	xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
	xmlns:ese="http://www.europeana.eu/schemas/ese/"
	xmlns:europeana="http://www.europeana.eu/schemas/ese/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<!-- Datumafhandeling en filtering aangepast door Micon op 20-10-2022 -->

    <xsl:template match="recordlist | record | metadata">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- *** Entry point for OAI-DC records  *** -->
    <xsl:template match="europeana:record">
        <xsl:choose>
            <xsl:when test="contains(su:lowercase(dc:subject), 'tweede wereldoorlog')
							or contains(su:lowercase(dc:description), 'tweede wereldoorlog')
							or contains(su:lowercase(dc:subject), 'w.o. ii')
							or contains(su:lowercase(dc:description), 'w.o. ii')
							or contains(su:lowercase(dc:subject), 'bevrijding')
							or contains(su:lowercase(dc:description), 'bevrijding')
							or contains(su:lowercase(dc:subject), 'bombardement')
							or contains(su:lowercase(dc:description), 'bombardement')">
                <xsl:choose>
                    <xsl:when test="(dc:creator = 'Dalenoord, Jenny') or (dc:creator = 'Ham, Piet van der') or (dc:creator = 'Jong, Fotopersburo Jeroen de') or (dc:creator = 'Leeuwen, Jos van') or (dc:creator = 'Posthoorn')	or (dc:creator = 'Smit, Simon E.')">
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="subject" select="europeana:isShownAt"/>
                        <!-- run generic Dublin Core -->
                        <xsl:call-template name="dc_record">
                            <xsl:with-param name="subject" select="$subject"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>

		<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{su:replace(europeana:object, '250x250', '1000x1000')}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{europeana:isShownAt}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>

		<xsl:choose>
			<xsl:when test="dc:title != ''">
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:title"
					value="{dc:title}"
					type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<!--spinque:attribute
					subject="{$subject}"
					attribute="dc:title"
					value="{dc:description}"
					type="string"/-->
				<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:description))"/>

				<xsl:choose>
					<xsl:when test="string-length($title) &gt; 21">
						<xsl:variable name="titleLang"
							select="substring($title, 20, string-length($title))"/>
						<xsl:variable name="titleKort">
							<xsl:choose>
								<!--xsl:when test="contains($titleLang, '(')">
									<xsl:value-of select="substring-before($titleLang, '(')"/>
								</xsl:when-->
								<xsl:when test="contains($titleLang, ',')">
									<xsl:value-of select="substring-before($titleLang, ',')"/>
								</xsl:when>
								<xsl:when test="contains($titleLang, '.')">
									<xsl:value-of select="substring-before($titleLang, '.')"/>
								</xsl:when>
								<!--xsl:when test="contains($titleLang, ';')">
                            <xsl:value-of select="substring-before($titleLang, ';')"/>
                        </xsl:when-->
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

		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/115"/>
		<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="Haags Gemeentearchief" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank Den Haag" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_denhaag" type="string"/>
		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
		<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>

		<xsl:if test="dcterms:spatial !=''">
					<xsl:choose>
					<xsl:when test="dcterms:spatial[1] = 'Wassenaar'">
						<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{dcterms:spatia[1]}" type="string"/>
					</xsl:when>
					<xsl:otherwise>
						<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="Den Haag" type="string"/>
					</xsl:otherwise>
				</xsl:choose>

			<xsl:if test="dcterms:spatial[1] != dcterms:spatial[last()]">
				<xsl:choose>
					<xsl:when test="contains(dcterms:spatial[last()], ';')">
						<spinque:attribute subject="{$subject}" attribute="schema:address" value="{substring-before(dcterms:spatial[last()], ';')}" type="string"/>
					</xsl:when>
					<xsl:when test="contains(dcterms:spatial[last()], ',')">
						<spinque:attribute subject="{$subject}" attribute="schema:address" value="{substring-before(dcterms:spatial[last()], ',')}" type="string"/>
					</xsl:when>
					<xsl:otherwise>
						<spinque:attribute subject="{$subject}" attribute="schema:address" value="{dcterms:spatial[last()]}" type="string"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="europeana:rights = 'http://www.europeana.eu/rights/rr-f/'">
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
					object="http://rightsstatements.org/vocab/CNE/1.0/"/>
				<spinque:attribute
					subject="{$subject}"
					attribute="dc:rights"
					value="Copyright niet bekend"
					type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="dcterms:created">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:type">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:isPartOf">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:extent">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:creator">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dcterms:created">
		<xsl:param name="subject"/>
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="contains(., 'ex.')">
					<xsl:value-of select="su:replace(substring-after(., 'ex. '), ' ', '-')"/>
				</xsl:when>
				<xsl:when test="contains(., 'ca.')">
					<xsl:value-of select="su:replace(substring-after(., 'ca. '), ' ', '-')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="su:replace(., ' ', '-')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when  test="string-length($date) = 4">
				<spinque:attribute subject="{$subject}" attribute="dc:date" value="{$date}" type="integer"/>
			</xsl:when>
			<xsl:when test="string-length($date) &gt; 7 and string-length($date) &lt; 11">
				<spinque:attribute subject="{$subject}" attribute="dc:date" value="{su:parseDate($date, 'nl-NL', 'd-M-yyyy', 'd-MM-yyyy', 'dd-M-yyyy', 'dd-MM-yyyy')}" type="date"/>
			</xsl:when>
			<xsl:when test="string-length($date) &gt; 5 and string-length($date) &lt; 8">
				<spinque:attribute subject="{$subject}" attribute="dc:date" value="{su:parseDate($date, 'nl-NL', 'M-yyyy', 'MM-yyyy')}" type="date"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="schema:temporal" value="{$date}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(., ';')">
				<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{substring-before(., ';')}" type="string"/>
				<xsl:choose>
					<xsl:when test="contains(substring-after(., ';'), ',')">
						<xsl:variable name="arrayOfItems" select="su:split(substring-after(., ';'), ',', 5)"/>
						<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$arrayOfItems[1]}" type="string"/>
						<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$arrayOfItems[2]}" type="string"/>
						<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$arrayOfItems[3]}" type="string"/>
						<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$arrayOfItems[4]}" type="string"/>
						<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{$arrayOfItems[5]}" type="string"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dc:creator">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(., '(')">
				<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{.}" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{substring-after(.,',')} {substring-before(.,',')}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
