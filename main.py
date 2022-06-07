from utils import utils
import numpy as np
from statsmodels.regression.quantile_regression import QuantReg


if __name__ == "__main__":
    countries = ["Belgium", "France", "United States"]
    energy = {country : utils.countries_energy(country=country)["country"][country] for country in countries}

    gdp = {country : utils.get_gdp(country) for country in countries}
    import matplotlib.pyplot as plt

    n = len(energy["United States"])
    p = 11


    diff_exergy = utils.diff([energy["United States"][1971 + k]["exergy"] for k in range(n)])
    diff_exergy = diff_exergy - np.mean(diff_exergy)
    res = []
    gdp_lag = gdp["United States"][(p):(n + p - 1)] - np.mean(gdp["United States"][(p):(n + p - 1)])
    gdp = gdp["United States"][(p+1):(n + p)]- np.mean(gdp["United States"][(p+1):(n + p)])
    res_2 = []
    for q in range(1, 10):
        model = QuantReg(endog = gdp_lag, exog = diff_exergy).fit(q=q/10)
        model_2 = QuantReg(endog = gdp, exog= gdp_lag).fit(q=q/10)
        res += [model.params]
        print(model.summary())
        res_2 += [model_2.params]

    plt.figure()
    plt.plot(diff_exergy, label="Exergy")
    plt.plot([k+1 for k in range(len(gdp))], gdp, label="GDP forward")
    plt.legend()
    plt.show()