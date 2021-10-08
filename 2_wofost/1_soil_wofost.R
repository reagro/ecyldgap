
# set the working directory to the root of this repo
setwd(".")
dir.create("data/intermediate/")


library(terra)
library(Rwofost)

soilnms <- paste0("ec", 1:6)
wfsoils <- lapply(soilnms, function(i) wofost_soil(i))
smtab <- lapply(wfsoils, function(i) i$SMTAB)
smw <- sapply(wfsoils, function(i) i$SMW)
smfcf <- sapply(wfsoils, function(i) i$SMFCF)
sm0 <- sapply(wfsoils, function(i) i$SM0)
sparms <- cbind(sm0, smfcf, smw)
xpf <- c(-1, 2.2, 4.2)

findsoilidx <- function(y) {
	if (any(is.na(y))) return (NA)
	which.min(colSums((t(sparms) - y)^2))
}

afsoil <- rast("data/input/wofsoil.tif")
x <- app(afsoil[[c("sat", "FC", "PWP")]], findsoilidx, filename="data/intermediate/wofost_index.tif", wopt=list(names="wofsoil"), overwrite=TRUE)
saveRDS(wfsoils, "data/intermediate/wofost_index.rds")
