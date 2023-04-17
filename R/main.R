# Vulnerable Growth - Adrian et al. (2019)
# Growth at Risk
#
# Version : 11/04/2023
# Auteurs : Guillaume FLAMENT & Quentin LAJAUNIE

# A SUPPRIMER QUAND LE PACKAGE EXISTE
path <- 'Users\\guillaume.flament_ad\\Desktop\\GaR_Quentin'


# ZONE EURO
data_euro <- read.csv(file.path("C:", path, "data\\DataVulnerability_euro.csv"), header = T, sep=";")
data_essai <- read.csv(file.path("C:", path, "data\\essai.csv"), header = T, sep=";", dec=",")

PIB_esp <- sign(diff(data_essai$gdp_esp[3:(length(data_essai$gdp_esp) - 5)]))*(diff(data_essai$gdp_esp[3:(length(data_essai$gdp_esp) - 5)])/data_essai$gdp_esp[4:(length(data_essai$gdp_esp) - 5)] * 100)**4
PIB_esp <- na.omit(PIB_esp)

PIB_euro_forward_4 = PIB_esp[c(5:length(PIB_esp))]
PIB_euro_forward_1 = PIB_esp[c(2:length(PIB_esp))]
PIB_euro_lag_4 = PIB_esp[c(1:(length(PIB_esp) - 4))]
PIB_euro_lag_1 = PIB_esp[c(1:(length(PIB_esp) - 1))]
FCI_euro_lag_4 = data_euro["FCI"][c(1:(length(data_euro["PIB"][,1]) - 4)),]
FCI_euro_lag_1 = data_euro["FCI"][c(1:(length(data_euro["PIB"][,1]) - 1)),]
CISS_euro_lag_4 = data_euro["CISS"][c(1:(length(data_euro["PIB"][,1]) - 4)),]
CISS_euro_lag_1 = data_euro["CISS"][c(1:(length(data_euro["PIB"][,1]) - 1)),]




# replication

# COMPILE QUANTILE
quantile_target <- as.vector(c(0.10,0.25,0.75,0.90))
t_test <- 30 # time target for PIB values
source(file.path("C:", path, "f_compile_quantile.R"))

results_quantile_reg <- f_compile_quantile(qt_trgt=quantile_target, v_dep=PIB_euro_forward_1, v_expl=cbind(FCI_euro_lag_1, CISS_euro_lag_1), t_trgt = t_test)
results_quantile_reg


library(dfoptim)
source(file.path("C:", path, "f_distrib.R"))

#"gaussian", "skew-t"
param_g <- f_distrib(type_function="gaussian", compile_qt=results_quantile_reg, starting_values=c(0, 1))
param_st <- f_distrib(type_function="skew-t", compile_qt=results_quantile_reg, starting_values=c(0, 1, -0.5, 1.3))

# plot distribution
x <- seq(from=-15, to =10,by=0.01)
y <- dnorm(x, mean=param_g$mean, sd=param_g$sd)

y2 <- dst(x, xi=param_st$xi, omega=param_st$omega,
         alpha=param_st$alpha, nu=param_st$nu, dp=NULL, log=FALSE)


plot(x, y, col='blue', type="l", xlab="GDP", ylab="")
lines(x, y2, col='red', type="l", xlab="GDP", ylab="")

