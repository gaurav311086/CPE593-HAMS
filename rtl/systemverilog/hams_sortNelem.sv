// `include "hams_pkg.vh"

import hams_pkg::*;

module hams_sortNelem
(
  input   pair [NUM_ELEMENTS-1:0] unsorted,
  input   logic valid,
  output  pair [NUM_ELEMENTS-1:0] sorted,
  output  logic valid_o,
  input   logic clk,
  input   logic rst_n
);

pair  [ NUM_BITONIC_LAYER : 0] [NUM_ELEMENTS-1:0] intermediate_pairs;
logic [PIPELINES: 0] valid_i;


//Assertion to check if NUM_ELEMENTS is not a power of 2!
always @(clk) begin
  assert(NUM_ELEMENTS == 2**($clog2(NUM_ELEMENTS))) else $fatal("NUM_ELEMENTS: %d must be power of 2!", NUM_ELEMENTS); 
end

genvar k, j, i, ii;

assign intermediate_pairs[0] = unsorted;
always_comb
  valid_i[0] = valid; 
generate
  for(k=0;k < $clog2(NUM_ELEMENTS);k++) begin : upper_bitonic_layer
    for(j=k; j >=0 ; j--) begin : inner_bitonic_layer
      for(i=0; i<NUM_ELEMENTS/2; i++) begin : compare_box
        hams_sort2elem #(.PIPELINE_EN(PIPELINE_ENA_STAGES[((k*(k+1))/2)+j]))
        hams_sort2elem_swap(  .clk,
                              .unsorted ({intermediate_pairs[((k*(k+1))/2)+j][((i>>j)<<(j+1))+(i%(2**j))+2<<j],
                                          intermediate_pairs[((k*(k+1))/2)+j][((i>>j)<<(j+1))+(i%(2**j))]}),
                              .sorted   ({intermediate_pairs[((k*(k+1))/2)+j+1][((i>>j)<<(j+1))+(i%(2**j))+2<<j],
                                          intermediate_pairs[((k*(k+1))/2)+j+1][((i>>j)<<(j+1))+(i%(2**j))]}),
                              .direction(!((i>>k)%2 > 0))
                            );
      end
    end
  end
  for(ii=1; ii<=PIPELINES; ii++ ) begin : VALID_FF
    always_ff@(posedge clk) begin
      valid_i[i] <= valid_i[i-1];
    end
  end
endgenerate

assign valid_o  = valid_i[PIPELINES];
assign sorted   = intermediate_pairs[NUM_BITONIC_LAYER];

endmodule : hams_sortNelem
