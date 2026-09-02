# KyrPARK genetic analysis

`GP2 ❤️ Open Science 😍`

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![DOI](https://zenodo.org/badge/DOI/nnnnn/zenodo.nnnnn.svg)](https://doi.org/nnnnn/zenodo.nnnnn)

**Last updated:** August 2026

## Summary

This repository contains code used for the initial genetic analyses reported in the KyrPARK manuscript.

The workflow processes GP2 genotype data for KyrPARK participants assigned to Central Asian (CAS), East Asian (EAS), and European (EUR) ancestry groups. The ancestry-specific datasets are converted to PLINK format and merged, reference alleles are harmonised to the GRCh38/hg38 reference genome, selected Parkinson's disease-related genes are extracted, allele frequencies are calculated, and variants are prepared for annotation.

The analyses reported from this workflow are descriptive and relate to the initial batch of genotyped KyrPARK samples. They are not intended as a comprehensive genetic association analysis.


## Data statement
Data used in the preparation of this article were obtained from the Global Parkinson’s Genetics Program (GP2; https://gp2.org).

All GP2 data are hosted in collaboration with the Accelerating Medicines Partnership in Parkinson’s disease, and are available via application on the website (https://amp-pd.org/register-for-amp-pd). For up-to-date information on GP2 data acquisition, access, and policies, visit https://gp2.org/. Tier 1 data can be accessed by completing a form on the Accelerating Medicines Partnership in Parkinson’s Disease (AMP®-PD) website (https://amp-pd.org/register-for-amp-pd). Tier 2 data access requires approval and a Data Use Agreement signed by your institution. In this analysis we used Tier 1 GP2 Release 9 data ([10.5281/zenodo.14510099](https://doi.org/10.5281/zenodo.14510099))

### Helpful Links

- [GP2 Website](https://gp2.org/)
  - [GP2 Cohort Dashboard](https://gp2.org/cohort-dashboard-advanced/)
- [Introduction to GP2](https://movementdisorders.onlinelibrary.wiley.com/doi/10.1002/mds.28494)
  - [Other GP2 Manuscripts (PubMed)](https://pubmed.ncbi.nlm.nih.gov/?term=%22global+parkinson%27s+genetics+program%22)

## Repository Orientation
- The `analysis/` directory includes all analyses discussed in the manuscript.

<pre> THIS_REPO/ 
  ├── analyses/ 
  |     └── KGPAR.sh
  ├── LICENSE
  └── README.md 
</pre>

### `KGPAR.sh` script

Main shell script for processing and annotating the initial KyrPARK genetic dataset.

The script performs the following steps:

1. Converts ancestry-specific GP2 genotype datasets for CAS, EAS, and EUR participants from PLINK 2 format to binary PLINK format.
2. Merges the ancestry-specific datasets into a combined KyrPARK dataset.
3. Checks and corrects reference-allele and strand orientation against the GRCh38/hg38 reference genome.
4. Extracts genomic regions corresponding to selected Parkinson's disease-related genes:
   - `LRRK2`
   - `SNCA`
   - `VPS35`
   - `GBA1`
   - `PRKN`
   - `PINK1`
   - `ATP13A2`
   - `RAB29`
5. Calculates genotype/allele-frequency summaries for each extracted region.
6. Converts the resulting datasets to VCF format and sorts the VCF files.
7. Performs VCF validation and normalisation.
8. Annotates variants using ANNOVAR and the specified annotation databases.

## Input data

The script uses ancestry-stratified KyrPARK genotype datasets from GP2 Release 9:

- `KGPAR_CAS_release9`
- `KGPAR_EAS_release9`
- `KGPAR_EUR_release9`

Access to the underlying individual-level GP2 data is governed by GP2/AMP PD data-access procedures and the applicable participant consent, ethics, and data-governance requirements.

The GRCh38/hg38 human reference genome (`hg38.fa`) is required for reference-allele checking and variant normalisation but is not distributed with this repository.

## Gene regions examined

The script extracts the following genomic intervals on GRCh38/hg38:

| Gene | Chromosome | Start | End |
|---|---:|---:|---:|
| LRRK2 | 12 | 40224997 | 40369285 |
| SNCA | 4 | 89724099 | 89837161 |
| VPS35 | 16 | 46656132 | 46689178 |
| GBA1 | 1 | 155234452 | 155241249 |
| PRKN | 6 | 161347417 | 162727766 |
| PINK1 | 1 | 20633458 | 20651511 |
| ATP13A2 | 1 | 16985958 | 17011928 |
| RAB29 | 1 | 205767986 | 205775482 |

## Variant annotation

Variants are annotated with ANNOVAR using GRCh38/hg38 and the following annotation resources specified in the analysis script:

- RefGene
- dbSNP build 151 (`avsnp151`)
- dbNSFP 4.7a
- gnomAD v4.1 genome
- gnomAD v4.1 exome
- ClinVar release 2024-06-11
- ExAC 0.3
- 1000 Genomes August 2015 all-population dataset

The script does not itself generate a new clinical classification of variants. Interpretation and reporting of variants in the manuscript should follow the classification approach described in the manuscript and Supplementary Table S9.

## Software requirements

The analysis was performed in a Linux/SLURM environment.

The script loads the following software modules:

- PLINK
- PLINK 2
- QCTOOL
- ANNOVAR
- BCFtools
- SAMtools
- VCFtools

Additional commands used by the workflow include:

- `flippyr`
- `vcf-sort`
- `vcf-validator`

## Computing environment

The supplied SLURM script requests:

- 1 compute node
- 10 CPU cores
- 10 GB RAM
- 100 GB local scratch storage
- maximum run time of 6 hours

These resource requests reflect the computing environment used for the analysis and are not necessarily minimum requirements.

## Main outputs

The workflow produces:

- merged ancestry datasets;
- reference-allele/strand-harmonised PLINK datasets;
- gene-specific PLINK datasets;
- genotype-frequency output for each selected gene;
- gene-specific VCF files;
- normalised and validated VCF files;
- ANNOVAR multi-annotation output.

Results from this workflow contribute to the genetic quality-control and descriptive variant-screening results reported in the manuscript and supplementary material.

## Reproducibility and data access

The analysis code is provided openly to document the analytical workflow. Individual-level genotype data are not included in this repository.
Researchers wishing to reproduce analyses using GP2 data must obtain the relevant data through the applicable GP2/AMP PD access mechanism.


## Software
| **Software** | **Version(s)** | **Resource URL** | **RRID** | **Notes** |
|--------------|----------------|------------------|----------|-----------|
|ANNOVAR|d.06.08.2020|http://www.openbioinformatics.org/annovar/|RRID:SCR_012821|Used for variant annotation.|
|BCFtools|v.1.17+|http://samtools.sourceforge.net/mpileup.shtml|RRID:SCR_005227|Used for genomic file manipulation.|
|PLINK|v.1.9,v. 2.0|http://www.nitrc.org/projects/plink|RRID:SCR_001757|Used for genetic analyses.|
|SAMtools|latest|http://samtools.sourceforge.net/mpileup.shtml|RRID:SCR_005227|Used for genomic file manipulation.|
|VCFtools|latest|https://vcftools.github.io/index.html|SCR_001235| Used for processing VCF data.|