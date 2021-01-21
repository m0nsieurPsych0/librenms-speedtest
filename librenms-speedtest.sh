#!/bin/bash
# LibreNMS Speedtest plugin
RRDGraphsDir=/opt/librenms-speedtest/rrd
PNGImagesDir=/opt/librenms-speedtest/png
SpeedtestResultDir=/opt/librenms-speedtest/tmp


        case $1 in (create)
                # Create the Latency measurement RRD
                rrdtool create $RRDGraphsDir/speedtest-latency.rrd -s 1800 \
                DS:LATENCY:GAUGE:3600:0:1000 \
                RRA:AVERAGE:0.5:1:576 \
                RRA:AVERAGE:0.5:6:672 \
                RRA:AVERAGE:0.5:24:732 \
                RRA:AVERAGE:0.5:144:1460

                # Create the Bandwidth measurement RRD
                rrdtool create $RRDGraphsDir/speedtest-bandwidth.rrd -s 1800 \
                DS:DOWN:GAUGE:3600:0:1000 \
                DS:UP:GAUGE:3600:0:1000 \
                RRA:AVERAGE:0.5:1:576 \
                RRA:AVERAGE:0.5:6:672 \
                RRA:AVERAGE:0.5:24:732 \
                RRA:AVERAGE:0.5:144:1460
                ;;
        (run)
                # Get the date of the moment we start the test, in epoch format
                DATE=$(/bin/date +%s)

                # Generate speedtest results, store them in a temp file
                speedtest-cli --simple --share > $SpeedtestResultDir/speedtest-results 2>/dev/null

                # Get the Latency
                Latency=$(cat $SpeedtestResultDir/speedtest-results | grep Ping | sed -r 's/\s+//g'| cut -d":" -f2 | cut -d"m" -f1)

                # Get the Download speed
                DownloadSpeed=$(cat $SpeedtestResultDir/speedtest-results | grep Download | sed -r 's/\s+//g'| cut -d":" -f2 | cut -d"M" -f1)

                # Get the Upload speed
                UploadSpeed=$(cat $SpeedtestResultDir/speedtest-results | grep Upload | sed -r 's/\s+//g'| cut -d":" -f2 | cut -d"M" -f1)

                # Update the RRD graphs
                rrdtool update $RRDGraphsDir/speedtest-latency.rrd $DATE:$Latency
                rrdtool update $RRDGraphsDir/speedtest-bandwidth.rrd $DATE:$DownloadSpeed:$UploadSpeed
                ;;
        (graph)
                # Create the Latency PNG
                rrdtool graph $PNGImagesDir/speedtest-latency.png -J -a PNG -s -1day \
                --title="Latency during Speedtest" \
                --vertical-label "ms" \
                DEF:P=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:AVERAGE \
                DEF:PMIN=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MIN \
                DEF:PMAX=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MAX \
                VDEF:Pavg=P,AVERAGE \
                LINE1:Pavg#cc3300:"Avg \n" \
                LINE2:P#3d61ab:"Last latency (ms)\n" \
                GPRINT:Pavg:"Avg latency %2.1lf ms\n" \
                -h 300 -w 650 -y1:2 \
                -c BACK#EEEEEE00 \
                -c SHADEA#EEEEEE00 \
                -c SHADEB#EEEEEE00 \
                -c CANVAS#FFFFFF00 \
                -c GRID#a5a5a5 \
                -c MGRID#FF9999 \
                -c FRAME#5e5e5e \
                -c ARROW#5e5e5e \
                -R normal \
                -c FONT#000000 \
                --font LEGEND:8:DejaVuSansMono \
                --font AXIS:7:DejaVuSansMono > /dev/null 2>&1

                # Create the Bandwidth PNG
                rrdtool graph $PNGImagesDir/speedtest-bandwidth.png -J -a PNG -s -1day \
                --title="Speedtest Bandwidth" \
                --vertical-label "Mb/s" \
                DEF:D=$RRDGraphsDir/speedtest-bandwidth.rrd:DOWN:AVERAGE \
                DEF:DMIN=$RRDGraphsDir/speedtest-bandwidth.rrd:DOWN:MIN \
                DEF:DMAX=$RRDGraphsDir/speedtest-bandwidth.rrd:DOWN:MAX \
                DEF:U=$RRDGraphsDir/speedtest-bandwidth.rrd:UP:AVERAGE \
                DEF:UMIN=$RRDGraphsDir/speedtest-bandwidth.rrd:UP:MIN \
                DEF:UMAX=$RRDGraphsDir/speedtest-bandwidth.rrd:UP:MAX \
                CDEF:Y0=U,0,* \
                CDEF:NegU=U,-1,* \
                VDEF:Yavg=Y0,AVERAGE \
                VDEF:Davg=D,AVERAGE \
                VDEF:Uavg=NegU,AVERAGE \
                VDEF:Uavg2=U,AVERAGE \
                AREA:D#61ab3d:"Download" \
                AREA:NegU#3d61ab:"Upload" \
                LINE1:Uavg#cc1100: \
                LINE1:Davg#cc3300:"Avg\n" \
                LINE1:Yavg#111111: \
                GPRINT:D:LAST:"Last download bandwidth\: %2.1lf Mb/s\n" \
                GPRINT:U:LAST:"Last upload bandwidth\: %2.1lf Mb/s\n" \
                GPRINT:Davg:"Avg download bandwidth %2.1lf Mb/s\n" \
                GPRINT:Uavg2:"Avg upload bandwidth %2.1lf Mb/s" \
                -h 300 -w 650 -y1:2 \
                -c BACK#EEEEEE00 \
                -c SHADEA#EEEEEE00 \
                -c SHADEB#EEEEEE00 \
                -c CANVAS#FFFFFF00 \
                -c GRID#a5a5a5 \
                -c MGRID#FF9999 \
                -c FRAME#5e5e5e \
                -c ARROW#5e5e5e \
                -R normal \
                -c FONT#000000 \
                --font LEGEND:8:DejaVuSansMono \
                --font AXIS:7:DejaVuSansMono > /dev/null 2>&1

                # Move PNGs to the LibreNMS plugin location
                cp $PNGImagesDir/*.png /opt/librenms/html/plugins/Speedtest/image
                ;;

        (*)
                echo "Invalid option.";;
        esac