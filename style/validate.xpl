<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:exf="http://exproc.org/standard/functions">

<p:input port="source"/>
<p:output port="result"/>
<p:option name="schema" select="''"/>

<p:xinclude name="doc"/>

<p:choose>
  <p:when test="$schema = ''">
    <p:identity/>
  </p:when>
  <p:otherwise>
    <p:load name="rng">
      <p:with-option name="href" select="resolve-uri($schema, exf:cwd())"/>
    </p:load>
    <p:validate-with-relax-ng>
      <p:input port="source">
        <p:pipe step="doc" port="result"/>
      </p:input>
      <p:input port="schema">
        <p:pipe step="rng" port="result"/>
      </p:input>
    </p:validate-with-relax-ng>
  </p:otherwise>
</p:choose>

</p:declare-step>
