def clock_coroutine(clksig, tickslow, tickshigh, cycles):
    for cycle in range(cycles):
        clksig.val = False
        for tick in range(tickslow):
            yield
        clksig.val = True
        for tick in range(tickshigh):
            yield


def reset_coroutine(rstsig, rstval, tickcnt):
    rstsig.val = rstval
    for tick in range(tickcnt):
        yield
    rstsig.val = not rstval

def send_byte(sig, ticksperbit, val):
    sig.val = 0
    for i in range(ticksperbit):
        yield
    for i in range(8):
        sig.val =  val & 1
        val = val>>1
        for j in range(ticksperbit):
            yield
    sig.val = 1
    for i in range(ticksperbit):
        yield

def uart_coroutine(rxsig, ticksperbit, values):
    for val in values:
        yield from send_byte(rxsig, ticksperbit, val) 


