#!/bin/bash
#############################
# LibreNMS Speedtest plugin #
#############################
# Main plugin dir
SpeedtestPluginDir=/opt/librenms/html/plugins/Speedtest
# Other data dirs
RRDGraphsDir=$SpeedtestPluginDir/rrd
PNGImagesDir=$SpeedtestPluginDir/png
SpeedtestResultDir=$SpeedtestPluginDir/tmp

# Active script code

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
                
                # Init variables
		Latency=""
                DownloadSpeed=""
                UploadSpeed=""
		Server=""
		PreferedTried=false
                # Bell server list
		# Longueuil(Bell Canada), Boucherville(Bell Canada),  Montreal(Bell Mobility), Laval(Bell Canada),  Dartmouth, NS (Bell Mobility) (id: 17393)
		ServerList=("52030" "52028" "16754" "17567" "17393")

                # Get the date of the moment we start the test, in epoch format
                DATE=$(/bin/date +%s)

                # Init the files
		echo "" > $SpeedtestResultDir/speedtest-results
		echo "" > $SpeedtestResultDir/speedtest-server
		

                # Loop until there is a result that is not empty and that we get data for each variables
		while [ ! -n "$Latency" -o ! -n "$DownloadSpeed" -o ! -n "$UploadSpeed" -o ! -n "$Server" ]
		do
                        # Try a specific server first to reduce the variability in the results
			if [ "$PreferedTried" = "false" ]; then
				PreferedTried=true
				speedtest --accept-license --accept-gdpr -p no -s ${ServerList[3]} > $SpeedtestResultDir/speedtest-results 2>/dev/null
			else
				#If prefered not available, use one of three servers from Bell randomly chosen
				speedtest --accept-license --accept-gdpr -p no -s ${ServerList[`expr $(od -N 4 -An -t u4 /dev/urandom) % 3`]} > $SpeedtestResultDir/speedtest-results 2>/dev/null
			fi
			# Get best bandwidth speed
			DownloadSpeed=$(cat $SpeedtestResultDir/speedtest-results | grep Download | sed 's/.*Download:\s*\([0-9]*.[0-9]*\).*/\1/')
			UploadSpeed=$(cat $SpeedtestResultDir/speedtest-results | grep Upload | sed 's/.*Upload:\s*\([0-9]*.[0-9]*\).*/\1/')
			Server=$(cat $SpeedtestResultDir/speedtest-results | grep Server | sed 's/.*Server:\s*\(.*\)/\1/')
                        echo "BANDWIDTH: "$Server " | "> $SpeedtestResultDir/speedtest-server

			#Get best latency using the speedtest defined closest server
			speedtest --accept-license --accept-gdpr -p no > $SpeedtestResultDir/speedtest-results 2>/dev/null
			Latency=$(cat $SpeedtestResultDir/speedtest-results | grep Latency | sed 's/.*Latency:\s*\([0-9]*.[0-9]*\).*/\1/')
			Server=$(cat $SpeedtestResultDir/speedtest-results | grep Server | sed 's/.*Server:\s*\(.*\)/\1/')
			echo "LATENCY: "$Server >> $SpeedtestResultDir/speedtest-server

                        # Prevent throttling from Speedtest
			sleep 1
		done

                # Update the RRD graphs
                rrdtool update $RRDGraphsDir/speedtest-latency.rrd $DATE:$Latency
                rrdtool update $RRDGraphsDir/speedtest-bandwidth.rrd $DATE:$DownloadSpeed:$UploadSpeed
                ;;
        (graph)
                # Create the Latency PNG of the last day
                rrdtool graph $PNGImagesDir/speedtest-latency-day.png -J -a PNG --start "-1day" \
                --title="Last Day" \
                --vertical-label "ms" \
                DEF:P=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:AVERAGE \
                DEF:PMIN=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MIN \
                DEF:PMAX=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MAX \
                VDEF:Pavg=P,AVERAGE \
                LINE1:Pavg#cc3300:"Avg \n" \
                LINE2:P#3d61ab:"Last latency (ms)\n" \
                GPRINT:Pavg:"Avg latency %2.1lf ms\n" \
                -h 500 -w 1000 -y1:2 \
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

                # Create the Latency PNG of the last week
                rrdtool graph $PNGImagesDir/speedtest-latency-week.png -J -a PNG --start "-1week" \
                --title="Last Week" \
                --vertical-label "ms" \
                DEF:P=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:AVERAGE \
                DEF:PMIN=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MIN \
                DEF:PMAX=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MAX \
                VDEF:Pavg=P,AVERAGE \
                LINE1:Pavg#cc3300:"Avg \n" \
                LINE2:P#3d61ab:"Last latency (ms)\n" \
                GPRINT:Pavg:"Avg latency %2.1lf ms\n" \
                -h 500 -w 1000 -y1:2 \
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

                # Create the Latency PNG of the last month
                rrdtool graph $PNGImagesDir/speedtest-latency-month.png -J -a PNG --start "-1month" \
                --title="Last Month" \
                --vertical-label "ms" \
                DEF:P=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:AVERAGE \
                DEF:PMIN=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MIN \
                DEF:PMAX=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MAX \
                VDEF:Pavg=P,AVERAGE \
                LINE1:Pavg#cc3300:"Avg \n" \
                LINE2:P#3d61ab:"Last latency (ms)\n" \
                GPRINT:Pavg:"Avg latency %2.1lf ms\n" \
                -h 500 -w 1000 -y1:2 \
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

                # Create the Latency PNG of the last year
                rrdtool graph $PNGImagesDir/speedtest-latency-year.png -J -a PNG --start "-1year" \
                --title="Last Year" \
                --vertical-label "ms" \
                DEF:P=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:AVERAGE \
                DEF:PMIN=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MIN \
                DEF:PMAX=$RRDGraphsDir/speedtest-latency.rrd:LATENCY:MAX \
                VDEF:Pavg=P,AVERAGE \
                LINE1:Pavg#cc3300:"Avg \n" \
                LINE2:P#3d61ab:"Last latency (ms)\n" \
                GPRINT:Pavg:"Avg latency %2.1lf ms\n" \
                -h 500 -w 1000 -y1:2 \
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

                # Create the Bandwidth PNG of the last day
                rrdtool graph $PNGImagesDir/speedtest-bandwidth-day.png -J -a PNG --start "-1day" \
                --title="Last Day" \
                --vertical-label "Mbit/s" \
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
                -h 500 -w 1000 \
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

                # Create the Bandwidth PNG of the last week
                rrdtool graph $PNGImagesDir/speedtest-bandwidth-week.png -J -a PNG --start "-1week" \
                --title="Last Week" \
                --vertical-label "Mbit/s" \
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
                -h 500 -w 1000 \
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

                # Create the Bandwidth PNG of the last month
                rrdtool graph $PNGImagesDir/speedtest-bandwidth-month.png -J -a PNG --start "-1month" \
                --title="Last Month" \
                --vertical-label "Mbit/s" \
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
                -h 500 -w 1000 \
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

                # Create the Bandwidth PNG of the last year
                rrdtool graph $PNGImagesDir/speedtest-bandwidth-year.png -J -a PNG --start "-1year" \
                --title="Last Year" \
                --vertical-label "Mbit/s" \
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
                -h 500 -w 1000 \
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
                ;;

        (*)
                echo "Invalid option. Nothing to do. Please try again with: create - run - graph"
                ;;
     