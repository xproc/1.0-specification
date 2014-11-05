<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/ns/docbook"
                xmlns:tp="http://docbook.org/xslt/ns/template/private"
                xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="f h db m t xlink xs tp"
                version="2.0">

<xsl:import href="docbook/xslt/base/html/final-pass.xsl"/>

<xsl:param name="js-navigation" select="false()"/>

<xsl:param name="w3c-doctype" select="/db:specification/@class"/>

<xsl:param name="toc.section.depth">3</xsl:param>

<xsl:param name="docbook.css">
  <xsl:if test="db:specification/db:info/db:pubdate">
    <xsl:text>http://www.w3.org/StyleSheets/TR/</xsl:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$w3c-doctype='ed'">base</xsl:when>
    <xsl:when test="$w3c-doctype='fpwd'">W3C-WD</xsl:when>
    <xsl:when test="$w3c-doctype='wd'">W3C-WD</xsl:when>
    <xsl:when test="$w3c-doctype='rec'">W3C-REC</xsl:when>
    <xsl:when test="$w3c-doctype='pr'">W3C-PR</xsl:when>
    <xsl:when test="$w3c-doctype='per'">W3C-PER</xsl:when>
    <xsl:when test="$w3c-doctype='cr'">W3C-CR</xsl:when>
    <xsl:when test="$w3c-doctype='note'">W3C-WG-NOTE</xsl:when>
    <xsl:when test="$w3c-doctype='memsub'">W3C-Member-SUBM</xsl:when>
    <xsl:when test="$w3c-doctype='teamsub'">W3C-Team-SUBM</xsl:when>
    <xsl:otherwise>base</xsl:otherwise>
  </xsl:choose>
  <xsl:text>.css</xsl:text>
</xsl:param>

<xsl:param name="publication.root.uri"
	   select="if (/processing-instruction(publication-root))
                   then xs:string(processing-instruction(publication-root))
		   else 'http://www.w3.org/TR/'"/>

<xsl:param name="latest.version.uri"
	   select="if (/processing-instruction(latest-version))
                   then xs:string(processing-instruction(latest-version))
		   else ()"/>

<!-- ============================================================ -->

<xsl:variable name="pubdate"
	      select="(xs:date(db:specification/db:info/db:pubdate),
                       current-date())[1]"/>

<xsl:variable name="dtz"
              select="adjust-dateTime-to-timezone(current-dateTime(),
                                                  xs:dayTimeDuration('PT0H'))"/>

<xsl:variable name="pubdt" as="xs:string">
  <xsl:choose>
    <xsl:when test="db:specification/db:info/db:pubdate">
      <!-- If this isn't a valid date, we'll already have errored out -->
      <xsl:value-of select="db:specification/db:info/db:pubdate"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- get rid of fractional seconds -->
      <xsl:value-of select="replace(string($dtz), '\.[0-9]+', '')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="thisuri" as="xs:string">
  <xsl:value-of>
    <xsl:value-of select="$publication.root.uri"/>

    <xsl:if test="not(/processing-instruction(publication-root))">
      <xsl:value-of select="format-date($pubdate,'[Y0001]')"/>
      <xsl:text>/</xsl:text>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$w3c-doctype = 'fpwd'">WD</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="upper-case($w3c-doctype)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text>-</xsl:text>
    <xsl:value-of select="db:specification/db:info/db:w3c-shortname"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="format-date($pubdate,'[Y0001][M01][D01]')"/>
    <xsl:text>/</xsl:text>
  </xsl:value-of>
</xsl:variable>

<!-- ============================================================ -->

<xsl:template match="db:specification">
  <xsl:variable name="revisionflags" select="//*[@revisionflag][1]"/>

  <div class="{local-name(.)}">
    <xsl:if test="$revisionflags">
      <p>The presentation of this document has been augmented to
      identify changes from a previous version. Three kinds of changes
      are highlighted: <span class="revision-added">new, added text</span>,
      <span class="revision-changed">changed text</span>, and
      <span class="revision-deleted">deleted text</span>.</p>
      <hr/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$w3c-doctype = 'namespace'">
	<xsl:call-template name="format-namespace"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="format-specification"/>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template name="format-specification">
  <xsl:variable name="revisionflags" select="//*[@revisionflag][1]"/>

  <div class="head" id='spec.head'>
    <p>
      <a href="http://www.w3.org/">
	<img height="48" width="72" alt="W3C"
	     src="http://www.w3.org/Icons/w3c_home"/>
      </a>
    </p>

    <xsl:apply-templates select="db:info/db:title[1]"
			 mode="m:titlepage-mode"/>
    <h2>
      <xsl:text>W3C </xsl:text>
      <xsl:choose>
	<xsl:when test="$w3c-doctype='ed'">
	  <xsl:choose>
	    <xsl:when test="count(/*/db:info//db:editor) &gt; 1">
	      <xsl:text>Editors' Draft </xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text>Editor's Draft </xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:when test="$w3c-doctype='fpwd'">First Public Working Draft</xsl:when>
	<xsl:when test="$w3c-doctype='wd'">Working Draft</xsl:when>
	<xsl:when test="$w3c-doctype='rec'">Recommendation</xsl:when>
	<xsl:when test="$w3c-doctype='pr'">Proposed Recommendation</xsl:when>
	<xsl:when test="$w3c-doctype='per'">Proposed Edited Recommendation</xsl:when>
	<xsl:when test="$w3c-doctype='cr'">Candidate Recommendation</xsl:when>
	<xsl:when test="$w3c-doctype='note'">Working Group Note</xsl:when>
	<xsl:when test="$w3c-doctype='memsub'">Member Submission</xsl:when>
	<xsl:when test="$w3c-doctype='teamsub'">Team Submission</xsl:when>
	<xsl:otherwise>Unknown document type</xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$revisionflags">
	<xsl:text> (with revision marks)</xsl:text>
      </xsl:if>

      <xsl:text> </xsl:text>
      <time datetime="{$pubdt}">
        <xsl:value-of select="format-date($pubdate, '[D1] [MNn] [Y0001]')"/>
        <xsl:if test="not(db:specification/db:info/db:pubdate)">
          <xsl:text> at </xsl:text>
          <xsl:value-of select="format-dateTime($dtz, '[H01]:[m01]&#160;UTC')"/>
          <xsl:if test="$travis-build-number != ''">
            <xsl:text> (</xsl:text>
            <a href="https://github.com/{$travis-user}//{$travis-repo}/commit/{$travis-commit}">
              <xsl:text>build </xsl:text>
              <xsl:value-of select="$travis-build-number"/>
            </a>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:if>
      </time>
    </h2>

    <dl>
      <dt>This Version:</dt>
      <dd>
        <xsl:choose>
          <xsl:when test="$travis = 'true'">
            <a href="https://{$travis-user}.github.io/{$travis-repo}/langspec">
              <xsl:value-of select="concat('https://',
                                           $travis-user,
                                           '.github.io/',
                                           $travis-repo,
                                           '/langspec')"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a href="{$thisuri}"><xsl:value-of select="$thisuri"/></a>
          </xsl:otherwise>
        </xsl:choose>
      </dd>
      <dt>Latest Version:</dt>
      <dd>
	<xsl:choose>
	  <xsl:when test="$latest.version.uri">
	    <a href="{$latest.version.uri}">
	      <xsl:value-of select="$latest.version.uri"/>
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	    <a href="{$publication.root.uri}{db:info/db:w3c-shortname}/">
	      <xsl:value-of select="$publication.root.uri"/>
	      <xsl:value-of select="db:info/db:w3c-shortname"/>
	      <xsl:text>/</xsl:text>
	    </a>
	  </xsl:otherwise>
	</xsl:choose>
      </dd>

      <xsl:if test="db:info/db:bibliorelation[@type='replaces']">
	<xsl:variable name="vers" select="db:info/db:bibliorelation[@type='replaces']"/>
	<dt>
	  <xsl:text>Previous version</xsl:text>
	  <xsl:if test="count($vers) &gt; 1">s</xsl:if>
	  <xsl:text>:</xsl:text>
	</dt>
	<dd>
	  <xsl:for-each select="$vers">
	    <xsl:choose>
	      <xsl:when test="starts-with(@xlink:href, 'http:')">
		<a href="{@xlink:href}">
		  <xsl:value-of select="@xlink:href"/>
		</a>
	      </xsl:when>
	      <xsl:otherwise>
		<a href="{$publication.root.uri}{@xlink:href}/">
		  <xsl:value-of select="$publication.root.uri"/>
		  <xsl:value-of select="@xlink:href"/>
		</a>
	      </xsl:otherwise>
	    </xsl:choose>
	    <br/>
	  </xsl:for-each>
	</dd>
      </xsl:if>

      <xsl:variable name="editors"
		    select="db:info/db:authorgroup/*
			    |db:info/db:author
			    |db:info/db:editor"/>

      <dt>
	<xsl:text>Editor</xsl:text>
	<xsl:if test="count($editors) &gt; 1">s</xsl:if>
	<xsl:text>:</xsl:text>
      </dt>
      <xsl:for-each select="$editors">
	<dd>
	  <xsl:apply-templates select="db:personname"/>
	  <xsl:if test="db:affiliation">
	    <xsl:text>, </xsl:text>
	    <xsl:apply-templates select="db:affiliation/db:orgname"/>
	  </xsl:if>
	  <xsl:if test="db:email">
	    <xsl:text> </xsl:text>
	    <xsl:apply-templates select="db:email"/>
	  </xsl:if>
	</dd>
      </xsl:for-each>
    </dl>

    <xsl:apply-templates
        select="db:info/db:bibliorelation[@type='references'
                                          and @role='errata']"/>

    <xsl:apply-templates
        select="db:info/db:bibliorelation[@type='references'
                                          and @role='translations']"/>

    <xsl:if test="db:info/db:bibliorelation[@type='isformatof']">
      <p>
	<xsl:text>This document is also available in these </xsl:text>
	<xsl:text>non-normative formats: </xsl:text>
	<xsl:for-each select="db:info/db:bibliorelation[@type='isformatof']">
	  <a href="{@xlink:href}">
	    <xsl:value-of select="."/>
	  </a>
	  <xsl:if test="position() &lt; last()">, </xsl:if>
	</xsl:for-each>

        <xsl:if test="$auto-diff != ''">
          <xsl:text>, </xsl:text>
	  automatic <a href="diff.html">change markup</a> from the previous draft
          courtesy of <a href="http://www.deltaxml.com/">DeltaXML</a>.
        </xsl:if>
      </p>
    </xsl:if>

<p class="copyright"><a href=
"http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a>
© 2010 <a href="http://www.w3.org/"><acronym title=
"World Wide Web Consortium">W3C</acronym></a><sup>®</sup> (<a href=
"http://www.csail.mit.edu/"><acronym title=
"Massachusetts Institute of Technology">MIT</acronym></a>, <a href=
"http://www.ercim.org/"><acronym title=
"European Research Consortium for Informatics and Mathematics">ERCIM</acronym></a>,
<a href="http://www.keio.ac.jp/">Keio</a>), All Rights Reserved.
W3C <a href=
"http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>,
<a href=
"http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a>
and <a href=
"http://www.w3.org/Consortium/Legal/copyright-documents">document
use</a> rules apply.</p>

    <hr/>

    <xsl:apply-templates select="db:info/db:abstract"
			 mode="m:titlepage-mode"/>

    <xsl:apply-templates select="db:info/db:legalnotice"
			 mode="m:titlepage-mode"/>
  </div>
  <hr/>

  <xsl:apply-templates select="." mode="m:toc"/>

  <xsl:apply-templates/>

  <xsl:call-template name="t:process-footnotes"/>

  <xsl:if test="$js-navigation">
    <div id="jsnavbar" class="navbar">&#160;</div>
  </xsl:if>
</xsl:template>

<xsl:template match="db:bibliorelation[@type='references'
                                       and @role='errata']">
  <p>
    <xsl:text>Please refer to the </xsl:text>
    <a href="{@xlink:href}">
      <strong>errata</strong>
    </a>
    <xsl:text> for this document,</xsl:text>
    <xsl:text> which may include some normative corrections.</xsl:text>
  </p>
</xsl:template>

<xsl:template match="db:bibliorelation[@type='references'
                                       and @role='translations']">
  <p>See also <a href="{@xlink:href}"> <strong>translations</strong></a>.</p>
</xsl:template>

<xsl:template name="format-namespace">
  <div class="head">
    <p>
      <a href="http://www.w3.org/">
	<img height="48" width="72" alt="W3C"
	     src="http://www.w3.org/Icons/w3c_home"/>
      </a>
    </p>

    <xsl:apply-templates select="db:info/db:title[1]"
			 mode="m:titlepage-mode"/>
  </div>

  <hr/>

  <xsl:apply-templates/>

  <xsl:call-template name="t:process-footnotes"/>
</xsl:template>

<xsl:template match="db:specification/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <h1>
    <xsl:next-match/>
  </h1>
</xsl:template>

<xsl:template match="db:specification/db:info/db:abstract"
	      mode="m:titlepage-mode"
	      priority="100">
  <div class="abstract">
    <h2>Abstract</h2>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:specification/db:info/db:legalnotice"
	      mode="m:titlepage-mode"
	      priority="100">
  <div class="status">
    <h2>Status of this Document</h2>

    <xsl:if test="/db:specification/@class='ed'">
      <p>
	<strong>
	  <xsl:text>This document is an </xsl:text>
	  <xsl:choose>
	    <xsl:when test="count(/*/db:info//db:editor) &gt; 1">
	      <xsl:text>editors' </xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text>editor's </xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:text> draft that has no official standing.</xsl:text>
	</strong>
      </p>
    </xsl:if>

    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template name="t:user-localization-data">
  <l:l10n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
	  language="en" english-language-name="English">

    <l:context name="title">
      <l:template name="specification" text="%t"/>
    </l:context>

    <l:context name="title-numbered">
      <l:template name="appendix" text="%n&#160;%t"/>
      <l:template name="bridgehead" text="%n&#160;%t"/>
      <l:template name="sect1" text="%n&#160;%t"/>
      <l:template name="sect2" text="%n&#160;%t"/>
      <l:template name="sect3" text="%n&#160;%t"/>
      <l:template name="sect4" text="%n&#160;%t"/>
      <l:template name="sect5" text="%n&#160;%t"/>
      <l:template name="section" text="%n&#160;%t"/>
      <l:template name="simplesect" text="%t"/>
    </l:context>
  </l:l10n>
</xsl:template>

<!-- ============================================================ -->

<xsl:param name="generate.toc" as="element()*">
  <tocparam path="specification" toc="1"/>
  <tocparam path="appendix" toc="1" title="1"/>
  <tocparam path="section" toc="1" title="1"/>
</xsl:param>

<xsl:template match="db:specification" mode="m:toc">
  <xsl:param name="toc.params"
             select="f:find-toc-params(., $generate.toc)"/>

  <xsl:variable name="toc">
    <xsl:call-template name="t:make-lots">
      <xsl:with-param name="toc.params" select="$toc.params"/>
      <xsl:with-param name="toc">
        <xsl:call-template name="t:component-toc"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:apply-templates select="$toc/h:div" mode="fixup-toc"/>
</xsl:template>

<xsl:template match="db:section[@role='tocsuppress']" mode="m:toc">
  <!-- nop -->
</xsl:template>

<xsl:template name="t:format-toc-title">
  <xsl:param name="toc-context" as="element()"/>
  <xsl:param name="toc-title" as="node()*"/>
  <h2 id="TableOfContents">
    <xsl:sequence select="$toc-title"/>
  </h2>
</xsl:template>

<xsl:template name="tp:toc-line">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>

  <span>
    <xsl:apply-templates select="." mode="m:label-content"/>
    <xsl:text> </xsl:text>
    <a href="{f:href(/,.)}">
      <xsl:apply-templates select="." mode="m:titleabbrev-content"/>
    </a>
  </span>
</xsl:template>

<xsl:template match="h:li" mode="fixup-toc" priority="10">
  <dt>
    <xsl:apply-templates select="@*,node()" mode="fixup-toc"/>
  </dt>
  <xsl:if test="h:ul">
    <dd>
      <dl class="toc">
        <xsl:apply-templates select="h:ul/node()" mode="fixup-toc"/>
      </dl>
    </dd>
  </xsl:if>
</xsl:template>

<xsl:template match="h:ul[parent::h:li]" mode="fixup-toc" priority="15"/>

<xsl:template match="h:ul" mode="fixup-toc" priority="10">
  <dl class="toc">
    <xsl:apply-templates mode="fixup-toc"/>
  </dl>
</xsl:template>

<xsl:template match="*" mode="fixup-toc">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="fixup-toc"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|text()|attribute()|processing-instruction()"
              mode="fixup-toc">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:rfc2119">
  <span class="rfc2119">
    <xsl:sequence select="f:html-attributes(., f:node-id(.))"/>
    <xsl:if test="@lang or @xml:lang">
      <xsl:call-template name="lang-attribute"/>
    </xsl:if>
    <xsl:call-template name="t:xlink"/>
  </span>
</xsl:template>

</xsl:stylesheet>
