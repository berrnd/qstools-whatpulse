# qstools-whatpulse
A collection of (PowerShell) scripts around [WhatPulse](https://whatpulse.org/) to keep your statistics private - the scripts transfer them to a (private) [InfluxDB](https://github.com/influxdata/influxdb) database.

> This only works on windows!

## Motivation
WhatPulse is a great tool to capture mainly your keyboard and mouse usage statistics, I use it for many years. Although I don't not trust them, I wanted to have my statistics with me, and only me.
Unfortunately WhatPulse does not have a fully capable local API, but records everything in a SQLite database - these scripts querying this database directly and pushes everything to a InfluxDB database.
Perfect to visualize the result with [Grafana](https://grafana.com/), for example.

## What currently is supported/collected
Not everything WhatPulse collects is currently also handled by these scripts - supported metrics:

- Application usage (per application)
- PC boot times
- Keyboard key presses
- Mouse clicks

## Scripts/files/directories explained
### `data` directory
Contains data about the last sync, a text file per computer with the last sync timestamp as content

### `vendor` directory
Third party dependencies (SQLite and so on)

### `*.sql` files
Predefined SQL queries used by `whatpulse2influxdb.ps1`

### `config-dist.ps1`
The default/example config file, copy it to `data/config.ps1` and edit there to your needs

### `create_scheduled_task.bat`
Creates a scheduled task to execute `whatpulse2influxdb_hidden.vbs` when the computer is idle

### `firewall.bat`
Restricts internet access for WhatPulse completely

### `whatpulse2influxdb.ps1`
The main scripts, this reads the database and pushes the statistics to InfluxDB

### `whatpulse2influxdb_hidden.vbs`
Just a wrapper around `whatpulse2influxdb.ps1` to hide the PowerShell window, this is also used by the scheduled task created by `create_scheduled_task.bat`

## How to install
Just unpack the [latest release](https://github.com/berrnd/qstools-whatpulse/releases/latest), copy `config-dist.ps1` to `data/config.ps1`, edit it to your needs, ensure that the `data` directory is writable and you're ready to go - just start `whatpulse2influxdb.ps1` as explained above.
Alternatively clone this repository.

## Screenshots of the Grafana dashboard
Coming soon...

## License
The MIT License (MIT)
