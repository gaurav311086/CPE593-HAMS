import hams_pkg::*;
module hams_merge_sort_top 
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
  output  logic                                 done
);
logic [NUM_MEM-1:0]                   mem_wr;
logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_wdata;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_rdata;
logic fifo_full, fifo_empty, fifo_pop;
pair                                  merge_sort_data;
pair  [NUM_MEM-1:0]                   unsort_data_out;
logic [NUM_MEM-1:0]                   unsort_data_out_vld;


hams_merge_sort_ctrl  #(
.NUM_MEM(NUM_MEM),
.DATA_WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH)
)
merge_sort_ctrl
(
  .clk(clk),
  .rst_n(rst_n),
  .start(start),
  .pause(pause),
  .fifo_full(fifo_full),
  .fifo_empty(fifo_empty),
  .fifo_pop(fifo_pop),
  .bitonic_sort_data_vld(bitonic_sort_data_vld),
  .bitonic_sort_data(bitonic_sort_data),
  .bitonic_sort_done(bitonic_sort_done),
  .merge_sort_data(merge_sort_data),
  .unsort_data_out(unsort_data_out),
  .unsort_data_out_vld(unsort_data_out_vld),
  .mem_rdata(mem_rdata),
  .mem_wr(mem_wr),
  .mem_addr(mem_addr),
  .mem_wdata(mem_wdata)
);


hams_4to1_merge_sort
merge_4col_sorter
(
  .clk(clk),
  .rst_n(rst_n),
  .col_ena('1),
  .colDataVld(unsort_data_out_vld),
  .colData(unsort_data_out),
  .fifo_empty(fifo_empty),
  .fifo_full(fifo_full),
  .sort_data_o(merge_sort_data),
  .fifo_pop(fifo_pop)
);

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
// assign bitonic_sort_complete = bitonic_sort_done;
endmodule: hams_merge_sort_top