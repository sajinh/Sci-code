function fft_filter(var,fca,fcb)
begin
  ntim  = dimsizes(var)
  cf      = ezfftf (var)                    ; sub period (2, ntim/2)
  fcf     = fspan(0, 0.5, ntim/2) 
  ifcf    = ind(fcf.lt.fcb .or. fcf.gt.fca)
  cf(:,ifcf) = 0.0                        ; set coef to zero
  return(ezfftb (cf, cf@xbar))   
end
function make_another_plot(wks,xvar,var_fftsm,var_sm)
begin
  res2=True
  nodraw(res2)
  noframe(res2)
  res2@tmXTOn = False
  res2@tmXBOn = False
  res2@tmYLOn = False
  res2@tmYROn = False
  res2@xyLineColors      = (/"black","black"/)
  res2@xyLineThicknesses = (/2,3/)
  res2@xyDashPatterns    = (/1,0/)
  return(gsn_csm_xy(wks,xvar,(/var_fftsm,var_sm/),res2))
end


function plot_rain(wks,xvar,rain,ivar,filtr,nsmth,\
                         yr_low,yr_hig,res,opt)
begin
  if dimsizes(ivar) .eq. 1
    var     = dim_avg_n(rain(ivar:ivar,:),0)
  else
    var     = dim_avg_n(rain(ivar,:),0)
  end if
  var     = runave(var,nsmth,1)
  var_fftsm = fft_filter(var,1.0/(yr_low*12.0),1.0/(yr_hig*12.0))
  var_sm  = wgt_runave(var, filtr,0)
  ; a hack to remove fft filter ; take care to remove this if needed
  var_fftsm = var_sm

  ;res@tmXUseBottom  = False
  res@tmXTOn = False
  res@tmXBOn = False
  res@tmXTLabelsOn = False
  if isatt(opt, "top")
    if opt@top
    res@tmXTOn = True
    res@tmXTLabelsOn = True
    end if
  end if
  if isatt(opt, "bottom")
    if opt@bottom
    res@tmXBOn = True
    end if
  end if

  if isatt(opt,"minmax")
    mm=opt@minmax
    res@trYMinF=mm(0)
    res@trYMaxF=mm(1)
  end if

  res@tmYROn = False
  plotb = make_another_plot(wks,xvar,var_fftsm,var_sm)
  xref_int = 5
  if isatt(opt,"xref_int")
     xref_int=opt@xref_int
  end if
  cy = ispan(1900,2020,xref_int)*1.0
  res@gsnXRefLine = cy
  res@gsnYRefLine = 0.0
  res@gsnAboveYRefLineColor="red"
  res@gsnBelowYRefLineColor="lightblue"
  if isatt(opt, "nofrills")
    if opt@nofrills
    res@tmXTOn = False
    res@tmXBOn = False
    res@tmYLOn = False
    res@tmYROn = False
    delete(res@gsnXRefLine)
    delete(res@gsnYRefLine)
    delete(res@gsnAboveYRefLineColor)
    delete(res@gsnBelowYRefLineColor)
    end if
  end if
  plota = gsn_csm_xy(wks,xvar,var,res)
  overlay(plota,plotb)
  plota@var=var ;_fftsm
return(plota)
end

function plot_rain2(wks,xvar,rain1,ivar1,rain2,ivar2,filtr,nsmth,\
                         yr_low,yr_hig,res,opt)
begin
  var     = dim_avg_n(rain2(ivar2,:),0)
  opt@nofrills=False
  r1plot= plot_rain(wks,xvar,rain1,ivar1,filtr,nsmth,\
                         yr_low,yr_hig,res,opt)
  x1=r1plot@var
  return(r1plot)
  opt@nofrills=True
  r2plot= plot_rain(wks,xvar,rain2,ivar2,filtr,nsmth,\
                         yr_low,yr_hig,res,opt)
  x2=r2plot@var
  pp(escorc(x1,x2))
  overlay(r1plot,r2plot)
  return(r1plot)
end

function plot_rain_ts(wks,xvar,rain1,ivar1,filtr,nsmth,\
                         yr_low,yr_hig,res,opt)
begin
  opt@nofrills=False
  r1plot= plot_rain(wks,xvar,rain1,ivar1,filtr,nsmth,\
                         yr_low,yr_hig,res,opt)
  x1=r1plot@var
  return(r1plot)
end


function inum(istx,pct)
begin
  return(toint(dimsizes(istx)*pct/100.0))
end
function stn_id(ipx,stnx,stationx)
begin
  nstn = dimsizes(ipx)
  istn = new(nstn,integer)
  do i=0,nstn-1
    stn=stnx(ipx(i))
    istn(i) = ind(stn .eq. stationx)
  end do
  return(istn)
end
function latid(station,lat,istnx,pctx,lats,latn)
begin
  istn = istnx(0:inum(istnx,pctx)-1)
  stn = new(dimsizes(istn),integer)
  k = 0
  do i = 0,dimsizes(istn)-1
    lati = lat(istn(i))
    if ((lati .ge. lats) .and. (lati .lt. latn))
      stn(k) =  ind(station(istn(i)) .eq. station)
      k=k+1
    end if
  end do
  return(stn(0:k-1))
end
