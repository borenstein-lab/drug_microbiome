#==========================#
# Please set user args before running code
#==========================#

# Model name for output file names
model_name<-"your_model_name"

# Path for input feature table
input_path<- "your_input_path"

# Path for output files
out_path <- "your_output_path"


#==========================#
print("start")

#load libraries
library(tidymodels)
library(ranger)
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

message("libraries loaded")

##load feature data (drug+microbe features)

data_model<-readRDS(input_path)  

message("data loaded")

## data spliting


# split whole data into 10 fold cv
model_data_cv<- vfold_cv(data_model, v=10, repeats = 100)

#split whole data according to microbe specie (leave one out) - evaluate on a new microbe
model_data_microb_cv<-group_vfold_cv(data_model, group = specie_name, v = 10, repeats = 100)

#split the data according to drug - evaluate on a new drug
model_data_drug_cv<-group_vfold_cv(data_model, group = prestwick_ID, v = 10, repeats = 100)

message("data splited")


## workflow 
#create recipe for model
recipe_model<- recipe(values_boolean  ~ ., data = data_model)%>%
  update_role(prestwick_ID,
              specie_name,
              new_role = "ID")%>%
  step_zv(all_numeric())

#create random forest model with default parameters
cores <- parallel::detectCores()
model <- 
  logistic_reg(penalty = .10, mixture = 0) %>%
  set_engine("glmnet" ,  num.threads = cores)

#create_workflow
model_workflow <- workflow() %>%
  add_recipe(recipe_model) %>%
  add_model(model)

message("workflow loaded")

#==========================#
# new interactions scenario
#==========================#

message("run new interactions")


model_cv_results<- fit_resamples(model_workflow, model_data_cv, 
                                 control = control_resamples(save_pred = TRUE),
                                 metrics = metric_set(roc_auc, j_index, sens, spec, precision, kap, pr_auc))

# collect metrics
cv_metrics<-collect_metrics(model_cv_results)%>%
  mutate(model_name = model_name,
         model_type = "new interactions")

#collect predictions from the test set to form confusion Matrix
model_cv_predictions <-collect_predictions(model_cv_results)%>%
  mutate(model_name = model_name,
         model_type = "new interactions")

#save metrics and predictions 
name_for_metrics_save<-str_c(out_path, model_name, "_new_interactions", "_metrics.rds")
name_for_predictions_save<-str_c(out_path, model_name, "_new_interactions", "_predictions.rds")

saveRDS(cv_metrics,name_for_metrics_save )
saveRDS(model_cv_predictions,name_for_predictions_save )

message("save new_interactions")

#==========================#
## New microbe scenario
#==========================#

message("run new microbe")

model_microb_cv_results<- fit_resamples(model_workflow, model_data_microb_cv, 
                                        control = control_resamples(save_pred = TRUE),
                                        metrics = metric_set(roc_auc, j_index, sens, spec, precision, kap))

#collect metrics
microb_metrics<-collect_metrics(model_microb_cv_results)%>%
  mutate(model_name = model_name,
         model_type = "microb")

#collect predictions from the test set to form confusion Matrix
model_microb_predictions <-collect_predictions(model_microb_cv_results)%>%
  mutate(model_name = model_name,
         model_type = "microbe")

#save metrics and predictions 

name_for_metrics_save<-str_c(out_path, model_name, "_microb", "_metrics.rds")
name_for_predictions_save<-str_c(out_path, model_name, "_microb", "_predictions.rds")

saveRDS(microb_metrics,name_for_metrics_save )
saveRDS(model_microb_predictions,name_for_predictions_save )
message("save new microbe")

#==========================#
##new drug scenario
#==========================#

message("run drug")

model_drug_cv_results<- fit_resamples(model_workflow, model_data_drug_cv, 
                                      control = control_resamples(save_pred = TRUE),
                                      metrics = metric_set(roc_auc, j_index, sens, spec, precision, kap, pr_auc))

#collect metrics
drug_metrics<-collect_metrics(model_drug_cv_results)%>%
  mutate(model_name = model_name,
         model_type = "drug")

#collect predictions from the test set to form confusion Matrix
model_drug_predictions <-collect_predictions(model_drug_cv_results)%>%
  mutate(model_name = model_name,
         model_type = "drug")

#save metrics and predictions 

name_for_metrics_save<-str_c(out_path, model_name, "_drug", "_metrics.rds")
name_for_predictions_save<-str_c(out_path, model_name, "_drug", "_predictions.rds")

saveRDS(drug_metrics,name_for_metrics_save )
saveRDS(model_drug_predictions,name_for_predictions_save )

message("save new drug")
message("Finished!")


