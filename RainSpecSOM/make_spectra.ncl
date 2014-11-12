load "$SysE/lib/ncl/helper_libs.ncl"
load "./fft_helpers.ncl"

outfil="rain_spec.nc"

fin = fopen_read("rain.nc")
rm_file_if_present(outfil)

var     = fin->rain
station = var&station
month   = var&month
year    = var&year
ntim = dimsizes(year)*dimsizes(month)
nstn = dimsizes(station)

; we want a time series at every station
; so we collapse month and year to a
; a single time series

opt = True
opt@last_dim="station"
v2d = reduce_to_2D(var,opt)
add_dimensions(v2d,(/"time","station"/))
v2d&time=ispan(1,ntim,1)
v2d&station=station
delete(var)

; now to the spectral calculation

;---------------------------------------
;       PARAMETERS FOR SPECTRAL CALCULATION
;       ................................
ntaper=0.10
nsmooth=7
ibase2 = floattointeger(log(ntim)/log(2.0))+1
npad = floattointeger(2.0^ibase2) - ntim
dan_win=Daniell_Window(nsmooth)
sclfactor=2.0/sum(dan_win^2)
df=Calculate_Dof(dan_win,ntim,npad,ntaper)
;----------------------------------------
;       PAD THE DATA
;       .................................
ntim2=npad+ntim
nstart=npad/2
var=new((/nstn,ntim2/),typeof(v2d))
var=0.0
var(:,nstart:nstart+ntim-1)=v2d(station|:,time|:)
delete(v2d)
;.........................................
;       DETREND & TAPER
;       .............................
var=dtrend(var,False)
var=taper(var,ntaper,0)
;------------------------------------
;       SPECTRAL CALCULATION
;       .............................
cf=ezfftf(var)
cf=(/ cf*dble2flt(sclfactor) /)
psd=cf(0,:,:)^2+cf(1,:,:)^2
nfrq=dimsizes(psd(0,:))
psd(:,nfrq-1)=psd(:,nfrq-1)/2.0
freq=ispan(1,nfrq,1)/int2flt(ntim2)
delete(cf)
psd=wgt_runave(psd,dan_win,0)
add_dimensions(psd,(/"station","freq"/))
psd&station=station
psd&freq=freq

;--------------------------------------------
;       CALCULATE RED SPECTRA
;       .....................................

rspc=rspec(var,freq)
add_dimensions(rspc,(/"station","freq"/))
rspc&station=station
rspc&freq=freq
rscale=dim_sum(psd)/dim_sum(rspc)
rspc=rspc*conform(rspc,rscale,0)
;.............................................

xHigh = chiinv (0.95, df)/df
rspc=rspc*xHigh



fout=fopen_write(outfil)
fout->spectra=psd
fout->background_spc=rspc
fout->lat=fin->lat
fout->lon=fin->lon
info(psd)
