load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"


root = getenv("HOMEOFFICE")+"/japan_aph/Final"
fin = fopen_read(root+"/rain_wtim.nc")
r0 = fin->rain
time=fin->time
station=fin->station
typ1 = fin->typ1 ; indices of station with type1 rain regime
typ2 = fin->typ2 ; indices of station with type2 rain regime
typ3 = fin->typ3 ; indices of station with type3 rain regime

d1 = dimsizes(typ1)
d2 = dimsizes(typ2)
d3 = dimsizes(typ3)

n0stn = d1+d2+d3
nstn = dimsizes(station)
pp("Percentage of stations "+n0stn*100.0/nstn)
pp("Percentage of multidecadal stations "+d1*100.0/nstn)
pp("Percentage of decadal stations "+d2*100.0/nstn)
pp("Percentage of interannual stations "+d3*100.0/nstn)

ntim = dimsizes(time)
lat = fin->lat
lon = fin->lon
ran0 = onedtond(ndtooned(r0),(/ntim,nstn/))
add_dimensions(ran0,(/"time","station"/))
ran0&time=time
ran0&station=station
rain=ran0(station|:,time|:)

std1 = dim_variance(rain(typ1,:))
std2 = dim_variance(rain(typ2,:))
std3 = dim_variance(rain(typ3,:))
std = dim_variance(rain)
sd1=(sum(std1))
sd2=(sum(std2))
sd3=(sum(std3))
sd=(sum(std))
pp("Percentage variance "+(sd1+sd2+sd3)*100.0/sd)
pp((sd1)*100.0/sd)
pp((sd2)*100.0/sd)
pp((sd3)*100.0/sd)


