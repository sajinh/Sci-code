load "$SysE/lib/ncl/helper_libs.ncl"
load "$SysE/lib/ncl/data_analysis/filters/lanczos.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "./coa_helper.ncl"

PTYP = "pdf"
PNAM = "fig4"
ity = 0 ; Hokkaido
ryr = 112
rlv = 2

WRITE_OUTPUT=False

function nmon_amedas(var,idx)
begin
  ndx = dimsizes(idx)
  nmo = new(ndx, integer)
  do i = 0,ndx-1
    nmo(i) = num(.not.ismissing(var(:,idx(i))))
  end do
  return(nmo)
end

; How long since have been AMeDAS stations 
; with strong decadal signals been operating in Tohoku?
; show location of such stations
; calculate spectrum and wavelet of station averaged data

root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_5reg.nc")
fam = fopen_read(root+"/JMA.anom.activestations.nc")

rain    = fin->rain
am_rain = reduce_to_2D(fam->rain,False)
am_yr   = fam->year
am_mo   = fam->month
am_lat  = fam->lat
am_lon  = fam->lon

tyr = dimsizes(am_rain(:,0))/12
sti = ((tyr-ryr)*12)

function get_indices(ity,rlv,am_rain,ryr)
begin
  types=(/"hok","toh","kns","shi","kyu"/)
  loc=fin->$types(ity)$
  iloc=[/loc@ityp0,loc@ityp1,loc@ityp2/]
  vdx = iloc[rlv]
  hokm = nmon_amedas(am_rain,vdx)
  nstn = num(hokm .ge. ryr*12)
  istn= vdx(ind(hokm .ge. ryr*12))
  istn@nstn=nstn
  return(istn)
end

ihok = get_indices(0,2,am_rain,ryr)
itoh = get_indices(1,2,am_rain,ryr)

nstn=ihok@nstn
pp(nstn)
if (nstn .ge. 2)
  arn=(/ dim_avg(am_rain(sti:,ihok)) /)
else 
  arn=(/ am_rain(sti:,ihok) /)
end if


years = am_yr((tyr-ryr):)
nyr = dimsizes(years)
ntime = dimsizes(arn)
yr1=years(0)
yr2=years(nyr-1)
timeo = fspan(yr1+1.0/12,yr2*1.0,ntime)

add_dimensions(am_rain,(/"time","station"/))
am_rain&time=timeo
am_rain&station=fam->station
ar=am_rain(station|:,time|:)


fopt=True
fopt@xwt = 2
dt = 1.0/12 ; no of years in a month
dec1_fil = low_filter(15,dt,fopt)
dec2_fil = band_filter(5,15,dt,fopt)
int_fil = band_filter(1,10,dt,fopt)


colormap="rainbow"
wks=open_wks(PTYP,PNAM,colormap)


tres=True
topt=True
nodraw(tres)
noframe(tres)
topt@no_fft=True
topt@no_xrefline=True
topt@xref_int=10
topt@bottom=False
nsmth=11
tres@vpXF=0.2
tres@vpYF=0.9
tres@vpWidthF        = 0.65
tres@vpHeightF       = 0.3
topt@top=True
tres@tiYAxisFontHeightF = 0.015
tres@tiYAxisString = "rain anomaly (mm/day)"
rplot=plot_rain(wks,timeo,ar(:,sti:),ihok,dec1_fil,nsmth,\
                         15,100,tres,topt)
topt@top=False
topt@bottom=True
tres@vpYF=tres@vpYF-0.32
tplot=plot_rain(wks,timeo,ar(:,sti:),itoh,dec2_fil,nsmth,\
                         5,20,tres,topt)

if WRITE_OUTPUT
  toh_plot=plot_rain(wks,timeo,ar(:,sti:),itoh,dec2_fil,3,\
                         5,20,tres,topt)
  toh_rain=toh_plot@var
  toh_rain!0="time"
  toh_rain&time=timeo
  info(toh_rain)
  rm_file_if_present("toh_rain.nc")
  fout=fopen_write("toh_rain.nc")
  fout->toh_rain=toh_rain
end if
draw(rplot)
draw(tplot)
frame(wks)
