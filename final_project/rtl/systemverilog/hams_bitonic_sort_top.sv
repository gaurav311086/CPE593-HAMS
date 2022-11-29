import hams_pkg::*;
module hams_bitonic_sort_top 
#(
  parameter NUM_MEM = 4,
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 10
)
(
  input   logic start,
  input   logic pause,
  output  logic rdy,
  input   pair  data_in,
  input   logic data_in_vld,
  output  pair  [NUM_ELEMENTS-1:0] data_o,
  output  logic data_o_vld,
  output  logic bitonic_sort_complete,
  input   logic clk,
  input   logic rst_n
);

logic [ADDR_WIDTH:0] elements_to_sort, elements_to_sort_nxt;
logic bitonic_sort_done;
pair [NUM_ELEMENTS-1:0] bitonic_sort_out,bitonic_sort_in;
logic bitonic_sort_out_vld,bitonic_sort_in_vld;
logic [NUM_MEM-1:0]                   mem_wr;
logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_wdata;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_rdata;
always_comb begin
  elements_to_sort_nxt = data_in_vld ? (elements_to_sort + 1) : 'x;
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    elements_to_sort <= '0;
  else begin
    if(bitonic_sort_done)
      elements_to_sort  <= '0;
    else if(data_in_vld && rdy)    
      elements_to_sort  <=  elements_to_sort_nxt;    
  end
end

hams_bitonic_sort_ctrl  #(
.NUM_MEM(NUM_MEM),
.DATA_WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH)
)
bitonic_sort_ctrl
(
  .clk(clk),
  .rst_n(rst_n),
  .start(start),
  .pause(pause),
  .program_data_vld(data_in_vld),
  .program_data(data_in),
  .sort_elements(elements_to_sort),
  .mem_rdata(mem_rdata),
  .mem_wr(mem_wr),
  .mem_addr(mem_addr),
  .mem_wdata(mem_wdata),
  .data_to_sort(bitonic_sort_in),
  .data_to_sort_valid(bitonic_sort_in_vld),
  .bitonic_sort_done(bitonic_sort_done),
  .rdy
);


hams_sortNelem
bitonic_4ele_sorter
(
  .unsigned_cmp(1'b0),
  .unsorted(bitonic_sort_in),
  .valid(bitonic_sort_in_vld),
  .sorted(bitonic_sort_out),
  .valid_o(bitonic_sort_out_vld),
  .clk(clk),
  .rst_n(rst_n)
);

assign data_o = bitonic_sort_out;
assign data_o_vld = bitonic_sort_out_vld;
hams_syncbram 
#(
  .DATA_DEPTH(2**ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1)
)
mem_a
(
  .clk(clk),
  .wr_en(mem_wr[0]),
  .wr_data(mem_wdata[0]),
  .addr(mem_addr[0]),
  .rd_data(mem_rdata[0])
);
hams_syncbram 
#(
  .DATA_DEPTH(2**ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1)
)
mem_b
(
  .clk(clk),
  .wr_en(mem_wr[1]),
  .wr_data(mem_wdata[1]),
  .addr(mem_addr[1]),
  .rd_data(mem_rdata[1])
);
hams_syncbram 
#(
  .DATA_DEPTH(2**ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1)
)
mem_c
(
  .clk(clk),
  .wr_en(mem_wr[2]),
  .wr_data(mem_wdata[2]),
  .addr(mem_addr[2]),
  .rd_data(mem_rdata[2])
);
hams_syncbram 
#(
  .DATA_DEPTH(2**ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1)
)
mem_d
(
  .clk(clk),
  .wr_en(mem_wr[3]),
  .wr_data(mem_wdata[3]),
  .addr(mem_addr[3]),
  .rd_data(mem_rdata[3])
);
assign bitonic_sort_complete = bitonic_sort_done;
endmodule: hams_bitonic_sort_top