load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "./Plots/filters/lanczos.ncl"
load "./Plots/make_spec.ncl"
load "./Plots/plot_spec.ncl"


root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_5reg.nc")
fam = fopen_read(root+"/amrain_wtim.nc")


rain    = fin->rain
am_rain = fam->rain2D
station = fin->station
am_stn  = fam->station
lat     = fin->lat
lon     = fin->lon
am_lat  = fam->lat
am_lon  = fam->lon

function in_amedas(station,am_stn,in_typ)
begin
  ntyp=dimsizes(in_typ)
  in_stn=new(ntyp,logical)
  in_stn=False
  do i=0,ntyp-1
    in_stn(i) = any(am_stn .eq. station(in_typ(i)))
  end do
  return(in_stn)
end

function idx_amedas(station,am_stn,in_typ)
begin
  ntyp=dimsizes(in_typ)
  idx=new(ntyp,integer)
  idy=new(ntyp,integer)
  k=0
  do i=0,ntyp-1
    stn=station(in_typ(i))
    if any(am_stn .eq. stn)
      idx(k) = ind(stn .eq. am_stn) 
      idy(k) = in_typ(i)
      k=k+1
    end if
  end do
  if k .eq. 0
    return(idx@FillValue)
  end if
  val = idx(0:k-1)
  val@istn=idy(0:k-1)
  return(val)
end

hok=fin->hok
ihok=[/hok@ityp0,hok@ityp1,hok@ityp2,hok@ityp3/]

;pp(num(in_amedas(station,am_stn,ihok[3])))
idx=((idx_amedas(station,am_stn,ihok[0])))
istn=idx@istn
pp(idx)
pp(istn)
pp(array_join(am_lat(idx),":"))
pp(array_join(lat(istn),":"))
pp(array_join(am_lon(idx),":"))
pp(array_join(lon(istn),":"))

prn=rain(istn(0),:)
arn=am_rain(idx(0),:)
;DebugGraph(prn)
;DebugGraph(arn)
pp(escorc(prn,arn))

PTYP = "x11"
PNAM = "spectra"
SMOOTH_TS   = True
DTREND_TS = True
SMOOTH_SPEC = True
nave        = 3   ; a 3-month running mean
spec_nave   = 5   ; n-point smoother for spectra
pct_taper   = 0.1 ; taper 10% of the time series

spec1=calc_spec(prn,nave,spec_nave,pct_taper,\
    SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)
spec2=calc_spec(arn,nave,spec_nave,pct_taper,\
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
;ityp1_am= idx_amedas(station,am_stn,ityp1)
;ityp2_am= idx_amedas(station,am_stn,ityp2)
;ityp3_am= idx_amedas(station,am_stn,ityp3)
delete(res2)
res2=res
res2@vpYF=0.68
opt@top=False
plot2 = plot_spec(wks,spec2,dec2_fil,res2,opt)

draw(plot1[0])
draw(plot2[0])
frame(wks)
outfil=root+"/amrain_wtyp.nc"
rm_file_if_present(outfil)
fout = fopen_write(outfil)
