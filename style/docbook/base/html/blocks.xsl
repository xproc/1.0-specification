<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="h f m fn db"
                version="2.0">

<!-- ============================================================ -->

<xsl:template match="db:para|db:simpara">
  <xsl:param name="runin" select="()" tunnel="yes"/>
  <xsl:param name="class" select="''" tunnel="yes"/>

  <xsl:variable name="para" select="."/>

  <xsl:variable name="annotations" as="element()*">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:if test="f:first-in-context($para,.)">
	<xsl:sequence select="if (@annotations)
			      then key('id',tokenize(@annotations,'\s'))
			      else ()"/>
	<xsl:sequence select="if ($id)
			      then //db:annotation[tokenize(@annotates,'\s')=$id]
			      else ()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="annotmarkup">
    <xsl:for-each select="$annotations">
      <xsl:variable name="id"
		    select="concat(f:node-id(.),'-',generate-id($para))"/>
      <a style="display: inline" onclick="show_annotation('{$id}')"
	 id="annot-{$id}-on">
	<img border="0" src="{$annotation.graphic.open}" alt="[A+]"/>
      </a>
      <a style="display: none" onclick="hide_annotation('{$id}')"
	 id="annot-{$id}-off">
	<img border="0" src="{$annotation.graphic.close}" alt="[A-]"/>
      </a>
    </xsl:for-each>
    <xsl:for-each select="$annotations">
      <xsl:variable name="id"
		    select="concat(f:node-id(.),'-',generate-id($para))"/>
      <div style="display: none" id="annot-{$id}">
	<xsl:apply-templates select="." mode="m:annotation"/>
      </div>
    </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="parent::db:listitem
		    and not(preceding-sibling::*)
		    and not(@role)">
      <xsl:variable name="list"
		    select="(ancestor::db:orderedlist
			     |ancestor::db:itemizedlist
			     |ancestor::db:variablelist)[last()]"/>
      <xsl:choose>
	<xsl:when test="$list/@spacing='compact'">
	  <xsl:call-template name="anchor"/>
	  <xsl:apply-templates/>
	</xsl:when>

	<xsl:otherwise>
	  <p>
	    <xsl:call-template name="id"/>
	    <xsl:choose>
	      <xsl:when test="$class = ''">
		<xsl:call-template name="class"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:attribute name="class" select="$class"/>
	      </xsl:otherwise>
	    </xsl:choose>

	    <xsl:copy-of select="$runin"/>
	    <xsl:apply-templates/>
	    <xsl:copy-of select="$annotmarkup"/>
	  </p>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <p>
	<xsl:call-template name="id"/>
	<xsl:choose>
	  <xsl:when test="$class = ''">
	    <xsl:call-template name="class"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:attribute name="class" select="$class"/>
	  </xsl:otherwise>
	</xsl:choose>

	<xsl:copy-of select="$runin"/>
	<xsl:apply-templates/>
	<xsl:copy-of select="$annotmarkup"/>
      </p>
    </xsl:otherwise>
  </xsl:choose>

  <!--
  <xsl:for-each select="$annotations">
    <xsl:variable name="id"
		    select="concat(f:node-id(.),'-',generate-id($para))"/>
    <div style="display: none" id="annot-{$id}">
      <xsl:apply-templates select="." mode="m:annotation"/>
    </div>
  </xsl:for-each>
  -->
</xsl:template>

<xsl:template match="db:formalpara">
  <xsl:variable name="title">
    <xsl:apply-templates select="db:info/db:title"/>
  </xsl:variable>

  <div class="{local-name(.)}">
    <xsl:apply-templates select="db:indexterm"/>
    <xsl:apply-templates select="db:para">
      <xsl:with-param name="runin" select="$title/node()" tunnel="yes"/>
    </xsl:apply-templates>
  </div>
</xsl:template>

<xsl:template match="db:formalpara/db:info/db:title" priority="1000">
  <b>
    <xsl:apply-templates/>
  </b>
  <xsl:text>&#160;&#160;</xsl:text>
</xsl:template>

<xsl:template match="db:epigraph">
  <div class="{local-name(.)}">
    <xsl:apply-templates select="*[not(self::db:attribution)]"/>
    <xsl:apply-templates select="db:attribution"/>
  </div>
</xsl:template>

<xsl:template match="db:attribution">
  <div class="{local-name(.)}">
    <span class="mdash">—</span>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:ackno">
  <div class="{local-name(.)}"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="db:blockquote">
  <blockquote>
    <xsl:if test="db:info/db:title">
      <h3>
	<xsl:apply-templates select="db:info/db:title/node()"/>
      </h3>
    </xsl:if>
    <xsl:apply-templates select="* except (db:info|db:attribution)"/>
    <xsl:apply-templates select="db:attribution"/>
  </blockquote>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="db:remark">
  <xsl:if test="$show.comments != 0">
    <div class="{local-name(.)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="class"/>
      <xsl:apply-templates/>
    </div>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="db:sidebar">
  <xsl:variable name="titlepage"
		select="$titlepages/*[node-name(.)=node-name(current())][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>

    <xsl:call-template name="titlepage">
      <xsl:with-param name="content" select="$titlepage"/>
    </xsl:call-template>

    <div class="sidebar-content">
      <xsl:apply-templates select="*[not(self::db:info)]"/>
    </div>
  </div>
</xsl:template>

<xsl:template match="db:sidebar/db:info/db:title"
	      mode="m:titlepage-mode">
  <div class="title">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </div>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="db:annotation" mode="m:annotation">
  <xsl:variable name="titlepage"
		select="$titlepages/*[node-name(.)=node-name(current())][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>

    <xsl:call-template name="titlepage">
      <xsl:with-param name="content" select="$titlepage"/>
    </xsl:call-template>

    <div class="annotation-content">
      <xsl:apply-templates select="*[not(self::db:info)]"/>
    </div>
  </div>
</xsl:template>

<xsl:template match="db:annotation/db:info/db:title"
	      mode="m:titlepage-mode">
  <div class="title">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </div>
</xsl:template>

</xsl:stylesheet>
