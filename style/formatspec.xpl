<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:exf="http://exproc.org/standard/functions"
                xmlns:pos="http://exproc.org/proposed/steps/os"
                exclude-inline-prefixes="cx exf pos"
                name="main">
<p:input port="source"/>
<p:input port="parameters" kind="parameter"/>
<p:output port="result"/>
<p:serialization port="result" indent="false" method="xhtml"/>

<p:declare-step type="pos:env">
  <p:output port="result"/>
</p:declare-step>

<pos:env/>

<p:xslt>
  <p:input port="source">
    <p:pipe step="main" port="source"/>
  </p:input>
  <p:input port="stylesheet">
    <p:document href="dbspec.xsl"/>
  </p:input>
  <p:with-param name="travis"
                select="string(/c:result/c:env[@name='TRAVIS']/@value)"/>
  <p:with-param name="travis-commit"
                select="string(/c:result/c:env[@name='TRAVIS_COMMIT']/@value)"/>
  <p:with-param name="travis-build-number"
                select="string(/c:result/c:env[@name='TRAVIS_BUILD_NUMBER']/@value)"/>
  <p:with-param name="travis-user"
                select="substring-before(
                          /c:result/c:env[@name='TRAVIS_REPO_SLUG']/@value,
                          '/')"/>
  <p:with-param name="travis-repo"
                select="substring-after(
                          /c:result/c:env[@name='TRAVIS_REPO_SLUG']/@value,
                          '/')"/>
  <p:with-param name="auto-diff"
                select="string(/c:result/c:env[@name='DELTA_BASE']/@value)"/>
</p:xslt>

</p:declare-step>
