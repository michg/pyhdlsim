#### Pyhdlsim: using python for stimulation of vhdl and verilog designs

by using pybind11 to link python with the cxxrtl backend of [yosys](https://github.com/YosysHQ/yosys), which can handle
vhdl (with the [ghdl-plugin](https://github.com/ghdl/ghdl-yosys-plugin)) and also verilog code.

Prerequisites: yosys with ghdl-plugin and pybind11

Usage:

		`make SRC=adder`
		`python3 -m sim_adder`
