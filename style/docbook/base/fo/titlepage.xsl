<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:m="http://docbook.org/xslt/ns/mode"
		exclude-result-prefixes="db doc f fn m"
                version="2.0">

<xsl:template match="db:info">
  <!-- nop -->
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:titlepage-mode"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for formatting elements on the title page</refpurpose>

<refdescription>
<para>This mode is used to format elements on the title page.
Any element processed in this mode should generate markup appropriate
for the title page.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:set/db:info/db:title
		     |db:book/db:info/db:title
		     |db:part/db:info/db:title
		     |db:reference/db:info/db:title
		     |db:setindex/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <fo:block>
    <xsl:next-match/>
  </fo:block>
</xsl:template>

<xsl:template match="db:set/db:info/db:subtitle
		     |db:book/db:info/db:subtitle
		     |db:part/db:info/db:subtitle
		     |db:reference/db:info/db:subtitle"
	      mode="m:titlepage-mode"
	      priority="100">
  <fo:block>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="db:dedication/db:info/db:title
	             |db:preface/db:info/db:title
		     |db:chapter/db:info/db:title
		     |db:appendix/db:info/db:title
		     |db:colophon/db:info/db:title
		     |db:article/db:info/db:title
		     |db:bibliography/db:info/db:title
		     |db:glossary/db:info/db:title
		     |db:index/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <fo:block>
    <xsl:next-match/>
  </fo:block>
</xsl:template>

<xsl:template match="db:dedication/db:info/db:subtitle
	             |db:preface/db:info/db:subtitle
		     |db:chapter/db:info/db:subtitle
		     |db:appendix/db:info/db:subtitle
		     |db:colophon/db:info/db:subtitle
		     |db:article/db:info/db:subtitle
		     |db:bibliography/db:info/db:subtitle
		     |db:glossary/db:info/db:subtitle"
	      mode="m:titlepage-mode"
	      priority="100">
  <fo:block>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="db:bibliodiv/db:info/db:title
		     |db:glossdiv/db:info/db:title
		     |db:indexdiv/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <fo:block>
    <xsl:next-match/>
  </fo:block>
</xsl:template>

<xsl:template match="db:bibliodiv/db:info/db:subtitle
		     |db:glossdiv/db:info/db:subtitle"
	      mode="m:titlepage-mode"
	      priority="100">
  <fo:block>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="db:section/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:section)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 5) then $depth else 4"/>
  
  <xsl:element name="h{$hlevel+2}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:next-match/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:section/db:info/db:subtitle"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:section)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 4) then $depth else 3"/>
  
  <xsl:element name="h{$hlevel+3}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:simplesect/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:section)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 5) then $depth else 4"/>
  
  <xsl:element name="h{$hlevel+2}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:next-match/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:simplesect/db:info/db:subtitle"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:section)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 4) then $depth else 3"/>
  
  <xsl:element name="h{$hlevel+3}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:refsection/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:refsection)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 5) then $depth else 4"/>
  
  <xsl:element name="h{$hlevel+2}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:next-match/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:refsection/db:info/db:subtitle"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:refsection)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 4) then $depth else 3"/>
  
  <xsl:element name="h{$hlevel+3}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:title" mode="m:titlepage-mode">
  <xsl:apply-templates select="../.." mode="m:object-title-markup">
    <xsl:with-param name="allow-anchors" select="1"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:copyright" mode="m:titlepage-mode">
  <fo:block>
    <xsl:apply-templates select="."/> <!-- no mode -->
  </fo:block>
</xsl:template>

<xsl:template match="db:year" mode="m:titlepage-mode">
  <fo:inline>
    <xsl:call-template name="id"/>
    <xsl:apply-templates/>
  </fo:inline>
</xsl:template>

<xsl:template match="db:holder" mode="m:titlepage-mode">
  <fo:inline>
    <xsl:call-template name="id"/>
    <xsl:apply-templates/>
  </fo:inline>
  <xsl:if test="following-sibling::db:holder">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="db:releaseinfo" mode="m:titlepage-mode">
  <fo:block>
    <xsl:call-template name="id"/>
    <xsl:apply-templates mode="m:titlepage-mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="db:abstract" mode="m:titlepage-mode">
  <fo:block>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="db:legalnotice" mode="m:titlepage-mode">
  <fo:block>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="*" mode="m:titlepage-mode">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="db:authorgroup" mode="m:titlepage-mode">
  <xsl:apply-templates mode="m:titlepage-mode"/>
</xsl:template>

<xsl:template match="db:info/db:author
		     |db:info/db:authorgroup/db:author"
	      mode="m:titlepage-mode">
  <fo:block>
    <xsl:apply-templates select="."/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
