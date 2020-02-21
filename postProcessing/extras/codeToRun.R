################################################################################
# CONFIG
################################################################################
library(postProcessing)

execute(source = "STAGING_AUDIT.SOURCE",
        executionLog = "STAGING_AUDIT.EXECUTION_LOG",
        releaseVersion = "V1.0.0")
