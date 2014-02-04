<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:t="http://docbook.org/xslt/ns/template"
		exclude-result-prefixes="h f m fn db t"
                version="2.0">

<xsl:key name="glossterm" match="db:glossentry/db:glossterm" use="string(.)"/>

<!-- ==================================================================== -->

<xsl:template match="db:glossary">
  <xsl:variable name="recto"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='recto'][1]"/>
  <xsl:variable name="verso"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='verso'][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="titlepage">
      <xsl:with-param name="content" select="$recto"/>
    </xsl:call-template>

    <xsl:if test="not(empty($verso))">
      <xsl:call-template name="titlepage">
	<xsl:with-param name="content" select="$verso"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="db:glossdiv">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
	<dl>
	  <xsl:apply-templates/>
	</dl>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="not(parent::db:article)">
      <xsl:call-template name="t:process-footnotes"/>
    </xsl:if>
  </div>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="db:glossdiv">
  <xsl:variable name="recto"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='recto'][1]"/>
  <xsl:variable name="verso"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='verso'][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="titlepage">
      <xsl:with-param name="content" select="$recto"/>
    </xsl:call-template>

    <xsl:if test="not(empty($verso))">
      <xsl:call-template name="titlepage">
	<xsl:with-param name="content" select="$verso"/>
      </xsl:call-template>
    </xsl:if>

    <dl>
      <xsl:apply-templates/>
    </dl>
  </div>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="db:glosslist">
  <xsl:variable name="recto"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='recto'][1]"/>
  <xsl:variable name="verso"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='verso'][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>

    <xsl:if test="not(empty($recto))">
      <xsl:call-template name="titlepage">
	<xsl:with-param name="content" select="$recto"/>
      </xsl:call-template>

      <xsl:if test="not(empty($verso))">
	<xsl:call-template name="titlepage">
	  <xsl:with-param name="content" select="$verso"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>

    <xsl:apply-templates select="*[not(self::db:info)
				   and not(self::db:glossentry)]"/>

    <dl>
      <xsl:apply-templates select="db:glossentry"/>
    </dl>
  </div>
</xsl:template>

<!-- ==================================================================== -->

<!--
GlossEntry ::=
  GlossTerm, Acronym?, Abbrev?,
  (IndexTerm)*,
  RevHistory?,
  (GlossSee | GlossDef+)
-->

<xsl:template match="db:glossentry">
  <dt>
    <xsl:call-template name="id">
      <xsl:with-param name="force" select="$glossterm.auto.link"/>
    </xsl:call-template>
    <xsl:call-template name="class"/>
    
    <xsl:choose>
      <xsl:when test="$glossentry.show.acronym = 'primary'">
	<xsl:choose>
	  <xsl:when test="db:acronym|db:abbrev">
	    <xsl:apply-templates select="db:acronym|db:abbrev"/>
	    <xsl:text> (</xsl:text>
	    <xsl:apply-templates select="db:glossterm"/>
	    <xsl:text>)</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="db:glossterm"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$glossentry.show.acronym = 'yes'">
	<xsl:apply-templates select="db:glossterm"/>

	<xsl:if test="db:acronym|db:abbrev">
          <xsl:text> (</xsl:text>
          <xsl:apply-templates select="db:acronym|db:abbrev"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="db:glossterm"/>
      </xsl:otherwise>
    </xsl:choose>
  </dt>

  <xsl:apply-templates select="db:indexterm|db:glosssee|db:glossdef"/>
</xsl:template>

<xsl:template match="db:glossentry/db:glossterm">
  <span class="{local-name(.)}">
    <xsl:call-template name="id">
      <xsl:with-param name="force" select="$glossterm.auto.link"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </span>
  <xsl:if test="following-sibling::db:glossterm">, </xsl:if>
</xsl:template>

<xsl:template match="db:glossentry/db:acronym">
  <span class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:apply-templates/>
  </span>
  <xsl:if test="following-sibling::db:acronym
		|following-sibling::db:abbrev">, </xsl:if>
</xsl:template>

<xsl:template match="db:glossentry/db:abbrev">
  <span class="{local-name(.)}">
    <xsl:call-template name="id"/>
    <xsl:apply-templates/>
  </span>
  <xsl:if test="following-sibling::db:acronym
		|following-sibling::db:abbrev">, </xsl:if>
</xsl:template>

<xsl:template match="db:glossentry/db:glosssee">
  <xsl:variable name="target" select="key('id', @otherterm)[1]"/>

  <dd>
    <p>
      <xsl:call-template name="gentext-template">
        <xsl:with-param name="context" select="'glossary'"/>
        <xsl:with-param name="name" select="'see'"/>
      </xsl:call-template>
      <xsl:choose>
	<xsl:when test="$target">
	  <a href="{f:href(/,$target)}">
	    <xsl:apply-templates select="$target" mode="m:xref-to"/>
	  </a>
	</xsl:when>
	<xsl:when test="@otherterm and not($target)">
	  <xsl:message>
	    <xsl:text>Warning: </xsl:text>
	    <xsl:text>glosssee @otherterm reference not found: </xsl:text>
	    <xsl:value-of select="@otherterm"/>
	  </xsl:message>
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>.</xsl:text>
    </p>
  </dd>
</xsl:template>

<xsl:template match="db:glossentry/db:glossdef">
  <dd>
    <xsl:apply-templates select="*[not(self::db:glossseealso)]"/>
    <xsl:if test="db:glossseealso">
      <p>
	<xsl:call-template name="gentext-template">
          <xsl:with-param name="context" select="'glossary'"/>
          <xsl:with-param name="name" select="'seealso'"/>
        </xsl:call-template>
        <xsl:apply-templates select="db:glossseealso"/>
      </p>
    </xsl:if>
  </dd>
</xsl:template>

<xsl:template match="db:glossseealso">
  <xsl:variable name="target"
		select="if (key('id', @otherterm))
			then key('id', @otherterm)[1]
			else key('glossterm', string(.))"/>

  <xsl:choose>
    <xsl:when test="$target">
      <a href="{f:href(/,$target)}">
        <xsl:apply-templates select="$target" mode="m:xref-to"/>
      </a>
    </xsl:when>
    <xsl:when test="@otherterm and not($target)">
      <xsl:message>
        <xsl:text>Warning: </xsl:text>
	<xsl:text>glossseealso @otherterm reference not found: </xsl:text>
        <xsl:value-of select="@otherterm"/>
      </xsl:message>
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="position() = last()">
      <xsl:text>.</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>, </xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
