# Week 8 + holidays 

## Objectives 

Have a working version to read and write to the memory

## Changing the ping pong buffer

1. Change the size of the dual ported ssram 
2. Change from semi-dual to fully dual so that both DMA and IPCORE can read and write to the same buffer
3. Change the implementation of the pingpong buffer to handle this

Still an issue with the delay in the clock cycle in the SSRAM i don't have the good delay 

## Changing the DMA to use the new version of the pingpong buffer

Just change the communication interface with the pingpong buffer
