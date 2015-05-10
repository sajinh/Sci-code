load "$SysE/lib/ncl/helper_libs.ncl"


vnam1="kns"
vnam2="toh"
var="slp"

color_scheme="hotcolr_19lev"
color_scheme="BlueWhiteOrangeRed"
fname="decadal_tele_glb"
ftyp="x11"

DEBUG = False
ALT_CNT = True

fvar=fopen_read("../../Cache/dec_"+var+".nc")
fprc1=fopen_read("../../Cache/dec_rain_"+vnam1+".nc")
fprc2=fopen_read("../../Cache/dec_rain_"+vnam2+".nc")

tim1=fvar->time
tim2=fprc1->time
stim=max((/min(tim1),min(tim2)/))
etim=min((/max(tim1),max(tim2)/))
pp(stim+":"+etim)
stim@units=tim1@units
etim@units=tim1@units

if DEBUG
  pp(cd_calendar(stim,-5))
  pp(cd_calendar(etim,-5))
end if

slp=fvar->$var$({stim:etim},:,:)
prc1=fprc1->$vnam1$(:,{stim:etim})
prc2=fprc2->$vnam2$(:,{stim:etim})
pav1=dim_avg_n(prc1,0)
pav2=dim_avg_n(prc2,0)

pav=(pav1+pav2)*0.5
reg=slp(0,:,:)
reg=(/ regCoef(pav,slp(lat|:,lon|:,time|:)) /)
corr = reg
corr = (/ escorc(pav,slp(lat|:,lon|:,time|:)) /)


wks=open_wks(ftyp,fname,color_scheme)
res=True
copt=True
clev0=ispan(-20,20,4)*0.1
izero=ind(clev0.eq.0.0)
clevs=new(dimsizes(clev0)-1,typeof(clev0))
clevs(:izero-1)=clev0(:izero-1)
clevs(izero:)=clev0(izero+1:)

if DEBUG
  pp(clevs)
end if

copt@clevs=clev0
nodraw(res)
noframe(res)
cres=res

res@mpCenterLonF = 120
res@mpDataSetName         = "Earth..4"   ; This new database contains
res@mpDataBaseVersion     = "MediumRes"  ;

lcr = (/ 0.8, 0.8, 0.8, 0.2 /)
jcr = (/ 0.0, 0., 0.0, 1.0 /)
wcr = (/ 0.0, 0.4, 0.1, 0.2 /)
res@mpFillAreaSpecifiers=(/"land","water","japan","iceland","portugal","alaska"/)
res@mpSpecifiedFillColors = (/lcr,wcr,jcr,jcr,jcr,jcr/)
res@mpInlandWaterFillColor = 54
res@mpAreaMaskingOn=True
res@mpFillDrawOrder="PostDraw"
res@mpOutlineOn = False
res@mpGeophysicalLineColor      = "Black"       ; color of cont. outlines
res@mpGeophysicalLineThicknessF = 0.5          ; thickness of outlines
res@mpPerimDrawOrder="PostDraw"
res@mpPerimLineThicknessF=1.5

myfill(res,copt)
res@lbLabelBarOn=True
setstring(res,0.01,"","")
res@gsnAddCyclic = True
plot=gsn_csm_contour_map_ce(wks,reg,res)
delete(res@cnLevels)

if ALT_CNT
  reg@clevs=clev0(::2)
end if
cres@cnLineThicknessF=1.0
setstring(cres,0.01,"","")
cres@gsnContourZeroLineThicknessF=0.0
cplot=plot_contour(wks,reg,cres)
overlay(plot,cplot)

; indicate regions of high correlation with stipples
sres = True
nodraw(sres)
noframe(sres)

sres@cnLevelSelectionMode="ExplicitLevels"
sres@cnLevels=(/-0.8,-0.6,0.6,0.8/)
sres@cnMonoFillPattern = False
sres@cnFillPatterns = (/17,5,-1,5,17/)
sres@cnMonoFillScale = False
sres@cnFillScales = (/0.8,0.8,100.0,0.8,0.8/)
sres@cnMonoFillColor = True
sres@cnFillDotSizeF = 0.005
sres@cnFillOn = True
sres@cnLinesOn = False
sres@lbLabelBarOn = False
sres@cnInfoLabelOn = False

splot = gsn_csm_contour(wks,corr,sres)
overlay(plot,splot)
draw(plot)
frame(wks)
