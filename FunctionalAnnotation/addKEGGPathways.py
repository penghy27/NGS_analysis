#!/usr/bin/env python
# addKEGGPathways.py
"""
This program takes an input align predicted file, threshold value, output name
and then get an output with BLAST LINE, keggOrtho ID, keggPath ID, KEGG pathway description.
"""

import re
import argparse
import requests
import sys

def get_args():
    """Return parsed command-line arguments."""

    parser = argparse.ArgumentParser(
        description="Provide an input file, threshold value, and the output name",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-i', '--infile',
                        metavar='INFILE',
                        help='Give an input file',
                        type=str,
                        default='short_alignPredicted.txt',
                        required=False
                        )

    parser.add_argument('-n', '--number',
                        metavar='INT',
                        help='Give a threshold value',
                        type=int,
                        default=1e-50,
                        required=False
                        )

    parser.add_argument('-o', '--output',
                        metavar='OUTPUT',
                        help='Give an output file name',
                        default='keggPathway.txt',
                        required=False
                        )

    return(parser.parse_args())


def get_filehandle(file=None, mode=None):
    """
    filehanlde: get_filehandle(infile, "r")
    This function opens the input file and returns filehandle
    """
    try:
        fobj = open(file, mode)
        return fobj
    except OSError:
        print(f"Could not open the file: {file} for type '{mode}", file=sys.stderr)
        raise
    except ValueError:
        print(f"Could not open the file: {file} for type '{mode}", file=sys.stderr)
        raise


def getUniProtFromBlast(blast_line, threshold):
    """
    Returns UniProt ID from the BLAST line if the e-value is below the threshold.
    Returns False if e-value is above threshold
    """
    cleaned_line = blast_line.strip()
    blast_fields = cleaned_line.split("\t")
    if float(blast_fields[7]) < float(threshold):
        uniprotID = blast_fields[1]
        return uniprotID
    else:
        return False


def loadKeggPathways():
    """
    Return dictionary of key=pathID, value=pathway name from http://rest.kegg.jp/list/pathway/ko
    Example: keggPathways["path:ko00564"] = "Glycerophospholipid metabolism"
    """
    keggPathways = {}
    result = requests.get('https://rest.kegg.jp/list/pathway/ko')
    for entry in result.iter_lines():
        str_entry = entry.decode(result.encoding)  # convert from binary value to plain text
        fields = str_entry.split("\t")
        keggPathways[fields[0]] = fields[1]
    return keggPathways


def getKeggGenes(uniprotID):
    """Return a list of KEGG organism:gene pairs for a provided UniProtID."""
    keggGeneID = []
    result = requests.get(f'https://rest.kegg.jp/conv/genes/uniprot:{uniprotID}')
    for entry in result.iter_lines():
        str_entry = entry.decode(result.encoding)  # convert from binary value to plain text
        fields = str_entry.split("\t")
        keggGeneID.append(fields[1])  # second field is the keggGene ID
    return keggGeneID


def getKeggOrthology(keggGeneID):
    """Return a list of KEGG Orthology ID for a provided KEGG ID"""
    keggOrthoID = []
    result = requests.get(f'https://rest.kegg.jp/link/ko/{keggGeneID}')
    for entry in result.iter_lines():
        str_entry = entry.decode(result.encoding)  # convert from binary value to plain text
        fields = str_entry.split("\t")
        # new lines below
        if re.match('path:ko.*', fields[1]):
            keggOrthoID.append(fields[1])  # second field is the KEGG Orthology ID
    return keggOrthoID


def addKEGGPathway(infile, threshold, outfile):
    """
    Read BLAST results, find KEGG Pathyway IDs, and write the output to a file
    """
    keggPathways = loadKeggPathways()

    with get_filehandle(infile, "r") as in_fh, get_filehandle(outfile, "w") as out_fh:
        for line in in_fh:
            unitprotID = getUniProtFromBlast(line, threshold)
            if unitprotID:
                keggGenes = getKeggGenes(unitprotID)
                for gene in keggGenes:
                    keggOrthos = getKeggOrthology(gene)
                    for ortho in keggOrthos:
                        keggPaths = getKeggPathIDs(ortho)
                        for path in keggPaths:
                            pathway_description = keggPathways.get(path, "Unknown Pathway")
                            out_fh.write(f"f{line.strip()}\t{ortho}\t{path}\t{pathway_description}\n")


if __name__ == "__main__":
    args = get_args()
    addKEGGPathway(args.infile, args.number, args.output)

