pos_clk_tick = 0
neg_clk_tick = 0


def clock_coroutine(clksig, tickslow, tickshigh, cycles):
    global pos_clk_tick
    global neg_clk_tick
    for cycle in range(cycles):
        clksig.val = 0
        neg_clk_tick = 1
        yield
        neg_clk_tick = 0
        for tick in range(tickslow-1):
            yield
        clksig.val = 1
        pos_clk_tick = 1
        yield
        pos_clk_tick = 0
        for tick in range(tickshigh-1):
            yield


def posedge(func):
    def wrapper(*args):
        it = func(*args)
        while True:
            if(pos_clk_tick):
                yield next(it)
            else:
                yield
    return wrapper
            
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

def reset(rst):
    if(rst):
        yield

def ready(rdy):
    if(not rdy):
        yield

def wait_until(sig, cond):
    while sig.val != cond: 
        yield

@posedge
def axis_coroutine(rstsig, datasig, validsig, readysig, lastsig, values):
    yield from wait_until(rstsig, 0)
    lastval = values[-1]
    values = values[:-1]
    for val in values:
        datasig.val = val
        validsig.val = 1
        yield from wait_until(readysig, 1)
        yield
    datasig.val = lastval
    lastsig.val = 1
    validsig.val = 1
    yield from wait_until(readysig, 1)
    yield
    validsig.val = 0
        

