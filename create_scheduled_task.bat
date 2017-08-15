schtasks /CREATE /SC ONIDLE /I 5 /TN "whatpulse2influxdb" /TR "%~dp0whatpulse2influxdb_hidden.vbs"
