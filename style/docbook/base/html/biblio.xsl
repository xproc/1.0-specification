<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:t="http://docbook.org/xslt/ns/template"
		exclude-result-prefixes="db doc f fn h m t"
                version="2.0">

<xsl:template match="db:bibliography">
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

    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:bibliodiv">
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

    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:bibliolist">
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

    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:biblioentry|db:bibliomixed">
  <xsl:param name="label">
    <xsl:call-template name="biblioentry-label"/>
  </xsl:param>

  <xsl:variable name="id" select="f:node-id(.)"/>

  <xsl:choose>
    <xsl:when test="string(.) = ''">
      <xsl:variable name="bib" select="document($bibliography.collection,.)"/>
      <xsl:variable name="entry" select="$bib/bibliography/*[@xml:id=$id][1]"/>
      <xsl:choose>
        <xsl:when test="$entry">
	  <xsl:choose>
	    <xsl:when test="$bibliography.numbered != 0">
	      <xsl:apply-templates select="$entry">
		<xsl:with-param name="label" select="$label"/>
	      </xsl:apply-templates>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="self::db:biblioentry">
		  <xsl:apply-templates select="$entry" mode="m:biblioentry"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:apply-templates select="$entry" mode="m:bibliomixed"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>No bibliography entry: </xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text> found in </xsl:text>
            <xsl:value-of select="$bibliography.collection"/>
          </xsl:message>
          <div class="{local-name(.)}">
            <xsl:call-template name="id"/>
            <xsl:call-template name="class"/>
            <p>
	      <xsl:copy-of select="$label"/>
              <xsl:text>Error: no bibliography entry: </xsl:text>
              <xsl:value-of select="$id"/>
              <xsl:text> found in </xsl:text>
              <xsl:value-of select="$bibliography.collection"/>
            </p>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <div class="{local-name(.)}">
        <xsl:call-template name="id"/>
        <xsl:call-template name="class"/>
	<p>
	  <xsl:copy-of select="$label"/>
	  <xsl:choose>
	    <xsl:when test="self::db:biblioentry">
	      <xsl:apply-templates mode="m:biblioentry"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:apply-templates mode="m:bibliomixed"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</p>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="biblioentry-label" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the label for a bibliography entry</refpurpose>

<refdescription>
<para>This template formats the label for a bibliography entry
(<tag>biblioentry</tag> or <tag>bibliomixed</tag>).</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>node</term>
<listitem>
<para>The node containing the bibliography entry, defaults to the current
context node.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The bibliography entry label.</para>
</refreturn>
</doc:template>

<xsl:template name="biblioentry-label">
  <xsl:param name="node" select="."/>

  <xsl:variable name="context" select="(ancestor::db:bibliography
                                        |ancestor::db:bibliolist)[last()]"/>

  <xsl:choose>
    <xsl:when test="$bibliography.numbered != 0">
      <xsl:text>[</xsl:text>
      <xsl:choose>
	<xsl:when test="$context/self::db:bibliography">
	  <xsl:number from="db:bibliography"
		      count="db:biblioentry|db:bibliomixed"
		      level="any" format="1"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:number from="db:bibliolist"
		      count="db:biblioentry|db:bibliomixed"
		      level="any" format="1"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>] </xsl:text>
    </xsl:when>
    <xsl:when test="$node/*[1]/self::db:abbrev">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="$node/db:abbrev[1]"/>
      <xsl:text>] </xsl:text>
    </xsl:when>
    <xsl:when test="$node/@xreflabel">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$node/@xreflabel"/>
      <xsl:text>] </xsl:text>
    </xsl:when>
    <xsl:when test="$node/@id">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$node/@id"/>
      <xsl:text>] </xsl:text>
    </xsl:when>
    <xsl:otherwise><!-- nop --></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:bibliomixed"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for formatting <tag>bibliomixed</tag> elements</refpurpose>

<refdescription>
<para>This mode is used to format elements in a <tag>bibliomixed</tag>.
Any element processed in this mode should generate markup appropriate
for the content of a bibliography entry.</para>
</refdescription>
</doc:mode>

<xsl:template match="*" mode="m:bibliomixed">
  <xsl:apply-templates select="."/> <!-- try the default mode -->
</xsl:template>

<xsl:template match="db:abbrev" mode="m:bibliomixed">
  <xsl:if test="preceding-sibling::*">
    <xsl:apply-templates mode="m:bibliomixed"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:bibliomset/db:title|db:bibliomset/db:citetitle" 
	      mode="m:bibliomixed">
  <xsl:variable name="relation" select="../@relation"/>

  <xsl:call-template name="simple-xlink">
    <xsl:with-param name="content">
      <xsl:choose>
	<xsl:when test="$relation='article' or @pubwork='article'">
	  <xsl:call-template name="gentext-startquote"/>
	  <xsl:apply-templates mode="m:bibliomixed"/>
	  <xsl:call-template name="gentext-endquote"/>
	</xsl:when>
	<xsl:otherwise>
	  <cite>
	    <xsl:apply-templates mode="m:bibliomixed"/>
	  </cite>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:citetitle|db:title" mode="m:bibliomixed">
  <xsl:call-template name="simple-xlink">
    <xsl:with-param name="content">
      <span class="{name(.)}">
	<xsl:choose>
	  <xsl:when test="@pubwork = 'article'">
	    <xsl:call-template name="gentext-startquote"/>
	    <xsl:apply-templates mode="m:bibliomixed"/>
	    <xsl:call-template name="gentext-endquote"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <cite>
	      <xsl:apply-templates mode="m:bibliomixed"/>
	    </cite>
	  </xsl:otherwise>
	</xsl:choose>
      </span>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:revhistory" mode="m:bibliomixed">
  <!-- suppressed; how could this be represented? -->
</xsl:template>

<xsl:template match="db:abstract
		     |db:address
		     |db:affiliation
		     |db:artpagenums
		     |db:authorblurb
		     |db:authorinitials
		     |db:bibliocoverage
		     |db:biblioid
		     |db:bibliomisc
		     |db:bibliomset
		     |db:bibliorelation
		     |db:biblioset
		     |db:bibliosource
		     |db:collab
		     |db:confgroup
		     |db:contractnum
		     |db:contractsponsor
		     |db:contrib
		     |db:corpauthor
		     |db:corpcredit
		     |db:corpname
		     |db:date
		     |db:edition
		     |db:firstname
		     |db:honorific
		     |db:invpartnumber
		     |db:isbn
		     |db:issn
		     |db:issuenum
		     |db:jobtitle
		     |db:lineage
		     |db:orgname
		     |db:othername
		     |db:pagenums
		     |db:personblurb
		     |db:printhistory
		     |db:productname
		     |db:productnumber
		     |db:pubdate
		     |db:publisher
		     |db:publishername
		     |db:pubsnumber
		     |db:releaseinfo
		     |db:seriesvolnums
		     |db:shortaffil
		     |db:subtitle
		     |db:surname
		     |db:titleabbrev
		     |db:volumenum"
	      mode="m:bibliomixed">
  <span class="{local-name(.)}">
    <xsl:apply-templates mode="m:bibliomixed"/>
  </span>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:biblioentry"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for formatting <tag>biblioentry</tag> elements</refpurpose>

<refdescription>
<para>This mode is used to format elements in a <tag>biblioentry</tag>.
Any element processed in this mode should generate markup appropriate
for the content of a bibliography entry.</para>
</refdescription>
</doc:mode>

<xsl:template match="*" mode="m:biblioentry">
  <xsl:variable name="content">
    <xsl:apply-templates select="."/> <!-- try the default mode -->
  </xsl:variable>
  <xsl:copy-of select="$content"/>
  <xsl:if test="not(ends-with(string($content), '.'))">.</xsl:if>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:biblioset" mode="m:biblioentry">
  <span class="{local-name(.)}">
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
</xsl:template>

<xsl:template match="db:abbrev" mode="m:biblioentry">
  <xsl:if test="preceding-sibling::*">
    <xsl:apply-templates mode="m:biblioentry"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:bibliomset/db:title|db:bibliomset/db:citetitle" 
	      mode="m:biblioentry">
  <xsl:variable name="relation" select="../@relation"/>
  <xsl:call-template name="simple-xlink">
    <xsl:with-param name="content">
      <xsl:choose>
	<xsl:when test="$relation='article' or @pubwork='article'">
	  <xsl:call-template name="gentext-startquote"/>
	  <xsl:apply-templates mode="m:biblioentry"/>
	  <xsl:call-template name="gentext-endquote"/>
	</xsl:when>
	<xsl:otherwise>
	  <cite>
	    <xsl:apply-templates mode="m:biblioentry"/>
	  </cite>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:text>. </xsl:text>
</xsl:template>

<xsl:template match="db:citetitle|db:title" mode="m:biblioentry">
  <xsl:call-template name="simple-xlink">
    <xsl:with-param name="content">
      <span class="{name(.)}">
	<xsl:choose>
	  <xsl:when test="@pubwork = 'article'">
	    <xsl:call-template name="gentext-startquote"/>
	    <xsl:apply-templates mode="m:biblioentry"/>
	    <xsl:call-template name="gentext-endquote"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <cite>
	      <xsl:apply-templates mode="m:biblioentry"/>
	    </cite>
	  </xsl:otherwise>
	</xsl:choose>
      </span>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:text>. </xsl:text>
</xsl:template>

<xsl:template match="db:revhistory" mode="m:biblioentry">
  <!-- suppressed; how could this be represented? -->
</xsl:template>

</xsl:stylesheet>
