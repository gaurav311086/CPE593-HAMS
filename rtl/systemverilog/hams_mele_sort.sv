// `include "hams_pkg.vh"

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

pair [NUM_ELEMENTS-1:0] sorted_r;
logic valid_d;

always_ff@(posedge clk , negedge rst_n) begin
  if(!rst_n)
    valid_d <= 1'b0;
  else
    valid_d <= valid;
end

always_ff@(posedge clk , negedge rst_n) begin
  if(!rst_n)
    sorted_r <= 'x;
  else
    for(int i =0;i<NUM_ELEMENTS;i++) begin
      sorted_r[(NUM_ELEMENTS-1)-i] <= unsorted[i];
    end
end

assign sorted = sorted_r;
assign valid_o = valid_d;

endmodule : hams_Mele_sort
