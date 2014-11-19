require 'numru/netcdf'
require 'pp'
include NumRu

SEASONAL = true
smon = 8 # JAS (centered on 8th month/Aug)
file = NetCDF.open("typ1_rain.nc")
rain = file.var("smoothed_rain").get
station = file.var("station").get
file.close

pp rain.class
pp rain.size
pp rain.dim
pp rain.shape
ntim,nstn = rain.shape


if SEASONAL
  # we need only rain for selected season
  idx =  (smon-1..ntim-1).step(12).to_a
  ncol = ntim/12
else
  idx = (0..ntim-1).to_a
  ncol = ntim
end

fout = File.open("typ1_rain.txt","w")
fout.puts "#{ncol} rect 2 2 gaussian"
(0..nstn-1).each do |istn|
  txt = rain[idx,istn]
  txt/= txt.max
  fout.puts txt.to_a.map{|f| f.round(2)}.join(" ")+" #{station[istn]}"
end
fout.close

