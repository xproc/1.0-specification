<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://docbook.org/xslt/ns/extension" xmlns:h="http://www.w3.org/1999/xhtml" xmlns:db="http://docbook.org/ns/docbook" xmlns:doc="http://nwalsh.com/xmlns/schema-doc/" xmlns:m="http://docbook.org/xslt/ns/mode" xmlns:ml="http://nwalsh.com/ns/ml-macro#" xmlns:n="http://docbook.org/xslt/ns/normalize" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:t="http://docbook.org/xslt/ns/template" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="f h db doc m ml n rng t xlink xs" version="2.0">

<xsl:import href="docbook.xsl"/>
<xsl:import href="ml-macro.xsl"/>
<xsl:include href="elemsyntax.xsl"/>
<xsl:include href="rngsyntax.xsl"/>
<xsl:include href="xprocns.xsl"/>

<xsl:output name="final" method="xhtml" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:output name="library" method="xml" indent="yes"/>

<xsl:param name="travis" select="''" as="xs:string"/>
<xsl:param name="travis-commit" select="''" as="xs:string"/>
<xsl:param name="travis-build-number" select="''" as="xs:string"/>
<xsl:param name="travis-user" select="''" as="xs:string"/>
<xsl:param name="travis-repo" select="''" as="xs:string"/>
<xsl:param name="auto-diff" select="''" as="xs:string"/>

<!-- Default macros -->
<xsl:variable name="ml:defaultMacros" select="document($defaultMacros)"/>
<ml:collection xml:id="macros">
  <ml:macro name="pipeline"><db:phrase role="component">pipeline</db:phrase></ml:macro>
  <ml:macro name="for-each"><db:phrase role="component">for-each</db:phrase></ml:macro>
  <ml:macro name="viewport"><db:phrase role="component">viewport</db:phrase></ml:macro>
  <ml:macro name="choose"><db:phrase role="component">choose</db:phrase></ml:macro>
  <ml:macro name="try"><db:phrase role="component">try</db:phrase></ml:macro>
  <ml:macro name="catch"><db:phrase role="component">catch</db:phrase></ml:macro>
  <ml:macro name="group"><db:phrase role="component">group</db:phrase></ml:macro>
  <ml:macro name="try/catch"><db:phrase role="component">try/catch</db:phrase></ml:macro>
</ml:collection>

<!-- ============================================================ -->

<xsl:template match="db:note" mode="n:normalized-title">
  <xsl:param name="title-key"/>

  <xsl:choose>
    <xsl:when test="@role = 'editorial'">
      <xsl:text>Editorial Note</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="gentext">
	<xsl:with-param name="key" select="$title-key"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:termdef/db:firstterm">
  <em class="glossterm">
    <xsl:apply-templates/>
  </em>
</xsl:template>

<xsl:template match="db:termdef">
  <xsl:if test="not(.//db:firstterm)">
    <xsl:message>Error termdef (<xsl:value-of select="@xml:id"/>) does not contain firstterm.</xsl:message>
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<xsl:template match="db:glossterm">
  <xsl:variable name="term" select="string(.)"/>
  <xsl:variable name="anchorterm" select="if (@baseform) then @baseform else normalize-space($term)"/>
  <xsl:variable name="anchor" select="translate($anchorterm,' ','-')"/>
  <xsl:variable name="termdef" select="key('id',concat('dt-', $anchor))"/>

  <xsl:if test="($anchorterm = 'static error' or $anchorterm = 'dynamic error')
                and (not(ancestor::db:error)
		     and not(ancestor::db:termdef)
		     and not(ancestor::db:glossentry)
		     and not(@role = 'unwrapped'))">
    <xsl:message>
      <xsl:text>Unwrapped </xsl:text>
      <xsl:value-of select="$anchorterm"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="name(parent::*)"/>
      <xsl:text> ) in </xsl:text>
      <xsl:value-of select="parent::*"/>
    </xsl:message>
  </xsl:if>

  <xsl:if test="($anchorterm = 'implementation-defined'
		 or $anchorterm = 'implementation-dependent')
                and (not(ancestor::db:impl)
		     and not(@role='unwrapped')
		     and not(ancestor::db:glossentry))">
    <xsl:message>
      <xsl:text>Unwrapped </xsl:text>
      <xsl:value-of select="$anchorterm"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="name(parent::*)"/>
      <xsl:text> ) in </xsl:text>
      <xsl:value-of select="parent::*"/>
    </xsl:message>
  </xsl:if>

  <em class="glossterm">
    <xsl:choose>
      <xsl:when test="$termdef">
	<a href="#{$termdef/@xml:id}">
	  <xsl:apply-templates/>
	</a>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>No definition for glossterm: "</xsl:text>
	  <xsl:value-of select="$anchor"/>
	  <xsl:text>"</xsl:text>
	</xsl:message>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </em>

  <xsl:if test="ancestor::db:error
		and ($anchorterm = 'static error' or $anchorterm = 'dynamic error')">
    <xsl:variable name="code" select="ancestor::db:error[1]/@code"/>
    <xsl:text>&#160;(</xsl:text>
    <a href="#err.{$code}">
      <code class="errqname">
	<xsl:text>err:X</xsl:text>
	<xsl:value-of select="ancestor::db:error[1]/@code"/>
      </code>
    </a>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="db:phrase[@role='component']">
  <xsl:variable name="id">
    <xsl:choose>
      <xsl:when test=". = 'catch'">p.try</xsl:when>
      <xsl:when test=". = 'try/catch'">p.try</xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat('p.', .)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="def" select="key('id', $id)"/>

  <span class="component">
    <xsl:choose>
      <xsl:when test="$def and ancestor::* = $def">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$def">
	<a href="#{$def/@xml:id}">
	  <xsl:apply-templates/>
	</a>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>No definition for: "</xsl:text>
	  <xsl:value-of select="if (@baseform) then @baseform else normalize-space(.)"/>
	  <xsl:text>"</xsl:text>
	</xsl:message>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="db:error">
  <xsl:variable name="code" select="@code"/>
  <xsl:variable name="num" select="count(preceding::db:error[@code=$code])"/>

  <a name="err.inline.{@code}{if ($num&gt;0) then concat('.',$num) else ''}"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:impl">
  <xsl:param name="summary" select="0"/>

  <xsl:if test="$summary = 0">
    <a name="impl-{count(preceding::db:impl)+1}"/>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:literal[@role='infoset-property']">
  <xsl:call-template name="inline-monoseq">
    <xsl:with-param name="content">
      <xsl:call-template name="simple-xlink">
	<xsl:with-param name="content">
	  <xsl:text>[</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>]</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>
  
<xsl:template match="db:port">
  <xsl:call-template name="inline-monoseq"/>
</xsl:template>

<xsl:template match="db:type">
  <xsl:call-template name="inline-monoseq"/>
</xsl:template>

<xsl:template match="db:tag[@class='attribute']" priority="10">
  <xsl:apply-imports/>
</xsl:template>

<xsl:template match="db:tag">
  <xsl:variable name="name" select="."/>
  <xsl:variable name="local" select="substring-after($name,':')"/>

  <xsl:choose>
    <xsl:when test="starts-with(.,'p:') or starts-with(.,'c:')">
      <xsl:variable name="id" as="xs:string">
	<xsl:choose>
	  <xsl:when test="starts-with(.,'p:') and key('id', concat('p.',$local))">
	    <xsl:value-of select="concat('p.',$local)"/>
	  </xsl:when>
	  <xsl:when test="starts-with(.,'c:') and key('id', concat('cv.',$local))">
	    <xsl:value-of select="concat('cv.',$local)"/>
	  </xsl:when>
	  <xsl:when test="key('id', concat('p.',$local))">
	    <xsl:value-of select="concat('p.',$local)"/>
	  </xsl:when>
	  <xsl:when test="key('id', concat('c.',$local))">
	    <xsl:value-of select="concat('c.',$local)"/>
	  </xsl:when>
	  <xsl:when test="key('id', concat('cv.',$local))">
	    <xsl:value-of select="concat('cv.',$local)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="translate($name,':','.')"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="def" select="key('id', $id)"/>

      <xsl:choose>
	<xsl:when test="ancestor::db:section[1][@xml:id=$id]">
	  <!-- don't link inside the section that's defining the tag! -->
	  <xsl:apply-imports/>
	</xsl:when>
	<xsl:when test="$def">
	  <a href="#{$id}">
	    <xsl:apply-imports/>
	  </a>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message>Warning: No anchor for <xsl:value-of select="."/></xsl:message>
	  <xsl:apply-imports/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:function">
  <xsl:variable name="name" select="."/>
  <xsl:variable name="local" select="substring-after($name,':')"/>

  <xsl:choose>
    <xsl:when test="starts-with(.,'p:')">
      <xsl:variable name="id" as="xs:string">
	<xsl:choose>
	  <xsl:when test="key('id', concat('f.',$local))">
	    <xsl:value-of select="concat('f.',$local)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message>
	      <xsl:text>Unexpected function: </xsl:text>
	      <xsl:value-of select="$name"/>
	    </xsl:message>
	    <xsl:value-of select="translate($name,':','.')"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="def" select="key('id', $id)"/>

      <xsl:choose>
	<xsl:when test="$def">
	  <a href="#{$id}">
	    <xsl:apply-imports/>
	  </a>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message>Warning: No anchor for <xsl:value-of select="."/></xsl:message>
	  <xsl:apply-imports/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="css-style">
  <xsl:if test="$js-navigation">
    <script type="text/javascript" src="fg-menu/jquery-1.4.1.min.js"></script>
    <script type="text/javascript" src="fg-menu/fg.menu.js"></script>
    <link type="text/css" href="navbar.css" media="screen" rel="stylesheet" />
    <link type="text/css" href="fg-menu/fg.menu.css" media="screen"
          rel="stylesheet" />
    <link type="text/css" href="fg-menu/theme/ui.all.css" media="screen"
          rel="stylesheet" />
    <link type="text/css" href="fg-menu/dropdown.css" media="screen"
          rel="stylesheet" />

    <xsl:comment> style exceptions for IE 6 </xsl:comment>
    <xsl:comment>[if IE 6]>
&lt;style type="text/css">
    .fg-menu-ipod .fg-menu li { width: 95%; }
    .fg-menu-ipod .ui-widget-content { border:0; }
&lt;/style>
&lt;[endif]</xsl:comment>

    <script type="text/javascript" src="navbar.js"></script>

    <script type="text/javascript">
      $(document).ready(function(){
      navbarInit();
      });
    </script>
  </xsl:if>

<!--
  <link rel="stylesheet" type="text/css"
        href="http://www.w3.org/StyleSheets/TR/w3c-tr.css"/>
-->
  <link rel="stylesheet" type="text/css"
        href="http://www.w3.org/StyleSheets/TR/base.css"/>
  <link rel="stylesheet" type="text/css"
        href="xproc.css"/>
  <xsl:choose>
    <xsl:when test="$docbook.css.inline = 0">
      <link rel="stylesheet" type="text/css" href="{$docbook.css}"/>
    </xsl:when>
    <xsl:otherwise>
      <style type="text/css">
	<xsl:copy-of select="unparsed-text($docbook.css, 'us-ascii')"/>
      </style>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:head-links">
  <xsl:variable name="info" select="/db:specification/db:info"/>

  <xsl:for-each select="$info/db:bibliorelation[@type='isformatof']">
    <link rel="alternate" title="{.}" href="{@xlink:href}"/>
  </xsl:for-each>

  <link rel="alternate"
	title="Latest editor's draft"
	href="http://www.w3.org/XML/XProc/docs/langspec.html" />

  <link rel="alternate"
	title="Latest Public Working Draft"
	href="http://www.w3.org/TR/xproc/" />

  <xsl:for-each select="$info/db:bibliorelation[@type='replaces']">
    <xsl:variable name="datestr" select="concat(substring(@xlink:href,36,4),
			         '-',
				 substring(@xlink:href,40,2),
			         '-',
				 substring(@xlink:href,42,2))"/>

    <link rel="alternate" href="{@xlink:href}">
      <xsl:attribute name="title">
	<xsl:value-of select="format-date(xs:date($datestr),
			                  '[D01] [MNn,*-3] [Y0001]')"/>
	<xsl:text> Working Draft</xsl:text>
      </xsl:attribute>
    </link>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:root">
  <xsl:choose>
    <xsl:when test="@ml-expanded">
      <xsl:next-match/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="newRoot">
	<xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
	  <xsl:copy-of select="@*"/>
	  <xsl:attribute name="xml:base" select="base-uri(.)"/>
	  <xsl:attribute name="ml-expanded" select="1"/>
	  <xsl:apply-templates select="*" mode="ml:expand-macros"/>
	</xsl:element>
      </xsl:variable>

      <!-- newRoot has a totally borked base URI. Fix it. -->
      <xsl:variable name="fixedbase">
	<xsl:apply-templates select="$newRoot/*" mode="m:fixbaseuri">
	  <xsl:with-param name="base-uri" select="base-uri(.)"/>
	</xsl:apply-templates>
      </xsl:variable>

      <xsl:apply-templates select="$fixedbase/*" mode="m:root"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="processing-instruction('syntax-summary')">
  <xsl:apply-templates select="//e:rng-fragment[not(@role='nosummary')]
			       |//e:rng-pattern[not(@role='nosummary')]" xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax">
    <xsl:with-param name="class" select="'language-construct'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="processing-instruction('required-step-summary')">
  <xsl:apply-templates select="key('id','std-required')//p:declare-step" xmlns:p="http://www.w3.org/ns/xproc"/>
</xsl:template>

<xsl:template match="processing-instruction('optional-step-summary')">
  <xsl:apply-templates select="key('id','std-optional')//p:declare-step" xmlns:p="http://www.w3.org/ns/xproc"/>
</xsl:template>

<xsl:template match="processing-instruction('step-vocabulary-summary')">
  <xsl:apply-templates select="//e:rng-fragment[not(@role='nosummary')]
			       |//e:rng-pattern[not(@role='nosummary')]" xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax">
    <xsl:with-param name="class" select="'step-vocabulary'"/>
  </xsl:apply-templates>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="processing-instruction('static-error-list')">
  <div id="static-error-summary">
    <h5>Static Errors</h5>
    <dl class="errs">
      <xsl:call-template name="format-error-list">
	<xsl:with-param name="errors" select="//db:error[starts-with(@code,'S')]"/>
      </xsl:call-template>
    </dl>
  </div>
</xsl:template>

<xsl:template match="processing-instruction('dynamic-error-list')">
  <div id="dynamic-error-summary">
    <h5>Dynamic Errors</h5>
    <dl class="errs">
      <xsl:call-template name="format-error-list">
	<xsl:with-param name="errors" select="//db:error[starts-with(@code,'D')]"/>
      </xsl:call-template>
    </dl>
  </div>
</xsl:template>

<xsl:template match="processing-instruction('step-error-list')">
  <div id="step-error-summary">
    <h5>Step Errors</h5>
    <dl class="errs">
      <xsl:call-template name="format-error-list">
	<xsl:with-param name="errors" select="//db:error[starts-with(@code,'C')]"/>
      </xsl:call-template>
    </dl>
  </div>
</xsl:template>

<xsl:template name="format-error-list">
  <xsl:param name="errors"/>

  <xsl:variable name="sorted-errors" as="element()*">
    <xsl:for-each select="$errors">
      <xsl:sort select="@code" order="ascending" data-type="text"/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:for-each-group select="$sorted-errors" group-by="@code">
    <xsl:variable name="codes" select="distinct-values(current-group()/@code)"/>
    <dt>
      <a name="err.{$codes[1]}"/>
      <code class="errqname">
	<xsl:text>err:X</xsl:text>
	<xsl:value-of select="$codes[1]"/>
      </code>
    </dt>
    <dd>
      <p>
	<xsl:value-of select="current-group()[1]"/>
      </p>
      <p>
	<xsl:text>See: </xsl:text>
	<xsl:for-each select="current-group()">
	  <xsl:variable name="code" select="@code"/>
	  <xsl:variable name="num" select="count(preceding::db:error[@code=$code])"/>
	  <a href="#err.inline.{@code}{if ($num&gt;0) then concat('.',$num) else ''}">
	    <xsl:value-of select="(ancestor::db:section[1]/db:info/db:title, ancestor::db:appendix[1]/db:info/db:title)[1]"/>
	  </a>
	  <xsl:if test="position() &lt; last()">, </xsl:if>
	</xsl:for-each>
      </p>
    </dd>
  </xsl:for-each-group>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="err:error-list"
              xmlns:err="http://www.w3.org/ns/xproc-error">
  <dl>
    <xsl:apply-templates/>
  </dl>
</xsl:template>

<xsl:template match="err:error"
              xmlns:err="http://www.w3.org/ns/xproc-error">
  <dt><code>err:<xsl:value-of select="@code"/></code></dt>
  <dd>
    <p>
      <xsl:apply-templates/>
    </p>
  </dd>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="processing-instruction('implementation-dependent-features')">
  <ol class="features">
    <xsl:call-template name="format-feature-list">
      <xsl:with-param name="features" select="//db:impl[db:glossterm='implementation-dependent']"/>
    </xsl:call-template>
  </ol>
</xsl:template>

<xsl:template match="processing-instruction('implementation-defined-features')">
  <ol class="features">
    <xsl:call-template name="format-feature-list">
      <xsl:with-param name="features" select="//db:impl[db:glossterm='implementation-defined']"/>
    </xsl:call-template>
  </ol>
</xsl:template>

<xsl:template name="format-feature-list">
  <xsl:param name="features"/>

  <xsl:for-each select="$features">
    <li>
      <xsl:value-of select="."/>
      <xsl:text> See </xsl:text>
      <xsl:call-template name="db:xref">
	<xsl:with-param name="linkend" select="(ancestor::db:section|ancestor::db:appendix)[last()]/@xml:id"/>
      </xsl:call-template>
      <xsl:text>.</xsl:text>
    </li>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:block-element">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:sequence select="$content"/>
</xsl:template>

<xsl:template match="db:section[@revisionflag]" priority="21000">
  <div class="revision-inherited">
    <div class="revision-{@revisionflag}">
      <xsl:next-match/>
    </div>
  </div>
</xsl:template>

<xsl:template match="db:para[@revisionflag] | db:para[.//*[@revisionflag]]"
	      priority="21000">
  <xsl:variable name="prevd"
		select="preceding::*[@revisionflag][1]"/>
  <xsl:variable name="prev"
		select="if ($prevd/ancestor-or-self::db:para)
			then $prevd/ancestor-or-self::db:para
			else $prevd"/>

  <xsl:variable name="nextd"
		select="following::*[@revisionflag][1]"/>
  <xsl:variable name="next"
		select="if ($nextd/ancestor-or-self::db:para)
			then $nextd/ancestor-or-self::db:para
			else $nextd"/>

  <xsl:variable name="htmlpd">
    <xsl:next-match/>
  </xsl:variable>

  <xsl:variable name="htmlp" as="element()" select="$htmlpd/*"/>

  <div class="diffpara">
    <p>
      <xsl:copy-of select="$htmlp/@*"/>
      <a name="RF-{generate-id(.)}"/>
      <xsl:if test="$prev">
	<a class="difflink" href="#RF-{generate-id($prev)}"
	   title="Previous change (approximate)">←</a>
      </xsl:if>
      <span>
	<xsl:if test="@revisionflag">
	  <xsl:attribute name="class"
			 select="concat('revision-',@revisionflag)"/>
	</xsl:if>
	<!--
	<xsl:text>[[</xsl:text>
	<xsl:value-of select="count($htmlp)"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="name($htmlp)"/>
	<xsl:text>, </xsl:text>
	-->
	<xsl:sequence select="$htmlp/node()"/>
	<!--
	<xsl:text>]]</xsl:text>
	-->
      </span>
      <xsl:if test="$next">
	<a class="difflink" href="#RF-{generate-id($next)}"
	   title="Next change (approximate)">→</a>
      </xsl:if>
    </p>
  </div>
</xsl:template>

<!-- what was I thinking ??? -->
<xsl:template match="XXX[@revisionflag]" priority="20000">
  <xsl:choose>
    <xsl:when test="self::db:para or ancestor::db:para">
      <!-- nop -->
    </xsl:when>
    <xsl:when test="self::db:section">
      <!-- nop -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
	<xsl:text>-- unexpected revision flag on </xsl:text>
	<xsl:value-of select="name(.)"/>
	<xsl:text> --</xsl:text>
      </xsl:message>
      <xsl:comment> ??REVISION FLAG?? </xsl:comment>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:next-match/>
</xsl:template>

<xsl:template match="db:methodsynopsis">
  <div class="funcsynopsis">
    <span class="funcname">
      <xsl:value-of select="db:methodname"/>
    </span>
    <span class="funcparen">(</span>

    <xsl:apply-templates select="db:methodparam"/>

    <span class="funcparen">)</span>
    <span class="typeas"> as </span>
    <span class="type">
      <xsl:value-of select="db:type"/>
    </span>
  </div>
</xsl:template>

<xsl:template match="db:methodparam">
  <xsl:if test="preceding-sibling::db:methodparam">
    <span class="funccomma">, </span>
  </xsl:if>
  <span class="paramname">
    <xsl:text>$</xsl:text>
    <xsl:value-of select="db:parameter"/>
  </span>
  <span class="typeas"> as </span>
  <span class="type">
    <xsl:value-of select="db:type"/>
  </span>
</xsl:template>

</xsl:stylesheet>
