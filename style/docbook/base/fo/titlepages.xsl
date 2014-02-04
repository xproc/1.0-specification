<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:t="http://docbook.org/xslt/ns/template"
                exclude-result-prefixes="db doc f fn m t"
                version="2.0">

<xsl:variable name="titlepages.data" select="doc($titlepage.templates)"/>

<xsl:variable name="titlepages">
  <xsl:call-template name="user-titlepage-templates"/>
  <xsl:copy-of select="$titlepages.data/t:titlepages/*"/>
</xsl:variable>

<!-- ============================================================ -->

<doc:template name="user-titlepage-templates"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Hook for user defined titlepage templates</refpurpose>

<refdescription>
<para>This template is a hook for customizers. Any titlepage templates
defined in this template will be used in favor of the
default titlepage templates.</para>
</refdescription>

<refreturn>
<para>Any user-defined titepage templates.</para>
</refreturn>
</doc:template>

<xsl:template name="user-titlepage-templates">
  <!-- nop -->
</xsl:template>

</xsl:stylesheet>
