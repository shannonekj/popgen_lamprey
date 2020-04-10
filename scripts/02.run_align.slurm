#!/bin/bash -l
#SBATCH --mail-user=gmauringer@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J alignRAD
#SBATCH -e /home/auringer/scripts_USE/err_out/01.run_align.j%j.err
#SBATCH -o /home/auringer/scripts_USE/err_out/01.run_align.j%j.out
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
proj="popgen_lamprey"
fq_prefix="Pz" # You'll have to CHANGE this
lib_prefix="BMAG0" # CHANGE

# directories 
script_dir="/home/auringer/${proj}/scripts" # CHANGE
data_dir="/home/auringer/data/" # CHANGE
out_dir="${data_dir}/01_sealamprey_alignment" # CHANGE

# files
reference="/home/auringer/sealampreygenome/GCA_010993605.1_kPetMar1.pri_genomic.fna.gz" # CHANGE


#############
###  RUN  ###
#############

# index reference genome
bwa index ${reference}
sleep 1m

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
