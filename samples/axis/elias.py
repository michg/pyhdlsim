from __future__ import absolute_import
from __future__ import print_function
import sys
import os
import math

# the next line can be removed after installation
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))))

from veriloggen import *
import veriloggen.thread as vthread
import veriloggen.types.axi as axi


def mkElias(iw=32, ow=8):
    maxlen = 2*int(math.log(iw, 2))
    fifodep = 10
    m = Module('Elias')
    m.Localparam('IW', iw)
    m.Localparam('MAXLEN', maxlen) 
    
   
    clk = m.Input('CLK')
    rst = m.Input('RST')
    din = m.Reg('din',iw)
    bitlen = m.Reg('bitlen',maxlen)
    dout = m.Reg('dout',iw)
    
    curval = m.Reg('curval',2*iw)
    curlen = m.Reg('curlen',maxlen)
    nextval = m.Reg('nextval',2*iw)
    nextlen = m.Reg('nextlen',maxlen)
    
    m.EmbeddedCode("""
    integer i;
    reg [MAXLEN-1:0] cnt;
    reg [IW-1:0] data;
    always @* begin
		for (i = 0; i < IW; i = i+1)
			data[i] = din[(IW-i-1)];
		data = (data-1) & ~data;
        cnt = 0;
		for (i = 0; i < IW; i = i+1)
			cnt = cnt + data[i];
        bitlen = IW - cnt;
        dout = din;
        bitlen = bitlen + bitlen - 1;
        
	end
    """) 
    

   
    
    axi_in = vthread.AXIStreamInFifo(m, 'axi_in', clk, rst, iw,
                                     with_last=True)

    axi_out = vthread.AXIStreamOutFifo(m, 'axi_out', clk, rst, ow,
                                       with_last=True)
 
    fifo_addrwidth = 8
    fifo_in = vthread.FIFO(m, 'fifo_in', clk, rst, iw, fifodep)
    fifo_out = vthread.FIFO(m, 'fifo_out', clk, rst, ow, fifodep)
    fifo_val = vthread.FIFO(m, 'fifo_val', clk, rst, 2*iw, fifodep)
    fifo_len = vthread.FIFO(m, 'fifo_len', clk, rst, maxlen, fifodep )


    def recv():
        while 1:
           data, last = axi_in.read()
           fifo_in.enq(data)
        
    
    def clen():
        while 1:
            din.value = fifo_in.deq()
            vthread.set_parallel()
            fifo_val.enq(dout)
            fifo_len.enq(bitlen)
            vthread.unset_parallel()
    
    def comb():
        curlen.value = fifo_len.deq()
        curval.value = fifo_val.deq() << (2*iw - curlen)
        while 1:
            while curlen < ow:
                nextval.value = fifo_val.deq()
                nextlen.value = fifo_len.deq()
                curval.value = curval + (nextval<<(2*iw - curlen - nextlen))
                curlen.value = curlen + nextlen
            fifo_out.enq(curval[2*iw-ow:2*iw])
            curval.value = curval << ow
            curlen.value = curlen - ow

    
    def send():
        while 1:
           data = fifo_out.deq()
           axi_out.write(data)
           
    th_recv = vthread.Thread(m, 'recv', clk, rst, recv)
    th_clen = vthread.Thread(m, 'clen', clk, rst, clen)
    th_comb = vthread.Thread(m, 'comb', clk, rst, comb)
    th_send = vthread.Thread(m, 'send', clk, rst, send)
    fsm = th_recv.start()
    fsm = th_clen.start()
    fsm = th_comb.start()
    fsm = th_send.start()
    return m




def run(filename='tmp.v', simtype='iverilog', outputfile=None):
    test = mkElias()
    code = test.to_verilog(filename)
    return code


if __name__ == '__main__':
    rslt = run(filename='tmp.v')
    print(rslt)  