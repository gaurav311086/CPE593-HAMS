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
logic bitonic_sort_done;
integer rst_count = 0;
pair [NUM_ELEMENTS-1:0] unsorted;
pair [NUM_ELEMENTS-1:0] sorted;
logic valid, valid_o;
logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr;
logic [NUM_MEM-1:0] mem_wr;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_rdata;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  mem_wdata;
logic [NUM_MEM-1:0] [DATA_WIDTH-1:0]  vp_data_sorted;
logic sorted_data_rdyn;

always @(posedge clk) begin
  rst_count = `DELAY_CK_Q (rst_count + 1);
  if((rst_count>=0) && (rst_count < 10))
    rst_n = 1'b0;
  else if(rst_count >= 10)
    rst_n = `DELAY_CK_Q 1'b1;
end

always @(posedge clk) begin
  if((rst_n===1) && bitonic_sort_done ) begin
    $write("*-* All Finished *-*\n");
    $finish;
  end
end

hams_ctrl 
dut_ctrl
(
  .clk(clk),
  .rst_n(rst_n),
  .start(1'b1),
  .pause(1'b0),
  .sort_chunks((MEM_DEPTH/NUM_ELEMENTS)),
  .vp_data_sorted(vp_data_sorted),
  .vp_data_sorted_valid(!sorted_data_rdyn),
  .mem_rdata(mem_rdata),
  .mem_wr(mem_wr),
  .mem_addr(mem_addr),
  .mem_wdata(mem_wdata),
  .vp_data_to_sort(unsorted),
  .vp_data_to_sort_valid(valid),
  .bitonic_sort_done
);


hams_sortNelem
dut_vp
(
  .unsigned_cmp(1'b0),
  .unsorted(unsorted),
  .valid(valid),
  .sorted(sorted),
  .valid_o(valid_o),
  .clk(clk),
  .rst_n(rst_n)
);

hams_syncfifo 
#(
  .FIFO_DEPTH(NUM_MEM*2),
  .FIFO_WIDTH(DATA_WIDTH*NUM_ELEMENTS)
) dutx
(
  .clk,
  .rst_n,
  .push(valid_o),
  .pop(mem_wr[0]),
  .push_data(sorted),
  .pop_data(vp_data_sorted),
  .empty(sorted_data_rdyn),
  .full(),
  .enteries()
);

hams_syncbram 
#(
  .DATA_DEPTH(MEM_DEPTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1),
  .INIT_VAL_FILE("../../model/input_data.txt")
)
dut_work_mem_a
(
  .clk(clk),
  .wr_en(mem_wr[0]),
  .wr_data(mem_wdata[0]),
  .addr(mem_addr[0]),
  .rd_data(mem_rdata[0])
);
hams_syncbram 
#(
  .DATA_DEPTH(MEM_DEPTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1),
  .INIT_VAL_FILE("../../model/input_data.txt")
)
dut_work_mem_b
(
  .clk(clk),
  .wr_en(mem_wr[1]),
  .wr_data(mem_wdata[1]),
  .addr(mem_addr[1]),
  .rd_data(mem_rdata[1])
);
hams_syncbram 
#(
  .DATA_DEPTH(MEM_DEPTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1),
  .INIT_VAL_FILE("../../model/input_data.txt")
)
dut_work_mem_c
(
  .clk(clk),
  .wr_en(mem_wr[2]),
  .wr_data(mem_wdata[2]),
  .addr(mem_addr[2]),
  .rd_data(mem_rdata[2])
);
hams_syncbram 
#(
  .DATA_DEPTH(MEM_DEPTH),
  .DATA_WIDTH(DATA_WIDTH),
  .OUT_PIPELINE_ENA(1),
  .INIT_VAL_FILE("../../model/input_data.txt")
)
dut_work_mem_d
(
  .clk(clk),
  .wr_en(mem_wr[3]),
  .wr_data(mem_wdata[3]),
  .addr(mem_addr[3]),
  .rd_data(mem_rdata[3])
);

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