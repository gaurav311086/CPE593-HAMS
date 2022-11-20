`include "hams_pkg.vh"
`define DELAY_CK_Q #1
`define SIMULATION 1

import hams_pkg::*;
module tb_top(
  input logic clk
);
bit rst_n;
integer rst_count = 0;
pair [NUM_ELEMENTS-1:0] unsorted;
pair [NUM_ELEMENTS-1:0] sorted;
logic valid, valid_o;

always @(posedge clk) begin
  rst_count = `DELAY_CK_Q (rst_count + 1);
  if((rst_count>=0) && (rst_count < 10))
    rst_n = 1'b0;
  else if(rst_count >= 10)
    rst_n = `DELAY_CK_Q 1'b1;
end

always @(posedge clk) begin
  if((rst_n===1) && valid_o && (rst_count >= 100) ) begin
    $write("*-* All Finished *-*\n");
    $finish;
  end
end

always @(posedge clk , negedge rst_n) begin
  if(!rst_n) begin
    valid <= 1'b0;
  end 
  else begin
    valid <= `DELAY_CK_Q 1'b1;
  end
end

logic pop;
always @(posedge clk , negedge rst_n) begin
  if(!rst_n) begin
    pop <= 1'b0;
  end 
  else begin
    pop <= `DELAY_CK_Q (valid ^ pop);
  end
end

always @(posedge clk , negedge rst_n) begin
  if(!rst_n) begin
    unsorted <= 'x;
  end
  else begin
    for(int i =0; i< NUM_ELEMENTS; i++) begin
      // unsorted[i]<={$urandom,$urandom,$urandom,i};
      unsorted[i]<=`DELAY_CK_Q {NUM_ELEMENTS-i};
    end
  end
end

hams_sortNelem
dut
(
  .unsorted(unsorted),
  .valid(valid),
  .sorted(sorted),
  .valid_o(valid_o),
  .clk(clk),
  .rst_n(rst_n)
);

hams_syncfifo 
#(
  .FIFO_DEPTH(8),
  .FIFO_WIDTH(8)
) dutx
(
  .clk,
  .rst_n,
  .push(valid && (rst_count < 50)),
  .pop(pop),
  .push_data((rst_count[7:0]-8'd10)),
  .pop_data(),
  .empty(),
  .full(),
  .enteries()
);

hams_syncbram 
#(
  .DATA_DEPTH(1024),
  .DATA_WIDTH(32),
  .OUT_PIPELINE_ENA(1),
  .INIT_VAL_FILE("../../model/input_data.txt")
)
dut_work_mem_a
(
  .clk(clk),
  .wr_en(1'b0),
  .wr_data('0),
  .addr('0),
  .rd_data()
);
/*hams_syncbram 
#(
  .DATA_DEPTH(1024),
  .DATA_WIDTH(128),
  .OUT_PIPELINE_ENA(1)
)
dut_work_mem_b
(
  .clk(clk),
  .wr_en(1'b0),
  .wr_data('0),
  .addr('0),
  .rd_data()
);*/

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