`include "hams_pkg.vh"
// `define DELAY_CK_Q #1
`define DELAY_CK_Q 
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
integer rst_count = 0;
pair unsorted;
logic rdy;
logic unsorted_data_vld;
pair sorted;
logic sorted_vld;
logic start;
logic done;
logic done_d;

always @(posedge clk) begin
  rst_count = `DELAY_CK_Q (rst_count + 1);
  if((rst_count>=0) && (rst_count < 10))
    rst_n = 1'b0;
  else if(rst_count >= 10)
    rst_n = `DELAY_CK_Q 1'b1;
end

always @(posedge clk) begin
  if((rst_n===1) && done_d) begin
    $write("*-* All Finished *-*\n");
    $finish;
  end
  done_d = done;
end
integer data_to_mem;

initial begin
  bit file_dump_complete;
  int fd;
  fd = $fopen("../../model/input_data.txt","r");
  file_dump_complete = 1'b0;
  unsorted_data_vld = 1'b0;
  unsorted = 'x;
  start = 1'b0;
  @(posedge rst_n);
  forever begin
    @(posedge clk);
    if(!file_dump_complete && rdy) begin
      if(fd) begin
        while($fscanf(fd,"%x",data_to_mem) == 1) begin
          unsorted_data_vld = 1'b1;
          unsorted.info = data_to_mem;
          @(posedge clk);
        end
        unsorted_data_vld = 1'b0;
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

hams_top
dut 
(
  .clk,
  .rst_n,
  .start,
  .pause('0),
  .unsorted_data(unsorted),
  .unsorted_data_vld(unsorted_data_vld),
  .sorted_data(sorted),
  .sorted_data_vld(sorted_vld),
  .rdy(rdy),
  .done(done)
);



initial begin
  int fd;
  bit ph1_data_dump;
  ph1_data_dump = 1'b0;
  
  forever begin
    @(posedge clk);
    if(!ph1_data_dump) begin
      fd = $fopen("output_data.txt","w");
      ph1_data_dump = 1'b1;
    end
    if(sorted_vld) begin
      $fdisplayh(fd,sorted);
    end
    if(done_d && ph1_data_dump) begin
      $fclose(fd);
    end
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