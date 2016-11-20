# Brew

Simple temperature control for fermentation. It's just a simple on/off system around a certain setpoint.

## API

```

Brew.read_temperature :brew

Brew.bulb? :brew
Brew.fridge? :brew

```

## Hardware list

 - Raspberry Pi (every model supported as long as you set NERVES_TARGET)
 - DS18B20 1wire digital temperature sensor
 - 2x SSR-10DA solid state relay
 - 2x LED/diode
 - 4.7K ohm resistor for the sensor
 - 2x 330 ohm resistor for the diodes (check your diode spec)

The diodes are used in series with the SSRs to hopefully prevent them from failing. You'll also need some wires and a breadboard/perfboard ofcourse.

## TODO

 - PID controller?
 - Web display?
