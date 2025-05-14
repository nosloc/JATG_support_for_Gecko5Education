# Week 10 

Objective : Make the Ipcore working for sure

## Revisit the instructions :

| Data section (32 bits) | instruction code (4 bits) | Signification |
| ---------------------- | ------------------------- | ------------- |
| empty | 0000 | Does nothing just shift out the shift reg value |
| address (32 bits) | 0001 | Write the bus start address |
| byte_enable (4 bits) | 0010 | Write the byte enable reg |
| Size (32 bits) | 0011 | Write the burst_size of the transaction in number of words |
| | 0100 | Put the bus start address in the shift register|
| | 0101 | Put the byte enable reg in the shift register|
| | 0110 | Put the burst_size in the shift register|
| | 0111 | |
| data to send | 1000 | Write the data in the next place ping-pong buffer increassing the block size by one |
| empty | 1001 | Put next word in the ping-pong buffer in the shift buffer decrease block size by one | 
| empty | 1010 | Launch the write operation |
| empty | 1011 | launch the read operation |
| empty | 1111 | reset the registers |

