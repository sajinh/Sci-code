load "$SysE/lib/ncl/helper_libs.ncl"
load "../../ncllib/stndata/node_helpers.ncl"


nave = 3
rmon = 8 ; august/JAS
fin=fopen_read("../../rain.nc")
nodes = asciiread("../typ1_nodes.txt",-1,"string")
nodes="som"+nodes
node_dir="../node_members"
pr0=fin->rain
st0=fin->station
time=fin->time
idx = idx_members(node_dir,nodes,st0)
var = pr0(:,idx)
station = var&station
ntim = dimsizes(time)
nstn = dimsizes(station)

fout = fopen_write("typ1_rain.nc")
fout->rain=var(station|:,time|:)
fout->lat=fin->lat(idx)
fout->lon=fin->lon(idx)


