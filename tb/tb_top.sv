// `include "hams_pkg.vh"
`timescale 1ps/1ps

// import hams_pkg::*;
module tb_top();
parameter CLK_PERIOD=10000;

logic clk;
logic rst_n;

initial begin
  clk = 1'b0;
  forever begin
    #(CLK_PERIOD/2);
    clk = !clk;
  end
end

initial begin
  int rst_count = 0;
  rst_n = 1'bx;
  forever begin
    #CLK_PERIOD;
    rst_count++;
    if((rst_count>=1) && (rst_count < 10))
      rst_n = 1'b0;
    else if(rst_count >= 10)
      rst_n = 1'b1;
  end
end

hams_Mele_sort
dut
(
  .unsorted('x),
  .valid('x),
  .sorted(),
  .valid_o(),
  .clk(clk),
  .rst_n(rst_n)
);

endmodule :tb_top