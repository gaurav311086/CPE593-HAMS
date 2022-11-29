import hams_pkg::*;
module hams_4to1_merge_sort 
#(
  parameter MERGE_COLUMNS = 4,
  parameter FIFO_DEPTH = 2**10
)
(
  input   logic                                 clk,
  input   logic                                 rst_n,
  input   logic                                 fifo_pop,
  input   logic [NUM_ELEMENTS-1:0]              col_ena,
  input   logic [NUM_ELEMENTS-1:0]              colDataVld,
  input   pair  [NUM_ELEMENTS-1:0]              colData,
  output  logic                                 fifo_full,
  output  logic                                 fifo_empty,
  output  pair                                  sort_data_o 
);
`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif
pair colA_data,colB_data,colC_data,colD_data;
pair colA_dataO,colB_dataO,colC_dataO,colD_dataO;
logic colA_pop,colB_pop,colC_pop,colD_pop;
logic colA_empty,colB_empty,colC_empty,colD_empty;
logic colA_full,colB_full,colC_full,colD_full;
pair colAA_data,colBB_data,colAA_dataO,colBB_dataO;
logic colAA_empty,colBB_empty;
logic colAA_full,colBB_full;
pair colO_data,colO_dataO;
logic colAA_pop,colBB_pop;
logic colO_empty,colO_full;

assign colA_pop = (!colA_empty && col_ena[0] && !colAA_full && (colData[0].info < colData[1].info));
assign colB_pop = (!colB_empty && col_ena[1] && !colAA_full && (colData[1].info < colData[0].info));
assign colC_pop = (!colA_empty && col_ena[2] && !colBB_full && (colData[2].info < colData[3].info));
assign colD_pop = (!colB_empty && col_ena[3] && !colBB_full && (colData[3].info < colData[2].info));
assign colAA_data = colA_pop ? colA_dataO : colB_dataO;
assign colBB_data = colC_pop ? colC_dataO : colD_dataO;
assign colAA_pop = (!colAA_empty && !colO_full && (colAA_dataO.info < colBB_dataO.info));
assign colBB_pop = (!colBB_empty && !colO_full && (colAA_dataO.info < colBB_dataO.info));
assign colO_data = colAA_pop ? colAA_dataO : colBB_dataO;
assign fifo_full = (colA_full || colB_full || colC_full || colD_full);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/4),
  .FIFO_WIDTH($bits(pair))
) colA
(
  .clk,
  .rst_n,
  .push(colDataVld[0]),
  .pop(colA_pop),
  .push_data(colData[0]),
  .pop_data(colA_dataO),
  .empty(colA_empty),
  .full(colA_full),
  .enteries()
);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/4),
  .FIFO_WIDTH($bits(pair))
) colB
(
  .clk,
  .rst_n,
  .push(colDataVld[1]),
  .pop(colB_pop),
  .push_data(colData[1]),
  .pop_data(colB_dataO),
  .empty(colB_empty),
  .full(colB_full),
  .enteries()
);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/4),
  .FIFO_WIDTH($bits(pair))
) colC
(
  .clk,
  .rst_n,
  .push(colDataVld[2]),
  .pop(colC_pop),
  .push_data(colData[2]),
  .pop_data(colC_dataO),
  .empty(colC_empty),
  .full(colC_full),
  .enteries()
);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/4),
  .FIFO_WIDTH($bits(pair))
) colD
(
  .clk,
  .rst_n,
  .push(colDataVld[3]),
  .pop(colD_pop),
  .push_data(colData[3]),
  .pop_data(colD_dataO),
  .empty(colD_empty),
  .full(colD_full),
  .enteries()
);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/8),
  .FIFO_WIDTH($bits(pair))
) colAA
(
  .clk,
  .rst_n,
  .push(colA_pop || colB_pop),
  .pop(colAA_pop),
  .push_data(colAA_data),
  .pop_data(colAA_dataO),
  .empty(colAA_empty),
  .full(colAA_full),
  .enteries()
);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/8),
  .FIFO_WIDTH($bits(pair))
) colBB
(
  .clk,
  .rst_n,
  .push(colC_pop || colD_pop),
  .pop(colBB_pop),
  .push_data(colBB_data),
  .pop_data(colBB_dataO),
  .empty(colBB_empty),
  .full(colBB_full),
  .enteries()
);
hams_syncfifo 
#(
  .FIFO_DEPTH(FIFO_DEPTH/16),
  .FIFO_WIDTH($bits(pair))
) colO
(
  .clk,
  .rst_n,
  .push(colAA_pop || colBB_pop),
  .pop(fifo_pop),
  .push_data(colO_data),
  .pop_data(colO_dataO),
  .empty(colO_empty),
  .full(colO_full),
  .enteries()
);
assign sort_data_o = colO_dataO;
assign fifo_empty = colO_empty;
endmodule : hams_4to1_merge_sort