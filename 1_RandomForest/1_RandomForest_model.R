
# set the working directory to the root of this repo
setwd(".")

### make RandomForest model 

# read field trial data 
d <- read.csv("data/input/yield_and_predictors.csv")

# fit RandomForest model
library(randomForest)
set.seed(2020)
m <- yield_kg_ha ~ kg_N_ha + kg_P_ha + kg_K_ha + extractable_phosphorous + total_potassium + 
                    mean_temperature + sand_content + rainfall + root_depth + soil_organic_carbon + pH 
crf <- randomForest(m, data=d, importance=T)


### make predictions

# predictor data
library(terra)
predictors <- rast("data/input/predictors.tif")

N <- c(seq(0,75,15), seq(100, 200, 25))
K <- P <- N[1:7]
npk <- expand.grid(N=N,P=P,K=K)

path <- "output/yield/rf"
dir.create(path, FALSE, TRUE)

a <- apply(npk, 1, function(i) paste(i, collapse="-"))
f <- file.path(path, paste0("rf_", a, ".tif"))

for (i in 1:nrow(npk)) {
	if (file.exists(f[i])) next
	NPK <- data.frame(kg_N_ha=npk$N[i], kg_P_ha=npk$P[i], kg_K_ha=npk$K[i])
	p <- predict(predictors, crf, const=NPK, filename=f[i], overwrite=TRUE,
				wopt=list(datatype="INT2S", names=a[i]))
}

