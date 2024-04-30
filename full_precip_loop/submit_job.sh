#!/bin/bash

#BSUB -n 1 		## request nodes
#BSUB -W 360 		## work time minutes
#BSUB -J animation 	## run name
#BSUB -o out.%J 	## output
#BSUB -e err.%J 	## error
##BSUB -x ##Use exclusive only if necessary, uncomment if job spawns additional threads
module load matlab 
matlab -nodisplay -nosplash -nodesktop -singleCompThread -r "run('precip_animation.m');exit;"
