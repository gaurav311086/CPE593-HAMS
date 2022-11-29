import hams_pkg::*;
module hams_merge_sort_ctrl 
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
  input   pair  [NUM_MEM-1:0]                   bitonic_sort_data,
  input   logic                                 bitonic_sort_data_vld,
  input   logic                                 bitonic_sort_done,
  input   pair                                  merge_sort_data,
  output  pair  [NUM_MEM-1:0]                   unsort_data_out,
  output  logic [NUM_MEM-1:0]                   unsort_data_out_vld,
  input   logic                                 fifo_full,
  input   logic                                 fifo_empty,
  input   logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_rdata,
  output  logic [NUM_MEM-1:0]                   mem_wr,
  output  logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr,
  output  logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_wdata,
  output  logic                                 fifo_pop
);
`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif

localparam logic [2:0] IDLE               = 3'd0;
localparam logic [2:0] PREP_MERGE_4ELEMS  = 3'd1;
localparam logic [2:0] MERGE_4ELEMS       = 3'd2;
localparam logic [2:0] MERGE_16ELEMS      = 3'd3;
localparam logic [2:0] MERGE_64ELEMS      = 3'd4;
localparam logic [2:0] MERGE_256ELEMS     = 3'd5;
localparam logic [2:0] MERGE_DONE         = 3'd6;

logic [3:0] fsm_state, fsm_state_nxt;
logic [NUM_MEM-1:0] bitonic_sort_data_vld_i,bitonic_sort_data_vld_i_d;
logic [NUM_MEM-1:0] mem_wr_colq_ctrl;
logic [NUM_MEM-1:0] mem_select, mem_select_nxt;
logic [$clog2(NUM_MEM+1)-1:0] cyc_count, cyc_count_nxt;
pair  [NUM_MEM-1:0] [NUM_MEM-1:0] bitonic_data_serialized;
logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr_colq_ctrl, mem_addr_dprep, mem_addr_dprep_d;
logic [NUM_MEM-1:0] bitonic_sort_done_d;
logic [8:0] column_length;
logic colMergeDone;

assign   bitonic_sort_data_vld_i[0] = bitonic_sort_data_vld;
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    bitonic_sort_data_vld_i[NUM_MEM-1:1] <= `DELAY_CK_Q  '0;
  else
    bitonic_sort_data_vld_i[NUM_MEM-1:1] <= `DELAY_CK_Q  bitonic_sort_data_vld_i[NUM_MEM-2:0];
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    bitonic_sort_data_vld_i_d <= `DELAY_CK_Q  '0;
  else
    bitonic_sort_data_vld_i_d <= `DELAY_CK_Q  bitonic_sort_data_vld_i;
end
always_comb begin
  mem_select_nxt = {mem_select[NUM_MEM-2:0],mem_select[NUM_MEM-1]};
  cyc_count_nxt  = (cyc_count==NUM_MEM-1)? '0: cyc_count+1;
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    mem_select  <= `DELAY_CK_Q  1;
  else begin
    if(start)
      mem_select  <= `DELAY_CK_Q  1;
    else if(|bitonic_sort_data_vld_i)
      mem_select  <= `DELAY_CK_Q  mem_select_nxt;
  end
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    mem_addr_dprep  <= `DELAY_CK_Q  '0;
  else begin
    if(start) begin
      mem_addr_dprep  <=  {{{(ADDR_WIDTH-4){1'b0}},4'b1100},{{(ADDR_WIDTH-4){1'b0}},4'b1000},
                          {{(ADDR_WIDTH-3){1'b0}},3'b100},{ADDR_WIDTH{1'b0}}};
    end
    else begin
      if(bitonic_sort_data_vld_i[1] )
        mem_addr_dprep[1]  <= `DELAY_CK_Q  mem_addr_dprep[0] + 4;
      if(bitonic_sort_data_vld_i[2] )
        mem_addr_dprep[2]  <= `DELAY_CK_Q  mem_addr_dprep[1] + 4;
      if(bitonic_sort_data_vld_i[3] )
        mem_addr_dprep[3]  <= `DELAY_CK_Q  mem_addr_dprep[2] + 4;
      if(bitonic_sort_data_vld_i[0] ) begin
        if(mem_select[NUM_MEM-1])
          mem_addr_dprep[0]  <= `DELAY_CK_Q  mem_addr_dprep[0] + 1 + 12;
        else
          mem_addr_dprep[0]  <= `DELAY_CK_Q  mem_addr_dprep[0] + 1;
      end
    end
  end
end
always_ff @(posedge clk) begin
  mem_addr_dprep_d <= (fsm_state > PREP_MERGE_4ELEMS)? mem_addr_colq_ctrl : mem_addr_dprep;
end
always_ff @(posedge clk) begin
  bitonic_sort_done_d <=  {bitonic_sort_done_d[NUM_MEM-2:0],bitonic_sort_done};
end
always_ff @(posedge clk) begin
  if(bitonic_sort_done)
    column_length <= 9'd4;
  else if(colMergeDone)
    column_length <= {column_length[6:0],2'b00};
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    cyc_count  <=  `DELAY_CK_Q '0;
  else begin
    if(start)
      cyc_count  <=  `DELAY_CK_Q '0;
    else if(|bitonic_sort_data_vld_i)
      cyc_count  <=  `DELAY_CK_Q cyc_count_nxt;
  end
end

always_ff @(posedge clk) begin
  for(int i=0;i<NUM_MEM;i++) begin
    if(bitonic_sort_data_vld_i[i]) begin
      if(mem_select[i])
        bitonic_data_serialized[i]  <= `DELAY_CK_Q bitonic_sort_data;
      else
        bitonic_data_serialized[i]  <= `DELAY_CK_Q {bitonic_data_serialized[i][0],
                                                    bitonic_data_serialized[i][NUM_MEM-1:1]};
    end
  end
end
always_comb begin
  case (fsm_state) inside
    IDLE : begin
      if(start)
        fsm_state_nxt =  PREP_MERGE_4ELEMS;
      else
        fsm_state_nxt =  IDLE;
    end
    PREP_MERGE_4ELEMS : begin
      if(bitonic_sort_done_d[NUM_MEM-1])
        fsm_state_nxt =  MERGE_4ELEMS;
      else
        fsm_state_nxt =  PREP_MERGE_4ELEMS;
    end
    MERGE_4ELEMS : begin
      if(colMergeDone)
        fsm_state_nxt =  MERGE_16ELEMS;
      else
        fsm_state_nxt =  MERGE_4ELEMS;
    end
    MERGE_16ELEMS : begin
      if(colMergeDone)
        fsm_state_nxt =  MERGE_64ELEMS;
      else
        fsm_state_nxt =  MERGE_16ELEMS;
    end
    MERGE_64ELEMS : begin
      if(colMergeDone)
        fsm_state_nxt =  MERGE_256ELEMS;
      else
        fsm_state_nxt =  MERGE_64ELEMS;
    end
    MERGE_256ELEMS : begin
      if(colMergeDone)
        fsm_state_nxt =  MERGE_DONE;
      else
        fsm_state_nxt =  MERGE_256ELEMS;
    end
    MERGE_DONE : begin
      fsm_state_nxt =  MERGE_DONE;
    end
    default: begin
      fsm_state_nxt =  IDLE;
    end
  endcase
end

logic fifo_push;

hams_merge_sort_colq_ctrl 
#(
  .NUM_MEM(NUM_MEM),
  .ADDR_WIDTH(ADDR_WIDTH)
)
addrGen
(
  .clk(clk),
  .rst_n(rst_n),
  .fifo_full(fifo_full),
  .fifo_empty(fifo_empty),
  .fifo_pop(fifo_pop),
  .start(bitonic_sort_done_d[NUM_MEM-1] || (colMergeDone && (fsm_state != MERGE_256ELEMS))),
  .pause(pause),
  .init({10'd12,10'd8,10'd4,10'd0}),
  .stride(10'd16),
  .loop_limit(10'd4),
  .stride_limit(11'd1024),
  .mem_wr(mem_wr_colq_ctrl),
  .mem_addr(mem_addr_colq_ctrl),
  .done(colMergeDone),
  .fifo_push(fifo_push)
);
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    unsort_data_out_vld <=  `DELAY_CK_Q '0;
  else begin
    unsort_data_out_vld <=  `DELAY_CK_Q {NUM_MEM{fifo_push}};
  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    fsm_state <=  `DELAY_CK_Q IDLE;
  else if(!pause)
    fsm_state <=  `DELAY_CK_Q fsm_state_nxt;
end

assign mem_wdata = (fsm_state > PREP_MERGE_4ELEMS)? {NUM_MEM{merge_sort_data}} :
                    {bitonic_data_serialized[3][0],bitonic_data_serialized[2][0],
                    bitonic_data_serialized[1][0],bitonic_data_serialized[0][0]};
assign mem_addr = mem_addr_dprep_d;
assign mem_wr = (fsm_state > PREP_MERGE_4ELEMS)? mem_wr_colq_ctrl : bitonic_sort_data_vld_i_d;
assign unsort_data_out = mem_rdata;
endmodule : hams_merge_sort_ctrl