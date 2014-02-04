<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="db doc f fn m xs"
                version="2.0">

<!-- ********************************************************************
     $Id: titles.xsl,v 1.1 2007/03/07 19:37:15 NormanWalsh Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->
<!-- title markup -->

<doc:mode name="m:title-markup"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for inserting title markup</refpurpose>

<refdescription>
<para>This mode is used to insert title markup.
Any element processed in this mode should generate its title.</para>
</refdescription>
</doc:mode>

<xsl:template match="*" mode="m:title-markup" priority="10000">
  <xsl:param name="allow-anchors" select="0" as="xs:integer"/>
  <xsl:param name="verbose" select="1"/>

  <xsl:variable name="markup">
    <xsl:next-match>
      <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
      <xsl:with-param name="verbose" select="$verbose"/>
    </xsl:next-match>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$allow-anchors != 0">
      <xsl:copy-of select="$markup"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$markup" mode="m:strip-anchors"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="m:title-markup">
  <xsl:param name="allow-anchors" select="0" as="xs:integer"/>
  <xsl:param name="verbose" select="1"/>

  <xsl:choose>
    <xsl:when test="db:info/db:title">
      <xsl:apply-templates select="db:info/db:title[1]" mode="m:title-markup">
	<xsl:with-param name="allow-anchors" select="$allow-anchors"/>
	<xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:when>

    <xsl:when test="fn:node-name(.) = xs:QName('db:partintro')">
      <!-- partintro's don't have titles, use the parent (part or reference)
	   title instead. -->
      <xsl:apply-templates select="parent::*" mode="m:title-markup">
	<xsl:with-param name="allow-anchors" select="$allow-anchors"/>
	<xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:when>

    <xsl:otherwise>
      <xsl:if test="$verbose != 0">
	<xsl:message>
	  <xsl:text>Request for title of element with no title: </xsl:text>
	  <xsl:value-of select="name(.)"/>
	  <xsl:if test="@id|@xml:id">
	    <xsl:text> (id="</xsl:text>
	    <xsl:value-of select="(@id|@xml:id)[1]"/>
	    <xsl:text>")</xsl:text>
	  </xsl:if>
	</xsl:message>
      </xsl:if>
      <xsl:text>???TITLE???</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:title" mode="m:title-markup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:refentry" mode="m:title-markup">
  <xsl:variable name="refmeta" select=".//db:refmeta"/>
  <xsl:variable name="refentrytitle" select="$refmeta//db:refentrytitle"/>
  <xsl:variable name="refnamediv" select=".//db:refnamediv"/>
  <xsl:variable name="refname" select="$refnamediv//db:refname"/>

  <xsl:choose>
    <xsl:when test="$refentrytitle">
      <xsl:apply-templates select="$refentrytitle[1]" mode="m:title-markup"/>
    </xsl:when>
    <xsl:when test="$refname">
      <xsl:apply-templates select="$refname[1]" mode="m:title-markup"/>
    </xsl:when>
    <xsl:otherwise>???REFENTRY TITLE???</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:refentrytitle|db:refname" mode="m:title-markup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:bridgehead" mode="m:title-markup">
  <xsl:apply-templates mode="m:title-markup"/>
</xsl:template>

<xsl:template match="db:glossentry" mode="m:title-markup">
  <xsl:apply-templates select="db:glossterm" mode="m:title-markup"/>
</xsl:template>

<xsl:template match="db:glossterm" mode="m:title-markup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="question" mode="m:title-markup">
  <!-- questions don't have titles -->
  <xsl:text>Question</xsl:text>
</xsl:template>

<xsl:template match="answer" mode="m:title-markup">
  <!-- answers don't have titles -->
  <xsl:text>Answer</xsl:text>
</xsl:template>

<xsl:template match="qandaentry" mode="m:title-markup">
  <!-- qandaentrys are represented by the first question in them -->
  <xsl:text>Question</xsl:text>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:titleabbrev-markup"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for inserting abbreviated title markup</refpurpose>

<refdescription>
<para>This mode is used to insert abbreviated title markup.
Any element processed in this mode should generate its abbreviated
title.</para>
</refdescription>
</doc:mode>

<xsl:template match="*" mode="m:titleabbrev-markup" priority="10000">
  <xsl:param name="allow-anchors" select="0" as="xs:integer"/>
  <xsl:param name="verbose" select="1"/>

  <xsl:variable name="markup">
    <xsl:next-match/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$allow-anchors != 0">
      <xsl:copy-of select="$markup"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$markup" mode="m:strip-anchors"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="m:titleabbrev-markup">
  <xsl:param name="allow-anchors" select="0" as="xs:integer"/>
  <xsl:param name="verbose" select="1"/>

  <xsl:choose>
    <xsl:when test="db:info/db:titleabbrev">
      <xsl:apply-templates select="db:info/db:titleabbrev[1]"
			   mode="m:title-markup">
	<xsl:with-param name="allow-anchors" select="$allow-anchors"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="m:title-markup">
        <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
        <xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:titleabbrev" mode="m:title-markup">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>

