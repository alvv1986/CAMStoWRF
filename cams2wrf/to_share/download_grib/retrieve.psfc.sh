for mon in  12; do
#for mon in  01 02 03 04 05 06 08 09 10 11 12; do
for dd in `seq 15 31`; do
#for dd in 01 02 03 04 05 06 07 08 09 `seq 10 31`; do
#sed -e "s/mon/$mon/g" grib.2019.baz > dublu.par
sed -e "s/mon/$mon/g" grib.PSFC.2019.baz > dublu.parps
sed -e "s/dd/$dd/g" dublu.parps > gribps.py
/apps/anaconda/5.1.0_py3/bin/python gribps.py
mv downloadpsfc.grib PSFC_2018-${mon}-${dd}.grib
done
done

