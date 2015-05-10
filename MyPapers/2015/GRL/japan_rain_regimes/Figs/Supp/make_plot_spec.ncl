procedure plot_spectra(nodes,node_dir,fin,nave,spec_nave,pct_taper,SMOOTH_TS,\
         DTREND_TS, SMOOTH_SPEC,opt)
begin
station=fin->station
imembers = idx_members(node_dir,nodes,station)
nmembers=dimsizes(imembers)
nstn = dimsizes(station)
pp(100*nmembers/nstn+"% of stations")
opt@conf_int=0

lat=fin->lat(imembers)
lon=fin->lon(imembers)
if nmembers .eq. 1
  prec=fin->rain(:,:,imembers:imembers)
else
  prec=fin->rain(:,:,imembers)
end if
info(prec)
prec({1993},:,:) = 0.0
prec({1994},:,:) = 0.0
nstn=dimsizes(prec&station)
nyr=dimsizes(prec&year)
nmo=dimsizes(prec&month)
ntim=nyr*nmo

; stnave_prec : average over all stations
; pmask       : an mask array that will be multiplied element by element 
;               with the timeseries -  this will suppress data at months
;               other than the season of interest. A cosine bell or double
;               cosine bell function is used.
; 

stnave_prec=ndtooned(dim_avg(prec))
if SMOOTH_TS
  stnave_prec = runave(stnave_prec,nave,1)
end if

pmask = (/stnave_prec/) ; same length as 1d time series

if .not. SMOOTH_SPEC
  spec_nave = -1*spec_nave
end if
if DTREND_TS
  iopt = 1
else
  iopt = 0
end if

spec=specx_anal(stnave_prec,iopt,spec_nave,pct_taper)
freq = spec@frq
spec1 = spec@spcx
nfrq = dimsizes(freq)
spec2d = new ((/nmo,nfrq/), typeof(spec1))
xlag1 = new(nmo, typeof(spec@xlag1))
sdof = new(nmo, typeof(spec))
add_dimensions(spec2d,(/"month","freq"/))
spec2d&month=ispan(1,nmo,1)
spec2d&freq=freq

; Spectra for each month by masking variance during other months
do rmon=0,nmo-1
  k=0
  pmask = 0.0
  do iyr = 0,nyr-1
    do imo = 0,nmo-1
      ; Give mask a value of 1 if we encounter month of interest
      dmon=(imo-rmon)/12.0
     mval = fabs(cos(3.14*dmon))
      pmask(k) = mval^5
      k=k+1 
    end do
  end do
  rain = stnave_prec*pmask
  tmp = specx_anal(rain,iopt,spec_nave,pct_taper)
  sdof(rmon) = tmp
  xlag1(rmon) = tmp@xlag1
  spec2d(rmon,:) = tmp@spcx
end do   

; find band-averaged maxima
if isatt(opt,"b1")
  b1 = 1.0*opt@b1
  b2 = 1.0*opt@b2
  b1 = 1.0/(b1*12.0)
  b2 = 1.0/(b2*12.0)
  ib1 = closest_val(b1,freq)
  ib2 = closest_val(b2,freq)
  pp(b1+"==?"+freq(ib1))
  pp(b2+"==?"+freq(ib2))
  avg_spec=dim_avg(spec2d(:,ib1:ib2))
  max_time=maxind(avg_spec)
  if isatt(opt,"max_mon")
    max_time=opt@max_mon
  end if
  pp(max_time)
  spec1 = dim_avg_n(spec2d(max_time-1:max_time+1,:),0)
  spec1d = avg(sdof(max_time-1:max_time+1))
  spec1d@xlag1=avg(xlag1(max_time-1:max_time+1))
  spec1d@spcx=dim_avg_n(spec2d(max_time-1:max_time+1,:),0)
  spec1d@frq=spec@frq
  ;rspc = specx_ci(spec1d,0.10,0.90)
  rspc = specx_ci(spec1d,0.05,0.95)
end if

period=(1.0/freq)/12.0

colormap="rainbow"
ptyp = "x11"
pnam = "spectra"
if isatt(opt,"plot_type")
  ptyp = opt@plot_type
end if
if isatt(opt,"plot_name")
  pnam = opt@plot_name
end if


wks=open_wks(ptyp,pnam,colormap)

mpres                           = True
mpres@mpOutlineOn           = True         ; Turn on map outlines
mpres@mpOutlineSpecifiers   = (/"India"/)

mpres@mpMinLatF                 = 24
mpres@mpMaxLatF                 = 47
mpres@mpMinLonF                 = 125
mpres@mpMaxLonF                 = 147
mpres@gsnDraw                   = False
mpres@gsnFrame                  = False 
; this controls the size and location of the first plot
mpres@vpXF            = 0.1         
mpres@vpWidthF        = 0.3	    
mpres@vpYF            = 0.95
ocr = (/ 0.9,0.9,0.9,0.5/)
lcr = (/ 0.2, 1., 0.2, .7 /)
mpres@mpOceanFillColor       = ocr
mpres@mpLandFillColor        = lcr
mpres@mpDataSetName         = "Earth..4" 
mpres@mpDataBaseVersion = "MediumRes"

; -- marker styling
gsres = True
gsres@gsMarkerIndex = 16
gsres@gsMarkerSizeF = 0.004

res = True
nodraw(res)
noframe(res)
month=ispan(1,12,1)
nmon = dimsizes(month)
res@xyLineColors      = (/"black"/)
res@xyLineThicknesses = (/1.0/)
res@xyDashPatterns    = (/0.0/)
; this controls the size and location of the second plot
res@vpXF            = 0.5         
res@vpWidthF        = 0.45	    
res@vpYF            = 0.85
res@vpHeightF       = 0.265   
res@tfPolyDrawOrder    = "Predraw"    
res@trYMaxF = max(spec1)+max(spec1)*0.1
res@trYMinF = min(spec1)-0.02
if isatt(opt,"conf_int")
  if isatt(opt,"b1")
  res@trYMaxF = 2*max(spec1d@spcx)+0.02
  res@trYMinF = 2*min(spec1d@spcx)-0.02
  end if
end if
 
res@tmXUseBottom  = False
res@trXLog              = True                 ; log scaling
res@trXMinF             = 0.0039
res@trXMinF              = freq(0)
;res@trXMinF             = 0.0009765625
;res@trXMinF             = 0.000744048
res@tmXTLabelsOn = True
res@tmXTOn = True
res@tmXTMode = "Explicit"
;res@tmXTValues    = (/0.00403226,0.0081,0.0201, 0.0416667, 0.083,0.1667,0.33333/)
;res@tmXTLabels    = (/"21yr","10yr","4yr", "2yr", "1yr","6m","3m"/)

spec_mons =  (/15*12,5*12,2*12,1*12,6,3/)
res@tmXTValues = 1.0/spec_mons
res@tmXTLabels    = (/"15yr","5yr", "2yr", "1yr","6m","3m"/)
;7.11111 to 14.2222 yrs
;(0)	interannual 1.58025 to 6.09524 yrs
cy = ((/1.6,7,14/))*12
f2 = 1.0/cy
res@gsnXRefLine = (/f2/)


cres=True
nodraw(cres)
noframe(cres)
opt=True
;opt@clevs=cnvals
myfill(cres,opt)
cres@cnFillMode="RasterFill"
cres@cnRasterSmoothingOn = True
cres@tmXUseBottom  = False
cres@trXLog              = True                 ; log scaling
cres@trXMinF             = res@trXMinF
cres@tmXTLabelsOn = True
cres@tmXTOn = True
cres@tmXTMode = "Explicit"
cres@tmXTValues    = res@tmXTValues
cres@tmXTLabels    = res@tmXTLabels
cres@tmYLMode = "Explicit"
cres@tmYLValues = month(1::2)
mvals = _3mon_seasons()
cres@tmYLLabels = mvals(1::2)
cres@vpXF            = 0.1
cres@vpWidthF        = 0.8
cres@vpYF            = 0.4
cres@vpHeightF       = 0.3

cy = ((/1.6,7,14/))*12
f2 = 1.0/cy
;cres@gsnXRefLine = (/f2/)
;cres@gsnYRefLine = (/5,8/)

plot = gsn_csm_xy(wks,freq,spec1,res)
if isatt(opt,"conf_int")
  if isatt(opt,"b1")
  plot = gsn_csm_xy(wks,freq,rspc,res)
  end if
end if
cplot = gsn_csm_contour(wks,spec2d,cres)
xp = (/freq(0),freq(nfrq-1)/)

gsres                   = True                        ; poly res
gsres@gsFillColor       = "SlateBlue"                 ; color chosen


txres=True
txres@txFontHeightF = 0.02
map = gsn_csm_map(wks,mpres)        
d1=gsn_add_polymarker(wks,map,lon,lat,gsres)
;dummy = gsn_add_polygon (wks,plot,xp,yp,gsres)
gsn_text_ndc(wks,"# of members = "+nmembers,0.2,0.9,txres)

;drawNDCGrid(wks)  

draw(map)
draw(plot)
draw(cplot)
if isatt(opt,"b1")
  yp=(/max_time,max_time/)
  gsn_polyline(wks,cplot,xp,yp,True)
end if
frame(wks)
end
