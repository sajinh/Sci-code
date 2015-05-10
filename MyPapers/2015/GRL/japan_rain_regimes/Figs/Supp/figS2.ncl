load "$SysE/lib/ncl/helper_libs.ncl"
load "$SysE/lib/ncl/data_analysis/filters/lanczos.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "../draw_stations.ncl"
load "../coa_helper.ncl"

TS = True
PTYP = "x11"
PNAM = "fig3_regts"
NORMALIZE = True
nave        = 5   ; a 3-month running mean
pcts = (/100,33,10/)

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_wtim.nc")
fty = fopen_read(root+"/rain_5reg.nc")
r0 = fin->rain
time=fin->time
station=fin->station
typ1 = fin->typ1 ; indices of station with type1 rain regime
typ2 = fin->typ2 ; indices of station with type2 rain regime
typ3 = fin->typ3 ; indices of station with type3 rain regime
function get_type(fty,reg,typ)
begin
  return(fty->$reg$@$typ$)
end
function add_em(one,two)
begin
  n1 = dimsizes(one)
  n2 = dimsizes(two)
  var = new(n1+n2, typeof(one))
  var(:n1-1) = one
  var(n1:) = two
  return(var)
end
ityp = "ityp2"
hok = get_type(fty,"hok",ityp)
toh = get_type(fty,"toh",ityp)
kns = get_type(fty,"kns",ityp)
kyu = get_type(fty,"kyu",ityp)
shi = get_type(fty,"shi",ityp)

idc = hok
dec = add_em(toh,kns)
int = add_em(shi,kyu)

nstn = dimsizes(station)
ntim = dimsizes(time)
year=fin->year
month=fin->month
nyr = dimsizes(year)
nmo = dimsizes(month)
lat = fin->lat
lon = fin->lon
ran0 = onedtond(ndtooned(r0),(/ntim,nstn/))
add_dimensions(ran0,(/"time","station"/))
ran0&time=time
ran0&station=station
rain=ran0(station|:,time|:)
rain=runave(rain,nave,1)

pp("Finished reading data")
fopt=True
fopt@xwt = 2
dt = 1.0/12 ; no of years in a month
dec1_fil = low_filter(15,dt,fopt)
dec2_fil = band_filter(5,15,dt,fopt)
int_fil = band_filter(1,10,dt,fopt)

pp("Finished making filters ")
nwt1 = dimsizes(dec1_fil)/2
nwt2 = dimsizes(dec2_fil)/2
nwt3 = dimsizes(int_fil)/2


colormap="GreenYellow"
wks=open_wks(PTYP,PNAM,colormap)
nsmth = nave
res = True
opt = True
nodraw(res)
noframe(res)
res@vpWidthF        = 0.5
res@vpHeightF       = 0.15
res@vpXF=0.1
res@vpYF=0.9
res2=res
opt@top=True
opt@bottom=False
opt@minmax=(/-2.0,2.0/)
opt@xref_int=10
mov_dwn=0.165
xvar = fspan(year(0)+1.0/12,year(nyr-1)*1.0,ntim)
if TS
  opt@bottom=False
  plot1=plot_rain_ts(wks,xvar,rain,idc,\
                            dec1_fil,nsmth,15,100,res2,opt)
  res2@vpYF=res2@vpYF-mov_dwn
  opt@top=False
  opt@bottom=False
  opt@minmax=(/-2.5,2.5/)
  plot2=plot_rain_ts(wks,xvar,rain,dec,\
                   dec2_fil,nsmth,5,20,res2,opt)
  res2@vpYF=res2@vpYF-mov_dwn
  opt@minmax=(/-2.6,2.6/)
  opt@bottom=True
  plot3=plot_rain_ts(wks,xvar,rain,int,\
                  int_fil,nsmth,5,20,res2,opt)
  draw(plot1)
  draw(plot2)
  draw(plot3)
  frame(wks)
end if

