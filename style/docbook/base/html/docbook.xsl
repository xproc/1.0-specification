<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="h f m fn db t"
                version="2.0">

  <xsl:include href="param.xsl"/>
  <xsl:include href="../common/l10n.xsl"/>
  <xsl:include href="../common/spspace.xsl"/>
  <xsl:include href="../common/gentext.xsl"/>
  <xsl:include href="../common/normalize.xsl"/>
  <xsl:include href="../common/root.xsl"/>
  <xsl:include href="../common/functions.xsl"/>
  <xsl:include href="../common/common.xsl"/>
  <xsl:include href="../common/titlepages.xsl"/>
  <xsl:include href="../common/labels.xsl"/>
  <xsl:include href="../common/titles.xsl"/>
  <xsl:include href="../common/inlines.xsl"/>
  <xsl:include href="../common/olink.xsl"/>
  <xsl:include href="titlepages.xsl"/>
  <xsl:include href="titlepage.xsl"/>
  <xsl:include href="autotoc.xsl"/>
  <xsl:include href="division.xsl"/>
  <xsl:include href="component.xsl"/>
  <xsl:include href="refentry.xsl"/>
  <xsl:include href="synopsis.xsl"/>
  <xsl:include href="section.xsl"/>
  <xsl:include href="biblio.xsl"/>
  <xsl:include href="pi.xsl"/>
  <xsl:include href="info.xsl"/>
  <xsl:include href="glossary.xsl"/>
  <xsl:include href="table.xsl"/>
  <xsl:include href="lists.xsl"/>
  <xsl:include href="task.xsl"/>
  <xsl:include href="callouts.xsl"/>
  <xsl:include href="formal.xsl"/>
  <xsl:include href="blocks.xsl"/>
  <xsl:include href="graphics.xsl"/>
  <xsl:include href="footnotes.xsl"/>
  <xsl:include href="admonitions.xsl"/>
  <xsl:include href="verbatim.xsl"/>
  <xsl:include href="qandaset.xsl"/>
  <xsl:include href="inlines.xsl"/>
  <xsl:include href="xref.xsl"/>
  <xsl:include href="math.xsl"/>
  <xsl:include href="html.xsl"/>
  <xsl:include href="index.xsl"/>
  <xsl:include href="autoidx.xsl"/>
  <xsl:include href="chunker.xsl"/>

<!-- ============================================================ -->
<!-- HACK HACK HACK for testing framework. Delete me! -->

<xsl:template match="db:emphasis" mode="foobar">
  <b><xsl:apply-templates/></b>
</xsl:template>

<xsl:param name="save.normalized.xml" select="0"/>

<!-- ============================================================ -->

  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  <xsl:output name="final" method="xhtml" encoding="utf-8" indent="yes"/>

  <xsl:param name="stylesheet.result.type" select="'xhtml'"/>
  <xsl:param name="input" select="/"/>

  <xsl:template match="*" mode="m:root">
    <xsl:if test="$save.normalized.xml != 0">
      <xsl:message>Saving normalized xml.</xsl:message>
      <xsl:result-document href="normalized.xml">
	<xsl:copy-of select="."/>
      </xsl:result-document>
    </xsl:if>

    <xsl:result-document format="final">
      <html>
	<head>
	  <title>
	    <xsl:choose>
	      <xsl:when test="db:info/db:title">
		<xsl:value-of select="db:info/db:title"/>
	      </xsl:when>
	      <xsl:when test="db:refmeta/db:refentrytitle">
		<xsl:value-of select="db:refmeta/db:refentrytitle"/>
	      </xsl:when>
	      <xsl:when test="db:refmeta/db:refnamediv/db:refname">
		<xsl:value-of select="db:refmeta/db:refnamediv/db:refname"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>???</xsl:text>
		<xsl:message>
		  <xsl:text>Warning: no title for root element: </xsl:text>
		  <xsl:value-of select="local-name(.)"/>
		</xsl:message>
	      </xsl:otherwise>
	    </xsl:choose>
	  </title>
	  <xsl:call-template name="t:head-meta"/>
	  <xsl:call-template name="t:head-links"/>
	  <xsl:call-template name="css-style"/>
	  <xsl:call-template name="javascript"/>
	</head>
	<body>
	  <xsl:call-template name="t:body-attributes"/>
	  <xsl:if test="@status">
	    <xsl:attribute name="class" select="@status"/>
	  </xsl:if>

	  <xsl:apply-templates select="."/>
	</body>
      </html>
    </xsl:result-document>

    <xsl:for-each select=".//db:mediaobject[db:textobject[not(db:phrase)]]">
      <xsl:call-template name="t:write-longdesc"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*">
    <div class="unknowntag">
      <xsl:call-template name="id"/>
      <font color="red">
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="name(.)"/>
	<xsl:for-each select="@*">
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="name(.)"/>
	  <xsl:text>="</xsl:text>
	  <xsl:value-of select="."/>
	  <xsl:text>"</xsl:text>
	</xsl:for-each>
	<xsl:text>&gt;</xsl:text>
      </font>
      <xsl:apply-templates/>
      <font color="red">
	<xsl:text>&lt;/</xsl:text>
	<xsl:value-of select="name(.)"/>
	<xsl:text>&gt;</xsl:text>
      </font>
    </div>
  </xsl:template>

<!-- ============================================================ -->

<!-- blocks -->
<xsl:template match="db:para|db:simpara|db:cmdsynopsis" priority="100000">
  <xsl:param name="content">
    <xsl:next-match/>
  </xsl:param>

  <xsl:call-template name="t:block-element">
    <xsl:with-param name="content">
      <xsl:copy-of select="$content"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="t:block-element">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:variable name="inherit" select="self::db:para or self::db:simpara"/>
  <xsl:variable name="changed" select=".//*[@revisionflag and
                                            @revisionflag != 'off']"/>

  <xsl:choose>
    <xsl:when test="@revisionflag">
      <div class="revision-inherited">
	<div class="revision-{@revisionflag}">
	  <xsl:copy-of select="$content"/>
	</div>
      </div>
    </xsl:when>
    <xsl:when test="$inherit and $changed">
      <div class="revision-inherited">
	<xsl:copy-of select="$content"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- inlines -->
<xsl:template match="db:emphasis|db:phrase" priority="100000">
  <xsl:param name="content">
    <xsl:next-match/>
  </xsl:param>

  <xsl:call-template name="t:inline-element">
    <xsl:with-param name="content">
      <xsl:copy-of select="$content"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="t:inline-element">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:choose>
    <xsl:when test="@revisionflag">
      <span class="revision-{@revisionflag}">
	<xsl:copy-of select="$content"/>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
