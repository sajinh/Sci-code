load "$SysE/lib/ncl/helper_libs.ncl"

BARCHART=True
PTYPE = "x11"

fin = fopen_read("../rain.nc")
nstn = dimsizes(fin->station)
head = readAsciiHead("./rain.fin_map", 1) 
arr  = str_split(head," ")
nvec = toint(arr(0))
ncol = toint(arr(2))
nrow = toint(arr(3))
pp("num cols = "+ncol)
pp("num rows = "+nrow)
mon = ispan(1,nvec,1)
monl =(/"d","i","a"/)

som = new( (/nrow,ncol,nvec/), "float")
som_text = new( (/nrow,ncol/), "string")
som_text = "0"
nsom = nrow*ncol
isom = 0
plot = new(nsom,"graphic")
tnum  = plot
ttxt  = plot
wks  = open_wks(PTYPE,"som_map","rainbow")
res = True
if BARCHART
  res@gsnXYBarChart = True
;  res@gsnXYBarChartOutlineOnly = True
end if
;  res@gsnYRefLine = ispan(2,8,2)*0.1
;  res@gsnXRefLine = (/17,38/)
;  res@gsnYRefLineDashPatterns = (/2/)
;  res@gsnXRefLineDashPattern = (/2/)
;  res@gsnAboveYRefLineColor = (/"green","blue","orange"/)
;  res@xyMarkLineMode = "MarkLines"

res@trYMaxF = 1.2
res@trYMinF = 0.0
nodraw(res)
noframe(res)
res@tmXBMode   = "Explicit"
res@tmXBValues = mon
res@tmXBLabels = monl

txres               = True                     ; text mods desired
txres@txFontHeightF = 0.05                     ; font smaller. default big
do iy = 0,nrow-1
  do ix = 0,ncol-1
    fnam = "./node_weights/som"+ix+"_"+iy
    som(iy,ix,:) = asciiread(fnam,nvec,"float")
    tnam = "./node_members/som"+ix+"_"+iy
    if isfilepresent(tnam)
      som_text(iy,ix) = 100*numAsciiRow(tnam)/nstn
    end if
    plot(isom) = gsn_csm_xy(wks,mon,som(iy,ix,:), res)
    tnum(isom)  = gsn_add_text(wks,plot(isom),ix+"_"+iy,2,1.1,txres) 
    ttxt(isom)  = gsn_add_text(wks,plot(isom),som_text(iy,ix)+"%",2,0.9,txres) 
    isom = isom + 1
  end do
end do

gsn_panel(wks,plot,(/nrow,ncol/),True)
