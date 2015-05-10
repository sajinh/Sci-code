function plot_spec(wks,spec,lcz_fil,res,opt)
begin
  spcx = spec@spcx
  freq=spec@frq
  rspc = specx_ci(spec,0.05,0.90)
  lcz_res = lcz_fil@resp
  lcz_frq = lcz_fil@freq
  nodraw(res)
  noframe(res)
  res@xyLineColors      = (/"black"/)
  res@xyLineThicknesses = (/1.0/)
  res@xyDashPatterns    = (/0.0/)
  res@tmXUseBottom  = False
  res@trXLog              = True                 ; log scaling
  res@trXMinF             = 0.000744048
  res@tmXTLabelsOn = True
  months = (/15*12,5*12,2*12,1*12,6,3/)
  if opt@top
    res@tmXTOn = True
    res@tmXTMode = "Explicit"
;    res@tmXTValues    = (/0.00403226,0.0081,0.0201, 0.0416667, 0.083,0.1667,0.33333/)
    res@tmXTValues = 1.0/months
    res@tmXTLabels    = (/"15yr","5yr", "2yr", "1yr","6m","3m"/)
  else
    res@tmXTOn = False
  end if
  if opt@bottom
    res@tmXBOn = True
  else
    res@tmXBOn = False
  end if

  res@tmYROn = False
  res@tiYAxisFontHeightF = 0.01
  res@tiYAxisString = "Power Spectral Density"
  plot1 = gsn_csm_xy(wks,freq,spcx,res)
  delete(res@tiYAxisString)
  ;plot1 = gsn_csm_xy(wks,freq,rspc,res)
  res@tmYUseLeft  = False
  res@tmYLOn = False
  res@tmYROn = True
  res@tmYRLabelsOn = True
  res@xyDashPatterns    = (/1/)
  res@trYMaxF = 1.05
  res@trYMinF = -0.05
  cy = ((/5,15/))*12
  f2 = 1.0/cy
  ;res@gsnXRefLine = (/f2/)
  ;res@gsnYRefLine = 0.5
  plot2 = gsn_csm_xy(wks,lcz_frq(1:),lcz_res(1:),res)
return([/plot1,plot2/])
end
