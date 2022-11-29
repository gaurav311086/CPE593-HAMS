import hams_pkg::*;
module hams_merge_sort_colq_ctrl 
#(
  parameter NUM_MEM = 4,
  parameter ADDR_WIDTH = 10
)
(
  input   logic                                 clk,
  input   logic                                 rst_n,
  input   logic                                 fifo_full,
  input   logic                                 fifo_empty,
  input   logic                                 start,
  input   logic                                 pause,
  input   logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  init,
  input   logic               [ADDR_WIDTH-1:0]  stride,
  input   logic               [ADDR_WIDTH-1:0]  loop_limit,
  input   logic               [ADDR_WIDTH:0]    stride_limit,
  output  logic                                 done,
  output  logic                                 fifo_pop,
  output  logic                                 fifo_push,
  output  logic [NUM_MEM-1:0]                   mem_wr,
  output  logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr
);
`ifndef DELAY_CK_Q
  `define DELAY_CK_Q #1
`endif


logic [NUM_MEM-1:0] [ADDR_WIDTH-1:0]  mem_addr_o;
logic [ADDR_WIDTH-1:0]  loop_cnt_i;
logic [ADDR_WIDTH:0]  stride_rd;
logic [ADDR_WIDTH:0]  stride_wr;
logic  read_done;
logic  write_now;

always_ff @(posedge clk) begin
  if(!pause) begin
    if(start) begin
      loop_cnt_i    <=  `DELAY_CK_Q '0;
    end
    else if (!fifo_full && !read_done && !write_now) begin
      if(loop_cnt_i==loop_limit-1)
        loop_cnt_i  <=  `DELAY_CK_Q '0;
      else
        loop_cnt_i  <= `DELAY_CK_Q loop_cnt_i + 1;
    end
  end
end
logic fifo_push_i;
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    fifo_push_i <= `DELAY_CK_Q '0;
  end
  else begin
    if(!pause) begin
      if(start) begin
        fifo_push_i   <= `DELAY_CK_Q '1;
      end
      else if (!fifo_full && !read_done && !write_now) begin
        if(loop_cnt_i==loop_limit-1)
          fifo_push_i <= `DELAY_CK_Q '0;
      end
      else if(write_now && !fifo_empty && (mem_addr_o[0]==stride_wr-1))
        fifo_push_i <= `DELAY_CK_Q '1;
    end
  end
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    fifo_push <= `DELAY_CK_Q '0;
  end
  else begin
    if(!pause) begin
      fifo_push <= `DELAY_CK_Q fifo_push_i;
    end
  end
end

always_ff @(posedge clk) begin
  if(!pause) begin
    if(start) begin
      stride_rd    <=  `DELAY_CK_Q {'0,stride};
    end
    else if (write_now && !fifo_empty && (mem_addr_o[0]==stride_wr-1)) begin
      stride_rd  <=  `DELAY_CK_Q stride_rd+stride;
    end
  end
end

always_ff @(posedge clk) begin
  if(!pause) begin
    if(start) begin
      stride_wr    <=  `DELAY_CK_Q {'0,stride};
    end
    else if ((write_now && !fifo_empty) && (mem_addr_o[0]==stride_wr-1)) begin
      stride_wr  <=  `DELAY_CK_Q stride_wr+stride;
    end
  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    write_now <=`DELAY_CK_Q '0;
  else begin
    if(!pause) begin
      if(start || ((write_now && !fifo_empty) && (mem_addr_o[0]==stride_wr-1)))
        write_now <=`DELAY_CK_Q '0;
      else if((loop_cnt_i==loop_limit-1))
        write_now <=`DELAY_CK_Q 1'b1;
    end
  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    read_done <=`DELAY_CK_Q '0;
  else begin
    if(!pause) begin
      if(start)
        read_done <=`DELAY_CK_Q '0;
      else if((stride_rd==stride_limit) && (loop_cnt_i==loop_limit-1))
        read_done <=`DELAY_CK_Q 1'b1;
    end
  end
end

always_ff @(posedge clk) begin
  if(!pause) begin
    if(start) begin
      for(int i=0;i<NUM_MEM;i++)
        mem_addr_o[i] <= `DELAY_CK_Q  init[i];
    end else if (!fifo_full && !write_now && (loop_cnt_i==loop_limit-1)) begin
      for(int i=0;i<NUM_MEM;i++) 
        mem_addr_o[i] <= `DELAY_CK_Q  init[0] + stride_wr - stride;
    end else if((write_now && !fifo_empty) && (mem_addr_o[0]==stride_wr-1) ) begin
      for(int i=0;i<NUM_MEM;i++) 
        mem_addr_o[i] <=  `DELAY_CK_Q  init[i] + stride_rd;
    end else if ((!fifo_full && !read_done && !write_now) || (write_now && !fifo_empty)) begin
      for(int i=0;i<NUM_MEM;i++) begin
        mem_addr_o[i] <= `DELAY_CK_Q  mem_addr_o[i] + 1;
      end
    end
  end
end

assign mem_addr = mem_addr_o;
assign mem_wr = {NUM_MEM{write_now}};
assign done = (write_now && !fifo_empty) && read_done && (mem_addr_o[0]==stride_wr-1);
assign fifo_pop = write_now && !pause;
endmodule : hams_merge_sort_colq_ctrl