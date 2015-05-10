load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "./Plots/filters/lanczos.ncl"
load "./Plots/draw_stations.ncl"
load "./Plots/coa_helper.ncl"
load "./reg5_def.ncl"

NORMALIZE = True
nave        = 3   ; a 3-month running mean
pcts = (/100,33,10/)

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_wtim.nc")
outfil = root+"/rain_5reg.nc"
rm_file_if_present(outfil)
fout=fopen_write(outfil)

r0 = fin->rain
time=fin->time
year=fin->year
month=fin->month
station=fin->station
lat = fin->lat
lon = fin->lon
typ1 = fin->typ1 ; indices of station with type1 rain regime
typ2 = fin->typ2 ; indices of station with type2 rain regime
typ3 = fin->typ3 ; indices of station with type3 rain regime

nstn = dimsizes(station)
ntim = dimsizes(time)
nyr = dimsizes(year)
nmo = dimsizes(month)
ran0 = onedtond(ndtooned(r0),(/ntim,nstn/))
add_dimensions(ran0,(/"time","station"/))
ran0&time=time
ran0&station=station
rain=ran0(station|:,time|:)

out_rain=rain
rain=runave(rain,nave,1)

pp("Finished reading data")
fopt=True
fopt@xwt = 2
idc_fil = low_filter(15,fopt)
dec_fil = band_filter(5,20,fopt)
int_fil = band_filter(1,10,fopt)


pp("Finished making filters ")
nwt1 = dimsizes(idc_fil)/2
nwt2 = dimsizes(dec_fil)/2
nwt3 = dimsizes(int_fil)/2
nwt=max((/nwt1,nwt2,nwt3/))

stn1 = station(typ1)
stn2 = station(typ2)
stn3 = station(typ3)
ridc = wgt_runave(rain(typ1,:),idc_fil,0)
rdec = wgt_runave(rain(typ2,:),dec_fil,0)
rint = wgt_runave(rain(typ3,:),int_fil,0)
std1 = (dim_stddev(ridc(:,nwt1:ntim-nwt1-1)))
std2 = (dim_stddev(rdec(:,nwt2:ntim-nwt2-1)))
std3 = (dim_stddev(rint(:,nwt3:ntim-nwt3-1)))
std  = (dim_stddev(rain(:,nwt:ntim-nwt-1)))

if NORMALIZE
  std1 = std1/dim_stddev(rain(typ1,nwt1:ntim-nwt1-1))
  std2 = std2/dim_stddev(rain(typ2,nwt2:ntim-nwt2-1))
  std3 = std3/dim_stddev(rain(typ3,nwt3:ntim-nwt3-1))
end if

ip1 = dim_pqsort(std1,-2)
ip2 = dim_pqsort(std2,-2)
ip3 = dim_pqsort(std3,-2)

ist1 = stn_id(ip1,stn1,station)
ist2 = stn_id(ip2,stn2,station)
ist3 = stn_id(ip3,stn3,station)

out_rain@ist1=ist1
out_rain@ist2=ist2
out_rain@ist3=ist3

hok=rhok
toh=rtoh
kns=rkns
shi=rshi
kyu=rkyu

out_rain@pcts=pcts
hok@ityp2=latid(station,lat,ist1,pcts(2),hok(0),hok(1))
hok@ityp1=latid(station,lat,ist1,pcts(1),hok(0),hok(1))
hok@ityp0=latid(station,lat,ist1,pcts(0),hok(0),hok(1))

toh@ityp2=latid(station,lat,ist2,pcts(2),toh(0),toh(1))
toh@ityp1=latid(station,lat,ist2,pcts(1),toh(0),toh(1))
toh@ityp0=latid(station,lat,ist2,pcts(0),toh(0),toh(1))

kns@ityp2=latid(station,lat,ist2,pcts(2),kns(0),kns(1))
kns@ityp1=latid(station,lat,ist2,pcts(1),kns(0),kns(1))
kns@ityp0=latid(station,lat,ist2,pcts(0),kns(0),kns(1))

shi@ityp2=latid(station,lat,ist3,pcts(2),shi(0),shi(1))
shi@ityp1=latid(station,lat,ist3,pcts(1),shi(0),shi(1))
shi@ityp0=latid(station,lat,ist3,pcts(0),shi(0),shi(1))

kyu@ityp2=latid(station,lat,ist3,pcts(2),kyu(0),kyu(1))
kyu@ityp1=latid(station,lat,ist3,pcts(1),kyu(0),kyu(1))
kyu@ityp0=latid(station,lat,ist3,pcts(0),kyu(0),kyu(1))

fout->rain=out_rain
fout->hok=hok
fout->toh=toh
fout->kns=kns
fout->shi=shi
fout->kyu=kyu
fout->lat=fin->lat
fout->lon=fin->lon
fout->time=fin->time
