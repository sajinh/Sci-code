module GeoGMap
  PI          = Math::PI
  EARTH_RAD   = 6378137 # radius of earth in meters
  EARTH_CIRC  = 2 * PI * EARTH_RAD
  RAD_PER_DEG = PI / 180.0
  ORG_SHIFT   = EARTH_CIRC / 2.0

  def gtile_res_at_zoom(zoom)
    EARTH_CIRC/ntiles_at_zoom(zoom) 
  end

  def org_shift
    ORG_SHIFT
  end

  def ntiles_at_zoom(zoom)
    2**zoom
  end
  
  def mtr_per_deg
    EARTH_CIRC / 360.0
  end
end

class GMapLatLon
  include Math
  include GeoGMap

  attr_reader :lon, :lat

  def initialize(lat,lon,til_siz=256)
    @lat      = lat * 1.0
    @lon      = lon * 1.0
    @til_siz  = til_siz
    @init_res = EARTH_CIRC / @til_siz
  end

  def to_meter
    y = log( tan((90 + lat) * PI / 360.0) ) / RAD_PER_DEG
    [y,lon].map {|c| c* mtr_per_deg}
  end

  def to_px(zoom)
    my, mx = self.to_meter
    mtr_to_pxl(my,mx,zoom)
  end

  def to_tile(zoom)
    py, px = self.to_px(zoom)
    [py, px].map {|c| (c/@til_siz).ceil} 
  end

  def to_gtile(zoom)
    gtres = gtile_res_at_zoom(zoom)
    my, mx = self.to_meter
    ty, tx = [my, mx].map {|c| ((c+ORG_SHIFT)/gtres).ceil - 1} 
    return [((2**zoom -1) - ty), tx]
  end

  def res(zoom)
    resolution_at_zoom(zoom)
  end

private
  def mtr_to_pxl(my,mx,zoom)
    res = resolution_at(zoom)  
    p res
    [my, mx].map {|c| ((c + ORG_SHIFT) / res).ceil} 
  end

  def resolution_at_zoom(zoom)
    @init_res / ntiles_at_zoom(zoom)
  end
end

class GTile
  include GeoGMap

  attr_accessor :ty,:tx
  attr_reader :zoom
  def initialize(ty,tx,zoom)
    @ty=ty
    @tx=tx
    @zoom=zoom
  end

  def gtres
    gtile_res_at_zoom(zoom)
  end

  def sw_latlon
    my,mx = [(2**zoom-1) - ty, tx].map { |t| t * gtres - org_shift }
    lat,lon = [my,mx].map {|c| (c / mtr_per_deg) }
    lat = 180/Math::PI * (2*Math.atan(Math.exp(lat*Math::PI/180.0)) - Math::PI/2.0)
    [lat,lon]
  end

  def bounds
    del=0.0000001
    sw=sw_latlon
    ne=GTile.new(ty-1,tx+1,zoom).sw_latlon 
    [sw[0]+del,sw[1]+del,ne[0]-del,ne[1]-del]
  end
end

class GPoint
  def initialize(lat,lon,zoom)
    @lat=lat
    @lon=lon
    @zoom=zoom
    @info = {}
  end

  def tile_loc
    @info[:tile_loc]=GMapLatLon.new(@lat,@lon).to_gtile(@zoom)
  end

  def tile_bnds
    [:sw_lat,:sw_lon,:ne_lat,:ne_lon].zip(
      GTile.new(tile_loc[0],tile_loc[1],@zoom).bounds)
  end

  def tile_info
    @info[:tile_bnds]=Hash[tile_bnds]
    @info
  end
end

class GArea
  def initialize(lats,lons,zoom)
    @lats=lats
    @lons=lons
    @zoom=zoom
    @info={:zoom => zoom}
  end

  def sw_tile_info
    GPoint.new(@lats[0],@lons[0],@zoom).tile_info 
  end

  def ne_tile_info
    GPoint.new(@lats[1],@lons[1],@zoom).tile_info 
  end

  def sw_tile_loc
    sw_tile_info[:tile_loc]
  end

  def ne_tile_loc
    ne_tile_info[:tile_loc]
  end

  def num_ew_tiles
    ne_tile_loc[1]-sw_tile_loc[1] + 1
  end

  def num_ns_tiles
    -ne_tile_loc[0]+sw_tile_loc[0] + 1
  end

  def sw_lat
    sw_tile_info[:tile_bnds][:sw_lat]
  end

  def sw_lon
    sw_tile_info[:tile_bnds][:sw_lon]
  end

  def ne_lat
    ne_tile_info[:tile_bnds][:ne_lat]
  end

  def ne_lon
    ne_tile_info[:tile_bnds][:ne_lon]
  end

  def tile_loc
    @info[:lat_tiles]=(sw_tile_loc[0]..ne_tile_loc[0])
    @info[:num_lat_tiles]=num_ns_tiles
    @info[:lon_tiles]=(sw_tile_loc[1]..ne_tile_loc[1])
    @info[:num_lon_tiles]=num_ew_tiles
  end

  def tile_coord
    @info[:lat_bds]=(sw_lat..ne_lat)
    @info[:lon_bds]=(sw_lon..ne_lon)
  end

  def tile_info
    tile_loc
    tile_coord
    @info
  end

private
  def ary_elem_to_rng(*ary)
    (ary.min..ary.max)
  end
end



=begin doc
How to use...
#lat, lon = 85.0511287798066, -180.0
lat, lon = ARGV.map {|arg| arg.to_f}
zoom = ARGV[2].to_i | 0
gm = GMapLatLon.new(lat,lon)
gp = GPoint.new(lat,lon,zoom)
require 'pp'
puts gp.tile_loc
pp gp.tile_info
puts "Now to GArea"
ga = GArea.new([30,40],[150,170],6)
puts ga.ne_tile_loc
puts ga.num_ew_tiles
puts ga.num_ns_tiles
puts ga.sw_lat
puts ga.sw_lon
puts ga.ne_lat
puts ga.ne_lon
pp ga.tile_info
puts "30,150::40,170"
exit
#puts gm.to_meter.join(",")
#puts gm.res(zoom)
#gtile = gm.to_gtile(zoom)

#puts  "The latlon co-ords #{lat}, #{lon} 
#         belongs to tile  #{(gm.to_gtile(zoom)).join(",")}
#         at zoom=#{zoom}"

#gtile=GTile.new(gtile[0],gtile[1],zoom)
gtile=GTile.new(24,56,6)
puts gtile.bounds.join ","
=end doc
