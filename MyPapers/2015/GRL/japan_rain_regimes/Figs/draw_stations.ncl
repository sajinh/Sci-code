function draw_stations(wks,map,lon,lat,opt)
begin
  ; -- marker styling
  gsres = True
  gsres@gsMarkerIndex = 16
  gsres@gsMarkerSizeF = 0.008
  gsres@gsMarkerColor = (/0.0,0.0,0.0,0.0/)
  if isatt(opt,"color")
    gsres@gsMarkerColor = opt@color
  end if
  if isatt(opt,"size")
    gsres@gsMarkerSizeF = opt@size
  end if
  if isatt(opt,"type")
    gsres@gsMarkerIndex = opt@type
  end if
  
  return(gsn_add_polymarker(wks,map,lon,lat,gsres))
end

function draw_all_stations(wks,map,spec,lon,lat)
begin
  gsres = True
  gsres@gsMarkerIndex = 16
  gsres@gsMarkerSizeF = 0.008
  nstn = dimsizes(lon)
  color = new(4,float)
  color = 0.0
  stmp = new(nstn,"graphic")
  do i=0,nstn-1
    color((/0,2/)) = spec((/0,2/),i)
    color(3) = 0.1
    gsres@gsMarkerColor = color
    stmp(i)=gsn_add_polymarker(wks,map,lon(i),lat(i),gsres)
  end do
  return(stmp)
end
