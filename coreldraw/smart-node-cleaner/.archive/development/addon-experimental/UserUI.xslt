<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:frmwrk="Corel Framework Data">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <frmwrk:uiconfig>
    <frmwrk:applicationInfo userConfiguration="true"/>
    <frmwrk:compositeNode xPath="/uiConfig/commandBars/commandBarData[@guid='7c905e2a-cb64-4ba1-aff0-c306f392680c']"/>
    <frmwrk:compositeNode xPath="/uiConfig/frame"/>
  </frmwrk:uiconfig>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- CorelDRAW toolbox, not an existing personalized command bar. -->
  <xsl:template match="uiConfig/commandBars/commandBarData[@guid='7c905e2a-cb64-4ba1-aff0-c306f392680c']/toolbar">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <xsl:if test="not(item[@guidRef='bc3e4415-d5d9-43a9-a607-7c099eedf8f5'])">
        <item guidRef="bc3e4415-d5d9-43a9-a607-7c099eedf8f5"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
