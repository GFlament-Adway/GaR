import csv
import numpy as np
import json



def countries_energy(exergy_coefs_path = "data/iea/exergy_coefs.json", energy_path="data/iea/IEA_all_countries/countries_energy_balance.csv", country="Belgium", starting_year = 1971, end_year = 2020):
    years = [starting_year + k for k in range(end_year - starting_year)]
    exergy_coef = get_exergy_coefs(exergy_coefs_path)
    energy_data = {"country": {country: {year : {} for year in years}}}
    with open(energy_path, "r") as csv_file:
        rows = csv.reader(csv_file)
        for row in rows:
            if ("Total energy supply (ktoe)" in row[5] or (
                    "Electricity output (GWh)" in row[5] and "Renewable sources" in row[4])) and country == row[0]:
                if ("Electricity output (GWh)" in row[5] and "Renewable sources" in row[4]):
                    for year in range(len(years)):
                        energy_data["country"][country][starting_year + year].update(
                            {
                                    "Renewable sources": float(row[6 - 1971 + starting_year + year]) * 85.9845 / 1000}
                        )
                else:
                    if "Coal, peat and oil shale" in row[4]:
                        for year in range(len(years)):
                            energy_data["country"][country][starting_year + year].update(
                                {
                                    "Coal": float(row[6 - 1971 + starting_year + year])}
                            )
                    if "Natural gas" in row[4]:
                        for year in range(len(years)):
                            energy_data["country"][country][starting_year + year].update(
                                {
                                    "Natural gas": float(row[6 - 1971 + starting_year + year])}
                            )

                    if "Crude, NGL and feedstocks" in row[4]:
                        for year in range(len(years)):
                            energy_data["country"][country][starting_year + year].update(
                                {
                                    "Crude oil": float(row[6 - 1971 + starting_year + year])}
                            )
                    if "Nuclear" in row[4]:
                        for year in range(len(years)):
                            energy_data["country"][country][starting_year + year].update(
                                {
                                    "Nuclear": float(row[6 - 1971 + starting_year + year])}
                            )
                    if "Renewables and waste" in row[4]:
                        for year in range(len(years)):
                            energy_data["country"][country][starting_year + year].update(
                                {
                                    "Renewables and waste": float(row[6 - 1971 + starting_year+ year])}
                            )
                    if "Oil products" in row[4]:
                        for year in range(len(years)):
                            energy_data["country"][country][starting_year + year].update(
                                {
                                    "Oil products": float(row[6 - 1971 + starting_year + year])}
                            )

        for year in years:
            energy_data["country"][country][year]["Biofuels and waste"] = energy_data["country"][country][year]["Renewables and waste"] - energy_data["country"][country][year]['Renewable sources']
            if year < 2000:
                energy_data["country"][country][year]["Hydro"] = energy_data["country"][country][year]['Renewable sources']
            else:
                energy_data["country"][country][year]["Hydro"] = energy_data["country"][country][2000][
                    'Renewable sources']
            energy_data["country"][country][year]['Wind, solar, etc.'] = energy_data["country"][country][year]['Renewable sources'] - energy_data["country"][country][year]["Hydro"]
            energy_data["country"][country][year]["exergy"] = np.sum([exergy_coef[ener]*energy_data["country"][country][year][ener] for ener in list(exergy_coef.keys())])
    energy_data = add_emissions(energy_data, country)
    return energy_data




def get_exergy_coefs(path="data/iea/exergy_coefs.json"):
    with open(path, "r") as json_file:
        data = json.load(json_file)
    return data


def add_emissions(energie, country):

    years = list(energie["country"][country].keys())
    emissions_factor = {"Coal": 820, "Natural gas": 490, "Crude oil": 400, "Nuclear": 12, "Hydro": 24, "Biofuels and waste": 230, 'Wind, solar, etc.': 25}
    sources = list(emissions_factor.keys())

    for year in years:
        emissions = 0
        for source in sources:
            emissions += energie["country"][country][year][source]*emissions_factor[source]*11630/1000 #kg to tonnes
        energie["country"][country][year].update({"emissions": emissions})
    return energie

def get_exergy(energy, exergy_coefs):
    exergy = {}
    for k in range(len(energy)):
        year = list(energy[k].keys())[0]
        exergy.update({year: np.sum(
            [float(exergy_coefs[ener]) * float(energy[k][year][ener]) for ener in energy[0][year].keys()])})
    return exergy

def diff(series):
    return [(series[k] - series[k-1])/series[k-1] for k in range(1, len(series))]


def get_gdp(country):
    """

    :param country:
    :return: GDP variation from world bank
    """
    with open("data/gdp/GDP.csv", "r") as csv_file:
        raw = csv.reader(csv_file)
        for data in raw:
            try:
                if data[0] == country:
                    return [float(x)/100 for x in data[5:-2]]
            except:
                pass

    return []
