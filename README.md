

**Welcome!**  

This repository contains the analysis code for:   
"A data-driven approach for predicting the impact of drugs on the human microbiome" by Y.M Algavi and E. Borenstein  
doi: https://doi.org/10.1101/2022.10.08.510500 

**Abstract**  
Many medications can negatively impact the bacteria residing in our gut, depleting beneficial species, and causing adverse effects. To guide personalized pharmaceutical treatment, a comprehensive understanding of the impact of various drugs on the gut microbiome is needed, yet, to date, experimentally challenging to obtain. Towards this end, we developed a data-driven approach, integrating information about the chemical properties of each drug and the genomic content of each microbe, to systematically predict drug-microbiome interactions. We show that this framework successfully predicts outcomes of in-vitro pairwise drug-microbe experiments, as well as drug-induced microbiome dysbiosis in both animal models and clinical trials. Applying this methodology, we systematically map a large array of interactions between pharmaceuticals and human gut bacteria and demonstrate that medications’ anti-microbial properties are tightly linked to their adverse effects. This computational framework has the potential to unlock the development of personalized medicine and microbiome-based therapeutic approaches, improving outcomes and minimizing side effects. 

**System requirements**

python3
RDKit in conda enviroment - packge spacific instractions can be found here - https://github.com/rdkit/rdkit/blob/master/Docs/Book/Install.md\.

R version 4.0.2 (2020-06-22)    
tidyverse_2.0.0    
vegan_2.6-2     
glmnet_4.1-4         
forcats_1.0.0            
readr_2.1.2           
vip_0.3.2           
kernlab_0.9-30           
RColorBrewer_1.1-3         
ranger_0.13.1       
yardstick_0.0.9       
workflows_0.2.4       
tune_0.1.6         
tidyr_1.2.0         
infer_1.0.4         
tibble_3.1.6        
rsample_1.1.0          
recipes_0.2.0       
purrr_0.3.4           
parsnip_0.2.0      
dplyr_1.0.8          
tidymodels_0.1.4         
ggplot2_3.3.5          

**Installation guide**    

Download repo using: 
````
git clone https://github.com/borenstein-lab/drug_microbiome.git 
````
 

**Scripts and files overview**    
These scripts allow for replicating the results presented in the paper. 
Please see more specific instructions within each folder.
The scripts and files included in this repository are detailed below according to their role in the manuscript:  

1 - data_preprocessing  
- get_drug_descriptors.ipynb - Calculates physio-chemical drug descriptors from SMILES   
- get_tc_distance.ipynb - Calculates Tanimoto similarity matrix between drugs from SMILES  

2 - model_training_and_validation  
- rf_model.R - Estimate RF model performance in predicting drug impact across three scenarios - new interactions, new drugs, and new microbes.  
- lasso_model.R - Conduct the analysis above using lasso logistic regression  
- ridge_model. R - Analyze using ridge logistic regression  
- elastic_net_model.R - Analyze using ENT regression  
- svm_rbf_model.R - Analyze using the SVM RBF model  
- svm_poly_model.R - Analyze using the SVM poly model  
- drug_loo_tc_cutoff_selection.R - leave-one-drug-out while excluding all compounds that are similar to the predicted drug using several TC similarity thresholds    

3 - model_vip 
 - rf_vip.R - Calculate variable importance for the RF model  
  
4 - large_scale_drug_impact
- predict_on_new_drug_microbiome_interactions.R - predict the impact of drugs on multiple drug-microbe combinations   
  

tanimoto_distance_matrix_wide.rds






