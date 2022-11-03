`include "hams_pkg.vh"
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
  rst_count++;
  if((rst_count>=0) && (rst_count < 10))
    rst_n = 1'b0;
  else if(rst_count >= 10)
    rst_n = 1'b1;
end

always @(posedge clk) begin
  if(rst_n && valid_o && (rst_count >= 100) ) begin
    $write("*-* All Finished *-*\n");
    $finish;
  end
end

always @(posedge clk , negedge rst_n) begin
  if(!rst_n) begin
    valid <= 1'b0;
  end 
  else begin
    valid <= 1'b1;
  end
end

always @(posedge clk , negedge rst_n) begin
  if(!rst_n) begin
    unsorted <= 'x;
  end
  else begin
    for(int i =0; i< NUM_ELEMENTS; i++) begin
      // unsorted[i]<={$urandom,$urandom,$urandom,i};
      unsorted[i]<={NUM_ELEMENTS-i};
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