load "$SysE/lib/ncl/helper_libs.ncl"

DEBUG=False

fin=fopen_read("rain_spec.nc")
stn_spc=fin->spectra(freq|0:100,station|:)
freq = stn_spc&freq
per = 1.0/(12*freq) ; in years
pp("interdecadal "+per(4)+" to "+per(0)+" yrs")
pp("decadal "+per(11)+" to "+per(5)+" yrs")
pp("interannual "+per(53)+" to "+per(13)+" yrs")
pp("subannual "+per(99)+" to "+per(73)+" yrs")
station=fin->station
nstn = dimsizes(station)
bspc = new((/3,nstn/), typeof(stn_spc))
;bspc = new((/4,nstn/), typeof(stn_spc))
bspc(0,:) = dim_avg(stn_spc(station|:,freq|0:4))
bspc(1,:) = dim_avg(stn_spc(station|:,freq|5:11))
bspc(2,:) = dim_avg(stn_spc(station|:,freq|13:53))
;bspc(3,:) = dim_avg(stn_spc(station|:,freq|73:99))
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

