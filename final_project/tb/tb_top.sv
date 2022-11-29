`include "hams_pkg.vh"
`define DELAY_CK_Q #1
`define SIMULATION 1

import hams_pkg::*;
module tb_top(
  input logic clk
);
localparam NUM_MEM = NUM_ELEMENTS;
localparam MEM_DEPTH = 1024;
localparam ADDR_WIDTH = $clog2(MEM_DEPTH);
localparam DATA_WIDTH = 32;

bit rst_n;
logic bitonic_sort_done, data_in_vld,rdy;
logic bitonic_sort_done_d, bitonic_sort_done_dd, bitonic_sort_done_ddd;
integer rst_count = 0;
pair unsorted;
pair [NUM_ELEMENTS-1:0] sorted;
logic valid, valid_o;
logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr;
logic [NUM_MEM-1:0] mem_wr;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_rdata;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_wdata;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  vp_data_sorted;
logic sorted_data_rdyn;
logic start;

always @(posedge clk) begin
  rst_count = `DELAY_CK_Q (rst_count + 1);
  if((rst_count>=0) && (rst_count < 10))
    rst_n = 1'b0;
  else if(rst_count >= 10)
    rst_n = `DELAY_CK_Q 1'b1;
end

// always @(posedge clk) begin
  // if((rst_n===1) && bitonic_sort_done && sorted_data_rdyn) begin
    // $write("*-* All Finished *-*\n");
    // $finish;
  // end
// end
integer data_to_mem;

initial begin
  bit file_dump_complete;
  int fd;
  fd = $fopen("../../model/input_data.txt","r");
  file_dump_complete = 1'b0;
  data_in_vld = 1'b0;
  unsorted = 'x;
  start = 1'b0;
  @(posedge rst_n);
  forever begin
    @(posedge clk);
    if(!file_dump_complete && rdy) begin
      if(fd) begin
        while($fscanf(fd,"%x",data_to_mem) == 1) begin
          data_in_vld = 1'b1;
          unsorted.info = data_to_mem;
          @(posedge clk);
        end
        data_in_vld = 1'b0;
        unsorted = 'x;
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        file_dump_complete = 1'b1;
        $fclose(fd);
        fd=-1;
      end
    end
  end
end

hams_bitonic_sort_top
dut
(
  .start(start),
  .pause(1'b0),
  .rdy(rdy),
  .data_in(unsorted),
  .data_in_vld(data_in_vld),
  .data_o(sorted),
  .data_o_vld(valid_o),
  .bitonic_sort_complete(bitonic_sort_done),
  .clk,
  .rst_n
);


logic vp_data_sorted_last;

hams_syncfifo 
#(
  .FIFO_DEPTH(NUM_MEM),
  .FIFO_WIDTH(DATA_WIDTH*NUM_ELEMENTS + 1)
) dutx
(
  .clk,
  .rst_n,
  .push(valid_o),
  .pop(!sorted_data_rdyn),
  .push_data({bitonic_sort_done_dd,sorted}),
  .pop_data({vp_data_sorted_last,vp_data_sorted}),
  .empty(sorted_data_rdyn),
  .full(),
  .enteries()
);


hams_merge_sort_top 
#(
  .NUM_MEM(NUM_MEM),
  .DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH)
) duty
(
  .clk(clk),
  .rst_n(rst_n),
  .start(start),
  .pause(1'b0),
  .bitonic_sort_data(vp_data_sorted),
  .bitonic_sort_data_vld(!sorted_data_rdyn),
  .bitonic_sort_done(vp_data_sorted_last),
  .done()
);

always_ff @(posedge clk)
  bitonic_sort_done_d <=  bitonic_sort_done;
always_ff @(posedge clk)
  bitonic_sort_done_dd <=  bitonic_sort_done_d;
always_ff @(posedge clk)
  bitonic_sort_done_ddd <=  bitonic_sort_done_dd;


initial begin
  int fd;
  bit ph1_data_dump;
  ph1_data_dump = 1'b0;
  
  forever begin
    @(posedge clk);
    if(!ph1_data_dump) begin
      fd = $fopen("output_data_ph1.txt","w");
      ph1_data_dump = 1'b1;
    end
    if(!sorted_data_rdyn) begin
      $fdisplayh(fd,vp_data_sorted[0]);
      $fdisplayh(fd,vp_data_sorted[1]);
      $fdisplayh(fd,vp_data_sorted[2]);
      $fdisplayh(fd,vp_data_sorted[3]);
    end
    // if(bitonic_sort_done && ph1_data_dump) begin
      // $fclose(fd);
      // print_done = 1'b1;
    // end
  end
end

// Print some stuff as an example
initial begin
  if ($test$plusargs("trace") != 0) begin
    $display("[%0t] Tracing to logs/tb_top_dump.vcd...\n", $time);
    $dumpfile("logs/tb_top_dump.vcd");
    $dumpvars();
  end
  $display("[%0t] Model running...\n", $time);
end


endmodule :tb_top