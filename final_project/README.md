# Hardware Accelerated Merge Sorting
# CPE593-HAMS

This repo contains HDL implementation of harware accelerated merge sort algorithm in FPGA using high-performance vector stream processing. 

Repository structure:
```bash
./
├── Makefile
├── README.md
├── doc
│   ├── README.md
│   ├── overleaf
│   │   ├── Hardware_Accelerated_Merge_Sort.pdf
│   │   ├── README.md
│   │   ├── animation_files
│   │   │   ├── Hardware_accelerated_sorting.pdf
│   │   │   ├── SINGLE.gif
│   │   │   ├── address
│   │   │   │   ├── ad-1.png
│   │   │   │   ├── ad-2.png
│   │   │   │   ├── ad-3.png
│   │   │   │   ├── ad-4.png
│   │   │   │   ├── ad-5.png
│   │   │   │   ├── ad-6.png
│   │   │   │   ├── ad-7.png
│   │   │   │   └── ad-8.png
│   │   │   ├── address.mp4
│   │   │   ├── address.pptx
│   │   │   ├── address_parallel
│   │   │   │   ├── Slide1.PNG
│   │   │   │   ├── Slide10.PNG
│   │   │   │   ├── Slide11.PNG
│   │   │   │   ├── Slide12.PNG
│   │   │   │   ├── Slide13.PNG
│   │   │   │   ├── Slide14.PNG
│   │   │   │   ├── Slide15.PNG
│   │   │   │   ├── Slide16.PNG
│   │   │   │   ├── Slide17.PNG
│   │   │   │   ├── Slide18.PNG
│   │   │   │   ├── Slide19.PNG
│   │   │   │   ├── Slide2.PNG
│   │   │   │   ├── Slide3.PNG
│   │   │   │   ├── Slide4.PNG
│   │   │   │   ├── Slide5.PNG
│   │   │   │   ├── Slide6.PNG
│   │   │   │   ├── Slide7.PNG
│   │   │   │   ├── Slide8.PNG
│   │   │   │   └── Slide9.PNG
│   │   │   ├── address_parallel.pptx
│   │   │   ├── address_serial
│   │   │   │   ├── address_serial1.PNG
│   │   │   │   ├── address_serial10.PNG
│   │   │   │   ├── address_serial11.PNG
│   │   │   │   ├── address_serial12.PNG
│   │   │   │   ├── address_serial13.PNG
│   │   │   │   ├── address_serial14.PNG
│   │   │   │   ├── address_serial15.PNG
│   │   │   │   ├── address_serial16.PNG
│   │   │   │   ├── address_serial17.PNG
│   │   │   │   ├── address_serial18.PNG
│   │   │   │   ├── address_serial19.PNG
│   │   │   │   ├── address_serial2.PNG
│   │   │   │   ├── address_serial20.PNG
│   │   │   │   ├── address_serial21.PNG
│   │   │   │   ├── address_serial22.PNG
│   │   │   │   ├── address_serial23.PNG
│   │   │   │   ├── address_serial24.PNG
│   │   │   │   ├── address_serial25.PNG
│   │   │   │   ├── address_serial26.PNG
│   │   │   │   ├── address_serial27.PNG
│   │   │   │   ├── address_serial28.PNG
│   │   │   │   ├── address_serial29.PNG
│   │   │   │   ├── address_serial3.PNG
│   │   │   │   ├── address_serial30.PNG
│   │   │   │   ├── address_serial31.PNG
│   │   │   │   ├── address_serial32.PNG
│   │   │   │   ├── address_serial33.PNG
│   │   │   │   ├── address_serial4.PNG
│   │   │   │   ├── address_serial5.PNG
│   │   │   │   ├── address_serial6.PNG
│   │   │   │   ├── address_serial7.PNG
│   │   │   │   ├── address_serial8.PNG
│   │   │   │   ├── address_serial9.PNG
│   │   │   │   └── this.sh
│   │   │   ├── address_serial.pptx
│   │   │   ├── bitonic_nwk.PNG
│   │   │   ├── fifo_network
│   │   │   │   ├── fifo_nwk
│   │   │   │   │   └── Slide1.PNG
│   │   │   │   └── fifo_nwk.PNG
│   │   │   ├── fifo_network.pptx
│   │   │   ├── hams.pptx
│   │   │   ├── hams_scheme.png
│   │   │   ├── merge_serial
│   │   │   │   ├── Slide1.PNG
│   │   │   │   ├── Slide2.PNG
│   │   │   │   ├── Slide3.PNG
│   │   │   │   ├── Slide4.PNG
│   │   │   │   ├── Slide5.PNG
│   │   │   │   ├── Slide6.PNG
│   │   │   │   ├── Slide7.PNG
│   │   │   │   ├── Slide8.PNG
│   │   │   │   ├── Slide9.PNG
│   │   │   │   ├── merge_serial1.PNG
│   │   │   │   ├── merge_serial2.PNG
│   │   │   │   ├── merge_serial3.PNG
│   │   │   │   ├── merge_serial4.PNG
│   │   │   │   ├── merge_serial5.PNG
│   │   │   │   ├── merge_serial6.PNG
│   │   │   │   ├── merge_serial7.PNG
│   │   │   │   ├── merge_serial8.PNG
│   │   │   │   ├── merge_serial9.PNG
│   │   │   │   └── this.sh
│   │   │   ├── merge_serial.pptx
│   │   │   ├── odd_even.pptx
│   │   │   └── odd_even_nwk.PNG
│   │   └── project_files
│   │       ├── ad-1.png
│   │       ├── ad-2.png
│   │       ├── ad-3.png
│   │       ├── ad-4.png
│   │       ├── ad-5.png
│   │       ├── ad-6.png
│   │       ├── ad-7.png
│   │       ├── ad-8.png
│   │       ├── address_serial1.PNG
│   │       ├── address_serial10.PNG
│   │       ├── address_serial11.PNG
│   │       ├── address_serial12.PNG
│   │       ├── address_serial13.PNG
│   │       ├── address_serial14.PNG
│   │       ├── address_serial15.PNG
│   │       ├── address_serial16.PNG
│   │       ├── address_serial17.PNG
│   │       ├── address_serial18.PNG
│   │       ├── address_serial19.PNG
│   │       ├── address_serial2.PNG
│   │       ├── address_serial20.PNG
│   │       ├── address_serial21.PNG
│   │       ├── address_serial22.PNG
│   │       ├── address_serial23.PNG
│   │       ├── address_serial24.PNG
│   │       ├── address_serial25.PNG
│   │       ├── address_serial26.PNG
│   │       ├── address_serial27.PNG
│   │       ├── address_serial28.PNG
│   │       ├── address_serial29.PNG
│   │       ├── address_serial3.PNG
│   │       ├── address_serial30.PNG
│   │       ├── address_serial31.PNG
│   │       ├── address_serial32.PNG
│   │       ├── address_serial33.PNG
│   │       ├── address_serial4.PNG
│   │       ├── address_serial5.PNG
│   │       ├── address_serial6.PNG
│   │       ├── address_serial7.PNG
│   │       ├── address_serial8.PNG
│   │       ├── address_serial9.PNG
│   │       ├── bitonic_nwk.PNG
│   │       ├── fifo_nwk.PNG
│   │       ├── hams_scheme.png
│   │       ├── impl3_animation
│   │       │   ├── Slide1.PNG
│   │       │   ├── Slide10.PNG
│   │       │   ├── Slide11.PNG
│   │       │   ├── Slide12.PNG
│   │       │   ├── Slide13.PNG
│   │       │   ├── Slide14.PNG
│   │       │   ├── Slide15.PNG
│   │       │   ├── Slide16.PNG
│   │       │   ├── Slide17.PNG
│   │       │   ├── Slide18.PNG
│   │       │   ├── Slide19.PNG
│   │       │   ├── Slide2.PNG
│   │       │   ├── Slide3.PNG
│   │       │   ├── Slide4.PNG
│   │       │   ├── Slide5.PNG
│   │       │   ├── Slide6.PNG
│   │       │   ├── Slide7.PNG
│   │       │   ├── Slide8.PNG
│   │       │   └── Slide9.PNG
│   │       ├── main.tex
│   │       ├── merge_sort_animation
│   │       │   ├── Slide1.PNG
│   │       │   ├── Slide2.PNG
│   │       │   ├── Slide3.PNG
│   │       │   ├── Slide4.PNG
│   │       │   ├── Slide5.PNG
│   │       │   ├── Slide6.PNG
│   │       │   ├── Slide7.PNG
│   │       │   ├── Slide8.PNG
│   │       │   └── Slide9.PNG
│   │       ├── odd_even_nwk.PNG
│   │       ├── references.bib
│   │       └── sample.bib
│   ├── presentation
│   │   └── Hardware_Accelerated_Sort_DUBEY_SALEK.pptx
│   ├── ref
│   ├── report
│   │   └── Hardware_Accelerated_Merge_Sort.pdf
│   ├── tools
│   │   └── verilator_doc.pdf
│   └── waveform.pdf
├── model
│   ├── BitonicSort.cpp
│   └── hams.cc
├── rtl
│   └── systemverilog
│       ├── hams_4to1_merge_sort.sv
│       ├── hams_bitonic_sort_ctrl.sv
│       ├── hams_bitonic_sort_top.sv
│       ├── hams_merge_sort_colq_ctrl.sv
│       ├── hams_merge_sort_ctrl.sv
│       ├── hams_merge_sort_top.sv
│       ├── hams_pipevld.sv
│       ├── hams_pkg.vh
│       ├── hams_sort2elem.sv
│       ├── hams_sortNelem.sv
│       ├── hams_syncbram.sv
│       ├── hams_syncfifo.sv
│       └── hams_top.sv
├── setup.sh
└── tb
    ├── tb_top.sv
    └── tool
        ├── Makefile_obj
        ├── input.vc
        ├── rtl.f
        └── tb_top.cc

21 directories, 201 files
```

Project requirements: 
Install modelsim.
Free version can be downloaded from https://www.intel.com/content/www/us/en/software-kit/750536/modelsim-intel-fpgas-pro-edition-software-version-20-3.html for linux and windows systems.

To run simulation:
  1. make vsim_debug
  
