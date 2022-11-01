package hams_pkg;
  typedef struct packed {
    // logic [63:0] cpp_pointer;
    // logic [31:0] reserved;
    logic [31:0] info;
  } pair;
  typedef struct packed {
    // logic [2:0] local_index;
    logic [31:0] info;
  } pair_lite;

  function automatic integer countones(input logic[NUM_BITONIC_LAYER-1:0] in);
    begin
      countones = 0;
      for(int i=0;i<NUM_BITONIC_LAYER;i++)
        countones+={31'b0,in[i]};
    end
  endfunction
  
  localparam NUM_ELEMENTS = 8;
  localparam NUM_BITONIC_LAYER = $clog2(NUM_ELEMENTS)*($clog2(NUM_ELEMENTS)+1)/2;
  localparam logic [NUM_BITONIC_LAYER -1 : 0] PIPELINE_ENA_STAGES = '0;
  localparam integer PIPELINES = countones(PIPELINE_ENA_STAGES);
endpackage
