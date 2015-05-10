
function calc_spec(r0,nave,spec_nave,pct_taper,\
    SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)
local stnave_rain
begin
  stnave_rain = r0
  if SMOOTH_TS
    stnave_rain = runave_Wrap(stnave_rain,nave,1)
  end if
  if .not. SMOOTH_SPEC
    spec_nave = -1*spec_nave
  end if
  if DTREND_TS
    iopt = 1
  else
    iopt = 0
  end if
  return(specx_anal(stnave_rain,iopt,spec_nave,pct_taper))
end
function make_spec(inodes,rain,nave,spec_nave,pct_taper,\
   SMOOTH_TS, DTREND_TS, SMOOTH_SPEC)
begin
  rain({1994},:,:)=0.0
  rain({1993},:,:)=0.0
  r0 = rain(:,:,inodes)
  stnave_rain=ndtooned(dim_avg(r0))
  return(calc_spec(stnave_rain,nave,spec_nave,pct_taper,SMOOTH_TS,DTREND_TS,SMOOTH_SPEC))
end
