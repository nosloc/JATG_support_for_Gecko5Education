# Week 5

Objectives : Start working with the FPGA and create a simple IP core to light up some leds  

## How to put something on the board ?

1. Synthesis : ```yosys -s <your_script_name>.script```  
    Where the script looks something like this :  

    ```script
    read -sv test_button_light.v
    synth_ecp5 -top button_led -json test_button_light.json
    ```

2. Place and route : ```nextpnr-ecp5 --timing-allow-fail --85k --package CABGA381 --json ./test_button_light.json --lpf fpga.lpf --textcfg test_button_light.config```  
    Where the lpf file looks like this :  

    ```lpf
    # Buttons

    # LOCATE COMP "buttons[0]" SITE "D19";
    # IOBUF PORT "buttons[0]" PULLMODE=UP IO_TYPE=LVCMOS18;
    # LOCATE COMP "buttons[1]" SITE "D17";
    # IOBUF PORT "buttons[1]" PULLMODE=UP IO_TYPE=LVCMOS18;
    # LOCATE COMP "buttons[2]" SITE "J16";
    # IOBUF PORT "buttons[2]" PULLMODE=UP IO_TYPE=LVCMOS18;

    LOCATE COMP "buttons[0]" SITE "M18";
    IOBUF PORT "buttons[0]" PULLMODE=UP IO_TYPE=LVCMOS18;
    LOCATE COMP "buttons[1]" SITE "M17";
    IOBUF PORT "buttons[1]" PULLMODE=UP IO_TYPE=LVCMOS18;
    LOCATE COMP "buttons[2]" SITE "L18";
    IOBUF PORT "buttons[2]" PULLMODE=UP IO_TYPE=LVCMOS18;

    # LED
    LOCATE COMP "led[0]" SITE "A7";
    IOBUF PORT "led[0]" IO_TYPE=LVCMOS18;
    LOCATE COMP "led[1]" SITE "C7";
    IOBUF PORT "led[1]" IO_TYPE=LVCMOS18;
    LOCATE COMP "led[2]" SITE "E6";
    IOBUF PORT "led[2]" IO_TYPE=LVCMOS18;

    LOCATE COMP "RGB_Column[0]" SITE "B6";
    IOBUF PORT "RGB_Column[0]" IO_TYPE=LVCMOS18;
    LOCATE COMP "RGB_Column[1]" SITE "J3";
    IOBUF PORT "RGB_Column[1]" IO_TYPE=LVCMOS18;
    LOCATE COMP "RGB_Column[2]" SITE "K3";
    IOBUF PORT "RGB_Column[2]" IO_TYPE=LVCMOS18;
    LOCATE COMP "RGB_Column[3]" SITE "B17";
    ```

3. Create the bit file : ```ecppack --compress --freq 62.0 --input test_button_light.config --bit test_button_light.bit```  
4. Load the bit file to the FPGA : ```openFPGALoader test_button_light.bit```  

As an example I create a very simple design that uses the swithes and the button to light a specific LED



## Notes 

To keep the LEDS in a consistent state I can simply iterate through all columns fast enough so that it does not blink for human eyes
