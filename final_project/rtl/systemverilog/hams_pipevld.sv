import hams_pkg::*;
module hams_pipevld
#(
  parameter PIPELINE_EN = 1'b0
)
(
  input  logic  clk,
  input  logic  rst_n,
  input  logic  vld_i,
  output logic  vld_o
);

`ifndef DELAY_CK_Q
  // `define DELAY_CK_Q #1
`endif

generate
  if(PIPELINE_EN) begin : PIPELINE
    always_ff@(posedge clk, negedge rst_n) begin
      if(!rst_n)
        vld_o <= 1'b0;
      else
        vld_o <= `DELAY_CK_Q vld_i;
    end
  end
  else begin: NO_PIPELINE
    always_comb begin
      vld_o = vld_i;
    end
  end
endgenerate

endmodule : hams_pipevld