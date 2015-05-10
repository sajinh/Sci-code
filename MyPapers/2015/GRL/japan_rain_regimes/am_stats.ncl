load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "./Plots/filters/lanczos.ncl"
load "./Plots/make_spec.ncl"
load "./Plots/plot_spec.ncl"

; How long since have been AMeDAS stations operating in key
; locations?

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_5reg.nc")
fam = fopen_read(root+"/JMA.anom.activestations.nc")


rain    = fin->rain
am_rain = reduce_to_2D(fam->rain,False)
add_dimensions(am_rain,(/"time","station"/))
info(am_rain)
station = fin->station
am_stn  = fam->station
lat     = fin->lat
lon     = fin->lon
am_lat  = fam->lat
am_lon  = fam->lon

function nmon_amedas(var,idx)
begin
  ndx = dimsizes(idx)
  nmo = new(ndx, integer)
  do i = 0,ndx-1
    nmo(i) = num(.not.ismissing(var(:,idx(i))))
  end do
  return(nmo)
end

types=(/"hok","toh","kns","shi","kyu"/)
ntyp = dimsizes(types)
nyr100 = new(ntyp,integer)
nyr = 35
do ity = 0, ntyp-1
  hok=fin->$types(ity)$
  ihok=[/hok@ityp0,hok@ityp1,hok@ityp2,hok@ityp3/]
  vdx = ihok[3]
  hokm = nmon_amedas(am_rain,vdx)
  nstn = num(hokm .ge. nyr*12)
  pp(nstn)
  if (nstn .ge. 2)
    ;pp( hokm(ind(hokm .ge. nyr*12))/12.0)
  end if
  ;pp(hokm(ind(nstn .ge. 2)))
  delete(vdx)
  delete(hokm)
  delete(hok)
end do

exit
pp(istn)
pp((max(hokm)))
arn=am_rain(:,istn)

arn=runave(arn,11,1)
arn=runave(arn,11,0)
DebugGraph(arn)
arn=am_rain(:,istn)

PTYP = "x11"
PNAM = "spectra"
SMOOTH_TS   = True
DTREND_TS = True
SMOOTH_SPEC = True
nave        = 11   ; a 3-month running mean
spec_nave   = 5   ; n-point smoother for spectra
pct_taper   = 0.1 ; taper 10% of the time series

spec1=calc_spec(arn,nave,spec_nave,pct_taper,\
    SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)

fopt=True
fopt@xwt=2
dec1_fil = low_filter(18,fopt)
dec2_fil = band_filter(5,20,fopt)
int_fil = band_filter(1,10,fopt)

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
plot1 = plot_spec(wks,spec1,dec1_fil,res2,opt)

draw(plot1[0])
draw(plot1[1])
frame(wks)
