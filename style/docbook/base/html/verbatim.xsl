<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
		xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:mp="http://docbook.org/xslt/ns/mode/private"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="doc h f m mp fn db ghost t"
                version="2.0">

<xsl:include href="../common/verbatim.xsl"/>

<xsl:template match="db:programlistingco">
  <xsl:variable name="cleanedup" as="element()+">
    <xsl:apply-templates select="." mode="m:verbatim-phase-1"/>
  </xsl:variable>

  <xsl:apply-templates select="$cleanedup/db:programlisting"
		       mode="m:verbatim"/>
</xsl:template>

<xsl:template match="db:programlisting|db:address|db:screen|db:synopsis
		     |db:literallayout">
  <xsl:variable name="cleanedup" as="element()">
    <xsl:apply-templates select="." mode="m:verbatim-phase-1"/>
  </xsl:variable>

  <xsl:apply-templates select="$cleanedup" mode="m:verbatim"/>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:verbatim" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for processing normalized verbatim elements</refpurpose>

<refdescription>
<para>This mode is used to format normalized verbatim elements.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:programlisting|db:screen|db:synopsis
		     |db:literallayout[@class='monospaced']"
	      mode="m:verbatim">

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>
    <pre>
      <xsl:apply-templates/>
    </pre>
  </div>
</xsl:template>

<xsl:template match="db:literallayout"
	      mode="m:verbatim">

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>
    <xsl:apply-templates mode="mp:literallayout"/>
  </div>
</xsl:template>

<xsl:template match="db:address"
	      mode="m:verbatim">

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>
    <xsl:apply-templates mode="mp:literallayout"/>
  </div>
</xsl:template>

<xsl:template match="ghost:co">
  <xsl:call-template name="t:callout-bug">
    <xsl:with-param name="conum">
      <xsl:number count="ghost:co"
                  level="any"
                  from="db:programlisting|db:screen|db:literallayout|db:synopsis"
                  format="1"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="ghost:linenumber">
  <span class="linenumber">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="ghost:linenumber-separator">
  <xsl:variable name="content" as="node()*">
    <xsl:apply-templates/>
  </xsl:variable>

  <xsl:if test="not(empty($content))">
    <span class="linenumber-separator">
      <xsl:apply-templates/>
    </span>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="mp:literallayout">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()"
	      mode="mp:literallayout">
  <xsl:copy/>
</xsl:template>

<xsl:template match="text()" mode="mp:literallayout">
  <xsl:analyze-string select="." regex="&#10;">
    <xsl:matching-substring>
      <br/>
    </xsl:matching-substring>
    <xsl:non-matching-substring>
      <xsl:analyze-string select="." regex="[\s]">
	<xsl:matching-substring>
	  <xsl:text>&#160;</xsl:text>
	</xsl:matching-substring>
	<xsl:non-matching-substring>
	  <xsl:copy/>
	</xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:non-matching-substring>
  </xsl:analyze-string>
</xsl:template>

</xsl:stylesheet>
