<html>

<body>
    <div class="panel panel-default">
        <div class="panel-body ">
            <img src="plugins/Speedtest/logos/speedtest-logo.png" title="Speedtest Logo" class="device-icon-header pull-left" style="max-height:25px;height:100%;margin-top:8px">
            <div class="pull-left" style="margin-top: 5px;">
                <span style="font-size: 12px;font-weight: bold">Last used Speedtest server:</span><br />
                <span style="font-size: 12px;"><?php require_once("plugins/Speedtest/tmp/speedtest-server");?></span>
            </div>
            <div class="pull-right">
            <img src="plugins/Speedtest/logos/ookla-logo.png" title="Ookla Logo" style="max-height: 50px">
            </div>
        </div>
    </div>

    <div style='clear: both;'>
        <div style='margin: 5px;'>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">Bandwidth</h3>
                </div>
                <div class="panel-body">
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-bandwidth-day.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-bandwidth-day.png" style="border: 0" /></a>
                    </div>
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-bandwidth-week.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-bandwidth-week.png" style="border: 0" /></a>
                    </div>
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-bandwidth-month.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-bandwidth-month.png" style="border: 0" /></a>
                    </div>
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-bandwidth-year.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-bandwidth-year.png" style="border: 0" /></a>
                    </div>
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">Latency during Speedtest</h3>
                </div>
                <div class="panel-body">
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-latency-day.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-latency-day.png" style="border: 0" /></a>
                    </div>
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-latency-week.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-latency-week.png" style="border: 0" /></a>
                    </div>
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-latency-month.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-latency-month.png" style="border: 0" /></a>
                    </div>
                    <div class="col-md-3">
                        <a onmouseover="return overlib('<div class=\'overlib-contents\'><img src=\'plugins/Speedtest/png/speedtest-latency-year.png\' style=\'border:0;\' /></div>',FGCOLOR,'#ffffff', BGCOLOR, '#e5e5e5', BORDER, 5, CELLPAD, 4, CAPCOLOR, '#555555', TEXTCOLOR, '#3e3e3e',WRAP,HAUTO,VAUTO); " onmouseout="return nd();"><img class="lazy img-responsive" data-original="plugins/Speedtest/png/speedtest-latency-year.png" style="border: 0" /></a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <?php

    ?>
</body>

</html>