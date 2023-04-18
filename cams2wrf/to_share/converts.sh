
for mon in 12 ; do
for dd in  31  ; do
 cdo -f nc copy PSFC_2019-${mon}-${dd}.grib  PSFC_2019-${mon}-${dd}.nc
 grib_to_netcdf -o CAMS_2019-${mon}-${dd}.nc CAMS_2019-${mon}-${dd}.grib
  ncks -A hyam.nc  CAMS_2019-${mon}-${dd}.nc
id=2019${mon}${dd}
echo $id
ln -s CAMS_2019-${mon}-${dd}.nc CAMS_${id}_eac4_EU.nc
ln -s PSFC_2019-${mon}-${dd}.nc PSFC_${id}_eac4_EU.nc
 ncl MACC_BC2MOZART.ncl fileid="${id}"
#
rm -f test.nc
cdo -b f32 copy processed/AQMEII_${id}.nc test.nc
cdo -invertlat test.nc AQMEII_${id}.nc
ncks -A hyam.nc AQMEII_${id}.nc
done
done


