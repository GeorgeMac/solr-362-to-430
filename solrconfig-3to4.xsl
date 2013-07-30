<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <xsl:output indent="yes" encoding="UTF-8" method="xml" />

  <xsl:param name="preserveComments" select="true()" />
  <xsl:param name="documentChanges" select="true()" />
  <xsl:param name="outputNotes" select="true()" />

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="config">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:call-template name="buildIndexConfig" />
      <!-- Everything before the new Index Config -->
      <xsl:apply-templates select="child::node()[not(name() = ('indexDefaults', 'mainIndex', 'indexConfig'))]" />
      <!-- The new Index Config comprising of the contents of the old indexDefaults and mainIndex elements -->
      
    </xsl:copy>
  </xsl:template>

  <!-- This functions builds a correctly structure indexConfig element, which contain
  all the necessary contents of the origin indexDefaults and mainIndex, without any
  content duplication. Look out for NOTE comments with info regarding the removed duplications -->
  <xsl:template name="buildIndexConfig">
    <xsl:variable name="hasUseCompoundFilter" select="not(empty(.//useCompoundFile))" />
    <xsl:text>
      
    </xsl:text>
    <xsl:comment> Your Shiny New Solrconfig.xml indexConfig </xsl:comment>
    <xsl:text>
    </xsl:text>
    <indexConfig>
      <xsl:variable name="indexConfigContents">
        <xsl:apply-templates select="indexDefaults | mainIndex | indexConfig" />
      </xsl:variable>

      <xsl:for-each-group select="$indexConfigContents/node()" group-by="node-name(.)">

        <xsl:text>
        </xsl:text>
        <xsl:copy-of select="current-group()[1]" />

        <xsl:text>
        </xsl:text>
        <xsl:for-each select="current-group()">
          <xsl:if test="position() != 1 and $documentChanges">
            <xsl:variable name="node-name" select="name()" />
            <xsl:variable name="node-contents" select="node()" />
            <xsl:comment>
                <xsl:value-of select="concat('CHANGE: A &lt;',$node-name,'/&gt; element with a value of: ',$node-contents,'; has been removed due to duplication')" />
              </xsl:comment>
          </xsl:if>
        </xsl:for-each>

      </xsl:for-each-group>
      <xsl:text>
      </xsl:text>
      <xsl:if test="not($hasUseCompoundFilter) and $outputNotes">
        <xsl:comment xml:space="preserve"> NOTE: Did you know the element useCompoundFile will be set by default to false
        Just a friendly warning, you may want to set this explicitly
        &lt;useCompoundFile&gt;true&lt;/useCompoundFile&gt; 
        </xsl:comment>
      </xsl:if>
      <xsl:text>
      </xsl:text>
    </indexConfig>

  </xsl:template>

  <xsl:template match="indexDefaults | mainIndex | indexConfig">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="node() | @*">
    <xsl:choose>
      <xsl:when test="not(current() instance of comment())">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <!-- Note this is a little biased towards the original Index Defaults comments -->
        <xsl:if test="$preserveComments and not(contains(.,'Index Defaults'))">
          <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
          </xsl:copy>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
