load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
am60_locs=root+"/amelt_rain_anom.nc"
fame=fopen_read(am60_locs)
rain=fame->rain(50:,:,:)

outfil="amrain_wtim.nc"
rm_file_if_present(outfil)
fout=fopen_write(outfil)

fout->rain=rain
fout->lat = fame->lat
fout->lon = fame->lon
station=fame->station
year=rain&year
month=rain&month
nyr = dimsizes(year)
nmo = dimsizes(month)
ntim = nyr*nmo
tunits="days since 1900-01-01"
; bug below -- day is 1 instead of 15; nhs nov 5
; modified code is just below commented old code
;time=make_monthly_time(year(0),month(0),1,\
;                       year(nyr-1),month(nmo-1),15,tunits,ntim)
time=make_monthly_time(year(0),month(0),15,\
                       year(nyr-1),month(nmo-1),15,tunits,ntim)
nstn=dimsizes(station)
ran0=onedtond(ndtooned(rain),(/ntim,nstn/))
time!0="time"
time&time=time
fout->time=time
add_dimensions(ran0,(/"time","station"/))
ran0&time=time
ran0&station=station
fout->rain2D=ran0(station|:,time|:)
