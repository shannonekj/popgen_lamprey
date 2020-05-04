#!/bin/bash -l
#SBATCH --mail-user=gmauringer@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J coverage
#SBATCH -e /home/auringer/scripts/err_out/01.run_coverage.j%j.err
#SBATCH -o /home/auringer/scripts/err_out/01.run_coverage.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=2-20:00:00

set -e
set -v

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

###  SETUP  ###
proj="popgen_lamprey"
align="01_sealamprey_alignment"

# directories 
script_dir="/home/auringer/${proj}/scripts" # CHANGE
align_dir="/home/auringer/${proj}/align/${align}" # CHANGE

cd ${align_dir}

touch bamlist.txt

ls *.sort-n.fixmate-m.sort.markdup-r.bam  > bamlist.txt

cat bamlist.txt | while read line
do samtools depth -a  $line | awk '{sum+=$3} END { print "Average = ", sum/NR}' >> bamlist.cov
done

end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
