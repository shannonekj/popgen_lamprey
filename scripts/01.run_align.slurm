#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J alignRAD
#SBATCH -e slurm/01.run_align.j%j.err
#SBATCH -o slurm/01.run_align.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=04:00:00
#SBATCH --mem=32G

set -e
set -v

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

###  SETUP  ###
proj="DS_history"
fq_prefix="Ht"
lib_prefix="BMAG0"

# directories
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/group/millermrgrp2/shannon/projects/${proj}/data"
out_dir="${data_dir}/10X_alignments"

# files
reference="/group/millermrgrp2/shannon/projects/genome_Hypomesus-transpacificus/data/04-supernova_out/60x/A/Hypomesus-transpacificus_10X_F_A.pseudohap2.1.fasta"


#############
###  RUN  ###
#############

# index reference genome
#bwa index ${reference}
#sleep 1m

# Make list of individuals
mkdir -p ${out_dir}
cd ${data_dir}

for i in ${lib_prefix}??
do
	echo "Navigating to ${i}"
	cd ${i}
	wc=$(wc -l indexid.list | awk '{print $1}')
	x=1
	while [ $x -le $wc ]
	do
		tagline="sed -n ${x}p indexid.list"
		tag=$($tagline)
		echo ${tag}
		cd ${tag}
		for file in ${fq_prefix}*_R1.fastq
		do
			base=$(basename ${file} _R1.fastq)
			echo ${data_dir}/${i}/${tag}/${base}_R1.fastq ${data_dir}/${i}/${tag}/${base}_R2.fastq ${base} >> ${out_dir}/list
		done
		cd ${data_dir}/${i}
		x=$(( $x + 1 ))
	done
	cd ${data_dir}
done

# submit list to launch align scripts
bash ${script_dir}/align_2019.sh ${out_dir}/list ${reference} ${out_dir}



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
