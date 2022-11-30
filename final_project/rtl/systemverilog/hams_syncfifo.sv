module hams_syncfifo 
#(
  parameter FIFO_DEPTH = 16,
  parameter FIFO_WIDTH = 8
)
(
  input   logic clk,
  input   logic rst_n,
  input   logic push,
  input   logic pop,
  input   logic [FIFO_WIDTH -1 : 0] push_data,
  output  logic [FIFO_WIDTH -1 : 0] pop_data,
  output  logic empty,
  output  logic full,
  output  logic [$clog2(FIFO_DEPTH+1):0] enteries
);
`ifndef DELAY_CK_Q
  // `define DELAY_CK_Q #1
`endif
  logic [FIFO_DEPTH - 1: 0] [FIFO_WIDTH -1 : 0] fifo_memory;
  logic [$clog2(FIFO_DEPTH+1):0] fifo_rd_pointer, fifo_rd_pointer_nxt;
  logic [$clog2(FIFO_DEPTH+1):0] fifo_wr_pointer, fifo_wr_pointer_nxt;
  logic [$clog2(FIFO_DEPTH+1):0] enteries_nxt;
  
  genvar i;
  generate
    for(i=0;i<FIFO_DEPTH;i++) begin
      always_ff@(posedge clk) begin
        if(i==fifo_wr_pointer[$clog2(FIFO_DEPTH+1)-1:0] && push)
          fifo_memory[i]  <= `DELAY_CK_Q push_data;
      end
    end
  endgenerate
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n)
      fifo_wr_pointer <= '0;
    else begin
      if(!full && push)
        fifo_wr_pointer <=  `DELAY_CK_Q fifo_wr_pointer_nxt;
    end
  end
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n)
      fifo_rd_pointer <= '0;
    else begin
      if(!empty && pop)
        fifo_rd_pointer <=  `DELAY_CK_Q fifo_rd_pointer_nxt;
    end
  end
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n)
      enteries <= '0;
    else begin
      if((!empty && pop) ^ (!full && push))
        enteries <=  `DELAY_CK_Q enteries_nxt;
    end
  end  
      
  always_comb begin
    fifo_wr_pointer_nxt = (fifo_wr_pointer[$clog2(FIFO_DEPTH+1)-1:0] == FIFO_DEPTH-1)? 
                            {!fifo_wr_pointer[$clog2(FIFO_DEPTH+1)],{$clog2(FIFO_DEPTH+1){1'b0}}} : fifo_wr_pointer + 1;
    fifo_rd_pointer_nxt = (fifo_rd_pointer[$clog2(FIFO_DEPTH+1)-1:0] == FIFO_DEPTH-1)? 
                            {!fifo_rd_pointer[$clog2(FIFO_DEPTH+1)],{$clog2(FIFO_DEPTH+1){1'b0}}} : fifo_rd_pointer + 1;
    
    case ({(!full && push), (!empty && pop)}) inside
      2'b10   : enteries_nxt = enteries + 1;
      2'b01   : enteries_nxt = enteries - 1;
      default : enteries_nxt = 'x;
    endcase
  end
  
  always_comb begin
    pop_data  = fifo_memory[fifo_rd_pointer[$clog2(FIFO_DEPTH+1)-1:0]];
    empty     = (fifo_rd_pointer == fifo_wr_pointer);
    full      = /*(fifo_rd_pointer[$clog2(FIFO_DEPTH+1)] ^ fifo_wr_pointer_nxt[$clog2(FIFO_DEPTH+1)]) && 
                  (fifo_rd_pointer[$clog2(FIFO_DEPTH+1)-1:0] == fifo_wr_pointer_nxt[$clog2(FIFO_DEPTH+1)-1:0]);*/
                  (enteries==FIFO_DEPTH);
  end
endmodule : hams_syncfifo