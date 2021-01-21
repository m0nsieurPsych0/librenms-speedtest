#!/bin/bash
# LibreNMS Speedtest plugin

RRDGraphsLocation=/opt/speedtest/rrd

        case $1 in (create)
                # Create the Ping measurement RRD
                rrdtool create $RRDGraphsLocation/speedtest_ping.rrd -s 1800 \
                DS:PING:GAUGE:3600:0:1000 \
                RRA:AVERAGE:0.5:1:576 \
                RRA:AVERAGE:0.5:6:672 \
                RRA:AVERAGE:0.5:24:732 \
                RRA:AVERAGE:0.5:144:1460

                # Create the Bandwidth measurement RRD
                rrdtool create $RRDGraphsLocation/speedtest_bandwidth.rrd -s 1800 \
                DS:DOWN:GAUGE:3600:0:1000 \
                DS:UP:GAUGE:3600:0:1000 \
                RRA:AVERAGE:0.5:1:576 \
                RRA:AVERAGE:0.5:6:672 \
                RRA:AVERAGE:0.5:24:732 \
                RRA:AVERAGE:0.5:144:1460
                ;;
        (speedtest)
                # Get the EPOCH date of the moment we start the test
                DATE=$(/bin/date +%s)

                # Generate speedtest results, store them in a temp file
                speedtest-cli --simple --share > /tmp/speedtest.results 2>/dev/null

                # Get the Ping time
                PingTime=$(cat /tmp/speedtest.results | grep Ping | sed -r 's/\s+//g'| cut -d":" -f2 | cut -d"m" -f1)

                # Get the Download speed
                DownloadSpeed=$(cat /tmp/speedtest.results | grep Download | sed -r 's/\s+//g'| cut -d":" -f2 | cut -d"M" -f1)

                # Get the Upload speed
                UploadSpeed=$(cat /tmp/speedtest.results | grep Upload | sed -r 's/\s+//g'| cut -d":" -f2 | cut -d"M" -f1)

                # Update the RRD graphs
                rrdtool update $RRDGraphsLocation/speedtest_ping.rrd $DATE:$PingTime
                rrdtool update $RRDGraphsLocation/speedtest_bandwidth.rrd $DATE:$DownloadSpeed:$UploadSpeed
                ;;
        (graph)
                /usr/bin/rrdtool graph $RRDGraphsLocation/upload.png \
                --start "-3day" \
                -c "BACK#000000" \
                -c "SHADEA#000000" \
                -c "SHADEB#000000" \
                -c "FONT#DDDDDD" \
                -c "CANVAS#202020" \
                -c "GRID#666666" \
                -c "MGRID#AAAAAA" \
                -c "FRAME#202020" \
                -c "ARROW#FFFFFF" \
                -u 1.1 -l 0 -v "Upload" -w 1100 -h 250 -t "Upload Speed - `/bin/date +%A", "%d" "%B" "%Y`" \
                DEF:upload=$RRDGraphsLocation/upload.rrd:upload:AVERAGE \
                AREA:upload\#FFFF00:"Upload speed (Mbit/s)" \
                GPRINT:upload:MIN:"Min\: %3.2lf " \
                GPRINT:upload:MAX:"Max\: %3.2lf" \
                GPRINT:upload:LAST:"Current\: %3.2lf\j" \
                COMMENT:"\\n"

                /usr/bin/rrdtool graph $RRDGraphsLocation/download.png \
                --start "-3day" \
                -c "BACK#000000" \
                -c "SHADEA#000000" \
                -c "SHADEB#000000" \
                -c "FONT#DDDDDD" \
                -c "CANVAS#202020" \
                -c "GRID#666666" \
                -c "MGRID#AAAAAA" \
                -c "FRAME#202020" \
                -c "ARROW#FFFFFF" \
                -u 1.1 -l 0 -v "Download" -w 1100 -h 250 -t "Download Speed - `/bin/date +%A", "%d" "%B" "%Y`" \
                DEF:download=$RRDGraphsLocation/download.rrd:download:AVERAGE \
                AREA:download\#00FF00:"Download speed (Mbit/s)" \
                GPRINT:download:MIN:"Min\: %3.2lf " \
                GPRINT:download:MAX:"Max\: %3.2lf" \
                GPRINT:download:LAST:"Current\: %3.2lf\j" \
                COMMENT:"\\n"

                /usr/bin/rrdtool graph $RRDGraphsLocation/echoreply.png \
                --start "-3day" \
                -c "BACK#000000" \
                -c "SHADEA#000000" \
                -c "SHADEB#000000" \
                -c "FONT#DDDDDD" \
                -c "CANVAS#202020" \
                -c "GRID#666666" \
                -c "MGRID#AAAAAA" \
                -c "FRAME#202020" \
                -c "ARROW#FFFFFF" \
                -u 1.1 -l 0 -v "Ping" -w 1100 -h 250 -t "Ping Response - `/bin/date +%A", "%d" "%B" "%Y`" \
                DEF:echoreply=$RRDGraphsLocation/echoreply.rrd:echoreply:AVERAGE \
                AREA:echoreply\#FF0000:"Ping Response (ms)" \
                GPRINT:echoreply:MIN:"Min\: %3.2lf " \
                GPRINT:echoreply:MAX:"Max\: %3.2lf" \
                GPRINT:echoreply:LAST:"Current\: %3.2lf\j" \
                COMMENT:"\\n"
                ;;

        (*)
                echo "Invalid option.";;
        esac