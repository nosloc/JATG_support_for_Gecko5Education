yosys -s yosis.script
if  [ $? -eq 0 ]; then 
echo "Synthesis completed sucessfully"
	nextpnr-ecp5 --timing-allow-fail --85k --package CABGA381 --json ./top.json --lpf fpga.lpf --textcfg top.config
	ecppack --compress --freq 62.0 --input top.config --bit top.bit
	openFPGALoader top.bit
else 
	echo "Error in synthesis" 
fi