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
                --title="LATENCY Test" \
                --color CANVAS#000000 \
                --vertical-label "ms" \
                DEF:P=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:AVERAGE \
                DEF:PMIN=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MIN \
                DEF:PMAX=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MAX \
                VDEF:Pavg=P,AVERAGE \
                LINE1:Pavg#cc3300:"Average" \
                LINE2:P#3d61ab:"LATENCY (ms)\n" \
                GPRINT:Pavg:"Average LATENCY %2.1lf ms\n" \
                -h 250 -w 525 -y1:2 \
                --color GRID#dddddd \
                --color MGRID#aaaaaa > /dev/null 2>&1
                ;;

        (*)
                echo "Invalid option.";;
        esac