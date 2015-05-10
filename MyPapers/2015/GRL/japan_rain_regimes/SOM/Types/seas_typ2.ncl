load "$SysE/lib/ncl/helper_libs.ncl"
load "$HOMEOFFICE/ncllib/stndata/node_helpers.ncl"
load "./make_plot_spec.ncl"

SMOOTH_TS   = True
DTREND_TS = True
SMOOTH_SPEC = True
nave        = 3   ; a 3-month running mean
spec_nave   = 5   ; n-point smoother for spectra
pct_taper   = 0.1 ; taper 10% of the time series
opt         = True
opt@plot_type = "x11"
opt@plot_name = "Decadal_spec"
opt@b1=5
opt@b2=15
;opt@conf_int=0


nodes = asciiread("../typ2_nodes.txt",-1,"string")
nodes="som"+nodes
node_dir="../node_members"
fin=fopen_read("../../rain_wtim.nc")
plot_spectra(nodes,node_dir,fin,nave,spec_nave,pct_taper,SMOOTH_TS,\
         DTREND_TS, SMOOTH_SPEC,opt)

