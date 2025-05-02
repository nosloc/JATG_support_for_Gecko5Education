# Week 9


## Clock synchronizer 

Since the DMA should use the clock of the system and not the JTAG one we need to synchronize the signal from the IPcore to the DMA.

To do that we use this design :

![Clock synchronizer](image/clock_synchronizer.drawio.png)


Change the ping pong buffer to use a different clock for the DMA and the Ipcore

Chang the JTAG_support design to handle both clock speeds


## Integrate the design in the actual virtual prototype 

Create a new component that has the JTAGG component and the JTAG support component linked together

Connect this component to the rest of the design : 

1. Bus architecture:
    - address_dataOUT : s_jtagAddressData -> or with the other addressData signals
    - byte_enableOUT : s_jtagByteEnable -> or with the other byteEnable signals
    - burst_sizeOUT : s_jtagBurstSize -> or with the other burstSize signals
    - read_n_writeOUT : s_jtagReadNotWrite -> or with the other ReadNotWrite signals
    - begin_transactionOUT : s_jtagBeginTransaction -> or with the other BeginTransaction signals
    - end_transactionOUT : s_jtagEndTransaction -> or with the other EndTransaction signals
    - data_validOUT : s_jtagDataValid -> or with the other DataValid signals
    - busyOUT : s_jtagBusy -> or with the other Busy signals
    - address_dataIN : s_addressData -> bus signal for AddressData
    - end_transactionIN : s_endTransaction -> bus signal for endTransaction
    - data_validIN : s_dataValid -> bus signal for dataValid
    - busyIN : s_busy -> bus signal for busy
    - errorIN : s_busError -> bus signal for error
2. System:
    - system_clock : s_systemClock -> clock for the DMA
3. Bus arbitrer :
   - request : s_jtagRequestBus -> s_busRequests\[27\]
   - busGranted : s_jtagBusAck -> s_busGrants\[27\]