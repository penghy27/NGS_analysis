# module-10-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: December 7th, 2022  

# Annotating SwissProt Hits with KEGG Ortholog IDs

## Overview

This project aims to annotate species-specific UniProt IDs from BLAST results with species-independent KEGG Ortholog IDs using the KEGG API. By retrieving relevant pathway information from KEGG, we can link our predicted protein sequences to biologically meaningful pathways.

## Methods

### 1. Input Data

- BLAST Results: The input file (`alignPredicted.txt`) contains the BLAST results of predicted proteins aligned to the SwissProt database.
- KEGG API: The KEGG API is used to convert UniProt IDs to KEGG Ortholog IDs and retrieve associated KEGG pathway information.

### 2. Tools Used
BLAST: Previously used to align ORFs to SwissProt.
KEGG API: Accessed via Python `requests` to retrieve KEGG Ortholog IDs and pathways.

### 3. Script: 
#### 3-1. `addKEGGPathways.py`

The core of the project is the `addKEGGPathways.py` script, which automates the annotation process. Below are the required functionalities included in the script:

- `get_args()`: Retrieves command-line arguments including input filename, e-value threshold, and output filename.
- `getUniProtFromBlast(blast_line, threshold)`: Extracts UniProt IDs from BLAST results if the e-value is below the specified threshold.
- `loadKeggPathways()`: Loads all KEGG pathways into a dictionary mapping Pathway IDs to descriptions.
- `getKeggGenes(uniprotID)`: Retrieves KEGG genes for a given UniProt ID from the KEGG API.
- `getKeggOrthology(keggGene)`: Retrieves KEGG Orthology IDs for a provided KEGG gene.
- `getKeggPathIDs(keggOrthology)`: Retrieves KEGG Pathway IDs associated with a given KEGG Orthology ID.
- `addKEGGPathways()`: Ties together the above functions to append KEGG Ortholog ID, KEGG Pathway ID, and description to each high-confidence BLAST result, skipping Path IDs that start with 'path
' and including only 'path
' versions.

#### 3-2. `test_addKEGGPathway.py`: 
Test `addKEGGPathways.py`


### Expected output:
```
TRINITY_DN21437_c0_g1_i1.p1     Q13496  132     603     132     82      62.121  1.84e-60        RecName: Full=Myotubularin; AltName: Full=Phosphatidylinositol-3,5-bisphosphate 3-phosphatase; AltName: Full=Phosphatidylinositol-3-phosphate phosphatase   ko:K01108 path:ko00562  Inositol phosphate metabolism
TRINITY_DN21437_c0_g1_i1.p1     Q13496  132     603     132     82      62.121  1.84e-60        RecName: Full=Myotubularin; AltName: Full=Phosphatidylinositol-3,5-bisphosphate 3-phosphatase; AltName: Full=Phosphatidylinositol-3-phosphate phosphatase   ko:K01108 path:ko01100  Metabolic pathways
TRINITY_DN21437_c0_g1_i1.p1     Q13496  132     603     132     82      62.121  1.84e-60        RecName: Full=Myotubularin; AltName: Full=Phosphatidylinositol-3,5-bisphosphate 3-phosphatase; AltName: Full=Phosphatidylinositol-3-phosphate phosphatase   ko:K01108 path:ko04070  Phosphatidylinositol signaling system
```

