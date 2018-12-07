# OWFS - MQTT - interface
A small set of bash scripts.
## Publisher
- Scans the local owfs mounted devices and reports all temperature|humidity|sensed.A|sensed.B values.
- If the device code is 28.* and the temperature above 70°C, a conversation to the pressure is applied 
- (026	1-​Wire Barometer/Temperatur/Luftfeuchte, https://www.tm3d.de/shop/kategorien/module)
- At first read out all values are reported, after a configurable delay the next read out will be performed
- Only changed values (rounded to x.y) will be reported.

## Callback
- Subscribes to the mqtt brokers CMD topic and will execute predefined commands
- for example:
- **rescan 1** - Forces full rescan and reporting of all values
- **devices** - publishes a list of all OneWire devices available into *Devices* topic, grouped by device type
- **getdevice <device-id>** - queries a single device and reports all values

## Requirements:
- mosquitto-client (mosquitto_pub & mosquitto_sub)
- Bash 4
- GNUTools like cat, grep, awk
- OWFS installed and OneWire network mounted to local path
- at least one OneWire device to contact
- screen (if you want to use the included start/stop scripts)
- and
- a mosquitto broker to report to
- Optional but recommanded: A tmpfs drive (most linux installation come with at least one active tmpfs mount per default)

