from tb import top
from pysim.sim import Signal, runsim
from pysim.coroutines import clock_coroutine, uart_coroutine

dut = top(True)
clk = Signal(dut, 'isl__clk')
rxd = Signal(dut, 'isl__data')
clk_co = clock_coroutine(clk, 1, 1, 400)
uart_co = uart_coroutine(rxd, 8, b"Hello!")
coros = [clk_co, uart_co]
runsim(dut, True, coros, 400)
 
