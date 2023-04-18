#==========================#
# Please set user args before running code
#==========================#
# Model name for output file names
drug_id<-"your_drugbank_id"

# Chosen TC cutoff
input_path<- "selected_tc_distance_cutoff"

# Path for input feature table
feature_table_path <- "feature_table_path"

# Path for input TC distance matrix
tc_distance_matrix_path <- "tc_distance_matrix_path"

# Path for output files
output_path <- "your_output_path"

#==========================#


#load libraries
library(tidymodels)
library(ranger)
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

options(yardstick.event_first = FALSE)

message("libareis loaded")

##load data
args<-commandArgs(trailingOnly = TRUE)

data_model<-readRDS(feature_table_path)  
distance_matrix<-readRDS(tc_distance_matrix_path)

message("data loaded")

## distance filtering 
non_close_drugs<-distance_matrix%>%
  select(drugbank_id , all_of(drug_id))%>%
  rename(distance = !!sym(drug_id))%>% #change the name of the drug_id 
  filter(distance<=distance_cutoff)

n_non_close_drugs <- length(unique(non_close_drugs$drugbank_id))

mean_5_distance<-non_close_drugs%>%
  slice_max(., order_by = distance, n=5)%>%
  summarise(mean_5_distance = mean(distance))

closest_mol<-non_close_drugs%>%
  slice_max(., order_by = distance, n=1)%>%
  select(distance)

## data filtering
predicted_data<-data_model%>%
  filter(drugbank_id == drug_id)

fitted_data<-data_model%>%
  filter(data_model$drugbank_id %in% non_close_drugs$drugbank_id)
  
message("data splited")


## workflow 
#create recipe for model 13
recipe_model<- recipe(values_boolean  ~ ., data = data_model)%>%
  update_role(prestwick_ID,
              drugbank_id,
              new_role = "ID")%>%
  step_zv(all_numeric())



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

#fit on non-close drugs and predict on new data 
message("run drug")

final_model<-fit(model_rf_workflow, fitted_data )

model_prediction<-predict(final_model, new_data = predicted_data, type = "raw")%>%
  .$predictions%>%
  as_tibble()%>%
  dplyr::rename(pred_1 = "1",
                pred_0 = "0")%>%
  bind_cols(., predicted_data)%>%
  mutate(. , mean_5_distance = mean_5_distance[[1]],
         closest_distance = closest_mol[[1]][1],
         distance_cutoff=distance_cutoff[[1]],
         n_non_close_drugs=n_non_close_drugs[[1]])

#save data
name_for_predictions_save<-str_c(output_path, drug_id, "_", distance_cutoff, "_predictions.rds")

saveRDS(model_prediction,name_for_predictions_save )
message("Finished")
