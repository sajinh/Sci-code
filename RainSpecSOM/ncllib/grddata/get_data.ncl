function dice_data(fnam,vnam,end_year)
local fin, dmi, time, dmi_son
begin
  fin=fopen_read(fnam)
  tunits = fin&time@units
  end_time = ut_inv_calendar(end_year,12,15,0,0,0,tunits,0)
  itim = doubletointeger(end_time)
  dmi=fin->$vnam$({:itim})
  time=dmi&time(9::12)
  dmi=runave_Wrap(dmi,3,0)
  dmi_son=dmi(9::12)
  dmi_son!0="time"
  dmi_son&time=time
  return(dmi_son)
end

function create_domain(lev,lat,lon)
begin
  domain=True
  domain@lat1=1.0
  domain@lon1=1.0
  domain@lev1=1
  domain@lat2=1.0
  domain@lon2=1.0
  domain@lev2=1
  CMS_subsetter(domain@lat1,domain@lat2,lat)
  CMS_subsetter(domain@lon1,domain@lon2,lon)
  ;if .not. ismissing(lev)
  if (.not. (lev.eq.False))
    CMS_subsetter(domain@lev1,domain@lev2,lev)
  end if
  return(domain)
end

function fname_from_domain(lev,lat,lon)
begin
  dm = create_domain(lev,lat,lon)
  if isatt(dm,"lat1")
    if dm@lat1 .lt. 0
      dm@lt1=-1*dm@lat1+"S"
    else
      dm@lt1=dm@lat1+"N"
    end if
    if dm@lat2 .lt. 0
      dm@lt2=-1*dm@lat2+"S"
    else
      dm@lt2=dm@lat2+"N"
    end if
  end if
  if isatt(dm,"lon1")
    if dm@lon1 .lt. 0
      dm@ln1=-1*dm@lon1+"W"
    else
      dm@ln1=dm@lon1+"E"
    end if
    if dm@lon2 .lt. 0
      dm@ln2=-1*dm@lon2+"W"
    else
      dm@ln2=dm@lon2+"E"
    end if
  end if
  lev_str=array_join((/dm@lev1,dm@lev2/),"to")
  lat_str=array_join((/dm@lt1,dm@lt2/),"to")
  lon_str=array_join((/dm@ln1,dm@ln2/),"to")
  dom_fname=array_join((/lev_str,lat_str,lon_str/),"_")
  return(dom_fname)
end

function create_local_fnam(opt)
begin
  tim = opt@Time
  if isatt(opt,"Lev")
    lev = opt@Lev
  else
    lev = False
  end if
  lat = opt@Lat
  lon = opt@Lon
  nam = opt@vname
  src = opt@DataSource
  frq = opt@DataFreq
  typ = opt@DataType
  cache_root = opt@cache_root
  dnam = file_join((/cache_root,src,frq,typ,nam/))+"/"+array_join(tim,"-")
  dfnam = fname_from_domain(lev,lat,lon)
  if .not. isfilepresent(dnam)
    print("Making Local Cache Directory :: "+dnam)
    make_the_dir(dnam)
  end if
  return(file_join((/dnam,dfnam/)))
end

function fill_opt_getdata(opt,root,src,vnam,tim,lev,lat,lon)
begin
  opt@DataRoot=root
  opt@DataSource=src
  opt@DataType="Anomaly"
  opt@vname=vnam
  if .not. (str_lower(lev) .eq. "none")
    opt@Lev=lev
  end if
  opt@Time=tim
  opt@Lat=lat
  opt@Lon=lon
  return(opt)
end

function get_data(cache_root,root,src,vnam,tim,lev,lat,lon)
begin
  opt = True
  opt=fill_opt_getdata(opt,root,src,vnam,tim,lev,lat,lon)
  opt@cache_root=cache_root
  opt@DataFreq="Monthly"
  local_fnam = create_local_fnam(opt)
  opt@LocalFile=local_fnam+".nc"
  return(slice_data_cached(opt))
end

function get_daily_data(cache_root,root,src,vnam,tim,lev,lat,lon)
begin
  opt = True
  opt=fill_opt_getdata(opt,root,src,vnam,tim,lev,lat,lon)
  opt@cache_root=cache_root
  opt@DataFreq="Daily"
  local_fnam = create_local_fnam(opt)
  opt@LocalFile=local_fnam+".nc"
  return(slice_data_cached(opt))
end
