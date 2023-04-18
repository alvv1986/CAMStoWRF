for mon in  01 02 03 04 05 06 08 09 10 11 12; do
#for dd in `seq 15 31`; do
for dd in 01 02 03 04 05 06 07 08 09 `seq 10 31`; do

sed -e "s/mon/$mon/g" grib.2019.baz > dublu.par
#sed -e "s/mon/$mon/g" grib.PSFC.2019.baz > dublu.par
sed -e "s/dd/$dd/g" dublu.par > grib.py
/apps/anaconda/5.1.0_py3/bin/python grib.py
mv download.grib CAMS_2019-${mon}-${dd}.grib
#mv download.grib PSFC_2019-${mon}-${dd}.grib
done
done

