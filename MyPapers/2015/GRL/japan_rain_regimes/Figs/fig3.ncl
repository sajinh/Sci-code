load "$SysE/lib/ncl/helper_libs.ncl"
load "$SysE/lib/ncl/data_analysis/filters/lanczos.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "./make_spec.ncl"
load "./plot_spec.ncl"

PTYP = "pdf"
PNAM = "fig3"
SMOOTH_TS   = True
DTREND_TS = True
SMOOTH_SPEC = True
nave        = 3   ; a 3-month running mean
spec_nave   = 5   ; n-point smoother for spectra
pct_taper   = 0.1 ; taper 10% of the time series

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_wtim.nc")
rain = fin->rain
station=fin->station
nstn = dimsizes(station)


idc = fin->typ1
dec = fin->typ2
int = fin->typ3

spec11 = make_spec(idc,rain,nave,spec_nave,pct_taper,\
   SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)
spec12 = make_spec(dec,rain,nave,spec_nave,pct_taper,\
   SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)
spec2 = make_spec(int,rain,nave,spec_nave,pct_taper,\
   SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)

fopt=True
fopt@xwt=2
dt=1.0/12 ; no of months in a year
dec1_fil = low_filter(18,dt,fopt)
dec2_fil = band_filter(5,20,dt,fopt)
int_fil = band_filter(1,10,dt,fopt)

colormap="rainbow"
wks=open_wks(PTYP,PNAM,colormap)

res=True
opt=True
res@vpWidthF        = 0.5
res@vpHeightF       = 0.2
res@vpXF=0.1
res@vpYF=0.9
res2=res
opt@top=True
opt@bottom=False
plot1 = plot_spec(wks,spec11,dec1_fil,res2,opt)
delete(res2)
res2=res
res2@vpYF=0.68
opt@top=False
plot2 = plot_spec(wks,spec12,dec2_fil,res2,opt)
delete(res2)
res2=res
res2@vpYF=0.46
opt@bottom=True
plot3 = plot_spec(wks,spec2,int_fil,res2,opt)
draw(plot1[0])
draw(plot1[1])
draw(plot2[0])
draw(plot2[1])
draw(plot3[0])
draw(plot3[1])
frame(wks)
