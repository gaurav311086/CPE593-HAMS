import hams_pkg::*;
module hams_sort2elem
#(
  parameter PIPELINE_EN = 1'b0
)
(
  input  logic        clk,
  input  pair [2-1:0] unsorted,
  input  logic        direction,
  output pair [2-1:0] sorted
);

`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif

pair [2-1:0] sorted_ascending;
pair [2-1:0] sorted_descending;
pair [2-1:0] sorted_int;

always_comb 
  sorted_ascending   = (unsorted[0].info > unsorted[1].info)? {unsorted[0],unsorted[1]} : unsorted;
always_comb 
  sorted_descending  = (unsorted[1].info > unsorted[0].info)? {unsorted[0],unsorted[1]} : unsorted;
always_comb 
  sorted_int         = (direction)? sorted_ascending : sorted_descending;

generate
  if(PIPELINE_EN) begin : PIPELINE
    always_ff@(posedge clk) begin
      sorted <= `DELAY_CK_Q sorted_int;
    end
  end
  else begin: NO_PIPELINE
    always_comb begin
      sorted = sorted_int;
    end
  end
endgenerate

endmodule : hams_sort2elem