package hams_pkg;
  typedef struct {
    logic [63:0] cpp_pointer;
    logic [31:0] reserved;
    logic [31:0] info;
  } pair;
  typedef struct {
    logic [2:0] local_index;
    logic [31:0] info;
  } pair_lite;
endpackage
