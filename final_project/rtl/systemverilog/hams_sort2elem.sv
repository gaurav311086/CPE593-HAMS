import hams_pkg::*;
module hams_sort2elem
#(
  parameter PIPELINE_EN = 1'b0
)
(
  input  logic        clk,
  input  logic        unsigned_cmp,
  input  pair [2-1:0] unsorted,
  input  logic        direction,
  output pair [2-1:0] sorted
);

`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif

pair [2-1:0] sorted_us_ascending;
pair [2-1:0] sorted_us_descending;
pair [2-1:0] sorted_s_ascending;
pair [2-1:0] sorted_s_descending;
pair [2-1:0] sorted_us_int;
pair [2-1:0] sorted_s_int;

always_comb 
  sorted_us_ascending   = (unsorted[0].info > unsorted[1].info)? {unsorted[0],unsorted[1]} : unsorted;
always_comb 
  sorted_us_descending  = (unsorted[1].info > unsorted[0].info)? {unsorted[0],unsorted[1]} : unsorted;
always_comb 
  sorted_s_ascending   = ($signed(unsorted[0].info) > $signed(unsorted[1].info))? {unsorted[0],unsorted[1]} : unsorted;
always_comb 
  sorted_s_descending  = ($signed(unsorted[1].info) > $signed(unsorted[0].info))? {unsorted[0],unsorted[1]} : unsorted;
always_comb 
  sorted_us_int         = (direction)? sorted_us_ascending : sorted_us_descending;
always_comb 
  sorted_s_int          = (direction)? sorted_s_ascending : sorted_s_descending;

generate
  if(PIPELINE_EN) begin : PIPELINE
    always_ff@(posedge clk) begin
      sorted <= `DELAY_CK_Q (unsigned_cmp)?sorted_us_int:sorted_s_int;
    end
  end
  else begin: NO_PIPELINE
    always_comb begin
      sorted = (unsigned_cmp)?sorted_us_int:sorted_s_int;
    end
  end
endgenerate

endmodule : hams_sort2elem