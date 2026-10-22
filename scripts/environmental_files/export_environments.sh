while read line; do 
	source ~/miniforge3/etc/profile.d/conda.sh
	conda activate ${line}
	conda env export > ${line}.yml
	conda deactivate 
done < environments.txt
