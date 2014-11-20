load "$SysE/lib/ncl/helper_libs.ncl"
load "../../ncllib/stndata/node_helpers.ncl"

PTYP = "x11"
PNAM = "stn_eof"
nave        = 3   ; a 3-month running mean

root = "../"
fin = fopen_read(root+"/rain_wtim.nc")
r0 = fin->rain
time=fin->time
station=fin->station
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

neof   = 1        ; number of EOFs
optEOF = True  
eof1 = eofunc(rain,neof,optEOF)


pp("Finished EOFs ")
colormap="BlWhRe"
wks=open_wks(PTYP,PNAM,colormap)

res = True
res@trGridType                  = "TriangularMesh" 
res@sfXArray                    = lon(:)
res@sfYArray                    = lat(:)
opt = True
opt@label_bar = True
myfill(res,opt)
res@mpProjection                = "LambertConformal"
res@mpLambertParallel1F         = min(lat)
res@mpLambertParallel2F         = max(lat)
res@mpLambertMeridianF          = 0.5*(min(lon)+max(lon))

res@mpLimitMode                 = "Corners"
res@mpLeftCornerLatF            = min(lat)
res@mpLeftCornerLonF            = min(lon)
res@mpRightCornerLatF           = max(lat)
res@mpRightCornerLonF           = max(lon)

res@mpDataSetName         = "Earth..4"   ; This new database contains
res@mpDataBaseVersion     = "MediumRes"
fill_specs = (/"ocean","land"/)
mask_specs = (/"japan"/)
ocr = (/ 0.9,0.9,0.9,1.0/)
lcr = (/ 0.2, 1., 0.2, 1.0 /)
res@mpFillAreaSpecifiers  = fill_specs
res@mpSpecifiedFillColors = (/ocr,lcr/)
res@mpAreaMaskingOn       = True
res@mpMaskAreaSpecifiers  = mask_specs
res@mpFillDrawOrder="PostDraw"
noframe(res)

; Draw markers on the plot in the lat/lon locations.
;
  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle
  mkres@gsMarkerSizeF =  0.001
mkres@gsMarkerColor=(/0.0,0.0,0.0,1.0/)



plot = gsn_csm_contour_map(wks,eof1(0,:),res)
gsn_polymarker(wks,plot,lon(:),lat(:),mkres)
frame(wks)
