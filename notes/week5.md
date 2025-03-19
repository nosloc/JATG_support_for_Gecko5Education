# Week 5


## Objectives

1. Be able to communicate with the JTAG pins of the board
2. Test the concrete implementation of the FPGA's JTAG interface


## Communicate with the board

Info about the JTAG interface : 

```shell
    $ openfpgaloader --detect
    Jtag frequency : requested 6.00MHz    -> real 6.00MHz   
    index 0:
        idcode 0x41113043
        manufacturer lattice
        family ECP5
        model  LFE5U-85
        irlength 8
```

```shell
    $ openfpga --scan-usb
    empty
    Bus device vid:pid       probe type      manufacturer serial               product
    020 005    0x0403:0x6010 FTDI2232        FTDI         none                 Dual RS232-HS
```

Create config file for openOCD : [openocd docs](https://openocd.org/doc/html/Config-File-Guidelines.html)

The config i have done seems to work correctly

From the OpenOCD user guides the states are : 

- RESET... stable (with TMS high); acts as if TRST were pulsed
- RUN/IDLE... stable; don’t assume this always means IDLE
- DRSELECT
- DRCAPTURE
- DRSHIFT... stable; TDI/TDO shifting through the data register
- DREXIT1
- DRPAUSE... stable; data register ready for update or more shifting
- DREXIT2
- DRUPDATE
- IRSELECT
- IRCAPTURE
- IRSHIFT... stable; TDI/TDO shifting through the instruction register
- IREXIT1
- IRPAUSE... stable; instruction register ready for update or more shifting
- IREXIT2
- IRUPDATE

Note that only six of those states are fully “stable” in the face of TMS fixed (low except
for reset) and a free-running JTAG clock. For all the others, the next TCK transition
changes to a new state.
• From drshift and irshift, clock transitions will produce side effects by changing
register contents. The values to be latched in upcoming drupdate or irupdate states
may not be as expected.
• run/idle, drpause, and irpause are reasonable choices after drscan or irscan com-
mands, since they are free of JTAG side effects.
• run/idle may have side effects that appear at non-JTAG levels, such as advancing
the ARM9E-S instruction pipeline. Consult the documentation for the TAP(s) you are
working with.

