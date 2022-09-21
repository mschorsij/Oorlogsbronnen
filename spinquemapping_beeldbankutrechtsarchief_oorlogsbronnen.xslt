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

	<xsl:template match="record | metadata | europeana:record">
		<xsl:if test="(dc:type = 'Foto') or contains(dc:type, 'Boek') or contains(dc:type, 'Krant') or contains(dc:type, 'Bouwtekening')">
			<xsl:variable name="subject" select="su:uri(europeana:isShownAt)"/>
			<!-- dc:relation kan ik niet zien -->
			<xsl:if test="contains(dc:relation[1], 'thumb')">
				<!-- boeken hebben geen thumbnail-->
				<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{concat(dc:relation[1], '?dummy=dummy.png')}" type="string"/>
			</xsl:if>
			<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
			<spinque:attribute subject="{$subject}" attribute="dcmit:Collection" value="Beeldbank Utrechts Archief" type="string"/>
			<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_utrecht" type="string"/>
			<spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
			<spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
			<spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/128"/>
			<spinque:attribute subject="{$subject}" attribute="dc:publisher" value="{europeana:dataProvider}" type="string"/>
			<!-- dc:rights kan ik niet zien -->
			<xsl:choose>
				<xsl:when test="contains(dc:rights[2], 'CC0') or contains(su:lowercase(dc:rights[2]), 'public domain') or contains(dc:rights[2], 'publicdomain')">
					<spinque:relation subject="{$subject}" predicate="dc:rights" object="https://creativecommons.org/publicdomain/zero/1.0/"/>
					<spinque:attribute subject="{$subject}" attribute="dc:rights" value="CC0" type="string"/>
				</xsl:when>
				<xsl:when test="contains(dc:rights[2], '/by/')">
					<spinque:relation subject="{$subject}" predicate="dc:rights" object="https://creativecommons.org/licenses/by/4.0/"/>
					<spinque:attribute subject="{$subject}" attribute="dc:rights" value="CC-BY" type="string"/>
				</xsl:when>
				<xsl:when test="contains(dc:rights[2], '/by-nc/')">
					<spinque:relation subject="{$subject}" predicate="dc:rights" object="https://creativecommons.org/licenses/by-nc/4.0/"/>
					<spinque:attribute subject="{$subject}" attribute="dc:rights" value="CC BY-NC" type="string"/>
				</xsl:when>
				<xsl:otherwise>
					<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/vocab/CNE/1.0/"/>
					<spinque:attribute subject="{$subject}" attribute="dc:rights" value="Copyright niet bekend" type="string"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="dc:type = 'Boek'">
					<xsl:choose>
						<xsl:when test="contains(dc:title, '; /')">
							<spinque:attribute subject="{$subject}" attribute="dc:title" value="{substring-before(dc:title, '; /')}" type="string"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:title))"/>
							<xsl:choose>
								<xsl:when test="string-length($title) &gt; 51">
									<xsl:variable name="titleLang" select="substring($title, 1,50)"/>
									<xsl:variable name="titleKort">
										<xsl:choose>
											<xsl:when test="contains($titleLang, ',')">
												<xsl:value-of select="substring-before($titleLang, ',')"/>
											</xsl:when>
											<xsl:when test="contains($titleLang, ';')">
												<xsl:value-of select="substring-before($titleLang, ';')"/>
											</xsl:when>
											<xsl:when test="contains($titleLang, '.')">
												<xsl:value-of select="substring-before($titleLang, '.')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$titleLang"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<spinque:attribute subject="{$subject}" attribute="dc:title" value="{concat($titleKort, ' [...]')}" type="string"/>
									<spinque:attribute subject="{$subject}" attribute="dc:description" value="{$title}" type="string"/>
									<spinque:debug message="ORG: {$title}"/>
                                    <spinque:debug message="LANG: {$titleLang}"/>
									<spinque:debug message="KORT: {$titleKort}"/>
								</xsl:when>
								<xsl:otherwise>
									<spinque:attribute subject="{$subject}" attribute="dc:title" value="{$title}" type="string"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:title))"/>
					<xsl:choose>
						<xsl:when test="string-length($title) &gt; 51">
							<xsl:variable name="titleLang" select="substring($title, 1,50)"/>
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
									<xsl:otherwise>
										<xsl:value-of select="$titleLang"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<spinque:attribute subject="{$subject}" attribute="dc:title" value="{concat($titleKort, ' [...]')}" type="string"/>
							<spinque:attribute subject="{$subject}" attribute="dc:description" value="{$title}" type="string"/>
							<spinque:debug message="ORG: {$title}"/>
									<spinque:debug message="LANG: {$titleLang}"/>
									<spinque:debug message="KORT: {$titleKort}"/>
									<spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort, ' [...]' )}"/>
						</xsl:when>
						<xsl:otherwise>
							<spinque:attribute subject="{$subject}" attribute="dc:title" value="{$title}" type="string"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
			<xsl:choose>
				<xsl:when test="dc:type = 'Boek'">
					<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Book"/>
					<spinque:attribute subject="{$subject}" attribute="dc:type" value="boek" type="string"/>
				</xsl:when>
				<xsl:when test="dc:type = 'Krant'">
					<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Newspaper"/>
					<spinque:attribute subject="{$subject}" attribute="dc:type" value="krant" type="string"/>
				</xsl:when>
				<xsl:otherwise>
					<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
					<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>
				</xsl:otherwise>
			</xsl:choose>
			<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>

			<xsl:apply-templates select="dc:publisher">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:apply-templates>

			<xsl:apply-templates select="dc:subject">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:apply-templates>

			<xsl:apply-templates select="dc:date">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="dc:date">
		<xsl:param name="subject"/>
		<xsl:variable name="datum" select="concat('0', .)"/>
		<xsl:choose>
			<xsl:when test="string-length(.) = 4">
				<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate(., 'yyyy')}"/>
			</xsl:when>
			<xsl:when test="string-length(.) = 6">
				<spinque:attribute subject="{$subject}" attribute="dc:date" type="date" value="{su:parseDate($datum, 'MM/yyyy')}"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
	</xsl:template>

</xsl:stylesheet>
