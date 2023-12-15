#!/usr/bin/enn bash
# runSpades.sh

mkdir -p "../results/rhodo/"

 function Spades {
     spades.py \
     -1 ../data/trimmed/paired/Rhodo.R1.paired.fastq \
     -2 ../data/trimmed/paired/Rhodo.R2.paired.fastq \
     -o ../results/rhodo
}

Spades # runs the fuction Spades

