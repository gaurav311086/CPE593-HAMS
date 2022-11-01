# Hardware Accelerated Merge Sorting
# CPE593-HAMS

This repo contains HDL implementation of harware accelerated merge sort algorithm in FPGA using high-performance vector stream processing. 

Repository structure:
```bash
./
├── Makefile                                (contains target to run lint, and run simulation)
├── README.md                               (this file::read me)
├── doc                                     (supporting documentation)
│   ├── Hardware_accelerated_sorting.pdf    (presentation of the project)
│   ├── ref                                 (reference paper, application notes)
│   └── tools                               (tool related documentation)
│       └── verilator_doc.pdf               (verilator - documentation)
├── model                                   (C++ merge sort implementation, this will be used to check logic equivalence)
│   └── hams.cc
├── rtl                                     (Digital implementation)
│   └── systemverilog
│       ├── hams_pipevld.sv
│       ├── hams_pkg.vh
│       ├── hams_sort2elem.sv
│       └── hams_sortNelem.sv
├── setup.sh                                (source this file to setup environment--this is the first step)
└── tb                                      (Digital logic testbench files)
    ├── tb_top.sv
    └── tool                                (specific to tool, applicable to verilator only)
        ├── Makefile_obj
        ├── input.vc
        └── tb_top.cc

8 directories, 14 files
```

To run simulation:
  1. make sim
  2. using gtkwave open simulation dump (vcd file) located in ./out/build/logs/
  
