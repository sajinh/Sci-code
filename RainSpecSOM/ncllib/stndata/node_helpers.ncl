function get_members(node_dir,node)
begin
  fname=file_join((/node_dir,node/))
  return(asciiread(fname,-1,"integer"))
end

function all_files(node_dir)
begin
  ;return(systemfunc("ls "+node_dir+"/som*_*"))
  return(systemfunc("cd "+node_dir+"; ls som*_*"))
end

function get_memb_size(node_dir,node)
begin
  fname=file_join((/node_dir,node/))
  if .not.file_exists(fname)
     return(0)
  end if
  return(numAsciiRow(fname))
end

function add_members(node_dir,nodes)
begin
  nnod=dimsizes(nodes)
  nsiz = new(nnod,integer)
  do i = 0,nnod-1
   nsiz(i) = get_memb_size(node_dir,nodes(i))
  end do
  members_all=new(sum(nsiz), integer)
  kstart=0
  do i = 0,nnod-1
    kend = kstart+nsiz(i)-1
    if nsiz(i) .gt. 0
      tmp = get_members(node_dir,nodes(i))
      members_all(kstart:kend) = tmp
      kstart = kend+1
      delete(tmp)
    end if
  end do
  return(members_all)
end
 
function idx_members(node_dir,nodes,station)
begin
  members = add_members(node_dir,nodes)
  nmembers = dimsizes(members)
  imembers=new(nmembers, "integer")
  do im = 0,nmembers-1
    imembers(im) = ind(members(im) .eq. station)
  end do
  return(imembers)
end

function idx_non_members(node_dir,nodes,station)
begin
  files=all_files(node_dir)
  nfile = dimsizes(files)
  needed=new(nfile,typeof(files))
  nnode=dimsizes(nodes)
  k=0
  do i=0,nfile-1
  fnames=node_dir+"/"+nodes
    ;pp(files(i)+":"+any(fnames.eq.files(i))) 
    if .not.(any(nodes.eq.files(i))) 
    needed(k) = files(i)
    k=k+1
    end if
  end do
  non_members=needed(:k-1)
  return(idx_members(node_dir,non_members,station))
end


function get_stn_data(node_dir,node,var,station)
begin
  return(var(idx_members(node_dir,node,station),:))
end

function get_multiple_data(node_dir,nodes,var,station)
begin
  return(var(idx_members(node_dir,nodes,station),:))
end

function get_locs(lat,lon,node_dir,node,station)
begin
  imembers=idx_members(node_dir,node,station)
  return((/lat(imembers),lon(imembers)/))
end

function get_multiple_locs(lat,lon,node_dir,nodes,station)
begin
  imembers=idx_members(node_dir,nodes,station)
  return((/lat(imembers),lon(imembers)/))
end
