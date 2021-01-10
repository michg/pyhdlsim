from tb import top
from pysim.sim import Signal, runsim
from pysim.coroutines import clock_coroutine, reset_coroutine

dut = top(True)
clk = Signal(dut, 'clock1')
rst = Signal(dut, 'reset')
clk_co = clock_coroutine(clk, 1, 1, 20)
rst_co = reset_coroutine(rst, 1, 3)
coros = [clk_co, rst_co]
dut.a = 10
dut.b = 20
runsim(dut, True, coros, 10)
 
