# LibreNMS Speedtest
A Speedtest plugin for LibreNMS, built with RRD and Speedtest CLI by Ookla

## Introduction
This is a plugin that enables internet uplink bandwidth graphing in a LibreNMS dashboard. It uses Ookla servers to perform the speedtest by calling Ookla's Speedtest CLI application. Data is stored in the backend into RRD and is visualized by using a LibreNMS style dashboard.
Installation should be pretty straight forward.<br/><br/>
Screenshot:<br/>
<img src="https://gitlab.com/jackgreyhat/librenms-speedtest/-/raw/master/images/dashboard-screenshot.png" width="800" height="400"/>
<br/>
## Installation
### Prerequisites
- A working LibreNMS installation :D
- Shell access to the LibreNMS server
- Speedtest CLI by Ookla. To install this, use the following link and instructions:
    - https://www.speedtest.net/apps/cli
    - Verify you are running Speedtest CLI by Ookla by issuing the following command on your CLI:<br/>
        > speedtest --version
      Expected output: </br>
        > Speedtest by Ookla ...
      Note: There is also the "speedtest-cli" package, which is possibly provided by your distribution's repository. This package, however, does not follow the same cli commands as the Ookla's Speedtest CLI package and is built with Python. It is known to under perform in some cases. This dashboard will not work out of the box with the "speedtest-cli" package. Prefer to install Ookla's package.



