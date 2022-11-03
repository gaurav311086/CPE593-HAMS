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

assign intermediate_pairs[0] = unsorted;

hams_pipevld
#(
  .PIPELINE_EN(1'b0)
)u_hams_pipevld_0
(
  .clk,
  .rst_n,
  .vld_i(valid),
  .vld_o(valid_i[0])
);

genvar k, j, i, ii;

generate
  for(k=0;k < $clog2(NUM_ELEMENTS);k++) begin : upper_bitonic_layer
    for(j=k; j >=0 ; j--) begin : inner_bitonic_layer
      for(i=0; i<NUM_ELEMENTS/2; i++) begin : compare_box
        if(j == 0) begin : lst_layer
          hams_sort2elem #(.PIPELINE_EN(PIPELINE_ENA_STAGES[((k*(k+1))/2)+j]))
          u_hams_sort2elem(  .clk,
                                .unsorted ({intermediate_pairs[((k*(k+1))/2)]   [(i<<1)+1],
                                            intermediate_pairs[((k*(k+1))/2)]   [(i<<1)]}),
                                .sorted   ({intermediate_pairs[((k*(k+1))/2)+1] [(i<<1)+1],
                                            intermediate_pairs[((k*(k+1))/2)+1] [(i<<1)]}),
                                .direction(!((i>>k)%2 > 0))
                              );
        end
        else begin : int_layer
          hams_sort2elem #(.PIPELINE_EN(PIPELINE_ENA_STAGES[((k*(k+1))/2)+j]))
          u_hams_sort2elem(  .clk,
                                .unsorted ({intermediate_pairs[((k*(k+1))/2)+j]   [((i>>j)<<(j+1))+(i%(2**j))+2**j],
                                            intermediate_pairs[((k*(k+1))/2)+j]   [((i>>j)<<(j+1))+(i%(2**j))]}),
                                .sorted   ({intermediate_pairs[((k*(k+1))/2)+j+1] [((i>>j)<<(j+1))+(i%(2**j))+2**j],
                                            intermediate_pairs[((k*(k+1))/2)+j+1] [((i>>j)<<(j+1))+(i%(2**j))]}),
                                .direction(!((i>>k)%2 > 0))
                              );
        end
      end
    end
  end
  for(ii=1; ii<=PIPELINES; ii++ ) begin : VALID_FF
    hams_pipevld
    #(
      .PIPELINE_EN(1'b1)
    )u_hams_pipevld
    (
      .clk,
      .rst_n,
      .vld_i(valid_i[ii-1]),
      .vld_o(valid_i[ii])
    );
  end
endgenerate

assign valid_o  = valid_i[PIPELINES];
assign sorted   = intermediate_pairs[NUM_BITONIC_LAYER];

endmodule : hams_sortNelem
