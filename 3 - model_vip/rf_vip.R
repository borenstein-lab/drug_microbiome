#==========================#
# Please set user args before running code
#==========================#
# Model name for output file names
model_name<-"your_model_name"

# Path for input feature table
input_path<- "your_input_path"

#==========================#

##load libraries
library(tidymodels)
library(ranger)
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

options(yardstick.event_first = FALSE)

message("libareis loaded")


##load data

data_model<-readRDS(model_path)  

message("data loaded")

# workflow 
#create recipe for model 13
recipe_model<- recipe(values_boolean  ~ ., data = data_model)%>%
  update_role(prestwick_ID,
              chemical_name,
              specie_name,
              drugbank_id,
              drug_class,
              p_value,
              drug_hit,
              microb_hit,
              drug_class,
              new_role = "ID")%>%
  step_normalize(all_numeric())%>%
  step_BoxCox(all_numeric())

#create random forest model with default parmeters
cores <- parallel::detectCores()
rf_model <- 
  rand_forest() %>%
  set_engine("ranger" ,  num.threads = cores, importance = "impurity") %>%
  set_mode("classification")

#create_workflow
model_rf_workflow <- workflow() %>%
  add_recipe(recipe_model) %>%
  add_model(rf_model)

message("workflow loaded")

#fit model 
final_model_fit<-fit(model_rf_workflow, data_model)

message("model fit finished")

#vip
model_vip<- importance_pvalues(final_model_fit$fit$fit$fit, method = "altmann", formula = values_boolean ~ ., data = data_model)

message("model vip finished")


#save results
file_path<-str_c("/specific/elhanan/PROJECTS/xenbiotics_YA/model_runs/in_vitro/" ,model_name, ".rds")

saveRDS(model_vip, file_path)

message("vip saved")



