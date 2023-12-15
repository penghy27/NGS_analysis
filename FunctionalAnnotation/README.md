## module-10-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: December 7th, 2022  
Purpose: This program takes 3 provided commands, including input file, threshold value, output file name, and then gets a file with BLAST line, keggOrthoID, kegg Pathway ID, and KeggPathway description. The input file, alignPredicted.txt, is from module-09-penghy27, we used BLAST to find hits in the SwissProt database for the ORFs. The SwissProt IDs are species-specific, but we want to annotate to a species-independent ortholog ID.   
(Note: Here we Getting API data in Python with ```requests```)  
The steps mainly are:
1. ```get_filehandle(file=None, mode=None)``` gets input file as filehandle
2. ```getUniProtFromBlast(blast_line, threshold)``` gets uniprotein ID from BLAST  
 
3. ```loadKeggPathways()``` gets all the path IDs and their associated path descriptions.

4. ```getKeggGenes(uniprotID)``` takes a uniprotID and return the list of all keggGenes associated with that uniprotID.   
  
5. ```getKeggOrthology(keggGeneID)```gets the KEGG ortholog for one KEGG protein ID.    

6. ```getKeggPathIDs(keggOrthoID)``` gets the KEGG pathways ID associated with a KEGG ortholog.   

7. look up the path description for any pathID we have.  
8. print the output.  
  
  
## Methods  

```addKEGGPathways.py``` integrates the functions mentioned aboved and will do the following steps.
- Filter to only BLAST output where evalue < 1e-50
- Append the KEGG Ortholog ID, KEGG Pathway ID, and KEGG Pathway Description for each of the SwissProt (Uniprot) IDs
- Skip PathIDs that start with 'path:map' but include a separate line for each 'path:ko' version (repeat the BLAST data on each line)

Running the program:  
```$python3 addKEGGPathways.py --i alignPredicted.txt -n 1e-50 -o keggPathway```

Expected output:
```
TRINITY_DN21437_c0_g1_i1.p1     Q13496  132     603     132     82      62.121  1.84e-60        RecName: Full=Myotubularin; AltName: Full=Phosphatidylinositol-3,5-bisphosphate 3-phosphatase; AltName: Full=Phosphatidylinositol-3-phosphate phosphatase   ko:K01108 path:ko00562  Inositol phosphate metabolism
TRINITY_DN21437_c0_g1_i1.p1     Q13496  132     603     132     82      62.121  1.84e-60        RecName: Full=Myotubularin; AltName: Full=Phosphatidylinositol-3,5-bisphosphate 3-phosphatase; AltName: Full=Phosphatidylinositol-3-phosphate phosphatase   ko:K01108 path:ko01100  Metabolic pathways
TRINITY_DN21437_c0_g1_i1.p1     Q13496  132     603     132     82      62.121  1.84e-60        RecName: Full=Myotubularin; AltName: Full=Phosphatidylinositol-3,5-bisphosphate 3-phosphatase; AltName: Full=Phosphatidylinositol-3-phosphate phosphatase   ko:K01108 path:ko04070  Phosphatidylinositol signaling system
```

