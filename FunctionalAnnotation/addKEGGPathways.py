#!/usr/bin/env python
# addKEGGPathways.py
"""
This program takes an input align predicted file, threshold value, output name
and then get an output with BLAST LINE, keggOrtho ID, keggPath ID, KEGG pathway description.
"""

import argparse
import requests
import sys
import re

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
    Returns UniProt ID from the BLAST line if the evalue is below the threshold
    Returns False if evalue is above threshold
    """
    cleaned_line = blast_line.strip()
    blast_fields = cleaned_line.split("\t")
    if float(blast_fields[7]) < float(threshold):
        uniprotID = blast_fields[1]
        return(uniprotID)
    else:
        return(False)


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
    return (keggPathways)


def getKeggGenes(uniprotID):
    """Return a list of KEGG organism:gene pairs for a provided UniProtID."""
    keggGeneID = []
    result = requests.get(f'https://rest.kegg.jp/conv/genes/uniprot:{uniprotID}')
    for entry in result.iter_lines():
        str_entry = entry.decode(result.encoding)  # convert from binary value to plain text
        fields = str_entry.split("\t")
        keggGeneID.append(fields[1])  # second field is the keggGene ID
    return(keggGeneID)


def getKeggOrthology(keggGeneID):
    """Return a list of KEGG Orthology ID for a provided KEGG ID"""
    keggOrthoID = []
    result = requests.get(f'https://rest.kegg.jp/link/ko/{keggGeneID}')
    for entry in result.iter_lines():
        str_entry = entry.decode(result.encoding)  # convert from binary value to plain text
        fields = str_entry.split("\t")
        keggOrthoID.append(fields[1])  # second field is the KEGG Orthology ID
    return(keggOrthoID)


def getKeggPathIDs(keggOrthoID):
    """
    Return a list of KEGG Path IDs from https://rest.kegg.jp/link/pathway/
    """
    keggPathID = []
    result = requests.get(f'https://rest.kegg.jp/link/pathway/{keggOrthoID}')
    for entry in result.iter_lines():
        str_entry = entry.decode(result.encoding)  # convert from binary value to plain text
        fields = str_entry.split("\t")
        if re.match('path:ko.*', fields[1]):
            keggPathID.append(fields[1])
    return(keggPathID)


def main():
    args = get_args()
    infile = args.infile
    threshold = args.number
    outfile = args.output
    fh_in = get_filehandle(infile, 'r')
    fh_out = get_filehandle(outfile, 'w')
    keggPathways = loadKeggPathways()

    for blast_line in fh_in:
        uniprotID = getUniProtFromBlast(blast_line, threshold)
        keggGeneID = getKeggGenes(uniprotID)
        keggOrthoID = getKeggOrthology(keggGeneID)
        keggPathID = getKeggPathIDs(keggOrthoID)
        keggPathDesc = keggPathways[keggPathID]
        fh_out.write(f"{blast_line}, {keggOrthoID}, {keggPathID}, {keggPathDesc}")
    # just clean up
    fh_in.close()
    fh_out.close()


if __name__ == "__main__":
    main()

