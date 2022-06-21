from utils import utils
import numpy as np
from statsmodels.regression.quantile_regression import QuantReg


if __name__ == "__main__":
    countries = ["Belgium", "France", "United States", "Sweden", "Italy"]
    energy = {country : utils.countries_energy(country=country)["country"][country] for country in countries}

    gdp = {country : utils.get_gdp(country) for country in countries}
    import matplotlib.pyplot as plt

    n = len(energy["United States"])
    p = 11
    print(gdp.keys())
    country = "France"
    diff_exergy = utils.diff([energy[country][1971 + k]["exergy"] for k in range(n)])
    res = []
    gdp_lag = gdp[country][(p):(n + p-1)]
    gdp = gdp[country][(p+1):(n + p)]
    res_2 = []
    for q in range(1, 10):
        model = QuantReg(endog = gdp, exog = diff_exergy).fit(q=q/10)
        model_2 = QuantReg(endog = gdp, exog= gdp_lag).fit(q=q/10)
        res += [model.params]
        print(model.summary())
        res_2 += [model_2.params]


