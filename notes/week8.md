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

## Changing the SSRAM 

The ssram does not produce any clock cycle delay when reading and i can't figure out why it happens. Still working on it for now i suppose it is working normally


## Modifying the Ip core 

What is needed to start reading and writting to a memory address in terms of user commands:

1. A command to set up the address
2. A command to Read the status of the whole system
3. A command to say the Byte enable
4. A command to send data
5. A command to start receiving
6. A command to receive data: need to write in order to read data 
7. Say how many bytes we want to receive or send 

Instruction size : 32 bits of data and few bits of command : for now 4 bits so 36 bits in total

The idea here will be to put everything in a single chain (arbitrarly 0x32) and communicate with it through multiple commands

Change the functionality of the chain1  to handle this : 
For the moment we don't care about the transaction size

### Instructions

| Data section (32 bits) | instruction code (4 bits) | Signification |
| ---------------------- | ------------------------- | ------------- |
| empty | 0000 | Read the status reg of the ipcore |
| address (32 bits) | 0001 | set the address reg to the value in the data section |
| byte_enable (4 bits) | 0010 | set the byte enable reg |
| Size (32 bits) | 0011 | set the size of the transaction in number of words |
| | 0100 ||
| | 0101 ||
| | 0110 ||
| | 0111 ||
| data to send | 1000 | write the data at the address loaded in the address reg |
| empty | 1001 | Read data | 

### The status register

| Is an operation running ? | is size loaded | is byte_enable loaded | is address loaded |

### Writing operation

The operation of writting is done in two phases:

1. Setting up the config registers
2. Actually send the data

The register that needs to be setted up :

- The address where we want to write
- The size of the data we want to write
- The byte enable register

They all can be set up using different instructions. 

Once the the send instruction is received the IPcore enter a fsm for the write :

![Write FSM](image/IPCORE_write.drawio.png)

- IDLE: Default state where the IPCORE wait for the next instruction
- FILL BUFFER: Add the data to the pingpong buffer (if the buffer is full the next state WAIT_FOR_SWITCH or the remaining data size reaches 0, else return to IDLE and wait other write instructions)
- WAIT_FOR_SWITCH: Wait for DMA signal that says that it is ready to switch the buffer
- SWITCH_BUFFER: switch the pinpong buffer
- LAUNCH_WRITE: Launch the transaction to the DMA and reset the operation running bit of the status reg if needed


A simulation of a write looks something like this :

![Write simulation](image/wave_write.png)

### Reading operation

In order to read in a register we need to write. So having a read operation that return the value read.

