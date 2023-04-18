This folder contains code for calculating drug properties and distance matrix from SMILES representation using RDKit.    
Please see RDKit installation instructions here: https://github.com/rdkit/rdkit/blob/master/Docs/Book/Install.md\.    
The notebooks above were run in a python3 conda environment.  

SMILES for DrugBank compounds could be retrieved with an academic license (free).  
More info on DrugBank license can be found here: https://www.drugbank.com/academic_research  

This folder contains pre-processing files:  
1. get_drug_descriptors.ipynb - Calculates physical-chemical descriptors from SMILES  
- Input: list of drugbank ids and their SMILES  
- Output: a table with calculated physical-chemical descriptors  
2. get_tc_distance.ipynb - Calculates TC distance from SMILES  
- Input: list of drugbank ids and their SMILES  
- Output: a similarity matrix between the drugs   
3. list_example.csv - example for input  
