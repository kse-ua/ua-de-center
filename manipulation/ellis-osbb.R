#+ echo=F ----------------------------------------------------------------------
library(knitr)
# align the root with the project working directory
opts_knit$set(root.dir='../')  #Don't combine this call with any
#+ echo=F ----------------------------------------------------------------------
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run.
#This is not called by knitr, because it's above the first chunk.
#+ results="hide",echo=F -------------------------------------------------------
cat("\014") # Clear the console
#+ echo=FALSE, results="asis" --------------------------------------------------
cat("Report's native working directory: `", getwd(),"`") # Must be set to Project Directory
#+ echo=F, results="asis" ------------------------------------------------------
cat("\n# 1.Environment")
#+ set_options, echo=F ---------------------------------------------------------
echo_chunks <- TRUE
eval_chunks <- TRUE
cache_chunks <- TRUE
report_render_start_time <- Sys.time()
options(width=100) # number of characters to display in the output (dflt = 80)
Sys.setlocale("LC_CTYPE", "russian")
#+ load-sources ----------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
#+ load-packages ---------------------------------------------------------------
library(tidyverse)

#+ declare-globals -------------------------------------------------------------
path_osbb<- "./data-private/raw/minregion-osbb.xlsx"
path_admin <- "./data-public/derived/ua-admin-map-2020.csv"


#+ results="asis", echo=F ------------------------------------------------------
cat("\n# 2.Data ")

#+ load-data, eval=eval_chunks -------------------------------------------------
ds0 <- readxl::read_excel(path_osbb)
ds_admin <- readr::read_csv(path_admin)

#+ create columns for merge name+oblast-----------------------------------------
ds_admin$settlement_name_full <- paste(ds_admin$settlement_type,
                              ds_admin$settlement_name)
ds_admin$oblast_name_full <- case_when(ds_admin$oblast_name=="?????????????????? ???????????????????? ????????"~ds_admin$oblast_name,
TRUE~paste(ds_admin$oblast_name,"??????????????"))
ds_admin$raion_name_full <- paste(ds_admin$raion_name,
                                  "??????????")

#+ Correcting mistakes and problems with cities---------------------------------
ds0 <- ds0 %>% mutate(locality = case_when(
  locality == "?????????? ????????????????????" ~ "?????????? ????????????",
  locality == "?????????? ????????" & region == "???????????????? ??????????????"  ~ "?????????? ???????? ????????????",
  locality == "?????????? ????????????????" & region == "???????????????????????? ??????????????"~ "?????????? ????????????????",
  locality == "?????????? ??????????????????-????????????????????" & region == "?????????????????? ??????????????"~ "?????????? ??????????????????",
  locality == "?????????? ??????????????" ~ "?????????? ?????????????? ????????????",
  locality == "?????????? ????????" & region == "???????????????????? ??????????????"~ "?????????? ???????? ????????????????",
  locality == "?????????? ????????????" & region == "?????????????????? ??????????????"~ "?????????? ???????????? ??????????",
  locality == "?????????? ??????'????????????" ~ "?????????? ?????????????????????",
  locality == "?????????? ????????????????????????????????" ~ "?????????? ?????????????????????",
  locality == "?????????? ????????????????????" ~ "?????????? ??????????????",
  locality == "?????????? ??????????????????????????????" ~ "?????????? ????????????",
  locality == "?????????? ??????????" & region == "???????????????????????????????? ??????????????"~ "?????????? ?????????? ????????",
  locality == "?????????? ????????'????????" ~ "?????????? ???????????????????",
  locality == "?????????? ????????????????????" & region == "?????????????? ??????????????"~ "?????????? ??????????????????????",
  locality == "?????????? ??????'??????????-??????????????????????" ~ "?????????? ???????????????????-??????????????????????",
  locality == "?????????? ????????????????????" ~ "?????????? ??????????????????????????",
  locality == "?????????? ??????????????" & region == "???????????????? ??????????????"~ "?????????? ??????????",
  locality == "?????????? ????????????" & region == "???????????????????????????????? ??????????????"~ "?????????? ???????????? ??????",
  locality == "?????????? ????????" & region == "???????????????????????????? ??????????????"~ "?????????? ???????? ??????????",
  locality == "?????????? ????????????????" ~ "?????????? ????????????????",
  locality == "?????????? ????????" & region == "???????????????????????? ??????????????"~ "?????????? ???????? ??????????",
  locality == "?????????? ????????" & region == "???????????????????? ??????????????"~ "?????????? ???????? ??????????????",
  locality == "?????????? ??????????" & region == "???????????????????????? ??????????????"~ "?????????? ?????????? ??????",
  locality == "?????????? ??????????" & region == "?????????????????? ??????????????"~ "?????????? ?????????? ????????????",
  locality == "?????????? ??????????????????-????????????????????????" & region == "???????????????? ??????????????"~ "?????????? ??????????????????",
  locality == "?????????? ????????????" & region == "?????????????????? ??????????????"~ "?????????? ???????????? ??????????",
  locality == "?????????? ??????????????" & region == "?????????????? ??????????????"~ "?????????? ??????????????",
  locality == "?????????? ????????????????????????" ~ "?????????? ????????????",
  locality == "?????????? ??????????????????????" ~ "?????????? ??????????????????",
  locality == "?????????? ????????????" & region == "?????????????????? ??????????????"~ "?????????? ???????????? ????????????",
  locality == "?????????? ??????????" & region == "???????????????? ??????????????"~ "?????????? ?????????? ????",
  locality == "?????????? ????????????????????????????????" & region == "???????????????????? ??????????????"~ "?????????? ??????????????????",
TRUE~locality)
)


ds0$locality <- gsub("'", "???",ds0$locality)

ds0 <- ds0 %>% mutate(region = case_when(
  locality == "?????????? ????????????" & region == "?????????????? ??????????????"~ "???????????????????? ??????????????",
  TRUE ~region))

#+ Correcting mistakes and problems with villages-------------------------------
ds0 <- ds0 %>% mutate(locality = case_when(
  locality == "???????? ??????????????????????????????" & district == "??????????-?????????????????????????? ??????????" ~ "???????? ?????????????????????????????? ????????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ????????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "???????????????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ??????????????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????" & district == "?????????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????????? ????????????????",
  locality == "???????????? ???????????????? ???????? ??????????" & district == "?????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????? ??????????????",
  locality == "???????? ????????????????????" & district == "??????????-?????????????????????????? ??????????" ~ "???????? ???????????????????? ????????????????????",
  locality == "???????? ??????????????????" & district == "???????????????????? ??????????" ~ "?????????? ??????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "???????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ????????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "???????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ??????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ??????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????" & district == "?????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????????? ????????????",
  locality == "???????????? ???????????????? ???????? ??????????????" & district == "???????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????????? ????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "???????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ??????????",
  locality == "???????? ??????????" & district == "?????????????????????????????? ??????????" ~ "???????? ?????????? ????????",
  locality == "???????? ????????????" & district == "???????????????????????????????? ??????????" ~ "???????? ??????????????????",
  locality == "???????? ????????????" & district == "?????????????????????? ??????????" ~ "???????? ???????????? ??????????",
  locality == "???????????? ??????????????" & district == "?????????????????????????????????????????? ??????????" ~ "???????????? ?????????????? ??????",
  locality == "???????????? ??????????????????????????" & district == "?????????????????????????? ??????????" ~ "???????????? ????????????????",
  locality == "???????????? ????????????????????" & district == "???????????????????????????? ??????????" ~ "???????? ??????????????????????",
  locality == "???????????? ????????????????" & district == "???????????????????????? ??????????"~ "???????? ????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????????" & district == "???????????????????? ??????????" ~ "???????????? ???????????????? ???????? ??????????????????????",
  locality == "???????????? ???????????????? ???????? ??????????" & district == "?????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????? ????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????????????" & district == "?????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ????????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ????????????",
  locality == "???????????? ???????????????? ???????? ??????????????????????????" & district == "???????????????????? ??????????" ~ "???????????? ???????????????? ???????? ????????????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????????????????" & district == "???????????????????????????? ??????????" ~ "???????? ??????????????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "???????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ????????????",
  locality == "???????????? ???????????????? ???????? ??????????" & district == "?????????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????? ????????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ??????????????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "?????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ????????????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "???????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "???????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "???????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ????????????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "???????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ????????????",
  locality == "???????????? ???????????????? ???????? ??????????" & district == "??????'????????-?????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????? ????????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "?????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ????????????????????????",
  locality == "???????????? ???????????????? ???????? ????????" & district == "?????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????? ??????????????",
  locality == "???????????? ???????????????? ???????? ??????????????????????" & district == "???????????????????????????? ??????????" ~ "?????????? ??????????????????????",
  locality == "???????????? ???????????????? ???????? ??????????????" & district == "????????????????-???????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????????? ??????????????????",
  locality == "???????????? ???????????????? ???????? ??????????" & district == "?????????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ?????????? ????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ???????????? ????????????",
  locality == "???????????? ???????????????? ???????? ????????????" & district == "?????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ??????????????????????",
  locality == "???????????? ??????????" & district == "???????????????????????? ??????????" ~ "???????????? ?????????? ??????????????????",
  locality == "???????????? ??????????" & district == "?????????????????????? ??????????" ~ "???????????? ?????????? ??????????????",
  locality == "???????? ," & district == "???????????????????????? ??????????" ~ "???????? ??????????????",
  locality == "???????????? ??????????" & district == "?????????????????????? ??????????" ~ "???????? ??????????????",
  locality == "???????? ????????" & district == "???????????????????? ??????????" ~ "???????? ???????? ????????????????????",
  locality == "???????? ????????" & district == "?????????????????????? ??????????" ~ "???????? ???????? ??????????????",
  locality == "???????? ??????????" & district == "???????????????????????? ??????????" ~ "???????? ?????????? ????????????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????" ~ "???????? ???????????? ??????????",
  locality == "???????? ????????????" & district == "?????????????????????? ??????????" ~ "???????? ???????????? ??????????????",
  locality == "???????? ??????????????" & district == "???????????????????? ??????????" ~ "???????? ?????????????? ??????????",
  locality == "???????? ??????????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????????? ??????????????",
  locality == "???????? ??????????????" & district == "?????????????? ??????????" ~ "???????? ?????????????? ????????????????",
  locality == "???????? ??????????????" & district == "???????????????????? ??????????" ~ "???????? ?????????????? ????????????????",
  locality == "???????? ??????????????" & district == "???????????????????? ??????????" ~ "???????? ?????????????? ????????????????",
  postalCode == "47707" & district == "???????????????????????????? ??????????" ~ "???????? ????????",
  postalCode == "47703" & district == "???????????????????????????? ??????????" ~ "???????? ?????????????? ????????????????",
  locality == "???????? ????????????" & district == "???????????????????????????? ??????????" ~ "???????? ???????????? ????????????????????",
  postalCode == "35302" ~ "???????? ?????????????? ??????????????",
  locality == "???????? ??????????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????????? ??????????????",
  postalCode == "42242" ~ "???????? ?????????????? ????????????????",
  locality == "???????? ??????????????" & district == "???????????????????????? ??????????" ~ "???????? ?????????????? ????????????????",
  
  locality == "???????? ????????????" & district == "???????????????????????????? ??????????" ~ "???????? ???????????? ??????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????" ~ "???????? ???????????? ????????????????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????" ~ "???????? ???????????? ????????????",
  locality == "???????? ????????" & district == "?????????????????????????? ??????????" ~ "???????? ???????? ??????????????",
  locality == "???????? ????????????????????" & district == "???????????????????? ??????????" ~ "???????? ???????????????????? ????????????",
  locality == "???????? ??????????" & district == "?????????????? ??????????" ~ "???????? ?????????? ??????????????",
  locality == "???????? ??????????????" & district == "???????????????????????????????????????????? ??????????" ~ "???????? ?????????????? ????????",
  locality == "???????? ??????????????-??????????????????????" & district == "?????????????????????? ??????????" ~ "???????????? ??????????????-??????????????????????",
  locality == "???????? ????????????" & district == "???????????????????????????? ??????????" ~ "???????? ???????????? ??????????",
  locality == "???????? ???????????????" & district == "?????????????????????? ??????????" ~ "???????? ???????????????",
  locality == "???????? ????????????????" & district == "???????????????????????????????? ??????????" ~ "???????? ???????????????? ????????",
  locality == "???????? ????????????????????????????????" & district == "???????????????????????????? ??????????" ~ "???????? ??????????????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????" ~ "???????? ???????????? ????????????",
  locality == "???????? ??." & district == "???????????????????????????? ??????????" ~ "???????????? ???????????????? ???????? ??????????????????",
  locality == "???????? ??????????????????" & district == "????????????????-???????????????????? ??????????" ~ "???????? ?????????????????? ????????",
  locality == "???????? ????????" & district == "?????????????????????????????? ??????????" ~ "???????? ???????? ??????????????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????? ????????????",
  locality == "???????? ??????????" & district == "???????????????????????? ??????????" ~ "???????? ?????????? ????????????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????? ??????????????",
  locality == "???????? ????????" & district == "???????????????????? ??????????" ~ "???????? ???????? ????????",
  locality == "???????? ????????????????" & postalCode == "35624" ~ "???????? ???????????????? ??????????",
  locality == "???????? ??????????" & district == "?????????????????????????? ??????????" ~ "???????? ?????????? ??????????????",
  locality == "???????? ????????" & district == "?????????????????????? ??????????" ~ "???????? ???????? ??????????????????",
  locality == "???????? ????????" & district == "???????????????????????????????? ??????????" ~ "???????? ???????? ???????????????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????? ????????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????? ????????",
  locality == "???????? ????????" & district == "?????????????????????????? ??????????" ~ "???????? ???????? ????????????????",
  locality == "???????? ????????????????" & district == "?????????????????????? ??????????" ~ "???????? ????????????????",
  locality == "???????? ????????????????????" & district == "??????????-?????????????????????????? ??????????" ~ "???????? ??????????????????????????????",
  locality == "???????? ????????????" & district == "???????????????????? ??????????" ~ "???????? ???????????? ????????????",
  locality == "???????? ??????????" & district == "???????????????????????????????? ??????????" ~ "???????? ?????????? ???????????????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????" ~ "???????? ?????????? ??????????????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????" ~ "???????? ???????????? ????????????????",
  locality == "???????? ????????????" & district == "???????????????????? ??????????" ~ "???????? ???????????? ??????????",
  locality == "???????? ??????????" & district == "?????????????????????????? ??????????" ~ "???????? ?????????? ????????????????",
  locality == "???????? ??????????" & district == "?????????????????????????????? ??????????" ~ "???????? ?????????? ??????????????????????",
  locality == "???????? ????????????????????" & district == "?????????????????????????? ??????????" ~ "???????????? ????????????????????",
  locality == "???????? ????????????????????" & district == "??????????????????-???????????????????????? ??????????" ~ "???????? ??????????",
  locality == "???????? ??????????????" & district == "???????????????????? ??????????" ~ "???????? ?????????????? ??????????????",
  locality == "???????? ??????????????" & district == "???????????????????????? ??????????" ~ "???????? ?????????????? ??????????????",
  locality == "???????? ??????????????" & district == "?????????????????????????? ??????????" ~ "???????? ?????????????? ????????????",
  locality == "???????? ??????????????????" & district == "?????????????????????????? ??????????" ~ "???????? ?????????????????? ????????????",
  locality == "???????? ??????????????????????????" & district == "???????????????????????? ??????????" ~ "???????? ??????????????????????",
  locality == "???????? ?????????????????????????" & district == "?????????????????????????? ??????????" ~ "???????????? ?????????????????????????",
  
  TRUE~locality)
)

ds0 <- ds0 %>% mutate(district = case_when(
  locality == "???????? ????????????????" & district == "???????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????????? ????????????????" & district == "?????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ??????????????????????" & district == "???????????????????????????? ??????????" ~ "???????????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ??????????????????????" & district == "???????????????????? ??????????" ~ "?????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????????????????" & district == "?????????????????????? ??????????" ~ "???????????????????????????? ??????????",
  
  TRUE ~district))

ds_admin <- ds_admin %>% mutate(settlement_name_full = case_when(
  settlement_name_full == "???????? ????????????????" ~ "?????????? ????????????????",
  TRUE~settlement_name_full)
)

ds_admin$settlement_name_full <- gsub("'", "???",ds_admin$settlement_name_full)

#+ merging OSBB with admin names for ATCs---------------------------------------
d1 <- ds0 %>% 
  left_join(
    ds_admin
    ,by = c("locality" = "settlement_name_full",
            "region" = "oblast_name_full")
  )

# Unmerged cases
d1 %>% filter(is.na(raion_name) ) %>% filter(locality!="?????????? ????????") %>%
  filter(locality!="?????????? ??????????????????????") %>%
  filter(region!="?????????????????? ???????????????????? ????????") %>% View()
d1 %>% filter(is.na(raion_name) ) %>% filter(locality!="?????????? ????????") %>%
  filter(locality!="?????????? ??????????????????????") %>%
  filter(region!="?????????????????? ???????????????????? ????????") %>% nrow()


#View(d1[duplicated(d1[c("edrpou")]),])
# Duplicated cases 
d1 %>% filter(,duplicated(edrpou)) %>% 
  View()

d1 %>% filter(,duplicated(edrpou)) %>% 
  distinct(locality,.keep_all= TRUE) %>% View()

d1 %>% filter(,duplicated(edrpou)) %>% 
  filter(,district == raion_name_full) %>%
  View()
  

d1 %>% 
  filter(,district == raion_name_full) %>%
  View()




#### Managing duplicated cases ones again usig raions additionally

dups <- d1 %>%
  group_by(edrpou) %>%
  filter(dplyr::n_distinct(settlement_code) > 1) %>%
  select(,1:21) %>%
  distinct(edrpou,.keep_all = TRUE)

dups <- dups %>% mutate(district = case_when(
  locality == "???????????? ??????????" & district == "????????'?????????????? ??????????"~ "?????????????????????????? ??????????",
  locality == "???????? ?????????????????" & district == "?????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ??????????????????" & district == "???????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????????????????????" & district == "???????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "???????????????????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ??????????????????????????" & district == "???????????????????????????????? ??????????"~ "?????????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????????????" & district == "???????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????????????" & district == "?????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????????? ???????????????? ???????? ????????????????????????" & district == "???????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????????? ????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????????? ????????????????????" & district == "?????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "?????????????????????????????? ??????????"~ "?????????????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "?????????????????????????? ??????????"~ "??????????????????????? ??????????",
  locality == "???????? ??????????????" & district == "??????????-?????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "?????????????????? ??????????"~ "????????????????-???????????????????? ??????????",
  locality == "???????? ????????????" & district == "??????'??????????-?????????????????????? ??????????"~ "???????????????????-?????????????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "????????'?????????????? ??????????"~ "?????????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????" & district == "???????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "??????????-?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????????" & district == "???????????????????????????? ??????????"~ "??????????????????????? ??????????",
  locality == "???????? ????????????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "???????????????????? ??????????"~ "???????????????? ??????????",
  locality == "???????? ????????" & district == "?????????????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????? ??????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ????????????" & district == "???????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "???????????????????????????? ??????????"~ "?????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "???????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ?????????????????" & district == "???????????????????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ???????????? ????????????" & district == "???????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "???????????????????????????????? ??????????"~ "???????????????? ??????????",
  locality == "???????? ??????????????" & district == "?????????????????????????? ??????????"~ "?????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "???????????????????????????????? ??????????"~ "???????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "???????????????????? ??????????"~ "???????????????? ??????????",
  locality == "???????? ??????????" & district == "???????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "???????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "???????????????????????????? ??????????"~ "???????????????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "?????????????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????"~ "???????????????? ??????????",
  locality == "???????? ??????????" & district == "?????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "?????????????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "?????????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ??????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "???????????????????????????????????????????? ??????????"~ "?????????????????????????? ??????????",
  locality == "???????? ????????????????????????" & district == "?????????????????????????? ??????????"~ "??????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "??????????-?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "???????????????????????????? ??????????"~ "??????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????? ??????????",
  locality == "???????? ????????????????" & district == "???????????????????????? ??????????"~ "??????????-???????????????????????? ??????????",
  locality == "???????? ????????????" & district == "?????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "????????'?????????????? ??????????"~ "?????????????????????????? ??????????",
  locality == "???????? ??????????????????????????" & district == "???????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "???????????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????? ??????????",
  locality == "???????? ??????????" & district == "???????????????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "?????????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????? ????????" & district == "?????????????????????????? ??????????"~ "?????????????????? ??????????",
  locality == "???????? ??????????????" & district == "???????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "?????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ????????????????" & district == "???????????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ??????????????" & district == "?????????????????????? ??????????"~ "???????????????????????? ??????????",
  locality == "???????? ??????????????????" & district == "?????????????????????? ??????????"~ "?????????????????????????? ??????????",
  locality == "???????? ??????????" & district == "??????????-?????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ??????????????" & district == "???????????????? ??????????"~ "???????????????????????????? ??????????",
  locality == "???????? ??????????????" & district == "?????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "???????????????????????????? ??????????"~ "???????????????????????????????? ??????????",
  locality == "???????? ????????????????????" & district == "??????????-?????????????????????????? ??????????"~ "???????????????????? ??????????",
  locality == "???????? ????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????????" & district == "?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ??????????????????????" & district == "???????????????????????? ??????????"~ "?????????????????????? ??????????",
  locality == "???????? ????????????" & district == "??????????-?????????????????????????? ??????????"~ "?????????????????????? ??????????",
  
  
  
  TRUE ~district))


dups_merge <- dups %>% 
  left_join(
    ds_admin
    ,by = c("locality" = "settlement_name_full",
            "region" = "oblast_name_full",
            "district" = "raion_name_full")
  )

dups_merge %>% filter(is.na(settlement_code) )  %>% View()
dups_merge %>% filter(duplicated(edrpou))  %>% View()

dups_merge$raion_name_full <- dups_merge$district

no_dups <- d1 %>%
  group_by(edrpou) %>%
  filter(dplyr::n_distinct(settlement_code) == 1)

full_merge <- rbind(no_dups, dups_merge)

#+ Year when OSBB was created and terminated------------------------------------
full_merge <- full_merge %>% 
  mutate(registration_year = substr(registration, 1, 4),
         termination_year = substr(termination, 1, 4))

#+ Counting number of OSBB since 2015 within ATC--------------------------------
d2 <- full_merge %>% 
  group_by(hromada_code) %>% 
  mutate(sum_osbb_2020 = n() - sum(!is.na(termination_year)))

d2 <- d2 %>% 
  group_by(hromada_code) %>% 
  mutate(sum_osbb_2019 = (sum(registration_year!="2020", na.rm = TRUE)+sum(is.na(registration_year))-sum(!is.na(termination_year)&termination_year!="2020", na.rm = TRUE)),
         sum_osbb_2018 = (sum(registration_year!="2020"&registration_year!="2019", na.rm = TRUE)+sum(is.na(registration_year))-sum(termination_year!="2020"&registration_year!="2019", na.rm = TRUE)),
         sum_osbb_2017 = (sum(registration_year!="2020"&registration_year!="2019"&registration_year!="2018", na.rm = TRUE)+sum(is.na(registration_year))-sum(termination_year!="2020"&registration_year!="2019"&registration_year!="2018", na.rm = TRUE)),
         sum_osbb_2016 = (sum(registration_year!="2020"&registration_year!="2019"&registration_year!="2018"&registration_year!="2017", na.rm = TRUE)+sum(is.na(registration_year))-sum(termination_year!="2020"&registration_year!="2019"&registration_year!="2018"&registration_year!="2017", na.rm = TRUE)),
         sum_osbb_2015 = (sum(registration_year!="2020"&registration_year!="2019"&registration_year!="2018"&registration_year!="2017"&registration_year!="2016", na.rm = TRUE)+sum(is.na(registration_year))-sum(termination_year!="2020"&registration_year!="2019"&registration_year!="2018"&registration_year!="2017"&registration_year!="2016", na.rm = TRUE))
  )

ds2 <- d2 %>%
  distinct(hromada_code,.keep_all= TRUE) %>%
  select(hromada_code,
         hromada_name,
         sum_osbb_2020,
         sum_osbb_2019,
         sum_osbb_2018,
         sum_osbb_2017,
         sum_osbb_2016,
         sum_osbb_2015)

oblast_distr <- d2 %>%
  distinct(hromada_code,.keep_all= TRUE) %>%
  group_by(region_ua, region) %>%
  summarise(osbb_2020 = sum(sum_osbb_2020),
            osbb_2019 = sum(sum_osbb_2019),
            osbb_2018 = sum(sum_osbb_2018),
            osbb_2017 = sum(sum_osbb_2017),
            osbb_2016 = sum(sum_osbb_2016),
            osbb_2015 = sum(sum_osbb_2015)) 

region_distr <- d2 %>%
  distinct(hromada_code,.keep_all= TRUE) %>%
  group_by(region_ua) %>%
  summarise(osbb_2020 = sum(sum_osbb_2020),
            osbb_2019 = sum(sum_osbb_2019),
            osbb_2018 = sum(sum_osbb_2018),
            osbb_2017 = sum(sum_osbb_2017),
            osbb_2016 = sum(sum_osbb_2016),
            osbb_2015 = sum(sum_osbb_2015)) 

#+ save-data, eval=eval_chunks -------------------------------------------------
readr::write_csv(full_merge, "./data-private/derived/osbb-all.csv") #long format
readr::write_csv(ds2, "./data-private/derived/osbb-hromada.csv") #aggregated on hromada level