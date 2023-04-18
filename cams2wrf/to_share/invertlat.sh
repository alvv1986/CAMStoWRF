for luna in 04 ; do
#for luna in 04 05 06 07 08 09 `seq 10 12` ; do
for zi in `seq 15 31`; do
rm -f test.nc
id=2019${luna}${zi}
cdo -b f32 copy orig/AQMEII_${id}.nc test.nc
cdo -invertlat test.nc AQMEII_${id}.nc
ncks -A hyam.nc AQMEII_${id}.nc
done
done



