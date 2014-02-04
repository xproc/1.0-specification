<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="h f m fn db"
                version="2.0">

<xsl:template match="db:qandaset|db:qandadiv">
  <xsl:variable name="titlepage"
		select="$titlepages/*[node-name(.)=node-name(current())][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>

    <xsl:call-template name="titlepage">
      <xsl:with-param name="content" select="$titlepage"/>
    </xsl:call-template>

    <!-- FIXME: What about the toc? -->

    <xsl:apply-templates select="*[not(self::db:info)
                                   and not(self::db:qandaentry)]"/>

    <xsl:if test="db:qandaentry">
      <table class="qandaentries" border="0" summary="Q&amp;A Set">
	<xsl:apply-templates select="db:qandaentry"/>
      </table>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="db:qandaentry">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:question">
  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()]
                              /@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <tr class="{local-name}">
    <xsl:call-template name="id">
      <xsl:with-param name="node" select=".."/>
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:call-template name="class"/>

    <td class="question-label" align="left" valign="top">
      <xsl:call-template name="id">
	<xsl:with-param name="force" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="class"/>

      <xsl:apply-templates select="." mode="m:label-markup"/>
      <xsl:if test="$deflabel = 'number' and not(label)">
	<xsl:apply-templates select="." mode="m:intralabel-punctuation"/>
      </xsl:if>
    </td>

    <td align="left" valign="top">
      <xsl:attribute name="class">
	<xsl:choose>
	  <xsl:when test="$deflabel = 'none' and not(db:label)">
	    <xsl:text>question-no-label</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>question</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="*[not(self::db:label)]"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="db:answer">
  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()]
                              /@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <tr class="{local-name}">
    <xsl:call-template name="id">
      <xsl:with-param name="node" select=".."/>
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:call-template name="class"/>

    <td class="answer-label" align="left" valign="top">
      <xsl:call-template name="id">
	<xsl:with-param name="force" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="class"/>

      <xsl:variable name="label">
	<xsl:apply-templates select="." mode="m:label-markup"/>
      </xsl:variable>

      <xsl:if test="$deflabel = 'number' and not(label) and $label != ''">
	<xsl:apply-templates select="." mode="m:intralabel-punctuation"/>
      </xsl:if>
    </td>

    <td align="left" valign="top">
      <xsl:attribute name="class">
	<xsl:choose>
	  <xsl:when test="$deflabel = 'none' and not(db:label)">
	    <xsl:text>answer-no-label</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>answer</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="*[not(self::db:label)]"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="db:label">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
