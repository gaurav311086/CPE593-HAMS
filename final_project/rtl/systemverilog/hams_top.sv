import hams_pkg::*;
module hams_top 
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
  input   pair                                  unsorted_data,
  input   logic                                 unsorted_data_vld,
  output  pair                                  sorted_data,
  output  logic                                 sorted_data_vld,
  output  logic                                 rdy,
  output  logic                                 done
);


pair [NUM_ELEMENTS-1:0] bitonic_sorted;
pair [NUM_ELEMENTS-1:0] bitonic_sorted_buf;
logic bitonic_sorted_vld;
logic bitonic_sorted_buf_last;
logic bitonic_sorted_buf_vld_n;
logic bitonic_sort_done_d, bitonic_sort_done_dd;

hams_bitonic_sort_top
#(
.ADDR_WIDTH(ADDR_WIDTH)
)
bitonic_sort4elem
(
  .start(start),
  .pause(pause),
  .rdy(rdy),
  .data_in(unsorted_data),
  .data_in_vld(unsorted_data_vld),
  .data_o(bitonic_sorted),
  .data_o_vld(bitonic_sorted_vld),
  .bitonic_sort_complete(bitonic_sort_done),
  .clk,
  .rst_n
);

hams_syncfifo 
#(
  .FIFO_DEPTH(NUM_MEM),
  .FIFO_WIDTH(DATA_WIDTH*NUM_ELEMENTS + 1)
) buffer
(
  .clk,
  .rst_n,
  .push(bitonic_sorted_vld),
  .pop(!bitonic_sorted_buf_vld_n),
  .push_data({bitonic_sort_done_dd,bitonic_sorted}),
  .pop_data({bitonic_sorted_buf_last,bitonic_sorted_buf}),
  .empty(bitonic_sorted_buf_vld_n),
  .full(),
  .enteries()
);


hams_merge_sort_top 
#(
  .NUM_MEM(NUM_MEM),
  .DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH)
) merge_function
(
  .clk(clk),
  .rst_n(rst_n),
  .start(start),
  .pause(pause),
  .bitonic_sort_data(bitonic_sorted_buf),
  .bitonic_sort_data_vld(!bitonic_sorted_buf_vld_n),
  .bitonic_sort_done(bitonic_sorted_buf_last),
  .sorted_data(sorted_data),
  .sorted_data_vld(sorted_data_vld),
  .done(done)
);

always_ff @(posedge clk)
  bitonic_sort_done_d <=  bitonic_sort_done;
always_ff @(posedge clk)
  bitonic_sort_done_dd <=  bitonic_sort_done_d;

endmodule: hams_top