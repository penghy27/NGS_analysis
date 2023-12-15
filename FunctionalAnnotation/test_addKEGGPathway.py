#!user/bin/env python3
# test_addKEGGPathway.py

"""Test behavior of addKEGGPathways.py"""

from addKEGGPathways import getUniProtFromBlast
from addKEGGPathways import getKeggGenes
from addKEGGPathways import getKeggOrthology
from addKEGGPathways import getKeggPathIDs


def test_getUniProtFromblast_belowThreshold():
    """Return UniProt ID from BLAST line."""

    blast_line = "TRINITY_DN10003_c0_g1_i1.p1	Q4G069	165	310	163	90	55.215	1.23e-61	RecName: Full=Regulator of microtubule dynamics protein 1; Short=RMD-1; AltName: Full=Protein FAM82B"
    assert getUniProtFromBlast(blast_line, "1e-30") == "Q4G069", "Expect the UniProt ID"


def test_getUniProtFromblast_aboveThreshold():
    """Return False because e-value doesn't pass the threshold."""

    blast_line = "TRINITY_DN10003_c0_g1_i1.p1	Q4G069	165	310	163	90	55.215	1.23e-61	RecName: Full=Regulator of microtubule dynamics protein 1; Short=RMD-1; AltName: Full=Protein FAM82B"

    assert getUniProtFromBlast(blast_line, "1e-70") == False, "Expect the e-value threshold to fail"


def test_getKeggGenes():
    """Get a KEGG Gene from a UniProtID."""

    assert getKeggGenes('P02649') == ['hsa:348'], "Expect a list with one entry"


def test_getKeggOrthology():
    """Get a KEGG Orthology from a KEGG Gene."""

    assert getKeggOrthology('hsa:348') == ['ko:K04524'], "Expect a list with one entry"


def test_getKeggPathIDs():
    """Get a KEGG Pathway IDs from a KEGG Orthology ID."""

    assert getKeggPathIDs('ko:K04524') == ['path:ko04979', 'path:ko05010'], "Expect a list with two entries"