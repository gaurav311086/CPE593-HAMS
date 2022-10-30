# Hardware Accelerated Merge Sorting
# CPE593-HAMS

This repo contains HDL implementation of harware accelerated merge sort algorithm in FPGA using high-performance vector stream processing. 

Repository structure:
```bash
.
├── Makefile
├── README.md
├── doc
│   ├── Hardware_accelerated_sorting.pdf
│   ├── ref
│   └── tools
│       └── verilator_doc.pdf
├── model
│   └── hams.cc
├── rtl
│   └── systemverilog
│       ├── hams_Mele_sort.sv
│       └── hams_pkg.vh
├── setup.sh
└── tb
    ├── tb_top.sv
    └── tool
        ├── Makefile_obj
        ├── input.vc
        └── tb_top.cc
```

To run simulation:
  1. make sim
  2. using gtkwave open simulation dump (vcd file) located in ./out/build/logs/
  