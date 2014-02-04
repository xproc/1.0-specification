<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fp="http://docbook.org/xslt/ns/extension"
                xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:mp="http://docbook.org/xslt/ns/mode/private"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:tp="http://docbook.org/xslt/ns/template/private"
                xmlns:u="http://nwalsh.com/xsl/unittests#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="doc f fp ghost h m t tp u xs"
                version="2.0">

<xsl:param name="callout.defaultcolumn" select="60"/>
<xsl:param name="verbatim.trim.blank.lines" select="1"/>

<xsl:param name="linenumbering" as="element()*">
<ln path="literallayout" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
<ln path="programlisting" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
<ln path="programlistingco" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
<ln path="screen" everyNth="2" width="3" separator="" padchar=" " minlines="3"/>
<ln path="synopsis" everyNth="2" width="3" separator="" padchar=" " minlines="3"/>
<ln path="address" everyNth="0"/>
<ln path="epigraph/literallayout" everyNth="0"/>
</xsl:param>

<!-- ============================================================ -->

<doc:mode name="m:verbatim-phase-1" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for normalizing verbatim environments</refpurpose>

<refdescription>
<para>This mode is used to normalize verbatim environments (<tag>address</tag>,
<tag>literallayout</tag>, <tag>programlisting</tag>, <tag>screen</tag>,
<tag>synopsis</tag>, and <tag>programlistingco</tag>.</para>

<para>This mode adds line numbers and inserts callouts if necessary.
The resulting normalized verbatim element can be formatted in the
ordinary, straightforward manner.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:programlistingco" mode="m:verbatim-phase-1">
  <xsl:variable name="areas-unsorted" as="element()*">
    <xsl:apply-templates select="db:areaspec"/>
  </xsl:variable>

  <xsl:variable name="areas" as="element()*">
    <xsl:for-each select="$areas-unsorted">
      <xsl:sort data-type="number" select="@ghost:line"/>
      <xsl:sort data-type="number" select="@ghost:col"/>
      <xsl:sort data-type="number" select="@ghost:number"/>
      <xsl:if test="@ghost:line">
	<xsl:copy-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="everyNth"  select="f:lineNumbering(.,'everyNth')"/>
  <xsl:variable name="width"     select="f:lineNumbering(.,'width')"/>
  <xsl:variable name="padchar"   select="f:lineNumbering(.,'padchar')"/>
  <xsl:variable name="separator" select="f:lineNumbering(.,'separator')"/>

  <xsl:variable name="expanded-text" as="node()*">
    <xsl:for-each select="db:programlisting/node()">
      <xsl:choose>
	<xsl:when test="self::db:inlinemediaobject
			and db:textobject/db:textdata">
	  <xsl:apply-templates select="."/>
	</xsl:when>
	<xsl:when test="self::db:textobject and db:textdata">
	  <xsl:apply-templates select="."/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="pl-empty-tags" as="node()*">
    <xsl:apply-templates select="$expanded-text"
			 mode="m:make-empty-elements"/>
  </xsl:variable>

  <xsl:variable name="pl-no-lb" as="node()*">
    <xsl:apply-templates select="$pl-empty-tags"
			 mode="mp:pl-no-lb"/>
  </xsl:variable>

  <xsl:variable name="pl-no-wrap-lb" as="node()*">
    <xsl:call-template name="t:unwrap">
      <xsl:with-param name="unwrap" select="xs:QName('ghost:br')"/>
      <xsl:with-param name="content" select="$pl-no-lb"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="pl-lines" as="element(ghost:line)*">
    <xsl:call-template name="tp:wrap-lines">
      <xsl:with-param name="nodes" select="$pl-no-wrap-lb"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="pl-callouts" as="element(ghost:line)*">
    <xsl:apply-templates select="$pl-lines" mode="mp:pl-callouts">
      <xsl:with-param name="areas" select="$areas"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="pl-removed-lines" as="node()*">
    <xsl:apply-templates select="$pl-callouts"
			 mode="mp:pl-restore-lines">
      <xsl:with-param name="everyNth" select="$everyNth"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="separator" select="$separator"/>
      <xsl:with-param name="padchar" select="$padchar"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:copy-of select="db:areaspec"/>
    <db:programlisting>
      <xsl:copy-of select="db:programlisting/@*"/>
      <xsl:apply-templates select="$pl-removed-lines"
			   mode="mp:pl-cleanup"/>
    </db:programlisting>
    <xsl:copy-of select="db:calloutlist"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="db:programlisting|db:screen|db:synopsis
                     |db:literallayout|db:address"
	      mode="m:verbatim-phase-1">

  <xsl:variable name="everyNth"  select="f:lineNumbering(.,'everyNth')"/>
  <xsl:variable name="width"     select="f:lineNumbering(.,'width')"/>
  <xsl:variable name="padchar"   select="f:lineNumbering(.,'padchar')"/>
  <xsl:variable name="separator" select="f:lineNumbering(.,'separator')"/>
  <xsl:variable name="minlines"  select="f:lineNumbering(.,'minlines')"/>

  <xsl:variable name="expanded-text" as="node()*">
    <xsl:for-each select="node()">
      <xsl:choose>
	<xsl:when test="self::db:inlinemediaobject
			and db:textobject/db:textdata">
	  <xsl:apply-templates select="."/>
	</xsl:when>
	<xsl:when test="self::db:textobject and db:textdata">
	  <xsl:apply-templates select="."/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="pl-empty-tags" as="node()*">
    <xsl:apply-templates select="$expanded-text" mode="m:make-empty-elements"/>
  </xsl:variable>

  <!--
  <xsl:message>
    <EMPTY>
      <xsl:copy-of select="$pl-empty-tags"/>
    </EMPTY>
  </xsl:message>
  -->

  <xsl:variable name="pl-no-lb" as="node()*">
    <xsl:apply-templates select="$pl-empty-tags"
			 mode="mp:pl-no-lb"/>
  </xsl:variable>

  <!--
  <xsl:message>
    <NOLB>
      <xsl:copy-of select="$pl-no-lb"/>
    </NOLB>
  </xsl:message>
  -->
  
  <xsl:variable name="pl-no-wrap-lb" as="node()*">
    <xsl:call-template name="t:unwrap">
      <xsl:with-param name="unwrap" select="xs:QName('ghost:br')"/>
      <xsl:with-param name="content" select="$pl-no-lb"/>
    </xsl:call-template>
  </xsl:variable>

  <!--
  <xsl:message>
    <NOWRAPLB>
      <xsl:copy-of select="$pl-no-wrap-lb"/>
    </NOWRAPLB>
  </xsl:message>
  -->

  <xsl:variable name="pl-lines" as="element(ghost:line)*">
    <xsl:call-template name="tp:wrap-lines">
      <xsl:with-param name="nodes" select="$pl-no-wrap-lb"/>
    </xsl:call-template>
  </xsl:variable>

  <!--
  <xsl:message>
    <LINES>
      <xsl:copy-of select="$pl-lines"/>
    </LINES>
  </xsl:message>
  -->

  <xsl:variable name="pl-removed-lines" as="node()*">
    <xsl:choose>
      <xsl:when test="$everyNth &gt; 0
	              and count($pl-lines) &gt;= $minlines">
	<xsl:apply-templates select="$pl-lines"
			     mode="mp:pl-restore-lines">
	  <xsl:with-param name="everyNth" select="$everyNth"/>
	  <xsl:with-param name="width" select="$width"/>
	  <xsl:with-param name="separator" select="$separator"/>
	  <xsl:with-param name="padchar" select="$padchar"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$pl-lines"
			     mode="mp:pl-restore-lines">
	  <xsl:with-param name="everyNth" select="0"/>
	  <xsl:with-param name="width" select="$width"/>
	  <xsl:with-param name="separator" select="$separator"/>
	  <xsl:with-param name="padchar" select="$padchar"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!--
  <xsl:message>
    <REMOVEDLINES>
      <xsl:copy-of select="$pl-removed-lines"/>
    </REMOVEDLINES>
  </xsl:message>
  -->

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="$pl-removed-lines"
			 mode="mp:pl-cleanup"/>
  </xsl:copy>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:footnote[@ghost:copy]" mode="mp:pl-cleanup">
  <!-- special case: when footnotes are copied (in a verbatim environment,
       because they contain content that contains a line break), suppress
       all the copies so they don't generate spurious footnote numbers -->
</xsl:template>

<xsl:template match="*" mode="mp:pl-cleanup">
  <xsl:variable name="id" select="@xml:id"/>

  <xsl:copy>
    <xsl:copy-of select="@*[name(.) != 'xml:id'
      and namespace-uri(.) != 'http://docbook.org/ns/docbook/ephemeral']"/>
    <xsl:if test="@xml:id and not(preceding::*[@xml:id = $id])">
      <xsl:attribute name="xml:id" select="$id"/>
    </xsl:if>

    <xsl:apply-templates mode="mp:pl-cleanup"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="mp:pl-cleanup">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="ghost:line" mode="mp:pl-restore-lines">
  <xsl:param name="everyNth" required="yes"/>
  <xsl:param name="width" required="yes"/>
  <xsl:param name="padchar" required="yes"/>
  <xsl:param name="separator" required="yes"/>

  <xsl:variable name="linenumber" select="position()"/>

  <xsl:if test="$everyNth &gt; 0">
    <xsl:choose>
      <xsl:when test="$linenumber = 1
		      or $linenumber mod $everyNth = 0">
	<xsl:variable name="numwidth"
		      select="string-length(string($linenumber))"/>

	<ghost:linenumber>
	  <xsl:if test="$numwidth &lt; $width">
	    <xsl:value-of select="f:pad(xs:integer($width - $numwidth), $padchar)"/>
	  </xsl:if>
	  <xsl:value-of select="$linenumber"/>
	</ghost:linenumber>
	<ghost:linenumber-separator>
	  <xsl:value-of select="$separator"/>
	</ghost:linenumber-separator>
      </xsl:when>
      <xsl:otherwise>
	<ghost:linenumber>
	  <xsl:value-of select="f:pad($width, $padchar)"/>
	</ghost:linenumber>
	<ghost:linenumber-separator>
	  <xsl:value-of select="$separator"/>
	</ghost:linenumber-separator>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="ghost:end">
      <xsl:call-template name="t:restore-content">
	<xsl:with-param name="nodes" select="node()"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="node()"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="t:restore-content" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Restores content to empty elements.</refpurpose>

<refdescription>
<para>This template reverses the flattening process performed by
the <code>m:make-empty-elements</code> mode. It replaces pairs of
empty elements and their corresponding <tag>ghost:end</tag>s with 
an element that has content.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>nodes</term>
<listitem>
<para>The sequence of nodes containing empty elements.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The nodes with content restored.</para>
</refreturn>
</doc:template>

<xsl:template name="t:restore-content">
  <xsl:param name="nodes" select="node()"/>

  <!--
  <xsl:message>
    <XXX>
      <xsl:copy-of select="$nodes"/>
    </XXX>
  </xsl:message>
  -->

  <xsl:choose>
    <xsl:when test="not($nodes)"/>
    <xsl:when test="$nodes[1] instance of element()
                    and $nodes[1]/@ghost:id">
      <xsl:variable name="id" select="$nodes[1]/@ghost:id"/>
      <xsl:variable name="end" select="$nodes[self::ghost:end[@idref=$id]][1]"/>

      <!--
      <xsl:message>
	<xsl:text>Restore </xsl:text>
	<xsl:value-of select="$id"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="count($end)"/>
      </xsl:message>
      -->

      <xsl:variable name="endpos"
		    select="f:find-node-in-sequence($nodes, $end, 2)"/>

      <xsl:element name="{name($nodes[1])}"
		   namespace="{namespace-uri($nodes[1])}">
	<xsl:copy-of select="$nodes[1]/@*"/>
	<xsl:call-template name="t:restore-content">
	  <xsl:with-param name="nodes"
			  select="subsequence($nodes, 2, $endpos - 2)"/>
	</xsl:call-template>
      </xsl:element>
      <xsl:call-template name="t:restore-content">
	<xsl:with-param name="nodes"
			select="subsequence($nodes, $endpos+1)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$nodes[1]"/>
      <xsl:call-template name="t:restore-content">
	<xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="ghost:line" mode="mp:pl-callouts">
  <xsl:param name="areas" as="element()*"/>
  <xsl:param name="linenumber" select="position()"/>

  <xsl:choose>
    <xsl:when test="$areas[@ghost:line = $linenumber]">
      <xsl:call-template name="tp:addcallouts">
	<xsl:with-param name="areas" select="$areas[@ghost:line = $linenumber]"/>
	<xsl:with-param name="line" select="."/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tp:addcallouts">
  <xsl:param name="areas" as="element(db:area)*"/>
  <xsl:param name="line" as="element(ghost:line)"/>

  <xsl:variable name="newline" as="element(ghost:line)">
    <ghost:line>
      <xsl:call-template name="tp:addcallout">
	<xsl:with-param name="area" select="$areas[1]"/>
	<xsl:with-param name="nodes" select="$line/node()"/>
      </xsl:call-template>
    </ghost:line>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="count($areas) = 1">
      <xsl:copy-of select="$newline"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="tp:addcallouts">
	<xsl:with-param name="areas" select="$areas[position() &gt; 1]"/>
	<xsl:with-param name="line" select="$newline"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tp:addcallout">
  <xsl:param name="area" as="element(db:area)"/>
  <xsl:param name="nodes" as="node()*"/>
  <xsl:param name="pos" as="xs:integer" select="1"/>
  
  <xsl:choose>
    <xsl:when test="not($nodes)">
      <xsl:if test="$pos &lt; $area/@ghost:col">
	<xsl:value-of select="f:pad(xs:integer($area/@ghost:col) - $pos, ' ')"/>
	<xsl:apply-templates select="$area" mode="mp:insert-callout"/>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$nodes[1] instance of text()">
      <xsl:choose>
	<xsl:when test="$pos = $area/@ghost:col">
	  <xsl:apply-templates select="$area" mode="mp:insert-callout"/>
	  <xsl:copy-of select="$nodes"/>
	</xsl:when>
	<xsl:when test="string-length($nodes[1]) = 1">
	  <xsl:copy-of select="$nodes[1]"/>
	  <xsl:call-template name="tp:addcallout">
	    <xsl:with-param name="area" select="$area"/>
	    <xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
	    <xsl:with-param name="pos" select="$pos+1"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="substring($nodes[1], 1, 1)"/>
	  <xsl:variable name="rest" as="text()">
	    <xsl:value-of select="substring($nodes[1], 2)"/>
	  </xsl:variable>
	  <xsl:call-template name="tp:addcallout">
	    <xsl:with-param name="area" select="$area"/>
	    <xsl:with-param name="nodes"
			    select="($rest, $nodes[position() &gt; 1])"/>
	    <xsl:with-param name="pos" select="$pos+1"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$nodes[1]"/>
      <xsl:call-template name="tp:addcallout">
	<xsl:with-param name="area" select="$area"/>
	<xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
	<xsl:with-param name="pos" select="$pos"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:area" mode="mp:insert-callout">
  <ghost:co number="{@ghost:number}" xml:id="{@xml:id}"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="tp:wrap-lines">
  <xsl:param name="nodes" as="node()*" required="yes"/>

  <xsl:variable name="br" as="element()">
    <ghost:br/>
  </xsl:variable>

  <xsl:variable name="wrapnodes" as="node()*">
    <xsl:choose>
      <xsl:when test="$verbatim.trim.blank.lines = 0">
	<xsl:choose>
	  <xsl:when test="$nodes[last()][self::ghost:br]">
	    <!-- because group-by will not form a group after the last one -->
	    <xsl:sequence select="($nodes, $br)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:sequence select="$nodes"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:sequence select="fp:trim-trailing-br($nodes)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:for-each-group select="$wrapnodes" group-ending-with="ghost:br">
    <ghost:line>
      <xsl:for-each select="current-group()">
	<xsl:if test="not(self::ghost:br)">
	  <xsl:copy-of select="."/>
	</xsl:if>
      </xsl:for-each>
    </ghost:line>
  </xsl:for-each-group>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="fp:trim-trailing-br" as="node()*">
  <xsl:param name="nodes" as="node()*"/>

  <xsl:choose>
    <xsl:when test="$nodes[last()][self::ghost:br]">
      <xsl:sequence select="fp:trim-trailing-br($nodes[position()&lt;last()])"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$nodes"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:template name="t:unwrap" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Unwraps an element with a particular name</refpurpose>

<refdescription>
<para>This template takes a sequence of nodes. It traverses that sequence
making sure that any element with the specified name occurs at the top-most
level of the sequence: it closes all open elements that the named element
is nested within, outputs the named element, then reopens all the elements
that it had been nested within.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>unwrap</term>
<listitem>
<para>The name of the element to unwrap.</para>
</listitem>
</varlistentry>
<varlistentry><term>content</term>
<listitem>
<para>The sequence of nodes.</para>
</listitem>
</varlistentry>
<varlistentry role="private"><term>stack</term>
<listitem>
<para>The stack of currently open elements.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The original content sequence modified so that all elements named
<parameter>unwrap</parameter> are at the top level.</para>
</refreturn>
</doc:template>

<xsl:template name="t:unwrap">
  <xsl:param name="unwrap" as="xs:QName"/>
  <xsl:param name="content" as="node()*"/>
  <xsl:param name="stack" as="element()*" select="()"/>

  <!--
  <xsl:if test="$content">
    <xsl:message>
      <xsl:text>UNWRAP[1]=</xsl:text>
      <xsl:value-of select="name($content[1])"/>; <xsl:value-of select="$content[1]/@ghost:id"/>
    </xsl:message>
  </xsl:if>

  <xsl:call-template name="tp:show-stack">
    <xsl:with-param name="stack" select="$stack"/>
  </xsl:call-template>
  -->

  <xsl:choose>
    <xsl:when test="not($content)"/>
    <xsl:when test="$content[1] instance of element()
                    and node-name($content[1]) = $unwrap">
      <xsl:call-template name="tp:close-stack">
	<xsl:with-param name="stack" select="$stack"/>
      </xsl:call-template>
      <xsl:copy-of select="$content[1]"/>
      <xsl:call-template name="tp:open-stack">
	<xsl:with-param name="stack" select="$stack"/>
      </xsl:call-template>
      <xsl:call-template name="t:unwrap">
	<xsl:with-param name="unwrap" select="$unwrap"/>
	<xsl:with-param name="content" select="$content[position() &gt; 1]"/>
	<xsl:with-param name="stack" select="$stack"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$content[1][self::ghost:end]">
      <xsl:copy-of select="$content[1]"/>
      <xsl:call-template name="t:unwrap">
	<xsl:with-param name="unwrap" select="$unwrap"/>
	<xsl:with-param name="content" select="$content[position() &gt; 1]"/>
	<xsl:with-param name="stack" select="$stack[position() &lt; last()]"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$content[1] instance of element()">
      <xsl:copy-of select="$content[1]"/>
      <xsl:call-template name="t:unwrap">
	<xsl:with-param name="unwrap" select="$unwrap"/>
	<xsl:with-param name="content" select="$content[position() &gt; 1]"/>
	<xsl:with-param name="stack" select="($stack, $content[1])"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content[1]"/>
      <xsl:call-template name="t:unwrap">
	<xsl:with-param name="unwrap" select="$unwrap"/>
	<xsl:with-param name="content" select="$content[position() &gt; 1]"/>
	<xsl:with-param name="stack" select="$stack"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tp:close-stack">
  <xsl:param name="stack" as="element()*" select="()"/>

  <xsl:if test="$stack">
    <ghost:end idref="{$stack[last()]/@ghost:id}"/>
    <!--
    <xsl:message>
      <xsl:text>close: </xsl:text>
      <xsl:value-of select="$stack[last()]/@ghost:id"/>
    </xsl:message>
    -->
    <xsl:call-template name="tp:close-stack">
      <xsl:with-param name="stack" select="$stack[position() &lt; last()]"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="tp:open-stack">
  <xsl:param name="stack" as="element()*" select="()"/>

  <xsl:if test="$stack">
    <xsl:apply-templates select="$stack[1]" mode="mp:stack-copy"/>
    <xsl:call-template name="tp:open-stack">
      <xsl:with-param name="stack" select="$stack[position() &gt; 1]"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="mp:stack-copy">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="ghost:copy" select="'yes'"/>
  </xsl:copy>
</xsl:template>

<xsl:template name="tp:show-stack">
  <xsl:param name="stack" as="element()*" select="()"/>

  <xsl:message>
    <xsl:text>STACK[</xsl:text>
    <xsl:value-of select="count($stack)"/>
    <xsl:text>]</xsl:text>
  </xsl:message>

  <xsl:for-each select="$stack">
    <xsl:message>
      <xsl:text>...</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="@ghost:id"/>
    </xsl:message>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="mp:pl-no-lb">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="mp:pl-no-lb"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="text()"
	      mode="mp:pl-no-lb">
  <xsl:analyze-string select="." regex="\n">
    <xsl:matching-substring>
      <ghost:br/>
    </xsl:matching-substring>
    <xsl:non-matching-substring>
      <xsl:value-of select="."/>
    </xsl:non-matching-substring>
  </xsl:analyze-string>
</xsl:template>

<xsl:template match="comment()|processing-instruction()"
	      mode="mp:pl-no-lb">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:make-empty-elements" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Make all elements empty</refpurpose>

<refdescription>
<para>This mode is used to completely flatten all nesting in a tree.
Every start tag is replaced with an empty tag that has a
<tag class="attribute">ghost:id</tag> attribute. Every end tag is
replaced with an empty <tag>ghost:end</tag> element that has an 
<tag class="attribute">idref</tag> attribute pointing to the
appropriate <tag class="attribute">ghost:id</tag>.</para>

<para>To reverse the process, see
<function role="named-template">t:restore-content</function>.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:footnote" mode="m:make-empty-elements">
  <xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:if test="not(@xml:id)">
      <xsl:attribute name="xml:id" select="f:node-id(.)"/>
    </xsl:if>
    <xsl:attribute name="ghost:id" select="generate-id()"/>
  </xsl:element>
  <xsl:apply-templates mode="m:make-empty-elements"/>
  <ghost:end idref="{generate-id()}"/>
</xsl:template>

<xsl:template match="*" mode="m:make-empty-elements">
  <xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="ghost:id" select="generate-id()"/>
  </xsl:element>
  <xsl:apply-templates mode="m:make-empty-elements"/>
  <ghost:end idref="{generate-id()}"/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="m:make-empty-elements">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:areaspec|db:areaset">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:areaspec/db:area">
  <db:area>
    <xsl:copy-of select="@*[name(.) != 'coords']"/>
    <xsl:if test="(not(@units)
		   or @units='linecolumn'
		   or @units='linecolumnpair')">
      <xsl:choose>
	<xsl:when test="not(contains(normalize-space(@coords), ' '))">
	  <xsl:attribute name="ghost:line" select="normalize-space(@coords)"/>
	  <xsl:attribute name="ghost:col" select="$callout.defaultcolumn"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="toks"
			select="tokenize(normalize-space(@coords), ' ')"/>
	  <xsl:attribute name="ghost:line" select="$toks[1]"/>
	  <xsl:attribute name="ghost:col" select="$toks[2]"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:attribute name="ghost:number"
		   select="count(preceding-sibling::db:area
                                 |preceding-sibling::db:areaset)+1"/>
  </db:area>
</xsl:template>

<xsl:template match="db:areaset/db:area">
  <db:area>
    <xsl:copy-of select="@*[name(.) != 'coords']"/>
    <xsl:attribute name="xml:id" select="parent::db:areaset/@xml:id"/>
    <xsl:if test="(not(@units)
		   or @units='linecolumn'
		   or @units='linecolumnpair')">
      <xsl:choose>
	<xsl:when test="not(contains(normalize-space(@coords), ' '))">
	  <xsl:attribute name="ghost:line" select="normalize-space(@coords)"/>
	  <xsl:attribute name="ghost:col" select="$callout.defaultcolumn"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="toks"
			select="tokenize(normalize-space(@coords), ' ')"/>
	  <xsl:attribute name="ghost:line" select="$toks[1]"/>
	  <xsl:attribute name="ghost:col" select="$toks[2]"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:attribute name="ghost:number"
		   select="count(parent::db:areaset/preceding-sibling::db:area
                             |parent::db:areaset/preceding-sibling::db:areaset)
			   + 1"/>
  </db:area>
</xsl:template>

</xsl:stylesheet>
