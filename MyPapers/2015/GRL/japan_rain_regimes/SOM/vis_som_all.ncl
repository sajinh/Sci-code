load "$SysE/lib/ncl/helper_libs.ncl"

PTYPE = "pdf"

fsp = fopen_read("../rain_spec.nc")
freq=fsp->freq(2:53)
fin = fopen_read("../rain_wtim.nc")
nstn = dimsizes(fin->station)
head = readAsciiHead("./rain.fin_map", 1) 
arr  = str_split(head," ")
nvec = toint(arr(0))
ncol = toint(arr(2))
nrow = toint(arr(3))
pp("num cols = "+ncol)
pp("num rows = "+nrow)
pp("num vecs = "+nvec)
mon = ispan(1,nvec,1)

som = new( (/nrow,ncol,nvec/), "float")
add_dimensions(som,(/"row","col","freq"/))
som&freq=freq
som_text = new( (/nrow,ncol/), "string")
som_text = "0"
nsom = nrow*ncol
isom = 0
plot = new(nsom,"graphic")
tnum  = plot
ttxt  = plot
wks  = open_wks(PTYPE,"spc_map","rainbow")
res = True

res@trYMaxF = 1.2
res@trYMinF = 0.0
nodraw(res)
noframe(res)
res@trXLog              = True                 ; log scaling
res@trXMinF              = freq(0)
res@tmXBLabelsOn = True
res@tmXBOn = True
res@tmXBMode = "Explicit"
spec_mons =  (/15*12,5*12,2*12,1*12,6,3/)
res@tmXBValues = 1.0/spec_mons
res@tmXBLabels    = (/"15yr","5yr", "2yr", "1yr","6m","3m"/)
cy = ((/2,6,14/))*12
f2 = 1.0/cy
res@gsnXRefLine = (/f2/)


txres               = True                     ; text mods desired
txres@txFontHeightF = 0.05                     ; font smaller. default big
do iy = 0,nrow-1
  do ix = 0,ncol-1
    fnam = "./node_weights/som"+ix+"_"+iy
    som(iy,ix,:) = asciiread(fnam,nvec,"float")
    tnam = "./node_members/som"+ix+"_"+iy
    if isfilepresent(tnam)
      ;som_text(iy,ix) = 100*numAsciiRow(tnam)/nstn
      som_text(iy,ix) = numAsciiRow(tnam)
    end if
    plot(isom) = gsn_csm_xy(wks,freq,som(iy,ix,:), res)
    tnum(isom)  = gsn_add_text(wks,plot(isom),ix+"_"+iy,freq(2),0.8,txres) 
    ;ttxt(isom)  = gsn_add_text(wks,plot(isom),som_text(iy,ix)+"%",freq(2),0.6,txres) 
    ttxt(isom)  = gsn_add_text(wks,plot(isom),som_text(iy,ix)+"",freq(2),0.6,txres) 
    isom = isom + 1
  end do
end do

gsn_panel(wks,plot,(/nrow,ncol/),True)
