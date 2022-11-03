# CPE593
#Group members: Gaurav Dubey & Michael Salek

This repo contains HDL implementation of harware accelerated merge sort algorithm in FPGA using high-performance vector stream processing. 

Repository structure:
```bash
README.md
├── final_project
│   ├── Makefile
│   ├── README.md
│   ├── doc
│   │   ├── Hardware_accelerated_sorting.pdf
│   │   ├── ref
│   │   └── tools
│   │       └── verilator_doc.pdf
│   ├── model
│   │   └── hams.cc
│   ├── rtl
│   │   └── systemverilog
│   │       ├── hams_pipevld.sv
│   │       ├── hams_pkg.vh
│   │       ├── hams_sort2elem.sv
│   │       ├── hams_sortNelem.sv
│   │       └── hams_syncfifo.sv
│   ├── setup.sh
│   └── tb
│       ├── tb_top.sv
│       └── tool
│           ├── Makefile_obj
│           ├── input.vc
│           └── tb_top.cc
└── mini_project_01

10 directories, 16 files
```
