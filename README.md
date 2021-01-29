# LibreNMS Speedtest
A Speedtest plugin for LibreNMS, built with RRD and Speedtest CLI by Ookla

## Introduction
This is a plugin that enables internet uplink bandwidth graphing in a LibreNMS dashboard. It uses Ookla servers to perform the speedtest by calling Ookla's Speedtest CLI application. Data is stored in the backend into RRD and is visualized by using a LibreNMS style dashboard.
Installation should be pretty straight forward.<br/><br/>
<img src="https://gitlab.com/jackgreyhat/librenms-speedtest/-/raw/master/images/dashboard-screenshot.png" width="50%" height="50%"/>

## Prerequisites
- A working LibreNMS installation. :D
- Shell access to the LibreNMS server.
- Speedtest CLI by Ookla. To install this, use the following link and instructions:
    - https://www.speedtest.net/apps/cli
    - Verify you are running Speedtest CLI by Ookla by issuing the following command on your CLI:<br> 
      `speedtest --version`<br/>
      Expected example output:<br/>
      `Speedtest by Ookla 1.0.0.2`
      <br/>
```
There is also the "speedtest-cli" package, which is possibly provided by your distribution's repository. 
This package, however, does not follow the same cli commands as the Ookla's Speedtest CLI package and is 
built with Python. It is known to under perform in some cases.
This dashboard will not work out of the box with the "speedtest-cli" package. Prefer to install Ookla's package.
```

## Installation
```
These instructions assume you are the root user. If you are not, prepend sudo 
to the shell commands or temporarily become a user with root privileges.
```
After logging in to your LibreNMS server CLI:
- Go to your home dir:<br/>
`cd ~/`
- Clone this repository into your home dir:<br/>
`git clone https://gitlab.com/jackgreyhat/librenms-speedtest.git`
- Create the plugin directory into LibreNMS plugin folder:<br/>
`mkdir /opt/librenms/html/plugins/Speedtest`
- Copy the LibreNMS speedtest plugin contents into the newly created directory:<br/>
`cp -r ~/librenms-speedtest/. /opt/librenms/html/plugins/Speedtest`
- Ensure correct ownership and permissions on the Speedtest plugin directory and files:<br/>
`chown -R librenms:librenms /opt/librenms/html/plugins/Speedtest`<br/>
`chmod -R --reference=/opt/librenms/html/plugins /opt/librenms/html/plugins/Speedtest`<br/>
`chmod +x /opt/librenms/html/plugins/Speedtest/librenms-speedtest.sh`<br/>
- Create a cron job to run the speedtest periodically. Edit the following file:<br/>
`vi /etc/cron.d/librenms`<br/>
and add:<br/>
`30   *    * * *   librenms    /opt/librenms/html/plugins/Speedtest/librenms-speedtest.sh run && /opt/librenms/html/plugins/Speedtest/librenms-speedtest.sh graph`
- Switch to the librenms user:<br/>
`su - librenms`
- Accept the speedtest EULA and GDPR notice (if applicable) and run an initial speedtest:<br/>
`speedtest --accept-license --accept-gdpr`
- Go to the Speedtest plugins directory:<br/>
`cd /opt/librenms/html/plugins/Speedtest/`
- Create the RRD files:<br/>
`./librenms-speedtest.sh create`
- Test and run the speedtest script:<br/>
`./librenms-speedtest.sh run`
- Output the speedtest results into PNG files:<br/>
`./librenms-speedtest.sh graph`
- Go to your LibreNMS web interface, and go to "Overview" -> "Plugins" -> "Plugin Admin"
- Enable the "Speedtest" plugin.
- Find the "Speedtest" plugin under "Overview" -> "Plugins" -> "Speedtest"
- Wait at least one hour (2 speedtest runs, one every 30 mins), for data to be properly populated in your graphs.
- Profit.

## FAQs
Most of the below FAQs are related to how the speedtest command can be adjusted. All of these commands or adjustments must be made to the speedtest command on line 37 in the librenms-speedtest.sh script. In the future, I will make it easier to adjust settings.
- How can I select a speedtest server manually?<br/>
Use `speedtest -L` to find the nearest speedtest servers, note the first column, this is the speedtest server id.<br/>
Adjust the speedtest command on line 37 to include the server id with the `-s` parameter, so it looks like this:<br/>
`speedtest --accept-license --accept-gdpr -p no -s 1234 > $SpeedtestResultDir/speedtest-results 2>/dev/null`

## Roadmap
- Include more metrics, such as:
    - Jitter during tests
    - Transfered data during test
    - Packet loss during test
- Add other speedtest providers, such as:
    - Cloudflare
    - Fast.com
    - ...
