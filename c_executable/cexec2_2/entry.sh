#!/bin/bash
# The ENTRYPOINT shell for an C executable docker image on CyVerse
#	illustrating interaction between DE "app" arguments and shell arguments
# Kurt Riitters, July 2024
#
# Useful de-bugging information is written to the "logs" directory in the user's Data Store
#	"analyses" directory. condor-stderr-0 reports failures. condor-stdout-0 reports outputs from
#	this script. JobParameters.csv shows the order and value of arguments passed to this script.
#
# From the dockerfile there is a user "ubuntu" with UID=1000, and directories /home/ubuntu/, 
#	/home/ubuntu/data-store/, /home/ubuntu/.irods/.
#
# CyVerse sets $IPLANT_USER as the current user (who is running the container). e.g., "kriitters"
# This exposes $IPLANT_USER's external Data Store volumes within the container at: ~/data-store/. 
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > $HOME/.irods/irods_environment.json
# 
echo "Debug info: "
echo "the name of this shell is: $0"  				# /home/ubuntu/entry.sh
echo "these are the run-time parameters set in the DE app:"
echo "     =this is the program to run: $1"			# 1=SpatCon, 2=GraySpatCon
echo "     =this is the input geotif file: $2" 		# 
echo "     =this is the input parameter file: $3"	# 
echo "     =this is the optional recode file: $4"	#
echo " "
cd /home/ubuntu
if [[ "$1" == "1" ]]
then
# Get set up to run spatcon 
echo "Running SpatCon"
# copy input files
cp /home/ubuntu/data-store/$2 input.tif
cp /home/ubuntu/data-store/$3 scpars.txt
cp /home/ubuntu/data-store/$4 screcode.txt	#this will be an empty file if optional recode file was not specified in DE
echo ".......finished file copy"
# convert input geotif to bsq format
gdal_translate -of ENVI -ot Byte input.tif scinput
echo ".......finished gdal_translate"
# construct the file scsize.txt using lines (nrows) and samples (ncols) from scinput.hdr
sed -n '/lines/p' scinput.hdr >> scsize.txt
sed -n '/samples/p' scinput.hdr >> scsize.txt
sed -i 's/=//g' scsize.txt
sed -i 's/lines/nrows/g' scsize.txt
sed -i 's/samples/ncols/g' scsize.txt
echo ".......finished constructing scsize.txt"
cat scsize.txt
# execute spatcon. In this mode it looks for the above files, and produces a bsq file "scoutput"
/home/ubuntu/spatcon_lin64
echo ".......finished spatcon"
# convert output bsq to geotif format
# use the same input header and projection info produced by gdal_translate
mv scinput.hdr scoutput.hdr
mv scoutput scoutput.bsq
gdal_translate -co BIGTIFF=YES -co compress=lzw scoutput.bsq scoutput.tif
# move the output to the data store so it will be copied into Data Store analyses folder
mv scoutput.tif /home/ubuntu/data-store/scoutput.tif
echo ".......finished gdal_translate"
#
elif [[ "$1" == "2" ]]
then
# Get set up to run grayspatcon 
echo "Running GraySpatCon"
# copy input files
cp /home/ubuntu/data-store/$2 input.tif
cp /home/ubuntu/data-store/$3 gscpars.txt
echo ".......finished file copy"
# convert input geotif to bsq format
gdal_translate -of ENVI -ot Byte input.tif gscinput
echo ".......finished gdal_translate"
# add the "r" and "c" parameters to gscpars.txt, using lines (nrows) and samples (ncols) from scinput.hdr
sed -n '/lines/p' gscinput.hdr >> gscpars.txt
sed -n '/samples/p' gscinput.hdr >> gscpars.txt
sed -i 's/=//g' gscpars.txt
sed -i 's/lines/R/g' gscpars.txt
sed -i 's/samples/C/g' gscpars.txt
echo ".......finished amending gscpars.txt"
cat gscpars.txt
# execute grayspatcon. In this mode it looks for the above files, and produces a bsq file "gscoutput"
/home/ubuntu/grayspatcon_lin64
echo ".......finished grayspatcon"
# test G parameter to see whether to copy global text file or translate/copy moving window image
grep -e "G" -e "g" gscpars.txt >> test.txt
if cat test.txt | grep -q "1"; then
# just copy the output text file from a global analysis
echo "moving output text file to data store"
mv gscoutput.txt /home/ubuntu/data-store/gscoutput.txt
else
# convert output bsq to geotif format
echo "converting output to geotiff and moving to data store"
# use the same input header and projection info produced by gdal_translate, but amend header for float output
mv gscinput.hdr gscoutput.hdr
# change the data type from byte to 4-byte float
sed -i 's/data type = 1/data type = 4/g' gscoutput.hdr
mv gscoutput gscoutput.bsq
gdal_translate -co BIGTIFF=YES -co compress=lzw gscoutput.bsq gscoutput.tif
# move the output to the data store so it will be copied into Data Store analyses folder
mv gscoutput.tif /home/ubuntu/data-store/gscoutput.tif
echo ".......finished gdal_translate"
fi

else 
echo "no program selected"
fi
echo "listing of /home/ubuntu:"
ls -alR /home/ubuntu
echo " "
echo "exiting"



