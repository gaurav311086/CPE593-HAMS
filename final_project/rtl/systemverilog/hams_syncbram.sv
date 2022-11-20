module hams_syncbram 
#(
  parameter DATA_DEPTH = 16,
  parameter DATA_WIDTH = 8,
  parameter OUT_PIPELINE_ENA = 1'b0,
  parameter INIT_VAL_FILE = ""
)
(
  input   logic clk,
  input   logic wr_en,
  input   logic [DATA_WIDTH -1 : 0] wr_data,
  input   logic [$clog2(DATA_DEPTH+1) -1 : 0] addr,
  output  logic [DATA_WIDTH -1 : 0] rd_data
);
`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif
`ifdef SIMULATION
  logic [DATA_WIDTH -1 : 0] bram_memory [0:DATA_DEPTH - 1] ;
`else
  logic [DATA_DEPTH - 1: 0] [DATA_WIDTH -1 : 0] bram_memory;
`endif
  
  genvar i;
  generate
    for(i=0;i<DATA_DEPTH;i++) begin
      always_ff@(posedge clk) begin
        if(i==addr && wr_en)
          bram_memory[i]  <= `DELAY_CK_Q wr_data;
      end
    end
    if(OUT_PIPELINE_ENA) begin : opipelined
      always_ff@(posedge clk) begin
        rd_data <=  `DELAY_CK_Q bram_memory[addr];
      end      
    end
    else begin : onotpiplined
      always_comb
        rd_data = bram_memory[addr];
    end
  endgenerate
  
`ifdef SIMULATION
initial $readmemh(INIT_VAL_FILE,bram_memory);
`endif
endmodule : hams_syncbram