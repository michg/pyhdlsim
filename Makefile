SRC ?= adder
YOSYSINC := $(shell sh -c 'yosys-config --datdir')/include
PYINC := $(shell sh -c 'python3 -m pybind11 --includes')
PYLIB := $(shell sh -c 'python3-config --libs')
SUF := $(shell sh -c 'python3-config --extension-suffix')

.PHONY: all
all: clean result/top.cpp result/io.json result/tb.cpp tb$(SUF)

result/top.cpp: samples/$(SRC)/$(SRC).ys
	mkdir result
	cd samples/$(SRC);yosys -p "script $(SRC).ys; write_cxxrtl -Og ../../result/top.cpp"

result/io.json: result/top.cpp
	python3 parseio.py result/top.cpp $@

result/tb.cpp: result/io.json
	python3 mkwrapper.py result/io.json $@

tb$(SUF): result/tb.cpp
	g++ -shared -fPIC $< $(PYINC) -I$(YOSYSINC) -I. $(PYLIB) -o $@



.PHONY: clean
clean:
	rm -f waves.vcd
	rm -f tb$(SUF)
	rm -f -r result
