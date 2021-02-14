

module Elias
(
  input CLK,
  input RST,
  input [32-1:0] axi_in_tdata,
  input axi_in_tvalid,
  output axi_in_tready,
  input axi_in_tlast,
  output reg [8-1:0] axi_out_tdata,
  output reg axi_out_tvalid,
  input axi_out_tready,
  output reg axi_out_tlast
);

  localparam IW = 32;
  localparam MAXLEN = 10;
  reg [32-1:0] din;
  reg [10-1:0] bitlen;
  reg [32-1:0] dout;
  reg [64-1:0] curval;
  reg [10-1:0] curlen;
  reg [64-1:0] nextval;
  reg [10-1:0] nextlen;

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
    
  reg _axi_in_read_start;
  reg [8-1:0] _axi_in_read_op_sel;
  reg [32-1:0] _axi_in_read_local_addr;
  reg [33-1:0] _axi_in_read_size;
  reg [32-1:0] _axi_in_read_local_stride;
  reg _axi_in_read_idle;
  reg _axi_out_write_start;
  reg [8-1:0] _axi_out_write_op_sel;
  reg [32-1:0] _axi_out_write_local_addr;
  reg [33-1:0] _axi_out_write_size;
  reg [32-1:0] _axi_out_write_local_stride;
  reg _axi_out_write_idle;
  wire fifo_in_enq;
  wire [32-1:0] fifo_in_wdata;
  wire fifo_in_full;
  wire fifo_in_almost_full;
  wire fifo_in_deq;
  wire [32-1:0] fifo_in_rdata;
  wire fifo_in_empty;
  wire fifo_in_almost_empty;

  fifo_in
  inst_fifo_in
  (
    .CLK(CLK),
    .RST(RST),
    .fifo_in_enq(fifo_in_enq),
    .fifo_in_wdata(fifo_in_wdata),
    .fifo_in_full(fifo_in_full),
    .fifo_in_almost_full(fifo_in_almost_full),
    .fifo_in_deq(fifo_in_deq),
    .fifo_in_rdata(fifo_in_rdata),
    .fifo_in_empty(fifo_in_empty),
    .fifo_in_almost_empty(fifo_in_almost_empty)
  );

  reg [11-1:0] count_fifo_in;
  wire fifo_out_enq;
  wire [8-1:0] fifo_out_wdata;
  wire fifo_out_full;
  wire fifo_out_almost_full;
  wire fifo_out_deq;
  wire [8-1:0] fifo_out_rdata;
  wire fifo_out_empty;
  wire fifo_out_almost_empty;

  fifo_out
  inst_fifo_out
  (
    .CLK(CLK),
    .RST(RST),
    .fifo_out_enq(fifo_out_enq),
    .fifo_out_wdata(fifo_out_wdata),
    .fifo_out_full(fifo_out_full),
    .fifo_out_almost_full(fifo_out_almost_full),
    .fifo_out_deq(fifo_out_deq),
    .fifo_out_rdata(fifo_out_rdata),
    .fifo_out_empty(fifo_out_empty),
    .fifo_out_almost_empty(fifo_out_almost_empty)
  );

  reg [11-1:0] count_fifo_out;
  wire fifo_val_enq;
  wire [64-1:0] fifo_val_wdata;
  wire fifo_val_full;
  wire fifo_val_almost_full;
  wire fifo_val_deq;
  wire [64-1:0] fifo_val_rdata;
  wire fifo_val_empty;
  wire fifo_val_almost_empty;

  fifo_val
  inst_fifo_val
  (
    .CLK(CLK),
    .RST(RST),
    .fifo_val_enq(fifo_val_enq),
    .fifo_val_wdata(fifo_val_wdata),
    .fifo_val_full(fifo_val_full),
    .fifo_val_almost_full(fifo_val_almost_full),
    .fifo_val_deq(fifo_val_deq),
    .fifo_val_rdata(fifo_val_rdata),
    .fifo_val_empty(fifo_val_empty),
    .fifo_val_almost_empty(fifo_val_almost_empty)
  );

  reg [11-1:0] count_fifo_val;
  wire fifo_len_enq;
  wire [10-1:0] fifo_len_wdata;
  wire fifo_len_full;
  wire fifo_len_almost_full;
  wire fifo_len_deq;
  wire [10-1:0] fifo_len_rdata;
  wire fifo_len_empty;
  wire fifo_len_almost_empty;

  fifo_len
  inst_fifo_len
  (
    .CLK(CLK),
    .RST(RST),
    .fifo_len_enq(fifo_len_enq),
    .fifo_len_wdata(fifo_len_wdata),
    .fifo_len_full(fifo_len_full),
    .fifo_len_almost_full(fifo_len_almost_full),
    .fifo_len_deq(fifo_len_deq),
    .fifo_len_rdata(fifo_len_rdata),
    .fifo_len_empty(fifo_len_empty),
    .fifo_len_almost_empty(fifo_len_almost_empty)
  );

  reg [11-1:0] count_fifo_len;
  reg [32-1:0] recv;
  localparam recv_init = 0;
  assign axi_in_tready = recv == 2;
  reg signed [32-1:0] axistreamin_rdata_0;
  reg [1-1:0] axistreamin_rlast_1;
  reg signed [32-1:0] _recv_data_0;
  reg signed [32-1:0] _recv_last_1;
  assign fifo_in_wdata = (recv == 4)? _recv_data_0 : 'hx;
  assign fifo_in_enq = (recv == 4)? (recv == 4) && !fifo_in_almost_full : 0;
  localparam _tmp_2 = 1;
  wire [_tmp_2-1:0] _tmp_3;
  assign _tmp_3 = !fifo_in_almost_full;
  reg [_tmp_2-1:0] __tmp_3_1;
  reg [32-1:0] clen;
  localparam clen_init = 0;
  assign fifo_in_deq = ((clen == 2) && !fifo_in_empty)? 1 : 0;
  localparam _tmp_4 = 1;
  wire [_tmp_4-1:0] _tmp_5;
  assign _tmp_5 = (clen == 2) && !fifo_in_empty;
  reg [_tmp_4-1:0] __tmp_5_1;
  reg signed [32-1:0] _tmp_6;
  assign fifo_val_wdata = (clen == 5)? dout : 'hx;
  assign fifo_val_enq = (clen == 5)? (clen == 5) && !fifo_val_almost_full : 0;
  localparam _tmp_7 = 1;
  wire [_tmp_7-1:0] _tmp_8;
  assign _tmp_8 = !fifo_val_almost_full;
  reg [_tmp_7-1:0] __tmp_8_1;
  assign fifo_len_wdata = (clen == 6)? bitlen : 'hx;
  assign fifo_len_enq = (clen == 6)? (clen == 6) && !fifo_len_almost_full : 0;
  localparam _tmp_9 = 1;
  wire [_tmp_9-1:0] _tmp_10;
  assign _tmp_10 = !fifo_len_almost_full;
  reg [_tmp_9-1:0] __tmp_10_1;
  reg [32-1:0] comb;
  localparam comb_init = 0;
  localparam _tmp_11 = 1;
  wire [_tmp_11-1:0] _tmp_12;
  assign _tmp_12 = (comb == 1) && !fifo_len_empty;
  reg [_tmp_11-1:0] __tmp_12_1;
  reg signed [10-1:0] _tmp_13;
  localparam _tmp_14 = 1;
  wire [_tmp_14-1:0] _tmp_15;
  assign _tmp_15 = (comb == 4) && !fifo_val_empty;
  reg [_tmp_14-1:0] __tmp_15_1;
  reg signed [64-1:0] _tmp_16;
  assign fifo_val_deq = ((comb == 9) && !fifo_val_empty)? 1 : 
                        ((comb == 4) && !fifo_val_empty)? 1 : 0;
  localparam _tmp_17 = 1;
  wire [_tmp_17-1:0] _tmp_18;
  assign _tmp_18 = (comb == 9) && !fifo_val_empty;
  reg [_tmp_17-1:0] __tmp_18_1;
  reg signed [64-1:0] _tmp_19;
  assign fifo_len_deq = ((comb == 12) && !fifo_len_empty)? 1 : 
                        ((comb == 1) && !fifo_len_empty)? 1 : 0;
  localparam _tmp_20 = 1;
  wire [_tmp_20-1:0] _tmp_21;
  assign _tmp_21 = (comb == 12) && !fifo_len_empty;
  reg [_tmp_20-1:0] __tmp_21_1;
  reg signed [10-1:0] _tmp_22;
  assign fifo_out_wdata = (comb == 18)? curval[63:56] : 'hx;
  assign fifo_out_enq = (comb == 18)? (comb == 18) && !fifo_out_almost_full : 0;
  localparam _tmp_23 = 1;
  wire [_tmp_23-1:0] _tmp_24;
  assign _tmp_24 = !fifo_out_almost_full;
  reg [_tmp_23-1:0] __tmp_24_1;
  reg [32-1:0] send;
  localparam send_init = 0;
  assign fifo_out_deq = ((send == 2) && !fifo_out_empty)? 1 : 0;
  localparam _tmp_25 = 1;
  wire [_tmp_25-1:0] _tmp_26;
  assign _tmp_26 = (send == 2) && !fifo_out_empty;
  reg [_tmp_25-1:0] __tmp_26_1;
  reg signed [8-1:0] _tmp_27;
  reg signed [32-1:0] _send_data_2;
  reg _axi_out_cond_0_1;

  always @(posedge CLK) begin
    if(RST) begin
      _axi_in_read_start <= 0;
    end else begin
      _axi_in_read_start <= 0;
    end
  end


  always @(posedge CLK) begin
    if(RST) begin
      _axi_out_write_start <= 0;
      axi_out_tdata <= 0;
      axi_out_tvalid <= 0;
      axi_out_tlast <= 0;
      _axi_out_cond_0_1 <= 0;
    end else begin
      if(_axi_out_cond_0_1) begin
        axi_out_tvalid <= 0;
        axi_out_tlast <= 0;
      end 
      _axi_out_write_start <= 0;
      if((send == 5) && (axi_out_tready || !axi_out_tvalid)) begin
        axi_out_tdata <= _send_data_2;
        axi_out_tvalid <= 1;
        axi_out_tlast <= 0;
      end 
      _axi_out_cond_0_1 <= 1;
      if(axi_out_tvalid && !axi_out_tready) begin
        axi_out_tvalid <= axi_out_tvalid;
        axi_out_tlast <= axi_out_tlast;
      end 
    end
  end


  always @(posedge CLK) begin
    if(RST) begin
      count_fifo_in <= 0;
      __tmp_3_1 <= 0;
      __tmp_5_1 <= 0;
    end else begin
      if(fifo_in_enq && !fifo_in_full && (fifo_in_deq && !fifo_in_empty)) begin
        count_fifo_in <= count_fifo_in;
      end else if(fifo_in_enq && !fifo_in_full) begin
        count_fifo_in <= count_fifo_in + 1;
      end else if(fifo_in_deq && !fifo_in_empty) begin
        count_fifo_in <= count_fifo_in - 1;
      end 
      __tmp_3_1 <= _tmp_3;
      __tmp_5_1 <= _tmp_5;
    end
  end


  always @(posedge CLK) begin
    if(RST) begin
      count_fifo_out <= 0;
      __tmp_24_1 <= 0;
      __tmp_26_1 <= 0;
    end else begin
      if(fifo_out_enq && !fifo_out_full && (fifo_out_deq && !fifo_out_empty)) begin
        count_fifo_out <= count_fifo_out;
      end else if(fifo_out_enq && !fifo_out_full) begin
        count_fifo_out <= count_fifo_out + 1;
      end else if(fifo_out_deq && !fifo_out_empty) begin
        count_fifo_out <= count_fifo_out - 1;
      end 
      __tmp_24_1 <= _tmp_24;
      __tmp_26_1 <= _tmp_26;
    end
  end


  always @(posedge CLK) begin
    if(RST) begin
      count_fifo_val <= 0;
      __tmp_8_1 <= 0;
      __tmp_15_1 <= 0;
      __tmp_18_1 <= 0;
    end else begin
      if(fifo_val_enq && !fifo_val_full && (fifo_val_deq && !fifo_val_empty)) begin
        count_fifo_val <= count_fifo_val;
      end else if(fifo_val_enq && !fifo_val_full) begin
        count_fifo_val <= count_fifo_val + 1;
      end else if(fifo_val_deq && !fifo_val_empty) begin
        count_fifo_val <= count_fifo_val - 1;
      end 
      __tmp_8_1 <= _tmp_8;
      __tmp_15_1 <= _tmp_15;
      __tmp_18_1 <= _tmp_18;
    end
  end


  always @(posedge CLK) begin
    if(RST) begin
      count_fifo_len <= 0;
      __tmp_10_1 <= 0;
      __tmp_12_1 <= 0;
      __tmp_21_1 <= 0;
    end else begin
      if(fifo_len_enq && !fifo_len_full && (fifo_len_deq && !fifo_len_empty)) begin
        count_fifo_len <= count_fifo_len;
      end else if(fifo_len_enq && !fifo_len_full) begin
        count_fifo_len <= count_fifo_len + 1;
      end else if(fifo_len_deq && !fifo_len_empty) begin
        count_fifo_len <= count_fifo_len - 1;
      end 
      __tmp_10_1 <= _tmp_10;
      __tmp_12_1 <= _tmp_12;
      __tmp_21_1 <= _tmp_21;
    end
  end

  localparam recv_1 = 1;
  localparam recv_2 = 2;
  localparam recv_3 = 3;
  localparam recv_4 = 4;
  localparam recv_5 = 5;
  localparam recv_6 = 6;

  always @(posedge CLK) begin
    if(RST) begin
      recv <= recv_init;
      axistreamin_rdata_0 <= 0;
      axistreamin_rlast_1 <= 0;
      _recv_data_0 <= 0;
      _recv_last_1 <= 0;
    end else begin
      case(recv)
        recv_init: begin
          recv <= recv_1;
        end
        recv_1: begin
          if(1) begin
            recv <= recv_2;
          end else begin
            recv <= recv_6;
          end
        end
        recv_2: begin
          if(axi_in_tready && axi_in_tvalid) begin
            axistreamin_rdata_0 <= axi_in_tdata;
            axistreamin_rlast_1 <= axi_in_tlast;
          end 
          if(axi_in_tready && axi_in_tvalid) begin
            recv <= recv_3;
          end 
        end
        recv_3: begin
          _recv_data_0 <= axistreamin_rdata_0;
          _recv_last_1 <= axistreamin_rlast_1;
          recv <= recv_4;
        end
        recv_4: begin
          if(!fifo_in_almost_full) begin
            recv <= recv_5;
          end 
        end
        recv_5: begin
          recv <= recv_1;
        end
      endcase
    end
  end

  localparam clen_1 = 1;
  localparam clen_2 = 2;
  localparam clen_3 = 3;
  localparam clen_4 = 4;
  localparam clen_5 = 5;
  localparam clen_6 = 6;
  localparam clen_7 = 7;
  localparam clen_8 = 8;
  localparam clen_9 = 9;

  always @(posedge CLK) begin
    if(RST) begin
      clen <= clen_init;
      _tmp_6 <= 0;
    end else begin
      case(clen)
        clen_init: begin
          clen <= clen_1;
        end
        clen_1: begin
          if(1) begin
            clen <= clen_2;
          end else begin
            clen <= clen_9;
          end
        end
        clen_2: begin
          if(!fifo_in_empty) begin
            clen <= clen_3;
          end 
        end
        clen_3: begin
          if(__tmp_5_1) begin
            _tmp_6 <= fifo_in_rdata;
          end 
          if(__tmp_5_1) begin
            clen <= clen_4;
          end 
        end
        clen_4: begin
          din <= _tmp_6;
          clen <= clen_5;
        end
        clen_5: begin
          if(!fifo_val_almost_full) begin
            clen <= clen_6;
          end 
        end
        clen_6: begin
          if(!fifo_len_almost_full) begin
            clen <= clen_7;
          end 
        end
        clen_7: begin
          clen <= clen_8;
        end
        clen_8: begin
          clen <= clen_1;
        end
      endcase
    end
  end

  localparam comb_1 = 1;
  localparam comb_2 = 2;
  localparam comb_3 = 3;
  localparam comb_4 = 4;
  localparam comb_5 = 5;
  localparam comb_6 = 6;
  localparam comb_7 = 7;
  localparam comb_8 = 8;
  localparam comb_9 = 9;
  localparam comb_10 = 10;
  localparam comb_11 = 11;
  localparam comb_12 = 12;
  localparam comb_13 = 13;
  localparam comb_14 = 14;
  localparam comb_15 = 15;
  localparam comb_16 = 16;
  localparam comb_17 = 17;
  localparam comb_18 = 18;
  localparam comb_19 = 19;
  localparam comb_20 = 20;
  localparam comb_21 = 21;
  localparam comb_22 = 22;

  always @(posedge CLK) begin
    if(RST) begin
      comb <= comb_init;
      _tmp_13 <= 0;
      _tmp_16 <= 0;
      _tmp_19 <= 0;
      _tmp_22 <= 0;
    end else begin
      case(comb)
        comb_init: begin
          comb <= comb_1;
        end
        comb_1: begin
          if(!fifo_len_empty) begin
            comb <= comb_2;
          end 
        end
        comb_2: begin
          if(__tmp_12_1) begin
            _tmp_13 <= fifo_len_rdata;
          end 
          if(__tmp_12_1) begin
            comb <= comb_3;
          end 
        end
        comb_3: begin
          curlen <= _tmp_13;
          comb <= comb_4;
        end
        comb_4: begin
          if(!fifo_val_empty) begin
            comb <= comb_5;
          end 
        end
        comb_5: begin
          if(__tmp_15_1) begin
            _tmp_16 <= fifo_val_rdata;
          end 
          if(__tmp_15_1) begin
            comb <= comb_6;
          end 
        end
        comb_6: begin
          curval <= _tmp_16 << 64 - curlen;
          comb <= comb_7;
        end
        comb_7: begin
          if(1) begin
            comb <= comb_8;
          end else begin
            comb <= comb_22;
          end
        end
        comb_8: begin
          if(curlen < 8) begin
            comb <= comb_9;
          end else begin
            comb <= comb_18;
          end
        end
        comb_9: begin
          if(!fifo_val_empty) begin
            comb <= comb_10;
          end 
        end
        comb_10: begin
          if(__tmp_18_1) begin
            _tmp_19 <= fifo_val_rdata;
          end 
          if(__tmp_18_1) begin
            comb <= comb_11;
          end 
        end
        comb_11: begin
          nextval <= _tmp_19;
          comb <= comb_12;
        end
        comb_12: begin
          if(!fifo_len_empty) begin
            comb <= comb_13;
          end 
        end
        comb_13: begin
          if(__tmp_21_1) begin
            _tmp_22 <= fifo_len_rdata;
          end 
          if(__tmp_21_1) begin
            comb <= comb_14;
          end 
        end
        comb_14: begin
          nextlen <= _tmp_22;
          comb <= comb_15;
        end
        comb_15: begin
          curval <= curval + (nextval << 64 - curlen - nextlen);
          comb <= comb_16;
        end
        comb_16: begin
          curlen <= curlen + nextlen;
          comb <= comb_17;
        end
        comb_17: begin
          comb <= comb_8;
        end
        comb_18: begin
          if(!fifo_out_almost_full) begin
            comb <= comb_19;
          end 
        end
        comb_19: begin
          curval <= curval << 8;
          comb <= comb_20;
        end
        comb_20: begin
          curlen <= curlen - 8;
          comb <= comb_21;
        end
        comb_21: begin
          comb <= comb_7;
        end
      endcase
    end
  end

  localparam send_1 = 1;
  localparam send_2 = 2;
  localparam send_3 = 3;
  localparam send_4 = 4;
  localparam send_5 = 5;
  localparam send_6 = 6;
  localparam send_7 = 7;

  always @(posedge CLK) begin
    if(RST) begin
      send <= send_init;
      _tmp_27 <= 0;
      _send_data_2 <= 0;
    end else begin
      case(send)
        send_init: begin
          send <= send_1;
        end
        send_1: begin
          if(1) begin
            send <= send_2;
          end else begin
            send <= send_7;
          end
        end
        send_2: begin
          if(!fifo_out_empty) begin
            send <= send_3;
          end 
        end
        send_3: begin
          if(__tmp_26_1) begin
            _tmp_27 <= fifo_out_rdata;
          end 
          if(__tmp_26_1) begin
            send <= send_4;
          end 
        end
        send_4: begin
          _send_data_2 <= _tmp_27;
          send <= send_5;
        end
        send_5: begin
          if(axi_out_tready || !axi_out_tvalid) begin
            send <= send_6;
          end 
        end
        send_6: begin
          send <= send_1;
        end
      endcase
    end
  end


endmodule



module fifo_in
(
  input CLK,
  input RST,
  input fifo_in_enq,
  input [32-1:0] fifo_in_wdata,
  output fifo_in_full,
  output fifo_in_almost_full,
  input fifo_in_deq,
  output [32-1:0] fifo_in_rdata,
  output fifo_in_empty,
  output fifo_in_almost_empty
);

  reg [32-1:0] mem [0:1024-1];
  reg [10-1:0] head;
  reg [10-1:0] tail;
  wire is_empty;
  wire is_almost_empty;
  wire is_full;
  wire is_almost_full;
  assign is_empty = head == tail;
  assign is_almost_empty = head == (tail + 1 & 1023);
  assign is_full = (head + 1 & 1023) == tail;
  assign is_almost_full = (head + 2 & 1023) == tail;
  reg [32-1:0] rdata_reg;
  assign fifo_in_full = is_full;
  assign fifo_in_almost_full = is_almost_full || is_full;
  assign fifo_in_empty = is_empty;
  assign fifo_in_almost_empty = is_almost_empty || is_empty;
  assign fifo_in_rdata = rdata_reg;

  always @(posedge CLK) begin
    if(RST) begin
      head <= 0;
      rdata_reg <= 0;
      tail <= 0;
    end else begin
      if(fifo_in_enq && !is_full) begin
        mem[head] <= fifo_in_wdata;
        head <= head + 1;
      end 
      if(fifo_in_deq && !is_empty) begin
        rdata_reg <= mem[tail];
        tail <= tail + 1;
      end 
    end
  end


endmodule



module fifo_out
(
  input CLK,
  input RST,
  input fifo_out_enq,
  input [8-1:0] fifo_out_wdata,
  output fifo_out_full,
  output fifo_out_almost_full,
  input fifo_out_deq,
  output [8-1:0] fifo_out_rdata,
  output fifo_out_empty,
  output fifo_out_almost_empty
);

  reg [8-1:0] mem [0:1024-1];
  reg [10-1:0] head;
  reg [10-1:0] tail;
  wire is_empty;
  wire is_almost_empty;
  wire is_full;
  wire is_almost_full;
  assign is_empty = head == tail;
  assign is_almost_empty = head == (tail + 1 & 1023);
  assign is_full = (head + 1 & 1023) == tail;
  assign is_almost_full = (head + 2 & 1023) == tail;
  reg [8-1:0] rdata_reg;
  assign fifo_out_full = is_full;
  assign fifo_out_almost_full = is_almost_full || is_full;
  assign fifo_out_empty = is_empty;
  assign fifo_out_almost_empty = is_almost_empty || is_empty;
  assign fifo_out_rdata = rdata_reg;

  always @(posedge CLK) begin
    if(RST) begin
      head <= 0;
      rdata_reg <= 0;
      tail <= 0;
    end else begin
      if(fifo_out_enq && !is_full) begin
        mem[head] <= fifo_out_wdata;
        head <= head + 1;
      end 
      if(fifo_out_deq && !is_empty) begin
        rdata_reg <= mem[tail];
        tail <= tail + 1;
      end 
    end
  end


endmodule



module fifo_val
(
  input CLK,
  input RST,
  input fifo_val_enq,
  input [64-1:0] fifo_val_wdata,
  output fifo_val_full,
  output fifo_val_almost_full,
  input fifo_val_deq,
  output [64-1:0] fifo_val_rdata,
  output fifo_val_empty,
  output fifo_val_almost_empty
);

  reg [64-1:0] mem [0:1024-1];
  reg [10-1:0] head;
  reg [10-1:0] tail;
  wire is_empty;
  wire is_almost_empty;
  wire is_full;
  wire is_almost_full;
  assign is_empty = head == tail;
  assign is_almost_empty = head == (tail + 1 & 1023);
  assign is_full = (head + 1 & 1023) == tail;
  assign is_almost_full = (head + 2 & 1023) == tail;
  reg [64-1:0] rdata_reg;
  assign fifo_val_full = is_full;
  assign fifo_val_almost_full = is_almost_full || is_full;
  assign fifo_val_empty = is_empty;
  assign fifo_val_almost_empty = is_almost_empty || is_empty;
  assign fifo_val_rdata = rdata_reg;

  always @(posedge CLK) begin
    if(RST) begin
      head <= 0;
      rdata_reg <= 0;
      tail <= 0;
    end else begin
      if(fifo_val_enq && !is_full) begin
        mem[head] <= fifo_val_wdata;
        head <= head + 1;
      end 
      if(fifo_val_deq && !is_empty) begin
        rdata_reg <= mem[tail];
        tail <= tail + 1;
      end 
    end
  end


endmodule



module fifo_len
(
  input CLK,
  input RST,
  input fifo_len_enq,
  input [10-1:0] fifo_len_wdata,
  output fifo_len_full,
  output fifo_len_almost_full,
  input fifo_len_deq,
  output [10-1:0] fifo_len_rdata,
  output fifo_len_empty,
  output fifo_len_almost_empty
);

  reg [10-1:0] mem [0:1024-1];
  reg [10-1:0] head;
  reg [10-1:0] tail;
  wire is_empty;
  wire is_almost_empty;
  wire is_full;
  wire is_almost_full;
  assign is_empty = head == tail;
  assign is_almost_empty = head == (tail + 1 & 1023);
  assign is_full = (head + 1 & 1023) == tail;
  assign is_almost_full = (head + 2 & 1023) == tail;
  reg [10-1:0] rdata_reg;
  assign fifo_len_full = is_full;
  assign fifo_len_almost_full = is_almost_full || is_full;
  assign fifo_len_empty = is_empty;
  assign fifo_len_almost_empty = is_almost_empty || is_empty;
  assign fifo_len_rdata = rdata_reg;

  always @(posedge CLK) begin
    if(RST) begin
      head <= 0;
      rdata_reg <= 0;
      tail <= 0;
    end else begin
      if(fifo_len_enq && !is_full) begin
        mem[head] <= fifo_len_wdata;
        head <= head + 1;
      end 
      if(fifo_len_deq && !is_empty) begin
        rdata_reg <= mem[tail];
        tail <= tail + 1;
      end 
    end
  end


endmodule

