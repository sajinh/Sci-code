load "$SysE/lib/ncl/helper_libs.ncl"

DEBUG=False

fin=fopen_read("rain_spec.nc")
stn_spc=fin->spectra(freq|3:100,station|:)
freq = stn_spc&freq
per = 1.0/(12*freq) ; in years
pp("decadal "+per(8)+" to "+per(2)+" yrs")
pp("interannual "+per(50)+" to "+per(10)+" yrs")
pp("interdecadal "+per(97)+" to "+per(60)+" yrs")
exit
station=fin->station
nstn = dimsizes(station)
bspc = new((/3,nstn/), typeof(stn_spc))
bspc(0,:) = dim_avg(stn_spc(station|:,freq|2:8))
bspc(1,:) = dim_avg(stn_spc(station|:,freq|10:50))
bspc(2,:) = dim_avg(stn_spc(station|:,freq|60:97))
do is = 0,nstn-1
  bspc(:,is) = bspc(:,is)/max(bspc(:,is))
end do

som_fil="rain_3band_spectra.txt"
;istn_spc=(floattolong(bspc))
istn_spc=((bspc))
if (DEBUG)
  pp(min(istn_spc))
  mxspec=max(istn_spc)
  pp(mxspec)
  pp(avg(istn_spc))
  imxsp = ind(ndtooned(stn_spc).ge.2e+16)
  exit
end if

nmonth=dimsizes(stn_spc&freq)

; Write time series of each station as a row
; Append station ID to the end of the record
; This is used to label SOM maps during visualization phase

ncol = dimsizes(istn_spc(:,0))
hlist = [/(ncol)+" rect 2 2 gaussian"/]
write_table(som_fil,"w", hlist, "%s")
do istn = 0,nstn-1
  dlist = [/array_join(istn_spc(:,istn),"  ")+" "+station(istn)/]
  write_table(som_fil,"a", dlist, "%s")
end do

