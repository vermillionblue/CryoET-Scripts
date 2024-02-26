#!/bin/bash
set -x
######################
# tested with imod_4.11.12

#### user inputs ######
#### aqusition pameters #####	
    pix="1.57"                 # pixel size in nanometers
    dose="4"                    # total dose per tilt in e/Å^2    
#### file names and pathes ####
    pd="2"   			        # number of zeros to pad tomo number 
	pfx="ts" 			        # prexif of tilt series
	aligned="aligned"           # aligned stacks suffix 
    dosefilt="dose-filt"       # dose-filtered stacks suffix  
    basepath="${PWD}"		    # root directory. 
	frames_dir="frames"			    # folder with frames movies 
	gain="frames/CountRef_apf3_22_001_0.0.mrc"	# path and name of gain ref
	stat_dir="alignframes"		# alignframes output stats dir
	mdir="mdocs"		    # path to mdoc files 
    mext="st.mdoc"              # mdoc extension     
    tomodir="tomograms"         # common dir for processed stacks 
#### prepare pathes  ####
     i="$(printf "%0${pd}d" $1)" 		                # zero pad stack id
     stack_dir="${tomodir}/${pfx}_${i}"          # stack output 
     alignstat_dir="${stack_dir}/${stat_dir}"                       # align stat dir  
     mdoc_file="${mdir}/${pfx}_${i}.${mext}"       # mdoc 
     

##### functions ##### 		
### create non-existent folders
testmkdir(){
if [[ ! -d "$1" ]]; then
	mkdir "$1"
fi
}

### prepare folders 
testmkdir "${tomodir}"
testmkdir "${stack_dir}"
testmkdir "${alignstat_dir}"

### create aligned stack
alignframes \
    -MetadataFile "${mdoc_file}" \
    -AdjustAndWriteMdoc \
    -PathToFramesInMdoc "${frames_dir}" \
    -PairwiseFrames -1 \
    -AlignAndSumBinning 1,1 \
    -TotalScalingOfData 39.3 \
    -TestBinnings 1,2,3 \
    -VaryFilter 0.167,0.125,0.10,0.06 \
    -FilterSigma2 0.0086 \
    -ShiftLimit 40 \
    -TransformExtension "${aligned}.xf" \
    -FRCOutputFile "${alignstat_dir}/${i}_${aligned}_FRC.txt" \
    -PlottableShiftFile "${alignstat_dir}/${i}_${aligned}_plot.txt" \
    -DebugOutput 3 \
    -TruncateAbove 7 \
    -GainReferenceFile "${gain}" \
    -RotationAndFlip -1 \
    -RefineAlignment 5 \
    -RefineRadius2 0.167 \
    -StopIterationsAtShift 0.1 \
    -UseGPU 0 \
    -OutputImageFile "${stack_dir}/${i}_${aligned}.st"
    
### extract rawtlt file for aligned stack
extracttilts \
    -InputFile "${stack_dir}/${i}_${aligned}.st" \
    -OutputFile "${stack_dir}/${i}_${aligned}.rawtlt"

### create dose filtered stack
alignframes \
    -MetadataFile "${stack_dir}/${i}_${aligned}.${mext}" \
    -AdjustAndWriteMdoc \
    -PathToFramesInMdoc "${frames_dir}" \
    -PairwiseFrames -1 \
    -AlignAndSumBinning 1,1 \
    -TotalScalingOfData 39.3 \
    -TestBinnings 1,2,3 \
    -VaryFilter 0.167,0.125,0.10,0.06 \
    -FilterSigma2 0.0086 \
    -ShiftLimit 40 \
    -TransformExtension "${dosefilt}.xf" \
    -FRCOutputFile "${alignstat_dir}/${i}_${dosefilt}_FRC.txt" \
    -PlottableShiftFile "${alignstat_dir}/${i}_${dosefilt}_plot.txt" \
    -DebugOutput 3 \
    -TruncateAbove 7 \
    -GainReferenceFile "${gain}" \
    -PixelSize "${pix}" \
    -FixedTotalDose "${dose}" \
    -RotationAndFlip -1 \
    -RefineAlignment 5 \
    -RefineRadius2 0.167 \
    -StopIterationsAtShift 0.1 \
    -UseGPU 0 \
    -OutputImageFile "${stack_dir}/${i}_${dosefilt}.st"
# 
extract rawtlt file for aligned stack
 extracttilts \
    -InputFile "${stack_dir}/${i}_${dosefilt}.st" \
    -OutputFile "${stack_dir}/${i}_${dosefilt}.rawtlt"
