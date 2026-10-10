<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:frmwrk="Corel Framework Data">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <frmwrk:uiconfig>
    <frmwrk:applicationInfo userConfiguration="true"/>
  </frmwrk:uiconfig>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- VBA macro entry point verified against the supplied CorelDRAW 2018 workspace. -->
  <xsl:template match="uiConfig/items">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <xsl:if test="not(itemData[@guid='bc3e4415-d5d9-43a9-a607-7c099eedf8f5'])">
        <itemData guid="bc3e4415-d5d9-43a9-a607-7c099eedf8f5"
                  dynamicCommand="UstaSmartNodeCleaner.Module1.UstaSmartNodeCleanerV073"
                  dynamicCategory="2cc24a3e-fe24-4708-9a74-9c75406eebcd"
                  bmpCol="0"
                  bmpRow="0"
                  userCaption="USTA Smart Node Cleaner"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
