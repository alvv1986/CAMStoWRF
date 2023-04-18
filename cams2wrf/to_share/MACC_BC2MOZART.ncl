; NAME:
;   MACC2_MOZART_AQMEII.ncl
; 
; PURPOSE:
;   Convert IFS-MOZART output into the same format as provided by
;   NCAR MOZART files.
;   This conversion is the first step of a two-step pre-processing
;   of IFS-MOZART files to be compatible with the format required
;   by the COSMO-ART preprocessor int2lm.
;
;   The three input files PS_, GRG_, AER_ containing surface pressure,
;   Global Reactive Gases and AERosols are merged into one, adds a variable
;   time with units of days since 0000-01-01 00:00:00 as "gregorian"
;   calender, a variable date (6 digit integer) a variable datesec 
;   (seconds of day) and a reference pressure P0 which is set to 1.0 here
;   for reasons mentioned in a comment below.
;
;   Note: although the date is given as "gregorian" calender, it is actually
;   a "proleptic_gregorian" calender. This wrong annotation is made to be
;   compatible with the MOZART-NCEP output.
; 
; CALLING:
;   ncl fileid="fileid" indir="indir" outdir="outdir" MACC2_MOZART_AQMEII.ncl
;
; INPUTS:
;   fileid: the date to process in format YYYYMMDD, e.g. 20100213
;   indir: directory of IFS-MOZART files (default is /nas/input/IFS-MOZART)
;   outdir: directory of processed file (default is /nas/input/IFS-MOZART/processed)
;
; AUTHOR:
;   Christoph Knote
;   v1: CK, Jan 2013: first implementation
;   v2: DB, 15 Jan 2013: added possibility to provide command line input
;   Jan 2018: Aura adapt it for AQMEII4
;   Jul 2020: Aura adapt it for COVID

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; aura overpass 4 Gb limit
setfileoption("nc","Format","LargeFile") 


if (.not. isvar("fileid")) then      ; is fileid on command line?
    print("parameter fileid missing")
    exit
end if

if (.not. isvar("indir")) then
    indir = "/worknb/users/alu/UBA_Data/CAMS_BC"
end if

if (.not. isvar("outdir")) then
    outdir = "/worknb/users/alu/UBA_Data/CAMS_BC/april"
end if


; input files
psfile  = indir+"/PSFC_"+fileid+"_eac4_EU.nc"
camsfile = indir+"/CAMS_"+fileid+"_eac4_EU.nc"

if ( isfilepresent(psfile) .and. isfilepresent(camsfile) ) then

ps   = addfile(psfile,"r")
cams  = addfile(camsfile,"r")

; output file
system ("rm "+outdir+"/AQMEII_"+fileid+".nc")      ; remove pre-existing file
out  = addfile(outdir+"/AQMEII_"+fileid+".nc","c")

; coordinate variables
hyam = cams->hyam(0:59)
hybm = cams->hybm(0:59)

hyam!0   = "level"
hybm!0   = "level"
hyam&level = ispan(0,59,1)
hybm&level = ispan(0,59,1)
; compatible with MOZART output
hyam     = hyam / 100000.0

; date and time
date              = toint(cd_calendar(cams->time, -2))
date@long_name    = "current date as 6 digit integer (YYMMDD)"
date!0            = "time"
date&time         = cams->time&time

datesec1          = cd_calendar(cams->time, 0)
datesec           = toint(datesec1(:,3) * 3600 + datesec1(:,4) * 60 + datesec1(:,5))
datesec@units     = "s"
datesec@long_name = "seconds to complete current date"
datesec!0         = "time"
datesec&time      = cams->time&time

time              = cd_convert(cams->time, "days since 0000-01-01 00:00:00")
time@long_name    = "simulation time"
time@calendar     = "gregorian"
time!0            = "time"
time&time         = cams->time&time

out->time         = time

out->hyam         = hyam
out->hybm         = hybm

out->lat          = ps->lat
out->lon          = ps->lon

out->date         = date
out->datesec      = datesec

; surface pressure
pres1             = ps->var134 ;ps
pres              = pres1(:,:,:)
pres@units        = "PA"
out->PS           = pres

p0                = 100000
p0@long_name      = "reference pressure"
p0@units          = "Pa"
out->P0           = p0

; gases

;add all the gases after c2h6 in the mapping namelist


gases         = (/ "co", "no", "no2", "no3", "so2", "nh3", "nh4","go3", "ch4_c","hno3", "pan", "c3h8", "hcho", "c5h8", "c2h6", "ch3coch3", "c2h5oh", "c2h4", "ch3oh", "ch3cocho", "onit", "c3h6", "c10h16", "ald2", "hcooh", "ho2", "ispd" /)
gasesNice     = (/ "CO", "NO", "NO2", "NO3", "SO2", "NH3", "NH4", "O3",  "CH4", "HNO3", "PAN", "C3H8", "HCHO", "C5H8", "C2H6", "CH3COCH3", "C2H5OH", "C2H4", "CH3OH", "CH3COCHO", "ONIT", "C3H6", "C10H16", "ALD2", "HCOOH", "HO2", "MVK" /)

ngases        = dimsizes(gases)

do n=0,ngases-1
  gase = cams->$gases(n)$

  gase@units          = "VMR"
  gase&level       = (/ ispan(0,59,1) /)
  out->$gasesNice(n)$ = gase

  delete(gase)
end do


; aerosols
aeros             = (/ "aermr01", "aermr02", "aermr03", "aermr04", "aermr05", "aermr06",  "aermr07" ,"aermr08",  "aermr09","aermr10","aermr11" /)
aerosNice         = (/ "SS01", "SS02", "SS03",           "DU01", "DU02",       "DU03",     "OC",  "OC1",          "BC", "BC1",  "SO4"   /)
naeros            = dimsizes(aeros)

do n=0,naeros-1
  aero = cams->$aeros(n)$

  aero@units          = "UG M-3"
  aero&level         = (/ ispan(0,59,1) /)
  out->$aerosNice(n)$ = aero

  delete(aero)
end do

else

print("Not all input files available for fileid "+fileid)

end if
