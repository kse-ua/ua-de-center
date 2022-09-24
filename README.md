# Decentralization Reform in Ukraine (2014 -2022)

The project investigates the effects of restructurization of local councils (*i.e.*, "rada", *N* = 11,250) into amalgamated territorial communities (*i.e.*, "hromada", *N* = 1,469) and the effect of this tranformation on key macroeconomic and psychosocial indicators. Of specific interest is hromadas' resiliance to full-scale russian invasion launched on 2022-02-24. 

The project is funded by ... grant (#`grant_id`)

![](https://www.nationsonline.org/maps/Ukraine-Administrative-Map.jpg)


  | Name            |Role   | @   |
  |---              |---|---|
  |Tymofii Brik     |   |   |
  |Andriy Darkovich |   |   |
  |Valentyn Hatsko  |   |   |
  |Andriy Koval     |Statistical modeling, data visualization, reproducible research   | [andkov](https://github.com/andkov)  |
  |Maryna Rabinovych|   |   |
  |Myroslava Savisko|   |   |
  |Serhii Tytiuk    |   |   |
  |Iryna Zasimovych |   |   |

# Data Products

  | Data Source     |Description   | Current State / Left To Do   | Script |
  |---              |---|---|---|
  |Admininstrative Units | Relationship among multiple administrative levels (settlement, rada, hromada, raion, oblast, region) | Needs to be placed in `data-public/derived/`   |`manipulation/ellis-ua-admin.R`|
  | Admin History | Composition of hromadas (what radas comprise it) at every point in time when such composition changed, from 2014 to 2020| ready for analysis| `manipulation/ellis-rada-hromada.R`|
  |Population | Population counts at the level of hromada   | Add more years (currently only 2021), push to ./data-public/derived/   |`manipulation/ellis-demography.R`|
  |Open Budget  | Tax revenues of admin units   | No clarity yet. Classify hromadas based on complexity of their admin history   |`manipulation/ellis-budget.R`|
  |Geographic     |Spatial poligons of hromadas| Demonstate graphing maps (at hromada-raion-oblast level) using a replacable quantifier (e.g. population)  |`manipulation/ellis-geography.R`|
  |Social | No data source has been identified yet  | Need ideas what metric of social activity (at hromada level) could be correlated with economic and demographic activity  | |
 
