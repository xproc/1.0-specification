<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:m="http://docbook.org/xslt/ns/mode"
		exclude-result-prefixes="db doc f fn m"
                version="2.0">

<xsl:key name="id" match="*" use="@xml:id"/>

<xsl:template match="/">
  <xsl:variable name="cleanup">
    <xsl:apply-templates select="." mode="m:cleanup"/>
  </xsl:variable>

  <xsl:apply-templates select="$cleanup" mode="m:root"/>
</xsl:template>
  
<!-- ============================================================ -->

<doc:mode name="m:cleanup"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for cleaning up DocBook documents</refpurpose>

<refdescription>
<para>This mode is used to clean up input documents. The namespace
fixup, profiling, and general normalizations are applied.</para>
</refdescription>
</doc:mode>

<xsl:template match="/" mode="m:cleanup">
  <!--
  <xsl:message>
    <xsl:text>Cleaning up </xsl:text>
    <xsl:value-of select="fn:base-uri(.)"/>
  </xsl:message>
  -->

  <xsl:variable name="fixedns">
    <xsl:apply-templates mode="m:fixnamespace"/>
  </xsl:variable>

  <xsl:variable name="profiled">
    <xsl:apply-templates select="$fixedns" mode="m:profile"/>
  </xsl:variable>

  <xsl:variable name="fixedbase">
    <xsl:apply-templates select="$profiled" mode="m:fixbaseuri">
      <xsl:with-param name="base-uri" select="base-uri(.)"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:apply-templates select="$fixedbase" mode="m:normalize"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="text()|processing-instruction()|comment()"
	      mode="m:fixbaseuri">
  <xsl:copy/>
</xsl:template>

<xsl:template match="*" mode="m:fixbaseuri">
  <xsl:param name="base-uri" required='yes'/>
  <xsl:copy>
    <xsl:attribute name="xml:base" select="$base-uri"/>
    <xsl:copy-of select="@*"/>
    <xsl:copy-of select="node()"/>
  </xsl:copy>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:root"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for processing the root of a the primary input document</refpurpose>

<refdescription>
<para>This mode is used to process the root of the primary input document.
</para>
</refdescription>
</doc:mode>

<xsl:template match="/" mode="m:root">
  <xsl:choose>
    <!-- if there's a rootid, start there -->
    <xsl:when test="$rootid != ''">
      <xsl:variable name="root" select="key('id', $rootid)"/>

      <xsl:choose>
	<xsl:when test="not($root)">
	  <xsl:message terminate="yes">
	    <xsl:text>ID '</xsl:text>
	    <xsl:value-of select="$rootid"/>
	    <xsl:text>' not found in document.</xsl:text>
	  </xsl:message>
	</xsl:when>

	<xsl:when test="not($root.elements/*[fn:node-name(.)
			                     = fn:node-name($root)])">
	  <xsl:call-template name="m:root-terminate"/>
	</xsl:when>

	<xsl:otherwise>
	  <xsl:apply-templates select="$root" mode="m:root"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <!-- Otherwise, process the document root element -->
    <xsl:otherwise>
      <xsl:variable name="root" select="*[1]"/>
      <xsl:choose>
	<xsl:when test="not($root.elements/*[fn:node-name(.)
			                     = fn:node-name($root)])">
	  <xsl:call-template name="m:root-terminate"/>
	</xsl:when>

	<xsl:otherwise>
	  <xsl:apply-templates select="$root" mode="m:root"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="m:root-terminate" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Aborts processing if the root element is inappropriate</refpurpose>

<refdescription>
<para>This template is called if the stylesheet detects that the root
element (or the element selected for processing with
<parameter>rootid</parameter>) is not an appropriate root element.
</para>
</refdescription>

<refreturn>
<para>Does not return.</para>
</refreturn>
</doc:template>

<xsl:template name="m:root-terminate">
  <xsl:message terminate="yes">
    <xsl:text>Error: document root element </xsl:text>
    <xsl:if test="$rootid">
      <xsl:text>($rootid=</xsl:text>
      <xsl:value-of select="$rootid"/>
      <xsl:text>) </xsl:text>
    </xsl:if>

    <xsl:text>must be one of the following elements: </xsl:text>
    <xsl:value-of select="for $elem in $root.elements/*[position() &lt; last()]
			  return local-name($elem)" separator=", "/>
    <xsl:text>, or </xsl:text>
    <xsl:value-of select="local-name($root.elements/*[last()])"/>
    <xsl:text>.</xsl:text>
  </xsl:message>
</xsl:template>

</xsl:stylesheet>
