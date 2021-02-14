
class Signal():
    def __init__(self, dut, name):
        self.dut = dut
        self.name = name
        self._val = None
        
    @property
    def val(self):
        if self._val is not None:
            return self._val
        else:
            return getattr(self.dut, self.name)
        

    @val.setter
    def val(self, value):
        self._val = value
        return setattr(self.dut, self.name, value) 

def runsim(dut, vcd, coros, len):
    for i in range(len):
        for coro in coros:
            try:
                next(coro)
            except:
                coros.remove(coro)
        dut.step()
        dut.sample(i)
 

