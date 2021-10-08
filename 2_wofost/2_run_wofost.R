
outpath <- "data/output/wofost/watlim"
dir.create(outpath, FALSE, TRUE)

library(terra)
library(Rwofost)

climids <- list.files("data/input/era", pattern="wind_.*tif$")
climids <- gsub("wcdera_", "", list.files("data/input/era", pattern="wind_.*tif$"))
climids <- gsub(".tif", "", climids)

soilidx <- rast("data/intermediate/wofost_index.tif")
soils <- readRDS("data/intermediate/wofost_index.rds")[1:4]

for (i in 1:length(soils)) {
	soils[[i]]$WAV <- 10
	soils[[i]]$SMLIM <- 0.10
}

wofmod <- wofost_model()
crop(wofmod) <- wofost_crop("maize_1")
contr <- wofost_control()
contr$latitude=0
contr$elevation=50
contr$water_limited <- TRUE
control(wofmod) <- contr

mstart = as.Date(paste0(rep(1987:2017, each=12), "-", 1:12, "-", 15))

varieties <- data.frame(stringsAsFactors=FALSE,
		name=c('pre', 'ear', 'mid', 'lat'), 
        TSUM1=c(600, 700, 800, 900), 
        TSUM2=c(650, 800, 950, 1100))


soilidx <- aggregate(soilidx, 6, fun=raster::modal)
cvars <- c("tmin", "tmax", "srad", "prec", "vapr", "wind")

wthpath <- "data/input/era"

ff <- file.path(wthpath, paste0("era_", cvars, ".tif"))
x <- sds(lapply(ff, rast))
names(x) <- cvars
sidx <- crop(soilidx, ext(x))
dates <- as.Date(names(x[1]), "X%Y.%m.%d")
for (j in 1:nrow(varieties)) {
	cat(varieties$name[j], " "); flush.console()
	outf <- file.path("wofost/sim", paste0(varieties$name[j], "_", climids, ".tif"))
	if (file.exists(outf[i])) next
	wofmod$crop$p$TSUM1 <- varieties$TSUM1[j]
	wofmod$crop$p$TSUM2 <- varieties$TSUM2[j]
	out <- predict(wofmod, x, mstart, dates, sidx, soils, filename=outf[i], overwrite=TRUE)
}

