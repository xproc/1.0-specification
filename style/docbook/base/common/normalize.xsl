<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
                xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:mp="http://docbook.org/xslt/ns/mode/private"
                xmlns:n="http://docbook.org/xslt/ns/normalize"
		xmlns:tp="http://docbook.org/xslt/ns/template/private"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="db doc f fn m mp n xlink xs ghost"
                version="2.0">

<xsl:param name="schemafile" select="''"/>

<!--	   select="'../../docbook/relaxng/dita4db/dita4db.rng'"/> -->

<xsl:param name="schema"
	   select="if ($schemafile = '')
		   then ()
		   else document($schemafile)"/>

<xsl:param name="schema-extensions" as="element()*" select="()"/>

<!-- ============================================================ -->
<!-- normalize content -->

<xsl:variable name="external.glossary">
  <xsl:choose>
    <xsl:when test="$glossary.collection = ''">
      <xsl:value-of select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="document($glossary.collection, .)"
			   mode="m:cleanup"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="external.bibliography">
  <xsl:choose>
    <xsl:when test="$bibliography.collection = ''">
      <xsl:value-of select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="document($bibliography.collection)"
			   mode="m:cleanup"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- ============================================================ -->

<doc:mode name="m:normalize" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for normalizing a DocBook document</refpurpose>

<refdescription>
<para>This mode is used to normalize an input document. Normalization
moves all <tag>title</tag>, <tag>subtitle</tag>, and
<tag>titleabbrev</tag> elements inside <tag>info</tag> wrappers,
creating the wrapper if necessary.</para>
<para>If the element being normalized has a default title (e.g.,
<tag>bibligraphy</tag> and <tag>glossary</tag>), the title is made
explicit during normalization.</para>
<para>External glossaries and bibliographies (not yet!) are also
copied by normalization.</para>
</refdescription>
</doc:mode>

<xsl:template match="/" mode="m:normalize">
  <xsl:apply-templates mode="m:normalize"/>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="n:normalize-movetitle" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Moves titles inside <tag>info</tag></refpurpose>

<refdescription>
<para>This template moves <tag>title</tag>, <tag>subtitle</tag>, and
<tag>titleabbrev</tag> elements inside an <tag>info</tag>.
</para>
</refdescription>

<refreturn>
<para>The transformed node.</para>
</refreturn>
</doc:template>

<xsl:template name="n:normalize-movetitle">
  <xsl:copy>
    <xsl:copy-of select="@*"/>

    <xsl:choose>
      <xsl:when test="db:info">
	<xsl:apply-templates mode="m:normalize"/>
      </xsl:when>
      <xsl:when test="db:title|db:subtitle|db:titleabbrev">
	<xsl:element name="info" namespace="{$docbook-namespace}">
	  <xsl:call-template name="n:normalize-dbinfo">
	    <xsl:with-param name="copynodes"
			    select="db:title|db:subtitle|db:titleabbrev"/>
	  </xsl:call-template>
	</xsl:element>
	<xsl:apply-templates mode="m:normalize"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="m:normalize"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template match="db:title|db:subtitle|db:titleabbrev" mode="m:normalize">
  <xsl:if test="parent::db:info">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="m:normalize"/>
    </xsl:copy>
  </xsl:if>
</xsl:template>

<xsl:template match="db:bibliography" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:bibliomixed|db:biblioentry" mode="m:normalize">
  <xsl:choose>
    <xsl:when test="not(node())"> <!-- totally empty -->
      <xsl:variable name="id" select="(@id|@xml:id)[1]"/>
      <xsl:choose>
	<xsl:when test="not($id)">
	  <xsl:message>
	    <xsl:text>Error: </xsl:text>
	    <xsl:text>empty </xsl:text>
	    <xsl:value-of select="local-name(.)"/>
	    <xsl:text> with no id.</xsl:text>
	  </xsl:message>
	</xsl:when>
	<xsl:when test="$external.bibliography/key('id', $id)">
	  <xsl:apply-templates select="$external.bibliography/key('id', $id)"
			       mode="m:normalize"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message>
	    <xsl:text>Error: </xsl:text>
	    <xsl:text>$bibliography.collection doesn't contain </xsl:text>
	    <xsl:value-of select="$id"/>
	  </xsl:message>
	  <xsl:copy>
	    <xsl:copy-of select="@*"/>
	    <xsl:text>???</xsl:text>
	  </xsl:copy>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="m:normalize"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:glossary" mode="m:normalize">
  <xsl:variable name="glossary">
    <xsl:call-template name="n:normalize-generated-title">
      <xsl:with-param name="title-key" select="local-name(.)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$glossary/db:glossary[@role='auto']">
      <xsl:if test="not($external.glossary)">
	<xsl:message>
	  <xsl:text>Warning: processing automatic glossary </xsl:text>
	  <xsl:text>without an external glossary.</xsl:text>
	</xsl:message>
      </xsl:if>

      <xsl:element name="glossary" namespace="{$docbook-namespace}">
	<xsl:for-each select="$glossary/db:glossary/@*">
	  <xsl:if test="name(.) != 'role'">
	    <xsl:copy-of select="."/>
	  </xsl:if>
	</xsl:for-each>
	<xsl:copy-of select="$glossary/db:glossary/db:info"/>

	<xsl:variable name="seealsos" as="element()*">
	  <xsl:for-each select="$external.glossary//db:glossseealso">
	    <xsl:copy-of select="if (key('id', @otherterm))
				  then key('id', @otherterm)[1]
				  else key('glossterm', string(.))"/>
	  </xsl:for-each>
	</xsl:variable>

	<xsl:variable name="divs"
		      select="$glossary//db:glossary/db:glossdiv"/>

	<xsl:choose>
	  <xsl:when test="$divs and $external.glossary//db:glossdiv">
	    <xsl:apply-templates select="$external.glossary//db:glossdiv"
				 mode="m:copy-external-glossary">
	      <xsl:with-param name="terms"
			      select="//db:glossterm[not(parent::db:glossdef)]
				      |//db:firstterm
				      |$seealsos"/>
	      <xsl:with-param name="divs" select="$divs"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="$external.glossary//db:glossentry"
				 mode="m:copy-external-glossary">
	      <xsl:with-param name="terms"
			      select="//db:glossterm[not(parent::db:glossdef)]
				      |//db:firstterm
				      |$seealsos"/>
	      <xsl:with-param name="divs" select="$divs"/>
	    </xsl:apply-templates>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$glossary"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:index" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:setindex" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:abstract" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:legalnotice" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:note" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:tip" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:caution" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:warning" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:important" mode="m:normalize">
  <xsl:call-template name="n:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="n:normalize-generated-title"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Generate a title, if necessary, and see that its moved into
<tag>info</tag></refpurpose>

<refdescription>
<para>If the context node does not have a title, this template will
generate one. In either case, the title will be placed or moved inside
an <tag>info</tag> which will be created if necessary.
</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>title-key</term>
<listitem>
<para>The key to use for creating the generated-text title if one is
necessary.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The transformed node.</para>
</refreturn>
</doc:template>

<xsl:template name="n:normalize-generated-title">
  <xsl:param name="title-key"/>

  <xsl:choose>
    <xsl:when test="db:title|db:info/db:title">
      <xsl:call-template name="n:normalize-movetitle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>

	<xsl:choose>
	  <xsl:when test="db:info">
	    <xsl:element name="info" namespace="{$docbook-namespace}">
	      <xsl:copy-of select="db:info/@*"/>
	      <xsl:element name="title" namespace="{$docbook-namespace}">
		<xsl:apply-templates select="." mode="n:normalized-title">
		  <xsl:with-param name="title-key" select="$title-key"/>
		</xsl:apply-templates>
	      </xsl:element>
	      <xsl:copy-of select="db:info/preceding-sibling::node()"/>
	      <xsl:copy-of select="db:info/*"/>
	    </xsl:element>
	    <xsl:apply-templates select="db:info//following-sibling::node()"
				 mode="m:normalize"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:variable name="node-tree">
	      <xsl:element name="title" namespace="{$docbook-namespace}">
		<xsl:attribute name="ghost:title" select="'yes'"/>
		<xsl:apply-templates select="." mode="n:normalized-title">
		  <xsl:with-param name="title-key" select="$title-key"/>
		</xsl:apply-templates>
	      </xsl:element>
	    </xsl:variable>

	    <xsl:element name="info" namespace="{$docbook-namespace}">
	      <xsl:call-template name="n:normalize-dbinfo">
		<xsl:with-param name="copynodes" select="$node-tree/*"/>
	      </xsl:call-template>
	    </xsl:element>
	    <xsl:apply-templates mode="m:normalize"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="n:normalized-title">
  <xsl:param name="title-key"/>
  <xsl:call-template name="gentext">
    <xsl:with-param name="key" select="$title-key"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:info" mode="m:normalize">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:call-template name="n:normalize-dbinfo"/>
  </xsl:copy>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="n:normalize-dbinfo"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Copy the specified nodes, normalizing other content
if appropriate</refpurpose>

<refdescription>
<para>The specified nodes are copied. If the context node is an
<tag>info</tag> element, then the rest of its contents are also normalized.
</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>copynodes</term>
<listitem>
<para>The nodes to copy.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The transformed node.</para>
</refreturn>
</doc:template>

<xsl:template name="n:normalize-dbinfo">
  <xsl:param name="copynodes"/>

  <xsl:for-each select="$copynodes">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="m:normalize"/>
    </xsl:copy>
  </xsl:for-each>

  <xsl:if test="self::db:info">
    <xsl:apply-templates mode="m:normalize"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:inlinemediaobject
		     [(parent::db:programlisting
		       or parent::db:screen
		       or parent::db:literallayout
		       or parent::db:address
		       or parent::db:funcsynopsisinfo)
		     and db:imageobject
		     and db:imageobject/db:imagedata[@format='linespecific']]"
	      mode="m:normalize">
  <xsl:variable name="data"
		select="(db:imageobject
			 /db:imagedata[@format='linespecific'])[1]"/>
  <xsl:choose>
    <xsl:when test="$data/@entityref">
      <xsl:value-of select="unparsed-text(unparsed-entity-uri($data/@entityref))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="unparsed-text($data/@fileref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:textobject
		     [parent::db:programlisting
		      or parent::db:screen
		      or parent::db:literallayout
		      or parent::db:address
		      or parent::db:funcsynopsisinfo]"
	      mode="m:normalize">
  <xsl:choose>
    <xsl:when test="db:textdata/@entityref">
      <xsl:value-of select="unparsed-text(unparsed-entity-uri(db:textdata/@entityref))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="unparsed-text(db:textdata/@fileref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="m:normalize"
	      xmlns:r="http://nwalsh.com/xmlns/schema-remap/"
	      xmlns:rng="http://relaxng.org/ns/structure/1.0">

  <xsl:variable name="element" select="local-name(.)"/>
  <xsl:variable name="element-name" select="node-name(.)"/>
  <xsl:variable name="known" select="for $n in $schema-extensions
				     return
				        if (node-name($n) = $element-name)
					then $n
					else ()"/>


  <!-- There are some limitations here with multiple patterns that define
       the same element, with namespaced elements, and with multiple remaps.
       We can come back to them if they ever matter. -->
  <xsl:variable name="remap"
		select="$schema
			//rng:element[@name=$element and r:remap]/r:remap[1]"/>

  <!--
  <xsl:message>
    <xsl:text>normalize </xsl:text>
    <xsl:value-of select="name(.)"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="name($remap/*[1])"/>
    <xsl:text>)</xsl:text>
  </xsl:message>
  -->

  <xsl:choose>
    <xsl:when test="$known">
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="m:normalize"/>
      </xsl:copy>
    </xsl:when>
    <xsl:when test="$remap">
      <xsl:variable name="mapped" as="element()">
	<xsl:choose>
	  <xsl:when test="$remap//r:content">
	    <xsl:apply-templates select="$remap/*" mode="m:remap">
	      <xsl:with-param name="attrs" select="@*"/>
	      <xsl:with-param name="content" select="node()"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:element name="{local-name($remap/*[1])}"
			 namespace="{namespace-uri($remap/*[1])}">
	      <xsl:copy-of select="$remap/*[1]/@*"/>
	      <xsl:copy-of select="@*"/>
	      <xsl:copy-of select="node()"/>
	    </xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:apply-templates select="$mapped" mode="m:normalize"/>
    </xsl:when>
    <xsl:when test="db:title|db:subtitle|db:titleabbrev|db:info/db:title">
      <xsl:call-template name="n:normalize-movetitle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="m:normalize"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="m:normalize">
  <xsl:copy/>
</xsl:template>
  
<!-- ============================================================ -->

<xsl:template match="r:content" mode="m:remap"
	      xmlns:r="http://nwalsh.com/xmlns/schema-remap/">
  <xsl:param name="attrs" select="()"/>
  <xsl:param name="content" select="()"/>
  <xsl:copy-of select="$content"/>
</xsl:template>

<xsl:template match="*" mode="m:remap">
  <xsl:param name="attrs" select="()"/>
  <xsl:param name="content" select="()"/>

  <xsl:element name="{local-name(.)}"
	       namespace="{namespace-uri(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:if test="$attrs">
      <xsl:copy-of select="$attrs"/>
    </xsl:if>
    <xsl:apply-templates mode="m:remap">
      <xsl:with-param name="content" select="$content"/>
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>

<xsl:template match="text()|processing-instruction()|comment()" mode="m:remap">
  <xsl:param name="attrs" select="()"/>
  <xsl:param name="content" select="()"/>
  <xsl:copy/>
</xsl:template>


<!-- ============================================================ -->
<!-- fix namespace -->

<doc:mode name="m:fixnamespace" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for fixing the namespace of DocBook documents</refpurpose>

<refdescription>
<para>This mode is used to fix the namespace of an input document.
All elements that are not in any namespace are moved into the
DocBook namespace. (See <parameter>docbook-namespace</parameter>).</para>
</refdescription>
</doc:mode>

<xsl:template match="/" mode="m:fixnamespace">
  <xsl:choose>
    <xsl:when test="namespace-uri(*[1]) = $docbook-namespace">
      <xsl:apply-templates mode="mp:justcopy"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="m:fixnamespace"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="m:fixnamespace">
  <xsl:choose>
    <xsl:when test="namespace-uri(.) = ''">
      <xsl:element name="{local-name(.)}" namespace="{$docbook-namespace}">
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="m:fixnamespace"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="m:fixnamespace"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="imagedata|db:imagedata
		     |textdata|db:textdata
		     |videodata|db:videodata
		     |audiodata|db:audiodata" mode="m:fixnamespace">
  <xsl:call-template name="tp:fixfileref"/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="m:fixnamespace">
  <xsl:copy/>
</xsl:template>

<xsl:template match="*" mode="mp:justcopy">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="mp:justcopy"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="imagedata|db:imagedata
		     |textdata|db:textdata
		     |videodata|db:videodata
		     |audiodata|db:audiodata" mode="m:justcopy">
  <xsl:call-template name="tp:fixfileref"/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="mp:justcopy">
  <xsl:copy/>
</xsl:template>

<xsl:template name="tp:fixfileref">
  <xsl:element name="{local-name(.)}" namespace="{$docbook-namespace}">
    <xsl:copy-of select="@*[name(.) != 'fileref' and name(.) != 'entityref']"/>

    <xsl:choose>
      <xsl:when test="@fileref">
	<xsl:attribute name="fileref"
		       select="resolve-uri(@fileref, base-uri(.))"/>
      </xsl:when>
      <xsl:when test="@entityref">
	<xsl:attribute name="fileref">
	  <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
	</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->
<!-- profile content -->

<doc:mode name="m:profile" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for profiling DocBook documents</refpurpose>

<refdescription>
<para>This mode is used to profile an input document. Profiling discards
content that is not in the specified profile.</para>
</refdescription>
</doc:mode>

<xsl:template match="/" mode="m:profile">
  <xsl:apply-templates mode="m:profile"/>
</xsl:template>

<xsl:template match="*" mode="m:profile">
  <xsl:if test="f:profile-ok(@arch, $profile.arch)
                and f:profile-ok(@condition, $profile.condition)
                and f:profile-ok(@conformance, $profile.conformance)
                and f:profile-ok(@lang, $profile.lang)
                and f:profile-ok(@os, $profile.os)
                and f:profile-ok(@revision, $profile.revision)
                and f:profile-ok(@revisionflag, $profile.revisionflag)
                and f:profile-ok(@role, $profile.role)
                and f:profile-ok(@security, $profile.security)
                and f:profile-ok(@userlevel, $profile.userlevel)
                and f:profile-ok(@vendor, $profile.vendor)
		and f:profile-attribute-ok(.,
		                           $profile.attribute, $profile.value)">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="m:profile"/>
    </xsl:copy>
  </xsl:if>
</xsl:template>

<xsl:template match="text()|comment()|processing-instruction()"
	      mode="m:profile">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<doc:function name="f:profile-ok" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns true if the specified attribute is in the specified profile
</refpurpose>

<refdescription>
<para>This function compares the profile values actually specified on
an element with the set of values being used for profiling and returns
true if the current attribute is in the specified profile.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>attr</term>
<listitem>
<para>The profiling attribute.</para>
</listitem>
</varlistentry>
<varlistentry><term>prof</term>
<listitem>
<para>The desired profile.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>True or false.</para>
</refreturn>
</doc:function>

<xsl:function name="f:profile-ok" as="xs:boolean">
  <xsl:param name="attr" as="attribute()?"/>
  <xsl:param name="prof" as="xs:string?"/>

  <xsl:choose>
    <xsl:when test="not($attr) or not($prof)">
      <xsl:value-of select="true()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="node-values"
		    select="fn:tokenize($attr, $profile.separator)"/>
      <xsl:variable name="profile-values"
		    select="fn:tokenize($prof, $profile.separator)"/>

      <!-- take advantage of existential semantics of "=" -->
      <xsl:value-of select="$node-values = $profile-values"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:profile-attribute-ok"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns true if the context node has the specified attribute and that attribute is in the specified profile
</refpurpose>

<refdescription>
<para>This function compares the profile values actually specified in the
named attribute on the context element
with the set of values being used for profiling and returns
true if the current attribute is in the specified profile.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>context</term>
<listitem>
<para>The context element.</para>
</listitem>
</varlistentry>
<varlistentry><term>attr</term>
<listitem>
<para>The profiling attribute.</para>
</listitem>
</varlistentry>
<varlistentry><term>prof</term>
<listitem>
<para>The desired profile.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>True or false.</para>
</refreturn>
</doc:function>

<xsl:function name="f:profile-attribute-ok" as="xs:boolean">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="attrname" as="xs:string?"/>
  <xsl:param name="prof" as="xs:string?"/>

  <xsl:choose>
    <xsl:when test="not($attrname) or not($prof)">
      <xsl:value-of select="true()"/>
    </xsl:when>
    <xsl:when test="not($context/@*[local-name(.) = $attrname
		                    and namespace-uri(.) = ''])">
      <xsl:value-of select="true()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="f:profile-ok($context/@*[local-name(.) = $attrname
                                                     and namespace-uri(.) = ''],
					 $prof)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->
<!-- copy external glossary -->

<doc:mode name="m:copy-external-glossary"
	  xmlns="http://docbook.org/ns/docbook">
<refpurpose>Mode for copying external glossary entries</refpurpose>

<refdescription>
<para>This mode is used to copy glossary entries from the
<parameter>glossary.collection</parameter> into the current document.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:glossdiv" mode="m:copy-external-glossary">
  <xsl:param name="terms"/>
  <xsl:param name="divs"/>

  <xsl:variable name="entries" as="element()*">
    <xsl:apply-templates select="db:glossentry" mode="m:copy-external-glossary">
      <xsl:with-param name="terms" select="$terms"/>
      <xsl:with-param name="divs" select="$divs"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="$entries">
    <xsl:choose>
      <xsl:when test="$divs">
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:copy-of select="db:info"/>
	  <xsl:copy-of select="$entries"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="$entries"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:glossentry" mode="m:copy-external-glossary">
  <xsl:param name="terms"/>
  <xsl:param name="divs"/>

  <xsl:variable name="include"
                select="for $dterm in $terms
                           return 
                              for $gterm in db:glossterm
                                 return
                                    if (string($dterm) = string($gterm)
                                        or $dterm/@baseform = string($gterm))
                                    then 'x'
                                    else ()"/>

  <xsl:if test="$include != ''">
    <xsl:copy-of select="."/>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="m:copy-external-glossary">
  <xsl:param name="terms"/>
  <xsl:param name="divs"/>

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:copy-external-glossary">
      <xsl:with-param name="terms" select="$terms"/>
      <xsl:with-param name="divs" select="$divs"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
