`include "hams_pkg.vh"

import hams_pkg::*;
module hams_Mele_sort 
#(
  parameter NUM_ELEMENTS = 8
)
(
  input pair [NUM_ELEMENTS-1:0] unsorted,
  input logic valid,
  output pair [NUM_ELEMENTS-1:0] sorted,
  output logic valid_o,
  input logic clk,
  input logic rst_n
);

assign valid_o = 'x;
assign sorted = 'x;

endmodule : hams_Mele_sort
