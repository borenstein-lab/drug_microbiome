#==========================#
# Please set user args before running code
#==========================#

# Model name for output file names
model_name<-"your_model_name"

# Path for input feature table with drug impact labels - the model will be trained on this data
labeled_input_path<- "your_input_path"

# Path for input drug features - the model will predict the impact on these drugs
feature_table_landscape_drugs <- "your_input_path"

# Path for input microbe features - the model will predict the impact on these microbes
feature_table_landscape_microbes <- "your_input_path"

# Path for output files
out_path <- "your_output_path"


#==========================#

##load libraries
library(tidymodels)
library(ranger)
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

options(yardstick.event_first = FALSE)
message("libraries loaded")

##load data
data_model<-readRDS(labeled_input_path)
feature_table_landscape_drugs <- readRDS(non_labeled_drug_feature)
feature_table_landscape_microbes <- readRDS(non_labeled_taxa_feature)

message("data loaded")

#organize data - to heavy to preform on PC

feature_table_landscape <- full_join(feature_table_landscape_drugs, feature_table_landscape_microbes , by = character())

### arrange columns - tidy models will throw errors if columns in train data and new data isn't the same ###

#chack which columns are unique in each table
columns_in_new_data<- colnames(feature_table_landscape) 
columns_in_train_data<-colnames(data_model) 

column_unique_in_train_data<-setdiff(columns_in_train_data,columns_in_new_data) # column apper only in traning data
column_unique_in_new_data<-setdiff(columns_in_new_data,columns_in_train_data) # column apper only in new data

message(str_c("column_unique_in_train_data", column_unique_in_train_data, "\n", sep = " "))
message(str_c("column_unique_in_new_data", column_unique_in_new_data, "\n", sep = " "))

#filter out uniuqe features missing from training data - maybe there is a better way to do it!!
new_data_modified<-select(feature_table_landscape, -all_of(column_unique_in_new_data))

#crate dummy varibles in new data to prevent tidymodels errors (this varibles are IDs, howeever there is might be a better way)
new_data_modified[column_unique_in_train_data]<-NA

message("data oregenized")

## workflow 
#create recipe for model 13
recipe_model<- recipe(values_boolean  ~ ., data = data_model)%>%
  update_role(drugbank_id,
              new_role = "ID")%>%
  step_normalize(all_numeric())%>%
  step_BoxCox(all_numeric())

#create random forest model with default parameters
cores <- parallel::detectCores()
rf_model <- 
  rand_forest() %>%
  #set_args(mtry = tune(), trees = tune()) %>%
  set_engine("ranger" ,  num.threads = cores, importance = "impurity") %>%
  set_mode("classification")

#create_workflow
model_rf_workflow <- workflow() %>%
  add_recipe(recipe_model) %>%
  add_model(rf_model)

message("workflow loaded")

#train model on train data
final_model<-fit(model_rf_workflow, data_model )

message("model fitted")

#predict on new data
model_prediction<-predict(final_model, new_data = new_data_modified, type = "raw")%>%
  .$predictions%>%
  as_tibble()

message("data predicted")

#arrange output - tidy data and add asv names
model_prediction_output<-dplyr::rename(model_prediction, pred_0 = `0`,pred_1 = `1`)%>%
  bind_cols(model_prediction, feature_table_landscape)%>%
  select(drugbank_id, specie_name, pred_0, pred_1)

#return
saveRDS(model_prediction_output, out_path)

message("Finished!")