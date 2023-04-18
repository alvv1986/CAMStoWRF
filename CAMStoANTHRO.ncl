load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;setfileoption("nc","Format","LargeFile") 

indir    = "/scr3/angel/EMISS/CAMS"
outdir   = "./"
f_ch4    = indir+"/CAMS-GLOB-ANT_v4.2_methane_2018.nc"
grg      = addfile(f_ch4,"r")

; output file
system ("rm "+outdir+"CAMS_CH4_TRA_EMIS.nc")      ; remove pre-existing file
out  = addfile(outdir+"/CAMS_CH4_TRA_EMIS.nc","c")

date              = toint(cd_calendar(grg->time, -2))
date@long_name    = "current date as 6 digit integer (YYYYMMDD)"
date!0            = "time"
date&time         = grg->time&time

datesec1          = cd_calendar(grg->time, 0)
datesec           = toint(datesec1(:,3) * 3600 + datesec1(:,4) * 60 + datesec1(:,5))
datesec@units     = "s"
datesec@long_name = "seconds to complete current date"
datesec!0         = "time"
datesec&time      = grg->time&time

time              = cd_convert(grg->time, "days since 0000-01-01 00:00:00")
time@long_name    = "simulation time"
time@calendar     = "gregorian"
time!0            = "time"
time&time         = grg->time&time

lat               = grg->lat 
lon               = grg->lon
setfileoption(out,"DefineMode",True)
fAtt              = True
fAtt@TITLE        = "CAMS global emission inventory: https://ads.atmosphere.copernicus.eu/cdsapp#!/dataset/cams-global-emission-inventories?tab=overview"
fileattdef(out,fAtt)
dimNames          = (/"time","lat","lon"/)
dimSizes          = (/dimsizes(time),dimsizes(lat),dimsizes(lon)/)
dimUnlim          = (/True,False,False/)
filedimdef(out,dimNames,dimSizes,dimUnlim)

out->time         = time
out->date         = date
out->datesec      = datesec

; methane sources

ch4_agl           = grg->agl
ch4_ags           = grg->ags
ch4_awb           = grg->awb
ch4_ene           = grg->ene
ch4_fef           = grg->fef
ch4_ind           = grg->ind
ch4_res           = grg->res
ch4_shp           = grg->shp
ch4_slv           = grg->slv
ch4_swd           = grg->swd
ch4_tnr           = grg->tnr
ch4_tro           = grg->tro
ch4_sum           = grg->sum ; sum of all sectors

;ch4_tot           = ch4_sum
ch4_tot           = ch4_tnr+ch4_tro   ; Transport
ch4_tot!0         = "time"
ch4_tot!1         = "lat"
ch4_tot!2         = "lon"
ch4_tot&time      = time
ch4_tot&lat       = lat
ch4_tot&lon       = lon
ch4_tot@units     = "kg m-2 s-1"
ch4_tot           = lonFlip(ch4_tot)
out->emis_tot     = ch4_tot                   
