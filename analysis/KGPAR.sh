#! /bin/bash
# Parameters for slurm (don't remove the # in front of #SBATCH!)
#  Use partition short-term:
#SBATCH --partition=shortterm
#  Use one node:
#SBATCH --nodes=1
#  Request 10 cores (hard constraint):
#SBATCH -c 10
#  Request 10GB of memory (hard constraint):
#SBATCH --mem=10GB
#  Request one day maximal execution time (hard constraint):
#SBATCH --time=0-6:0:0
#  Request 100 GB of local scratch disk (hard constraint):
#SBATCH --tmp=100G


#Initialize the module system:
source /etc/profile.d/modules.sh
# Allow aliases (required by some modules):
shopt -s expand_aliases
# Load your necessary modules (example):
module load plink
module load plink2
module load qctool
module load annovar
module load bcftools
module load samtools
module load vcftools


## Convert to plink format and merge different ancestries into one dataset
plink2 --pfile KGPAR_CAS_release9 --make-bed --out KGPAR_CAS_release9
plink2 --pfile KGPAR_EAS_release9 --make-bed --out KGPAR_EAS_release9
plink2 --pfile KGPAR_EUR_release9 --make-bed --out KGPAR_EUR_release9

plink --bfile KGPAR_CAS_release9 --bmerge KGPAR_EAS_release9 --make-bed --out KGPAR_CAS_EAS_release9
plink --bfile KGPAR_CAS_EAS_release9 --bmerge KGPAR_EUR_release9 --make-bed --recode --out KGPAR_CAS_EAS_EUR_release9


## Fix ref alleles that do not match fasta reference
# Run flippyr
flippyr -m hg38.fa KGPAR_CAS_EAS_EUR_release9.bim

# Run strand flip to get read ref alleles
plink --bfile KGPAR_CAS_EAS_EUR_release9 --make-bed  --real-ref-alleles --exclude KGPAR_CAS_EAS_EUR_release9_Ref-strand-fix.delete --flip KGPAR_CAS_EAS_EUR_release9_Ref-strand-fix.flip --a2-allele KGPAR_CAS_EAS_EUR_release9_Ref-strand-fix.allele 1 2 --out KGPAR_CAS_EAS_EUR_release9_flipped
plink --bfile KGPAR_CAS_EAS_EUR_release9 --make-bed  --real-ref-alleles --flip KGPAR_CAS_EAS_EUR_release9_Ref-strand-fix.flip --a2-allele KGPAR_CAS_EAS_EUR_release9_Ref-strand-fix.allele 1 2 --out KGPAR_CAS_EAS_EUR_release9_flipped2

## Extract PD genes with flipped files
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 12 --from-bp 40224997 --to-bp 40369285 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 4 --from-bp 89724099 --to-bp 89837161 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 16 --from-bp 46656132 --to-bp 46689178 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 1 --from-bp 155234452 --to-bp 155241249 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 6 --from-bp 161347417 --to-bp 162727766 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 1 --from-bp 20633458 --to-bp 20651511 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 1 --from-bp 16985958 --to-bp 17011928 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --chr 1 --from-bp 205767986 --to-bp 205775482 --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29

# Calculate frequencies
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2 --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35 --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1 --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1 --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2 --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2-freqx
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29 --freqx --out KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29-freqx


## Make vcf files for each PD gene
plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_LRRK2_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_SNCA_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_VPS35_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_GBA1_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_PRKN_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_PINK1_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_ATP13A2_SNPs-with-ref_sorted.vcf

plink2 --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29 --ref-from-fa --fa hg38.fa --make-bed --out KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29_SNPs-with-ref
plink --bfile KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29_SNPs-with-ref --recode vcf --real-ref-alleles --out KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29_SNPs-with-ref
vcf-sort KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29_SNPs-with-ref.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_RAB29_SNPs-with-ref_sorted.vcf


## Annotation for each PD gene ($1)
# First vcf-validation step
vcf-validator -u KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation_vcf_val_1.txt

# Separate into records and second vcf-validation step
bcftools norm -m-both -o KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.step1.vcf KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.vcf
vcf-validator -u KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.step1.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation_vcf_val_2.txt

# Left normalize bigger INDELs according to hg38 and third vcf-validation step
bcftools norm -f hg38.fa -o KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.step2.vcf KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.step1.vcf
vcf-validator -u KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.step2.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation_vcf_val_3.txt

# Annotate variants with Annovar
table_annovar.pl KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation.step2.vcf \
-buildver hg38 \
-out Results_KGPAR_CAS_EAS_EUR_release9_flipped2_$1 \
-remove \
-protocol refGene,avsnp151,dbnsfp47a,gnomad41_genome,gnomad41_exome,clinvar_20240611,exac03,1000g2015aug_all \
-operation g,f,f,f,f,f,f,f \
-nastring . \
-polish \
-vcfinput
vcf-validator -u Results_KGPAR_CAS_EAS_EUR_release9_flipped2_$1.hg38_multianno.vcf > KGPAR_CAS_EAS_EUR_release9_flipped2_$1_annotation_vcf_val_final.txt
