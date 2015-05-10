load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
am60_locs=root+"/amelt_rain_anom.nc"
fame=fopen_read(am60_locs)
am_lon=fame->lon
am_lat=fame->lat
am_stn=fame->station
am_lat!0="am_stn"
am_lon!0="am_stn"

fin=fopen_read("AphroJP_DPREC.anom.activestations.nc")
outfil="rain_wtim.nc"
rm_file_if_present(outfil)
fout=fopen_write(outfil)

rain=fin->rain(50:,:,:) ; only data from 1950
fout->rain=rain
fout->lat = fin->lat
fout->lon = fin->lon
station=fin->station
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
time!0="time"
time&time=time

node_dir=root+"/SOM/node_members"
typ1_nodes = "som"+asciiread(root+"/SOM/typ1_nodes.txt",-1,"string")
typ2_nodes = "som"+asciiread(root+"/SOM/typ2_nodes.txt",-1,"string")
typ3_nodes = "som"+asciiread(root+"/SOM/typ3_nodes.txt",-1,"string")

typ1 = idx_members(node_dir,typ1_nodes,station)
typ2 = idx_members(node_dir,typ2_nodes,station)
typ3 = idx_members(node_dir,typ3_nodes,station)

info(typ1)
info(typ2)
info(typ3)

typ1@desc="index of stations of type 1"
typ2@desc="index of stations of type 2"
typ3@desc="index of stations of type 3"

typ1!0="istns1"
typ2!0="istns2"
typ3!0="istns3"

fout->time=time
fout->typ1=typ1
fout->typ2=typ2
fout->typ3=typ3
fout->am_lat=am_lat
fout->am_lon=am_lon
