# Data Dictionary

The canonical analysis file is:

`data/analysis/thesis_panel_2002_2021.csv`

It contains the final panel used for the empirical analysis reported in the 2024 bachelor's thesis.

## Panel Structure

- **Countries:** 10 developed OECD economies
- **Years:** 2002–2021
- **Frequency:** Annual
- **Country-year observations:** 200
- **Missing values in final dataset:** 0
- **Regression observations:** 190 after applying the one-period lag of GDP per capita

Country codes:

| Code | Country |
|---|---|
| AUS | Australia |
| AUT | Austria |
| CHE | Switzerland |
| DNK | Denmark |
| IRL | Ireland |
| ISL | Iceland |
| LUX | Luxembourg |
| NLD | Netherlands |
| NOR | Norway |
| USA | United States |

## Variables

| Variable | Definition | Unit / Transformation in Data | Source documented in thesis |
|---|---|---|---|
| `Country` | Country identifier | Three-letter code | — |
| `Year` | Calendar year | 2002–2021 | — |
| `PSS` | Public social spending | % of GDP | OECD Social Expenditure Database |
| `GES` | Government expenditure on education | % of total government expenditure | UNESCO Institute for Statistics |
| `GDPpc` | GDP per capita at purchasing power parity | Current international dollars (PPP) | World Bank, World Development Indicators |
| `Educ` | Adult tertiary education attainment | % of 25–64 year-olds | OECD Adult Education Level indicator |
| `U` | Unemployment rate | % of total labor force | ILOSTAT |
| `POP` | Population | Millions | OECD Population indicator |
| `GCF` | Gross capital formation | % of GDP | World Bank national accounts data |

## Transformations Used in the Regression

The R analysis uses:

- `log(PSS)`
- lagged `log(GDPpc)`
- `log(GCF)`
- `log(GES)`
- `Educ` in levels
- `U` in levels
- `log(POP)`

The dependent variable is:

`log(GDPpc_t) - log(GDPpc_t-1)`

which represents annual log growth in GDP per capita.

## Provenance Note

This repository preserves the **final assembled analysis dataset** used for the thesis. It is intended to reproduce the reported econometric analysis from the analysis-ready panel.

The complete raw-data acquisition and transformation pipeline from the original OECD, World Bank, UNESCO, and ILOSTAT downloads was not preserved as executable code. The source definitions above are therefore retained for transparency, but this repository should not be described as a full raw-data replication archive.
