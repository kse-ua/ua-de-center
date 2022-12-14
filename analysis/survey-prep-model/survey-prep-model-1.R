rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
# -- 2.Import only certain functions of a package into the search path.
import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("janitor"  )# tidy data
requireNamespace("testit"   )# For asserting conditions meet expected patterns.

pacman::p_load(tidyr,dplyr, ggplot2)
library(tidyverse)
library(readr)
library(readxl)
library(survey)
library(fastDummies)
library(gt)

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R")             # basics
base::source("./scripts/graphing/graph-presets.R")       # font size, colors etc
base::source("./scripts/operational-functions.R")        # quick specific functions
base::source("./scripts/binary-categorical-functions.R") # graphing and modeling

# ---- declare-globals ---------------------------------------------------------
# printed figures will go here:
prints_folder <- paste0("./analysis/survey-overview/prints")
if (!fs::dir_exists(prints_folder)) { fs::dir_create(prints_folder) }

data_cache_folder <- prints_folder # to sink modeling steps
# ---- declare-functions -------------------------------------------------------
'%ni%' <- Negate(`%in%`)


make_corr_matrix <- function(d,metaData=d_meta,item_names,display_var="label_en", method="pearson"){
  # browser()
  # d <- ds0
  # metaData <- d_meta
  # item_names <- (d_meta %>% pull(item_name) %>% as.character() )[1:3]
  # add_short_label <- TRUE
  #
  # d %>% glimpse()
  # d <- ds %>% dplyr::select(foc_01:foc_49)
  d1 <- d %>% dplyr::select(all_of(item_names))
  d2 <- d1[complete.cases(d1),]
  # d2 %>% glimpse()
  rownames <- metaData %>%
    dplyr::filter(item_name %in% item_names) %>%
    dplyr::mutate(display_name = !!rlang::sym(display_var))
  # rownames <- rownames[,"display_name"]
  # rownames <- rownames %>% as.list() %>% unlist() %>% as.character()
  rownames <- rownames %>% pull(display_name)
  d3 <- sapply(d2, as.numeric)
  # d3 %>% glimpse()
  cormat <- cor(d3,method = method)
  colnames(cormat) <- rownames; rownames(cormat) <- rownames
  return(cormat)
}


make_corr_plot <- function (
    corr,
    lower="number",
    upper="number",
    bg="white",
    addgrid.col="gray"
    ,title 
    , ...
){
  corrplot::corrplot(
    corr
    , add=F
    , type   = "lower"
    , method = lower
    , diag   = TRUE
    , tl.pos = "lt"
    , cl.pos = "n"
    # ,order = "hclust"
    # ,addrect = 3
    ,...
  )
  corrplot::corrplot(
    corr
    ,add=T
    , type="upper"
    , method=upper
    , diag=TRUE
    , tl.pos="n"
    # ,order = "hclust"
    # ,addrect = 3
    ,title = title  
    , ...
  )
  
}

# ---- load-data ---------------------------------------------------------------
# the product of ./manipulation/ellis-general.R
ds_general <- readr::read_csv("./data-private/derived/full_dataset.csv")
# 
ds_survey <- readxl::read_excel("./data-private/derived/survey_hromadas_clean.xlsx")

# meta_oblast <- googlesheets4::read_sheet(sheet_name,"choices",skip = 0)

# Originally, we pulled the meta data object from Kobo front end and stored to 
# survey_xls  <- readxl::read_excel("./data-private/raw/kobo.xlsx", sheet = "survey")
# we put this on google drive now, to control manually
googlesheets4::gs4_deauth() # to indicate there is no need for a access token
# https://googlesheets4.tidyverse.org/ 
# https://docs.google.com/spreadsheets/d/1GaP92b7P1AI5nIYmlG0XoKYVV9AF4PDV8pVW3IeySFo/edit?usp=sharing
survey_url <- "1GaP92b7P1AI5nIYmlG0XoKYVV9AF4PDV8pVW3IeySFo"
meta_survey <- googlesheets4::read_sheet(survey_url,"survey",skip = 0)
meta_choices <- googlesheets4::read_sheet(survey_url,"choices",skip = 0)



# ---- inspect-data ------------------------------------------------------------
ds_general %>% glimpse(80)
ds_survey %>% glimpse(80)

# ---- variable-groups -----------------------------------------------------------
# create supporting objects for convenient reference of variable groups

# multiple choice questions
mcq <-
  meta_survey%>%
  dplyr::select(type,name)%>%
  dplyr::filter(str_detect(type, "select_multiple"))%>%
  dplyr::select(name)%>%
  pull() %>%  
  print()

#vectors of mcq names
preparation <- 
  ds_survey %>% 
  select(starts_with("prep_"), -prep_winter_count, -prep_count) %>% 
  colnames() %>% 
  print()

comm_channels <- 
  ds_survey %>% 
  select(telegram:hotline) %>% 
  colnames() %>% 
  print()

idp_help <- 
  ds_survey %>%
  select(starts_with('idp_help/'), -ends_with('number')) %>% 
  colnames() %>% 
  print()

military_help <- 
  ds_survey %>% 
  select(starts_with('help_for_military/')) %>% 
  colnames() %>% 
  print()

# only for occupied hromadas - few cases
hromada_cooperation <- 
  ds_survey %>% 
  select(starts_with('hromada_cooperation/')) %>% 
  colnames() %>% 
  print()

prep_for_winter <- c('info_campaign', 'reserves', 'count_power_sources', 
                     'count_heaters_need', 'solid_fuel_boiler')
# vector of income variables 
income <- 
  ds_survey %>%
  select(ends_with('capita'), ends_with('prop_2021')) %>%
  colnames() %>% 
  print()

# ---- meta-data-1 -------------------------------------------------------------
meta_survey %>% glimpse()

meta_survey %>% 
  filter(type %in% c("begin_group","end_group")) %>% 
  select(1:5) %>% 
  print_all()

meta_survey %>% glimpse()

ds_general %>% names() %>% str_subset("oblast_center")
# ---- tweak-data-0 ----------------------

ds_general0 <- 
  ds_general %>% 
  mutate(
    survey_response = case_when(
      hromada_code %in% (ds_survey %>% pull(hromada_code) %>% unique()) ~ TRUE
      ,TRUE ~ FALSE
    )
  ) %>% 
  mutate(
    income_own_per_capita       = income_own_2021         / total_population_2022
    ,income_total_per_capita     = income_total_2021       / total_population_2022
    ,income_tranfert_per_capita  = income_transfert_2021   / total_population_2022
    # ,idp_registration_share      = idp_registration_number / total_population_2022
    # ,idp_real_share              = idp_real_number         / total_population_2022
    # ,idp_child_share             = idp_child_education     / idp_registration_number
  )
# ds_general0 %>% group_by(survey_response) %>% count()
a <- c("A","B","C")
a %>% str_which("B")
a %>% str_match("B")
a %>% str_locate("B")
a %>% str_extract("B")
a %>% str_detect("B")

native_survey_vars <- names(ds_survey) %>% str_which("prep_winter_count")
ds0 <-
  ds_survey %>%
  select(1:native_survey_vars) #%>% 
  # left_join(ds_general %>% select(hromada_code, total_population_2022)) %>% 
  # mutate(
    # income_own_per_capita       = income_own_2021         / total_population_2022,
    # income_total_per_capita     = income_total_2021       / total_population_2022,
    # income_tranfert_per_capita  = income_transfert_2021   / total_population_2022,
    # idp_registration_share      = idp_registration_number / total_population_2022,
    # idp_real_share              = idp_real_number         / total_population_2022,
    # idp_child_share             = idp_child_education     / idp_registration_number
  # )
ds0 %>% glimpse(80)
# ---- inspect-data-0 ------------------------------------------------------------

# ---- tweak-data-1-prep ------------------------------------------------------------
# Select the focal section of the investigation - Invasion Preparation Block

# compute total binary score (preparations are made at all, regardless of timing)
d_meta_prep <- 
  meta_survey %>% 
  filter(group=="preparation") %>% 
  select(item_name = name,label_en,label)

ds1_prep <-
  ds0 %>% 
  mutate(
    # sum of 0|1|2 where larger numbers indicate more preparedness
    prep_score = rowSums(across(preparation),na.rm = T) 
   ,prep_score_before = rowSums(
      across(
        .cols = preparation
        ,.fns = ~case_when(
          .  == 0 ~ 0 #"No"
          ,. == 1 ~ 0 #"After Feb 24"
          ,. == 2 ~ 1 #"Before Feb 24"
        )
      )
      ,na.rm = T
    )
    ,prep_score_after = rowSums(
      across(
        .cols = preparation
        ,.fns = ~case_when(
          .  == 0 ~ 0 #"No"
          ,. == 1 ~ 1 #"After Feb 24"
          ,. == 2 ~ 1 #"Before Feb 24"
        )
      )
      ,na.rm = T
    )
  )  %>% 
  # to normalize the metric, making every scale to be out of 10 points maximum
  # mutate(
  #   prep_score = prep_score / 3 # because 15 items, maximum 2 points each
  #   ,prep_score_before =prep_score_before /1.5 # because 15 items, maximum 1 point each
  #   ,prep_score_after = prep_score_after /1.5 # because 15 items, maximum 1 point each
  # ) %>%
  select(hromada_code, starts_with("prep_score"),preparation) %>% 
  relocate(c("prep_score","prep_score_before","prep_score_after"),.after=1)
ds1_prep %>% select(2:4)
ds1_prep %>% glimpse(90)

# ---- prep-custom-objects ------------------------------
# Raw scale (0,1,2) with factors
ds1_prep_ordinal_factors <- 
  ds1_prep %>% 
  mutate(
    across(
      .cols = preparation
      ,.fns = ~case_when(
        . == 0  ~ "No"
        ,. == 1 ~ "After Feb 24"
        ,. == 2 ~ "Before Feb 24"
        ,TRUE   ~ "Not Applicable"
      ) %>% factor(levels=c("No","Before Feb 24","After Feb 24",  "Not Applicable"))
    )
  ) %>% 
  select(hromada_code, starts_with("prep_score"),preparation)

# Binary scale (0,1) with factors
ds1_prep_binary_factors <- 
  ds1_prep %>% 
  mutate(
    across(
      .cols = preparation
      ,.fns = ~case_when(
        .  == 0  ~ "No"
        ,. == 1 ~ "Yes"
        ,. == 2 ~ "Yes"
        ,TRUE   ~ "Not Applicable"
      ) %>% factor(levels=c("No","Yes","Not Applicable"))
    )
  ) %>% 
  select(hromada_code, starts_with("prep_score"),preparation)

m_prep <- 
  ds1_prep %>% 
  select(-hromada_code) %>%
  # you would recode into binary at this point, but we dont' in this case
  make_corr_matrix(
    item_names = names(.)
    ,metaData=d_meta_prep %>% bind_rows(
      list(
        "item_name" = c("prep_score","prep_score_before","prep_score_after")
        ,"label_en" = c("Prep Score","Prep Score (Before)","Prep Score (After)")
      ) %>% as_tibble()
    )
    ,method = "spearman"
  ) 

# TO test a hypothesis that binary measure of prepration item is better (not)
m_prep_binary <- 
  ds1_prep %>% 
  select(-hromada_code) %>%
  # recode individual items into binary
  mutate(
    across(
      .cols = preparation
      ,.fns = ~ case_when(.==2~1,T~.)
    )
  ) %>% 
  make_corr_matrix(
    item_names = names(.)
    ,metaData=d_meta_prep %>% bind_rows(
      list(
        "item_name" = c("prep_score","prep_score_before","prep_score_after")
        ,"label_en" = c("Prep Score","Prep Score (Before)","Prep Score (After)")
      ) %>% as_tibble()
    )
    ,method = "spearman"
  )  
  
d_item_total <- 
  list(
    "Total" = m_prep[,"Prep Score"]
    ,"Before"= m_prep[,"Prep Score (Before)"]
    ,"After" = m_prep[,"Prep Score (After)"]
  ) %>% 
  as_tibble() %>% 
  mutate(item_name = rownames(m_prep)) %>% 
  filter(item_name != "Total Prep Score") %>% 
  mutate(item_name = factor(item_name)) %>% 
  relocate(item_name)

d_item_total_binary <- 
  list(
    "Total"  = m_prep_binary[,"Prep Score"]
    ,"Before"= m_prep_binary[,"Prep Score (Before)"]
    ,"After" = m_prep_binary[,"Prep Score (After)"]
  ) %>% 
  as_tibble() %>% 
  mutate(item_name = rownames(m_prep)) %>% 
  filter(item_name != "Total Prep Score") %>% 
  mutate(item_name = factor(item_name)) %>% 
  relocate(item_name)


# -------- tweak-data-2-prep ------------
ds1_prep %>% glimpse()


predictor_vars_to_extract <- c(
  "income_own_2021"           
  ,"income_total_2021"         
  ,"income_transfert_2021"
  # continuous - demographic
  ,"area" # 
  ,"n_settlements"
  ,"travel_time" # to the oblast center
  ,"urban_pct"
  ,"total_population_2022"
  ,"urban_population_2022"                              
  ,"sum_osbb_2020"  # condo-owner association, sort of                                    
  ,"turnout_2020" # election turn out
  ,"age_head" # head of the hromada
  ,"time_before_24th"# time of voluntary hromada formation
  # categorical
  ,"sex_head"
  ,"region_en"
  ,"education_head"
  ,"type" # urban
  ,"voluntary" # formed
  ,"oblast_name_en"
)

ds2_prep <- 
  ds1_prep %>% 
  left_join(
    ds_general %>% 
      select(
        hromada_code,
        all_of(predictor_vars_to_extract)
      )
    ) %>%
  left_join(
    ds_survey %>% 
      select(
        hromada_code
        ,idp_registration_number
        ,idp_real_number
        ,idp_child_education
      )
  ) %>% 
  mutate(
    income_own_per_capita       = income_own_2021         / total_population_2022,
    income_total_per_capita     = income_total_2021       / total_population_2022,
    income_tranfert_per_capita  = income_transfert_2021   / total_population_2022,
    idp_registration_share      = idp_registration_number / total_population_2022,
    idp_real_share              = idp_real_number         / total_population_2022,
    idp_child_share             = idp_child_education     / idp_registration_number
  ) %>% 
  glimpse() 


# ---- tweak-data-3-prep ----------------------------

predictor_vars_continuous <- c(
   "income_own_per_capita"
  ,"income_total_per_capita"
  ,"income_tranfert_per_capita"
  ,"idp_registration_share"
  ,"idp_real_share"
  ,"idp_child_share"
  # continuous - demographic
  ,"area" # 
  ,"n_settlements"
  ,"travel_time" # to the oblast center
  ,"urban_pct"
  ,"total_population_2022"
  ,"urban_population_2022"                              
  ,"sum_osbb_2020"  # condo-owner association, sort of                                    
  ,"turnout_2020" # election turn out
  ,"age_head" # head of the hromada
  ,"time_before_24th"# time of voluntary hromada formation
)

predictors_vars_categorical <- c(
  # categorical
  "sex_head"
  ,"region_en"
  ,"education_head"
  ,"type" # urban
  ,"voluntary" # formed
  ,"oblast_name_en"
)

predictor_vars <- c(predictor_vars_continuous, predictors_vars_categorical)


ds3_prep %>%
  ds2_prep %>% 
  mutate(
    across(
      .cols = all_of(predictors_vars_categorical)
      ,.fns = ~factor(.)
    )
  ) %>%
  pivot_longer(
    cols = all_of(predictor_vars_continuous)
    ,names_to = "item_name"
    ,values_to = "item_value"
  ) #%>% glimpse()




# ----- inspect-data-1-prep -----------------------


ds1_prep_ordinal_integers %>% glimpse()
ds1_prep_ordinal_factors %>% glimpse()
ds1_prep_binary_integers %>% glimpse()
ds1_prep_binary_factors %>% glimpse()


# ---- save-to-disk ------------------------------------------------------------

# ---- publish ------------------------------------------------------------
path <- "./analysis/survey-prep-model/survey-prep-model.Rmd"
rmarkdown::render(
  input = path ,
  output_format=c(
    "html_document"
    # "word_document"
    # "pdf_document"
  ),
  clean=TRUE
)