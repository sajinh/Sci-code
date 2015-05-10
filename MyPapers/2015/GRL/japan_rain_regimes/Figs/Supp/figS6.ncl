load "$SysE/lib/ncl/helper_libs.ncl"


vprd="sst"
ftyp="x11"
rain_typ="rtyp3"

SMOOTH_SST=True
MASK_OUTLIERS=True
lead = 0 ; lead = 0 mean same year JJA
         ; lead = 3 means same year SON
         ; negative lead SST appears before rain
fname="int_"+vprd+"_corr_l"+lead

; --- don't change these below
sst_smon = 1 ; starts 1958 Jan
r_smon = 7 ; starts 1950 July (JJA) ; only available for JJA
r_ffwd = 8 ; no of years to advance rain
if lead .lt. (-1*r_smon)
  abort("lead cannot be less than "+(-1*r_smon))
end if

tstart = lead+r_smon-1  ; start at lead+r_smon
rstart = r_ffwd  ; start at 1950+r_ffwd=1958
if vprd .eq. "sst"
  color_scheme="BlWhRe"
else
  color_scheme="hotcolr_19lev"
end if
fsst=fopen_read("../../Cache/"+vprd+".nc")
fprc=fopen_read("../../Cache/int_rain_jja.nc")

tim1=fsst->time(tstart:)
tim2=fprc->year

tsst = cd_calendar(tim1(0),-5)
syr=tsst(0,0)
smo=tsst(0,1)
pp("SST start year="+syr+" mon="+smo)

if SMOOTH_SST
  tmp_sst=fsst->$vprd$
  smt_sst=runave_n_Wrap(tmp_sst,3,1,0)
  sst0=smt_sst(tstart::12,:,:)
else
  sst0=fsst->$vprd$(tstart::12,:,:)
end if
prc=fprc->$rain_typ$(rstart:)
delete(tsst)
tsst=dimsizes(sst0&time)
tprc=dimsizes(prc&year)

dtim=tsst-tprc
sst=sst0(:(tsst-dtim-1),:,:)
tsst=dimsizes(sst&time)
rain=prc
lyr_rain=rain&year(dimsizes(rain)-1)
lyr_sst=cd_calendar(sst&time(tsst-1),-5)

syr_rain=rain&year(0)
syr_sst=cd_calendar(sst&time(0),-5)
pp("rain "+syr_rain+" : "+lyr_rain)
print("sst "+syr_sst(0,0)+" : "+lyr_sst(0,0))
ryr = rain&year
iyr_93 = ind(ryr .eq. 1993)
pp(iyr_93)
iyr_94=iyr_93+1
pp(ryr(iyr_93))
if MASK_OUTLIERS
  rain(iyr_93) = rain@_FillValue ;rain(iyr_93)/50.0
  rain(iyr_94) = rain@_FillValue ;rain(iyr_94)/50.0
end if

corr=sst(0,:,:)
corr=escorc(sst(lat|:,lon|:,time|:),rain)

wks=open_wks(ftyp,fname,color_scheme)
res=True
corr@clevs=ispan(-6,6,1)*0.1
plot=map_shaded(wks,corr,res)
draw(plot)
frame(wks)
pp(max(corr))
pp(min(corr))
pp("Corr - Trop Ind Ocean")
lt1=-20
lt2=10
ln1=60
ln2=110
pp(max(corr({lt1:lt2},{ln1:ln2})))
pp(min(corr({lt1:lt2},{ln1:ln2})))
pp("Corr - Trop Pac Ocean")
lt1=-5
lt2=5
ln1=150
ln2=280
pp(max(corr({lt1:lt2},{ln1:ln2})))
pp(min(corr({lt1:lt2},{ln1:ln2})))
