import hams_pkg::*;
module hams_ctrl 
#(
  parameter NUM_MEM = 4,
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 10
)
(
  input   logic                                 clk,
  input   logic                                 rst_n,
  input   logic                                 start,
  input   logic                                 pause,
  input   logic [ADDR_WIDTH-$clog2(NUM_MEM):0]  sort_chunks,
  input   pair  [NUM_ELEMENTS-1:0]              vp_data_sorted,
  input   logic                                 vp_data_sorted_valid,
  input   logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_rdata,
  output  logic                                 bitonic_sort_done,
  output  logic [NUM_MEM-1:0]                   mem_wr,
  output  logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr,
  output  logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_wdata,
  output  pair  [NUM_ELEMENTS-1:0]              vp_data_to_sort,
  output  logic                                 vp_data_to_sort_valid  
);
`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif

localparam logic [1:0] IDLE = 2'd0;
localparam logic [1:0] SORT_4ELEM4CYCL = 2'd1;
localparam logic [1:0] WRBACK_SORTED4ELEM4CYCL = 2'd2;
localparam logic [1:0] MERGE_SORT_ELEM = 2'd3;

logic [1:0] fsm_state, fsm_state_nxt;
logic cyc4done;
logic [1:0] cyc_count, cyc_count_nxt;
logic vecprocdone;
logic [ADDR_WIDTH-$clog2(NUM_MEM):0] vecproc_rd1_addr, vecproc_rd1_addr_nxt;
logic [ADDR_WIDTH-$clog2(NUM_MEM):0] vecproc_wr1_addr, vecproc_wr1_addr_nxt;

always_comb begin
  case (fsm_state) inside
    IDLE : begin
      if(start)
        fsm_state_nxt =  SORT_4ELEM4CYCL;
      else
        fsm_state_nxt =  IDLE;
    end
    SORT_4ELEM4CYCL : begin
      if(cyc4done)
        fsm_state_nxt =  WRBACK_SORTED4ELEM4CYCL;
      else
        fsm_state_nxt =  SORT_4ELEM4CYCL;
    end
    WRBACK_SORTED4ELEM4CYCL : begin
      if(cyc4done && vecprocdone)
        fsm_state_nxt =  MERGE_SORT_ELEM;
      else if(cyc4done)
        fsm_state_nxt =  SORT_4ELEM4CYCL;
      else        
        fsm_state_nxt =  WRBACK_SORTED4ELEM4CYCL;
    end
    MERGE_SORT_ELEM : begin
      fsm_state_nxt =  MERGE_SORT_ELEM;
    end
    default: begin
      fsm_state_nxt =  IDLE;
    end
  endcase
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    fsm_state <=  `DELAY_CK_Q IDLE;
  else if(!pause)
    fsm_state <=  `DELAY_CK_Q fsm_state_nxt;
end

always_comb begin
  case  (fsm_state) inside
    [SORT_4ELEM4CYCL:WRBACK_SORTED4ELEM4CYCL] : cyc_count_nxt = cyc_count + 1;
    default : cyc_count_nxt = 2'b00;
  endcase
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    cyc_count <=  `DELAY_CK_Q 2'd0;
  else if(!pause)
    cyc_count <=  `DELAY_CK_Q cyc_count_nxt;
end
assign cyc4done = (cyc_count==2'd3)? 1'b1:1'b0;
assign vecprocdone = (sort_chunks == vecproc_rd1_addr)? 1'b1:1'b0;

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    vecproc_rd1_addr <=  `DELAY_CK_Q '0;
  else if(!pause)
    vecproc_rd1_addr <=  `DELAY_CK_Q vecproc_rd1_addr_nxt;
end
always_comb begin
  case (fsm_state) inside
    IDLE  :
      vecproc_rd1_addr_nxt  = '0;
    SORT_4ELEM4CYCL :
      vecproc_rd1_addr_nxt = vecproc_rd1_addr + 1;
    default : vecproc_rd1_addr_nxt = vecproc_rd1_addr;
  endcase
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    vecproc_wr1_addr <=  `DELAY_CK_Q '0;
  else if(!pause) begin
    if(vp_data_sorted_valid)
      vecproc_wr1_addr <=  `DELAY_CK_Q vecproc_wr1_addr_nxt;
  end
end
always_comb begin
  case (fsm_state) inside
    IDLE  :
      vecproc_wr1_addr_nxt  = '0;
    WRBACK_SORTED4ELEM4CYCL :
      vecproc_wr1_addr_nxt = vecproc_wr1_addr + 1;
    default : vecproc_wr1_addr_nxt = vecproc_wr1_addr;
  endcase
end

always_comb begin
  case (fsm_state) inside
    WRBACK_SORTED4ELEM4CYCL :
      for(int i=0;i<NUM_MEM;i++)
        mem_wr[i] = vp_data_sorted_valid && !pause;
    default : mem_wr = '0;
  endcase
end

always_comb begin
  case (fsm_state) inside
    SORT_4ELEM4CYCL : begin
      for(int i=0;i<NUM_MEM;i++) begin
        mem_addr[i] = {vecproc_rd1_addr[ADDR_WIDTH-2-1:0],i[1:0]};
      end
    end
    WRBACK_SORTED4ELEM4CYCL :begin
      for(int i=0;i<NUM_MEM;i++) begin
        mem_addr[i] = {vecproc_wr1_addr[ADDR_WIDTH-2-1:0],i[1:0]};
      end
    end
    default : mem_addr = 'x;
  endcase
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    vp_data_to_sort_valid <=  `DELAY_CK_Q '0;
  else
    vp_data_to_sort_valid <=  `DELAY_CK_Q (fsm_state==SORT_4ELEM4CYCL && !pause)?1'b1:1'b0;
end

assign mem_wdata = vp_data_sorted;
assign vp_data_to_sort = mem_rdata;
assign bitonic_sort_done = (fsm_state==WRBACK_SORTED4ELEM4CYCL) && cyc4done && vecprocdone;
endmodule : hams_ctrl