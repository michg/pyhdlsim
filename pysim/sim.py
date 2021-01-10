class Signal():
    def __init__(self, dut, name):
        self.dut = dut
        self.name = name
        
    @property
    def val(self):
        return getattr(self.dut, self.name)

    @val.setter
    def val(self, value):
        return setattr(self.dut, self.name, value) 

def runsim(dut, vcd, coros, len):
    for i in range(len):
        for coro in coros:
            try:
                next(coro)
            except StopIteration:
                coros.remove(coro)
        dut.step()
        dut.sample(i)
 

