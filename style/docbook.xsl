<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/ns/docbook"
                xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="f h db m t xlink xs"
                version="2.0">

<xsl:import href="docbook/base/html/docbook.xsl"/>

<xsl:param name="js-navigation" select="false()"/>

<xsl:param name="w3c-doctype" select="/db:specification/@class"/>

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

<xsl:param name="linenumbering" as="element()*">
<ln path="literallayout" everyNth="0"/>
<ln path="programlisting" everyNth="0"/>
<ln path="programlistingco" everyNth="0"/>
<ln path="screen" everyNth="0"/>
<ln path="synopsis" everyNth="0"/>
<ln path="address" everyNth="0"/>
</xsl:param>

<xsl:param name="toc.section.depth" select="3"/>
<xsl:param name="section.label.includes.component.label" select="1"/>

<xsl:param name="publication.root.uri"
	   select="if (/processing-instruction(publication-root))
                   then xs:string(processing-instruction(publication-root))
		   else 'http://www.w3.org/TR/'"/>

<xsl:param name="latest.version.uri"
	   select="if (/processing-instruction(latest-version))
                   then xs:string(processing-instruction(latest-version))
		   else ()"/>

<xsl:template name="user-titlepage-templates">
  <db:section t:side="recto">
    <db:title/>
    <db:subtitle/>
  </db:section>

  <db:appendix t:side="recto">
    <db:title/>
    <db:subtitle/>
  </db:appendix>
</xsl:template>

<!-- ============================================================ -->

<xsl:variable name="pubdate"
	      select="(xs:date(db:specification/db:info/db:pubdate),
                       current-date())[1]"/>

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

<xsl:template name="user-localization-data">
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

<xsl:param name="root.elements">
  <db:specification/>
</xsl:param>

<xsl:param name="autotoc.label.separator" select="'&#160;'"/>

<!-- ============================================================ -->

<xsl:template name="component-toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title" select="true()"/>

  <div id='spectoc'>
    <xsl:call-template name="make-toc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="toc.title" select="$toc.title"/>
      <xsl:with-param name="nodes"
                      select="db:section|db:sect1
                              |db:bridgehead[not(@renderas)
                                             and $bridgehead.in.toc != 0]
                              |.//db:bridgehead[@renderas='sect1'
                                                and $bridgehead.in.toc != 0]"/>
    </xsl:call-template>

    <xsl:if test="db:appendix">
      <h3><a name="appendices" id="appendices"/>Appendices</h3>
      <xsl:call-template name="make-toc">
	<xsl:with-param name="toc-context" select="$toc-context"/>
	<xsl:with-param name="toc.title" select="false()"/>
	<xsl:with-param name="nodes"
			select="db:appendix"/>
      </xsl:call-template>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template name="make-toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title" select="true()"/>
  <xsl:param name="nodes" select="()"/>

  <xsl:if test="$nodes">
    <div class="toc">
      <xsl:if test="$toc.title">
	<h2 id="TableOfContents">
	  <xsl:call-template name="gentext">
	    <xsl:with-param name="key">TableofContents</xsl:with-param>
	  </xsl:call-template>
	</h2>
      </xsl:if>

      <xsl:element name="{$toc.list.type}">
	<xsl:attribute name="class" select="'toc'"/>
	<xsl:apply-templates select="$nodes" mode="m:toc">
	  <xsl:with-param name="toc-context" select="$toc-context"/>
	</xsl:apply-templates>
      </xsl:element>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template name="toc-line">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>

  <span>
    <xsl:call-template name="class"/>

    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="m:label-markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>

    <a href="{f:href(/,.)}">
      <xsl:apply-templates select="." mode="m:titleabbrev-markup"/>
    </a>
  </span>
</xsl:template>

<xsl:template match="db:section[@role='tocsuppress']" mode="m:toc">
  <!-- nop -->
</xsl:template>

<xsl:template match="db:appendix">
  <xsl:variable name="recto"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='recto'][1]"/>
  <xsl:variable name="verso"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='verso'][1]"/>

  <div class="{local-name(.)}">
    <xsl:call-template name="titlepage">
      <xsl:with-param name="content" select="$recto"/>
    </xsl:call-template>

    <xsl:if test="not(empty($verso))">
      <xsl:call-template name="titlepage">
	<xsl:with-param name="content" select="$verso"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates/>

    <xsl:if test="not(parent::db:article)">
      <xsl:call-template name="t:process-footnotes"/>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="db:section">
  <xsl:variable name="recto"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='recto'][1]"/>
  <xsl:variable name="verso"
		select="$titlepages/*[node-name(.) = node-name(current())
			              and @t:side='verso'][1]"/>

  <div class="{local-name(.)}">
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

<xsl:template match="db:appendix/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <h2>
    <xsl:if test="../../@xml:id">
      <a name="{../../@xml:id}" id="{../../@xml:id}"/>
    </xsl:if>

    <xsl:apply-templates select="../.." mode="m:object-title-markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </h2>
</xsl:template>

<xsl:template match="db:section/db:info/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <xsl:variable name="depth"
		select="count(ancestor::db:section)"/>

  <xsl:variable name="hlevel"
		select="if ($depth &lt; 5) then $depth else 4"/>
  
  <xsl:element name="h{$hlevel+2}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:if test="../../@xml:id">
      <a name="{../../@xml:id}" id="{../../@xml:id}"/>
    </xsl:if>

    <xsl:apply-templates select="../.." mode="m:object-title-markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>

  </xsl:element>
</xsl:template>

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
      <xsl:value-of select="format-date($pubdate, '[D1] [MNn] [Y0001]')"/>
      <xsl:if test="not(db:specification/db:info/db:pubdate)">
        <xsl:text> at </xsl:text>
        <xsl:variable name="dtz"
                      select="adjust-dateTime-to-timezone(current-dateTime(),
                                 xs:dayTimeDuration('PT0H'))"/>
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

    <xsl:if test="not($travis = 'true')">
      <xsl:apply-templates
          select="db:info/db:bibliorelation[@type='references'
                                            and @role='errata']"/>

      <xsl:apply-templates
          select="db:info/db:bibliorelation[@type='references'
                                            and @role='translations']"/>
    </xsl:if>

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

  <xsl:variable name="toc.params" as="element()">
    <tocparam toc="1" title="1"/>
  </xsl:variable>

  <xsl:call-template name="make-lots">
    <xsl:with-param name="toc.params" select="$toc.params"/>
    <xsl:with-param name="toc">
      <xsl:call-template name="component-toc">
	<xsl:with-param name="toc.title" select="$toc.params/@title != 0"/>
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>

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

<!-- ============================================================ -->

<xsl:template match="db:rfc2119">
  <span class="rfc2119">
    <xsl:call-template name="id"/>
    <xsl:if test="@lang or @xml:lang">
      <xsl:call-template name="lang-attribute"/>
    </xsl:if>
    <xsl:call-template name="simple-xlink"/>
  </span>
</xsl:template>

</xsl:stylesheet>
