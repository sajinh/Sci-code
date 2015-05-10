load "$SysE/lib/ncl/helper_libs.ncl"

DEBUG=False

fin=fopen_read("rain_spec.nc")
stn_spc=fin->spectra(freq|2:53,station|:)
station=fin->station
som_fil="rain_spectra.txt"
istn_spc=(floattolong(stn_spc))
if (DEBUG)
  pp(min(istn_spc))
  mxspec=max(istn_spc)
  pp(mxspec)
  pp(avg(istn_spc))
  imxsp = ind(ndtooned(stn_spc).ge.2e+16)
  exit
end if

nmonth=dimsizes(stn_spc&freq)
nstn = dimsizes(station)

; Write time series of each station as a row
; Append station ID to the end of the record
; This is used to label SOM maps during visualization phase

ncol = nmonth+1
hlist = [/(ncol-1)+" rect 2 2 gaussian"/]
write_table(som_fil,"w", hlist, "%s")
do istn = 0,nstn-1
  tmp = stn_spc(:,istn)
  tmp = tmp/max(tmp)
  dlist = [/array_join(tmp,"  ")+" "+station(istn)/]
  write_table(som_fil,"a", dlist, "%s")
end do

