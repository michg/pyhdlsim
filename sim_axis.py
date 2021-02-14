from tb import top
from pysim.sim import Signal, runsim
from pysim.coroutines import clock_coroutine, reset_coroutine, axis_coroutine

dut = top(True)
clk = Signal(dut, 'CLK')
rst = Signal(dut, 'RST')
dat_i = Signal(dut, 'axi__in__tdata')
val_i = Signal(dut, 'axi__in__tvalid')
rdy_i = Signal(dut, 'axi__in__tready')
lst_i = Signal(dut, 'axi__in__tlast')
rdy_o = Signal(dut, 'axi__out__tready')

clk_co = clock_coroutine(clk, 1, 1, 400)
rst_co = reset_coroutine(rst, 1, 2)
axis_co = axis_coroutine(rst, dat_i, val_i, rdy_i, lst_i, [1,2,3,4,5,6])
coros = [clk_co, rst_co, axis_co]
rdy_o.val = 1
runsim(dut, True, coros, 400)

