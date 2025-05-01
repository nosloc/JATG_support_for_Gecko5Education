# Week 9


## Clock synchronizer 

Since the DMA should use the clock of the system and not the JTAG one we need to synchronize the signal from the IPcore to the DMA.

To do that we use this design :

![Clock synchronizer](image/clock_synchronizer.drawio.png)


