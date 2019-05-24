#!/bin/sh
# Purpose: Gridding data from the XYZ table by xyz2grd GMT module, here: Kuril-Kamchatka Trench
# GMT modules: gmtset, gmtdefaults, gmtinfo, gmtconvert, xyz2grd, grdcontour, pscoast, pstext, gmtlogo, psconvert
# Step-1. Generate a file
ps=GMT_xyz2grid_KKT.ps

# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN dimgray \
    MAP_FRAME_WIDTH 0.1c \
    MAP_TITLE_OFFSET 1.5c \
    MAP_ANNOT_OFFSET 0.1c \
    MAP_TICK_PEN_PRIMARY thinner,dimgray \
    MAP_GRID_PEN_PRIMARY thinner,dimgray \
    MAP_GRID_PEN_SECONDARY thinner,dimgray \
    MAP_ANNOT_OFFSET_PRIMARY 0.1c \
    FONT_TITLE 12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY 7p,Palatino-Roman,dimgray \
    FONT_ANNOT_SECONDARY 7p,Palatino-Roman,dimgray \
    FONT_LABEL 7p,Palatino-Roman,dimgray \

# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Step-4. Download data:
### http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-144-162;N40-51.

# Step-5. Examine the table
gmt info topo_KKT.xyz
# output: N = 1023707    <144.0083/162.0083>    <39.9976/50.9968>    <-9677/2143>

# Step-6. Convert ASCII to binary
gmt convert topo_KKT.xyz -bo > topo_KKT.b

# Step-7. Gridding using xyz2grd technique.
#gmt xyz2grd topo_KKT.b -D+xm+ym+zm -Gktopo.nc -R144/162/40/51 -I30s -ZTLhw
#gmt xyz2grd topo_KKT.b -D+xm+ym+zm -Graw.nc -R144/150/40/45 -I1 -V -Z -bi3f
gmt xyz2grd topo_KKT.xyz -Gxyz2grdKKT.nc -R144/162/40/51 -I5m -Vv

# Step-8. Add contour lines
gmt grdcontour xyz2grdKKT.nc -R144/40/162/51r -JM6i -P -C1000 -A2000 -Gd2i -K > $ps

# Step-9. Add coastline
gmt pscoast -R -J -P \
    -Bpxg1f1a2 -Bpyg1f1a2 -Df -Wthinnest \
    -B+t"Grid contour modelling using XYZ2grd GMT module algorithm. Kuril-Kamchatka Trench area" \
    -TdjBR+w0.4i+l+o0.15i \
    -Lx12.5c/-1.3c+c50+w400k+l"Mercator projection, Scale, km"+f \
    -UBL/-15p/-45p -O -K >> $ps

# Step-10. Add subtitle
gmt pstext -R -J -X0.5c -Y0.8c -N -O -K \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
144.0 51.5 Input table data: global 1-min grid resolution in ASCII XYZ-format, converted to binary
EOF
144.0 51.0 Output spatial model: 1-min grid spacing in netCDF format, using xyz2grd GMT module

# Step-11. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.3c/-0.2c+w2c -O >> $ps

# Step-12. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert GMT_xyz2grid_KKT.ps -A0.2c -E720 -Tj -P -Z
