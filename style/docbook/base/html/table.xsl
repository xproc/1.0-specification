<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
                xmlns:u="http://nwalsh.com/xsl/unittests#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="db doc f ghost h m t u xs"
                version="2.0">

<xsl:include href="../common/table.xsl"/>

<xsl:template match="db:table">
  <xsl:call-template name="t:formal-object">
    <xsl:with-param name="placement"
		    select="$formal.title.placement[self::db:table]/@placement"/>
    <xsl:with-param name="class" select="local-name(.)"/>
    <xsl:with-param name="longdesc" select="db:textobject[not(db:phrase)]"/>
    <xsl:with-param name="object" as="element()">
      <div class="{local-name(.)}">
	<xsl:call-template name="id"/>
	<xsl:call-template name="class"/>

	<xsl:choose>
	  <xsl:when test="db:tgroup|db:mediaobject">
	    <xsl:apply-templates select="db:tgroup|db:mediaobject"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="." mode="m:html"/>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="t:table-longdesc"/>
</xsl:template>

<xsl:template match="db:informaltable">
  <xsl:call-template name="t:formal-object">
    <xsl:with-param name="class" select="local-name(.)"/>
    <xsl:with-param name="longdesc" select="db:textobject[not(db:phrase)]"/>
    <xsl:with-param name="object" as="element()">
      <div class="{local-name(.)}">
	<xsl:call-template name="id"/>
	<xsl:call-template name="class"/>

	<xsl:choose>
	  <xsl:when test="db:tgroup|db:mediaobject">
	    <xsl:apply-templates select="db:tgroup|db:mediaobject"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="." mode="m:html">
	    </xsl:apply-templates>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="t:table-longdesc"/>
</xsl:template>

<xsl:template name="t:table-longdesc">
  <xsl:variable name="longdesc.uri" select="f:longdesc-uri(.)"/>

  <xsl:if test="$html.longdesc != 0 and $html.longdesc.link != 0
                and db:textobject[not(db:phrase)]">
    <xsl:call-template name="t:write-longdesc">
      <xsl:with-param name="mediaobject" select="."/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->
<!-- CALS tables -->

<xsl:template match="db:tgroup">
  <xsl:if test="not(@cols) or @cols = ''">
    <xsl:message terminate="yes">
      <xsl:text>Error: CALS tables must specify the number of columns.</xsl:text>
    </xsl:message>
  </xsl:if>

  <!-- Make sure we copy the tgroup container so that the tgroup -->
  <!-- template has access to the table/informaltable attributes -->
  <xsl:variable name="phase1">
    <xsl:element name="{local-name(..)}"
		 namespace="{namespace-uri(..)}">
      <xsl:copy-of select="../@*"/>
      <xsl:apply-templates select="." mode="m:cals-phase-1"/>
    </xsl:element>
  </xsl:variable>

  <!--
  <xsl:message>
    <XXX>
      <xsl:copy-of select="$phase1"/>
    </XXX>
  </xsl:message>
  -->

  <xsl:apply-templates select="$phase1/*/db:tgroup" mode="m:cals"/>
</xsl:template>

<xsl:template match="db:tgroup" name="db:tgroup" mode="m:cals">
  <xsl:variable name="summary"
		select="f:pi(processing-instruction('dbhtml'),'table-summary')"/>

  <xsl:variable name="cellspacing"
		select="f:pi(processing-instruction('dbhtml'),'cellspacing')"/>

  <xsl:variable name="cellpadding"
		select="f:pi(processing-instruction('dbhtml'),'cellpadding')"/>

  <table border="0">
    <xsl:choose>
      <!-- If there's a textobject/phrase for the table summary, use it -->
      <xsl:when test="../db:textobject/db:phrase">
	<xsl:attribute name="summary"
		       select="xs:string(../db:textobject/db:phrase)"/>
      </xsl:when>

      <!-- If there's a <?dbhtml table-summary="foo"?> PI, use it for
           the HTML table summary attribute -->
      <xsl:when test="$summary != ''">
        <xsl:attribute name="summary" select="$summary"/>
      </xsl:when>

      <!-- Otherwise, if there's a title, use that -->
      <xsl:when test="../db:info/db:title">
        <xsl:attribute name="summary" select="xs:string(../db:info/db:title)"/>
      </xsl:when>

      <!-- Otherwise, forget the whole idea -->
      <xsl:otherwise><!-- nevermind --></xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$cellspacing != '' or $table.html.cellspacing != ''">
      <xsl:attribute name="cellspacing"
		     select="if ($cellspacing != '')
	                     then $cellspacing
			     else $table.html.cellspacing"/>
    </xsl:if>

    <xsl:if test="$cellpadding != '' or $table.html.cellpadding != ''">
      <xsl:attribute name="cellpadding"
		     select="if ($cellpadding != '')
	                     then $cellpadding
			     else $table.html.cellpadding"/>
    </xsl:if>

    <xsl:if test="../@pgwide=1 or self::db:entrytbl">
      <xsl:attribute name="width" select="'100%'"/>
    </xsl:if>

    <xsl:variable name="frame"
		  select="if (../@frame)
                          then ../@frame
			  else $table.frame.default"/>

    <xsl:choose>
      <xsl:when test="$frame='all'">
	<xsl:attribute name="style">
	  <xsl:text>border-collapse: collapse;</xsl:text>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'top'"/>
	  </xsl:call-template>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'bottom'"/>
	  </xsl:call-template>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'left'"/>
	  </xsl:call-template>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'right'"/>
	  </xsl:call-template>
	</xsl:attribute>
      </xsl:when>
      <xsl:when test="$frame='topbot'">
	<xsl:attribute name="style">
	  <xsl:text>border-collapse: collapse;</xsl:text>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'top'"/>
	  </xsl:call-template>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'bottom'"/>
	  </xsl:call-template>
	</xsl:attribute>
      </xsl:when>
      <xsl:when test="$frame='top'">
	<xsl:attribute name="style">
	  <xsl:text>border-collapse: collapse;</xsl:text>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'top'"/>
	  </xsl:call-template>
	</xsl:attribute>
      </xsl:when>
      <xsl:when test="$frame='bottom'">
	<xsl:attribute name="style">
	  <xsl:text>border-collapse: collapse;</xsl:text>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'bottom'"/>
	  </xsl:call-template>
	</xsl:attribute>
      </xsl:when>
      <xsl:when test="$frame='sides'">
	<xsl:attribute name="style">
	  <xsl:text>border-collapse: collapse;</xsl:text>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'left'"/>
	  </xsl:call-template>
	  <xsl:call-template name="border">
	    <xsl:with-param name="side" select="'right'"/>
	  </xsl:call-template>
	</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
	<xsl:attribute name="style">
	  <xsl:text>border-collapse: collapse;</xsl:text>
	</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:variable name="colgroup" as="element()">
      <colgroup>
	<xsl:call-template name="generate-colgroup">
          <xsl:with-param name="cols" select="@cols"/>
	</xsl:call-template>
      </colgroup>
    </xsl:variable>

    <xsl:variable name="explicit.table.width"
		  select="f:pi(processing-instruction('dbhtml'),'table-width')"/>

    <xsl:variable name="table.width">
      <xsl:choose>
	<xsl:when test="$explicit.table.width != ''">
          <xsl:value-of select="$explicit.table.width"/>
        </xsl:when>
	<xsl:when test="$table.width.default = ''">
          <xsl:text>100%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$table.width.default"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$table.width.default != ''
                  or $explicit.table.width != ''">
      <xsl:attribute name="width"
		     select="f:convert-length($table.width)"/>
    </xsl:if>

    <xsl:call-template name="adjust-column-widths">
      <xsl:with-param name="table-width" select="$table.width"/>
      <xsl:with-param name="colgroup" select="$colgroup"/>
      <xsl:with-param name="abspixels" select="1"/>
    </xsl:call-template>

    <xsl:apply-templates select="db:thead" mode="m:cals"/>
    <xsl:apply-templates select="db:tfoot" mode="m:cals"/>
    <xsl:apply-templates select="db:tbody" mode="m:cals"/>

    <xsl:if test=".//db:footnote">
      <tbody class="footnotes">
        <tr>
	  <td colspan="{@cols}">
	    <xsl:apply-templates select=".//db:footnote"
				 mode="m:table-footnote-mode"/>
	  </td>
	</tr>
      </tbody>
    </xsl:if>
  </table>
</xsl:template>

<xsl:template match="db:entrytbl" mode="m:cals">
  <xsl:variable name="cellgi">
    <xsl:choose>
      <xsl:when test="ancestor::db:thead">th</xsl:when>
      <xsl:when test="ancestor::db:tfoot">th</xsl:when>
      <xsl:when test="ancestor::db:tgroup/parent::*/@rowheader='firstcol'
		      and ghost:colnum=1">th</xsl:when>
      <xsl:otherwise>td</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="{$cellgi}">
    <xsl:call-template name="db:tgroup"/>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->

<doc:mode name="m:cals" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for processing normalized CALS tables</refpurpose>

<refdescription>
<para>This mode is used to format normalized CALS tables.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:thead|db:tbody|db:tfoot" mode="m:cals">
  <xsl:element name="{local-name(.)}"
	       namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@align|@valign|@char|@charoff"/>
    <xsl:apply-templates mode="m:cals"/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:colspec|db:spanspec" mode="m:cals">
  <!-- nop -->
</xsl:template>

<xsl:template match="db:row" mode="m:cals">
  <xsl:variable name="row-height"
		select="f:pi(processing-instruction('dbhtml'),'row-height')"/>

  <xsl:variable name="bgcolor"
		select="f:pi(processing-instruction('dbhtml'),'bgcolor')"/>

  <xsl:variable name="class"
		select="f:pi(processing-instruction('dbhtml'),'class')"/>

  <tr>
    <xsl:call-template name="id"/>
    <xsl:call-template name="tr-attributes">
      <xsl:with-param name="rownum">
        <xsl:number count="db:row"/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:if test="$row-height != ''">
      <xsl:attribute name="height" select="$row-height"/>
    </xsl:if>

    <xsl:if test="$bgcolor != ''">
      <xsl:attribute name="bgcolor" select="$bgcolor"/>
    </xsl:if>

    <xsl:if test="$class != ''">
      <xsl:attribute name="class" select="$class"/>
    </xsl:if>

    <xsl:if test="@rowsep = 1 and following-sibling::db:row">
      <xsl:attribute name="style">
	<xsl:call-template name="border">
	  <xsl:with-param name="side" select="'bottom'"/>
	</xsl:call-template>
      </xsl:attribute>
    </xsl:if>

    <xsl:copy-of select="@align|@valign|@char|@charoff"/>

    <xsl:apply-templates mode="m:cals"/>
  </tr>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="tr-attributes" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Extension point for table row attributes</refpurpose>

<refdescription>
<para>This template can be redefined by a customization layer to add
attributes to table rows. For example, this template could be used
to add shading
to alternate rows of the table:</para>

<programlisting><![CDATA[<xsl:template name="tr-attributes">
  <xsl:param name="row" select="."/>
  <xsl:param name="rownum" required="yes"/>

  <xsl:if test="$rownum mod 2 = 0">
    <xsl:attribute name="class">oddrow</xsl:attribute>
  </xsl:if>
</xsl:template>]]></programlisting>

<para>The default version of this template does nothing.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>row</term>
<listitem>
<para>The table row element, defaults to the current context node.</para>
</listitem>
</varlistentry>
<varlistentry role="required"><term>colnum</term>
<listitem>
<para>The ordinal number of the row within its parent.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>A sequence of zero or more attribute nodes.</para>
</refreturn>
</doc:template>

<xsl:template name="tr-attributes">
  <xsl:param name="row" select="."/>
  <xsl:param name="rownum" required="yes"/>
  <!-- nop -->
</xsl:template>

<xsl:template match="db:entry" mode="m:cals">
  <xsl:variable name="cellgi">
    <xsl:choose>
      <xsl:when test="ancestor::db:thead">th</xsl:when>
      <xsl:when test="ancestor::db:tfoot">th</xsl:when>
      <xsl:when test="ancestor::db:tgroup/parent::*/@rowheader='firstcol'
		      and ghost:colnum=1">th</xsl:when>
      <xsl:otherwise>td</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="empty.cell" select="not(node())"/>

  <xsl:variable name="bgcolor"
		select="f:pi(processing-instruction('dbhtml'),'bgcolor')"/>

  <xsl:element name="{$cellgi}">
    <xsl:call-template name="id"/>
    <xsl:call-template name="class"/>
    
    <xsl:if test="$bgcolor != ''">
      <xsl:attribute name="bgcolor" select="$bgcolor"/>
    </xsl:if>

    <!-- FIXME: handle @revisionflag -->

    <xsl:attribute name="style">
      <xsl:if test="@colsep &gt; 0 and following-sibling::*">
	<xsl:call-template name="border">
	  <xsl:with-param name="side" select="'right'"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@rowsep &gt; 0 and parent::*/following-sibling::db:row">
	<xsl:call-template name="border">
	  <xsl:with-param name="side" select="'bottom'"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:attribute>

    <xsl:if test="@ghost:morerows &gt; 0">
      <xsl:attribute name="rowspan" select="@ghost:morerows + 1"/>
    </xsl:if>

    <xsl:if test="@ghost:width &gt; 1">
      <xsl:attribute name="colspan" select="@ghost:width"/>
    </xsl:if>

    <xsl:copy-of select="@align|@valign|@char|@charoff"/>

    <xsl:choose>
      <xsl:when test="$empty.cell">
	<xsl:text>&#160;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="ghost:empty" mode="m:cals">
  <!-- FIXME: what about attributes on empty cells? -->
  <td>
    <xsl:attribute name="style">
      <xsl:if test="@colsep &gt; 0 and following-sibling::*">
	<xsl:call-template name="border">
	  <xsl:with-param name="side" select="'right'"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@rowsep &gt; 0 and parent::*/following-sibling::db:row">
	<xsl:call-template name="border">
	  <xsl:with-param name="side" select="'bottom'"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:attribute>
    <xsl:text>&#160;</xsl:text>
  </td>
</xsl:template>

<xsl:template match="ghost:overlapped" mode="m:cals">
  <!-- nop -->
</xsl:template>

<xsl:template match="*" mode="m:cals">
  <xsl:message terminate="yes">
    <xsl:text>Error: attempt to process </xsl:text>
    <xsl:value-of select="name(.)"/>
    <xsl:text> in mode m:cals.</xsl:text>
  </xsl:message>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="m:cals">
  <xsl:copy/>
</xsl:template>

<!-- ==================================================================== -->

<doc:template name="border" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Generate CSS for table cell borders</refpurpose>

<refdescription>
<para>This template generates the inline CSS necessary to add borders
to a table cell.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry role="required"><term>side</term>
<listitem>
<para>The side of the table on which to apply the border: must be one of
“top”, “bottom”, “left”, or “right”.</para>
</listitem>
</varlistentry>
<varlistentry><term>padding</term>
<listitem>
<para>The desired padding. Defaults to zero.</para>
</listitem>
</varlistentry>
<varlistentry><term>style</term>
<listitem>
<para>The desired style.
Defaults to <parameter>table.cell.border.style</parameter>.</para>
</listitem>
</varlistentry>
<varlistentry><term>color</term>
<listitem>
<para>The desired color.
Defaults to <parameter>table.cell.border.color</parameter>.</para>
</listitem>
</varlistentry>
<varlistentry><term>thickness</term>
<listitem>
<para>The desired thickness.
Defaults to <parameter>table.cell.border.thickness</parameter>.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>A fragment of CSS style suitable for use in a style attribute.</para>
</refreturn>
</doc:template>

<xsl:template name="border">
  <xsl:param name="side" required="yes"/>
  <xsl:param name="padding" select="0"/>
  <xsl:param name="style" select="$table.cell.border.style"/>
  <xsl:param name="color" select="$table.cell.border.color"/>
  <xsl:param name="thickness" select="$table.cell.border.thickness"/>

  <!-- Note: Some browsers (mozilla) require at least a width and style. -->
  <xsl:choose>
    <xsl:when test="($thickness != ''
                     and $style != ''
                     and $color != '')
                    or ($thickness != ''
                        and $style != '')
                    or ($thickness != '')">
      <!-- use the compound property if we can: -->
      <!-- it saves space and probably works more reliably -->
      <xsl:text>border-</xsl:text>
      <xsl:value-of select="$side"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$thickness"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$color"/>
      <xsl:text>; </xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <!-- we need to specify the styles individually -->
      <xsl:if test="$thickness != ''">
        <xsl:text>border-</xsl:text>
        <xsl:value-of select="$side"/>
        <xsl:text>-width: </xsl:text>
        <xsl:value-of select="$thickness"/>
        <xsl:text>; </xsl:text>
      </xsl:if>

      <xsl:if test="$style != ''">
        <xsl:text>border-</xsl:text>
        <xsl:value-of select="$side"/>
        <xsl:text>-style: </xsl:text>
        <xsl:value-of select="$style"/>
        <xsl:text>; </xsl:text>
      </xsl:if>

      <xsl:if test="$color != ''">
        <xsl:text>border-</xsl:text>
        <xsl:value-of select="$side"/>
        <xsl:text>-color: </xsl:text>
        <xsl:value-of select="$color"/>
        <xsl:text>; </xsl:text>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="generate-colgroup" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Generates an HTML <tag>colgroup</tag>.</refpurpose>

<refdescription>
<para>Generates an HTML <tag>colgroup</tag> for the CALS table.
</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry role="required"><term>cols</term>
<listitem>
<para>The number of columns in the table.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>A sequence of one or more <tag>col</tag> elements.</para>
</refreturn>
</doc:template>

<xsl:template name="generate-colgroup">
  <xsl:param name="cols" required="yes"/>
  <xsl:param name="count" select="1"/>

  <xsl:choose>
    <xsl:when test="$count &gt; $cols"></xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="generate-col">
        <xsl:with-param name="countcol" select="$count"/>
      </xsl:call-template>
      <xsl:call-template name="generate-colgroup">
        <xsl:with-param name="cols" select="$cols"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="generate-col" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Generates an HTML <tag>col</tag>.</refpurpose>

<refdescription>
<para>Generates an HTML <tag>col</tag> for a
<tag>colgroup</tag>.
See <function role="named-template">generate-colgroup</function>.
</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry role="required"><term>countcol</term>
<listitem>
<para>The number of the column.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>A <tag>col</tag> element.</para>
</refreturn>
</doc:template>

<xsl:template name="generate-col">
  <xsl:param name="countcol" required="yes"/>
  <xsl:param name="colspecs" select="./db:colspec"/>
  <xsl:param name="count">1</xsl:param>
  <xsl:param name="colnum">1</xsl:param>

  <xsl:choose>
    <xsl:when test="$count &gt; count($colspecs)">
      <col/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="colspec" select="$colspecs[$count=position()]"/>
      <xsl:variable name="colspec.colnum">
	<xsl:choose>
	  <xsl:when test="$colspec/@colnum">
            <xsl:value-of select="$colspec/@colnum"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$colnum"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
	<xsl:when test="$colspec.colnum=$countcol">
	  <col>
	    <xsl:if test="$colspec/@colwidth">
	      <xsl:attribute name="width">
		<xsl:choose>
		  <xsl:when test="normalize-space($colspec/@colwidth) = '*'">
		    <xsl:value-of select="'1*'"/>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="$colspec/@colwidth"/>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	    </xsl:if>

	    <xsl:choose>
	      <xsl:when test="$colspec/@align">
		<xsl:attribute name="align">
		  <xsl:value-of select="$colspec/@align"/>
		</xsl:attribute>
	      </xsl:when>
	      <!-- Suggested by Pavel ZAMPACH <zampach@nemcb.cz> -->
	      <xsl:when test="$colspecs/parent::db:tgroup/@align">
		<xsl:attribute name="align">
                  <xsl:value-of select="$colspecs/parent::tgroup/@align"/>
		</xsl:attribute>
              </xsl:when>
            </xsl:choose>

	    <xsl:if test="$colspec/@char">
              <xsl:attribute name="char">
                <xsl:value-of select="$colspec/@char"/>
              </xsl:attribute>
            </xsl:if>

            <xsl:if test="$colspec/@charoff">
              <xsl:attribute name="charoff">
                <xsl:value-of select="$colspec/@charoff"/>
              </xsl:attribute>
            </xsl:if>
	  </col>
	</xsl:when>
	<xsl:otherwise>
          <xsl:call-template name="generate-col">
            <xsl:with-param name="countcol" select="$countcol"/>
            <xsl:with-param name="colspecs" select="$colspecs"/>
            <xsl:with-param name="count" select="$count+1"/>
            <xsl:with-param name="colnum">
              <xsl:choose>
                <xsl:when test="$colspec/@colnum">
                  <xsl:value-of select="$colspec/@colnum + 1"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$colnum + 1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
           </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->
<!-- HTML tables -->

<doc:mode name="m:html" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for processing HTML tables</refpurpose>

<refdescription>
<para>This mode is used to format HTML tables.</para>
<para>FIXME: don't copy non-HTML attributes if there are any!</para>
</refdescription>
</doc:mode>

<xsl:template match="db:table|db:caption|db:col|db:colgroup
                     |db:thead|db:tfoot|db:tbody|db:tr
		     |db:th|db:td" mode="m:html">
  <xsl:element name="{local-name(.)}"
	       namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:html"/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:informaltable" mode="m:html">
  <table>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:html"/>
  </table>
</xsl:template>

</xsl:stylesheet>
