load "$SysE/lib/ncl/helper_libs.ncl"

yrno=asciiread("fig1.csv",(/10,2/), "float")
yr=(yrno(:,0))
nyr=dimsizes(yr)
x=ispan(1,nyr,1)
nm=(yrno(:,1))
ptyp="pdf"
pnam="fig1"


wks=open_wks(ptyp,pnam,"default")

res = True
res@gsnXYBarChart = True
res@vpWidthF=0.7
res@vpHeightF=0.2
res@gsnYRefLine=0.0
res@gsnAboveYRefLineColor="gray"
res@tmXBMode = "Explicit"
res@tmXBValues = x
res@tmXBLabels = yr
res@tiYAxisString = "Number of stations"
res@tiXAxisString = "Time (Years)"
plot = gsn_csm_xy(wks,x,nm,res)
