load "$SysE/lib/ncl/helper_libs.ncl"
load "$SysE/lib/ncl/data_analysis/filters/lanczos.ncl"
load "./draw_stations.ncl"
load "./coa_helper.ncl"

PTYP = "pdf"
PNAM = "fig2"
NORMALIZE = True
OPTIMIZE_DOMAIN = True
NORMALIZE = True
OPTIMIZE_DOMAIN = True
pcts = (/100,33,10/)
sizes = (/0.005,0.004,0.004/)*2
types = (/1,4,16/)
opcs = (/1.0,0.5,0.8/)


root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_wtim.nc")
r0 = fin->rain
time=fin->time
station=fin->station
typ1 = fin->typ1 ; indices of station with type1 rain regime
typ2 = fin->typ2 ; indices of station with type2 rain regime
typ3 = fin->typ3 ; indices of station with type3 rain regime

nstn = dimsizes(station)
ntim = dimsizes(time)
lat = fin->lat
lon = fin->lon
ran0 = onedtond(ndtooned(r0),(/ntim,nstn/))
add_dimensions(ran0,(/"time","station"/))
ran0&time=time
ran0&station=station
rain=ran0(station|:,time|:)
rain=runave(rain,3,1)

pp("Finished reading data")
fopt=True
fopt@xwt = 2
dt = 1.0/12 ; no of years in a month
idc_fil = low_filter(15,dt,fopt)
dec_fil = band_filter(5,20,dt,fopt)
int_fil = band_filter(1,10,dt,fopt)

pp("Finished making filters ")
nwt1 = dimsizes(idc_fil)/2
nwt2 = dimsizes(dec_fil)/2
nwt3 = dimsizes(int_fil)/2

stn1 = station(typ1)
stn2 = station(typ2)
stn3 = station(typ3)
ridc = wgt_runave(rain(typ1,:),idc_fil,0)
rdec = wgt_runave(rain(typ2,:),dec_fil,0)
rint = wgt_runave(rain(typ3,:),int_fil,0)
std1 = (dim_stddev(ridc(:,nwt1:ntim-nwt1-1)))
std2 = (dim_stddev(rdec(:,nwt2:ntim-nwt2-1)))
std3 = (dim_stddev(rint(:,nwt3:ntim-nwt3-1)))
std  = (dim_stddev(rain(:,nwt2:ntim-nwt2-1)))

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
lat1 = lat(ist1)
lon1 = lon(ist1)
lat2 = lat(ist2)
lon2 = lon(ist2)
lat3 = lat(ist3)
lon3 = lon(ist3)

colormap="GreenYellow"
wks=open_wks(PTYP,PNAM,colormap)
plot = new(3,graphic)
if OPTIMIZE_DOMAIN
  up_lat =  6.6  ; move southern boundary up
  ri_lon =  5.2  ; move left boundary to its right
else
  up_lat =  0.0
  ri_lon =  0.0
end if

mpres = True
mpres@mpProjection                = "LambertConformal"
mpres@mpLambertParallel1F         = min(lat)+up_lat
mpres@mpLambertParallel2F         = max(lat)
mpres@mpLambertMeridianF          = 0.5*(min(lon)+max(lon))

mpres@mpLimitMode                 = "Corners"
mpres@mpLeftCornerLatF            = min(lat)+up_lat
mpres@mpLeftCornerLonF            = min(lon)+ri_lon
mpres@mpRightCornerLatF           = max(lat)
mpres@mpRightCornerLonF           = max(lon)

mpres@mpDataSetName         = "Earth..4"   ; This new database contains
mpres@mpDataBaseVersion     = "MediumRes"
fill_specs = (/"ocean","land"/)
mask_specs = (/"japan"/)
ocr = (/ 0.8,0.8,0.9,1.0/)
lcr = (/ 0.2, 1., 0.2, 1.0 /)
mpres@mpFillAreaSpecifiers  = fill_specs
mpres@mpSpecifiedFillColors = (/ocr,lcr/)
mpres@mpAreaMaskingOn       = True
mpres@mpMaskAreaSpecifiers  = mask_specs
mpres@mpFillDrawOrder="PostDraw"
nodraw(mpres)
noframe(mpres)

map = gsn_csm_map(wks,mpres)
sopt = True
nrpt = dimsizes(pcts)
tmp1 = new(nrpt, graphic)
tmp2 = new(nrpt, graphic)
tmp3 = new(nrpt, graphic)
glv=0.8
sopt@size=0.004
sopt@type=types(0)
sopt@color =  (/ glv,glv,glv, 1.0 /)
stn_locs = draw_stations(wks,map,lon,lat,sopt)

do irpt = 0,nrpt-1
  pct = pcts(irpt)
  inum1 = toint(dimsizes(ist1)*pct/100.0)
  inum2 = toint(dimsizes(ist2)*pct/100.0)
  inum3 = toint(dimsizes(ist3)*pct/100.0)
  sopt@size  = sizes(irpt)
  sopt@color =  (/ 1.0, 0.0, 0.0, opcs(irpt) /)
  sopt@type = types(irpt)
  tmp1(irpt) = draw_stations(wks,map,lon1(:inum1-1),lat1(:inum1-1),sopt)
  sopt@color =  (/ 0.0, 0.0, 1.0, opcs(irpt) /)
  tmp2(irpt) = draw_stations(wks,map,lon2(:inum2-1),lat2(:inum2-1),sopt)
  sopt@color =  (/ 0.0, 0.0, 0.0, opcs(irpt) /)
  tmp3(irpt) = draw_stations(wks,map,lon3(:inum3-1),lat3(:inum3-1),sopt)
end do

sopt@size=0.01
sopt@type=16
sopt@color =  (/ 1.0, 1.0, 0.6, 1.0 /)
;am_locs = draw_stations(wks,map,lon,lat,sopt)


draw(map)
frame(wks)
