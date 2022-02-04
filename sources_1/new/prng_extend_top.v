`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 01:23:00
// Design Name: 
// Module Name: prng_extend_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module prng_extend_top(
    clk,
    rstn,
    load_seed,
    data_in,
    data_out,
    get_random
);

/////////////////////////////////////////////////////////////////////////////////
//  I/O
/////////////////////////////////////////////////////////////////////////////////
input               clk;
input               rstn;
input               load_seed;
input       [7:0]   data_in;
input               get_random;
output      [7:0]   data_out;

wire        [7:0]   data_in;
wire        [7:0]   data_out;
/////////////////////////////////////////////////////////////////////////////////
// def 
/////////////////////////////////////////////////////////////////////////////////
wire        [31:0]  lfsr;
wire                data_done;
wire        [1:0]   cnt;
wire        [31:0]  seed;
/////////////////////////////////////////////////////////////////////////////////
// fsm 
/////////////////////////////////////////////////////////////////////////////////
assign      data_done = cnt == 2'b11;   
wire        [1:0]   state;

parameter   IDLE = 2'b00;
parameter   SHIFT = 2'b01;
parameter   DATAOUT = 2'b10;
parameter   SEEDLOAD = 2'b11;
wire        state_shift = state == SHIFT;
wire        state_dataout = state == DATAOUT;
wire        state_seedload = state == SEEDLOAD;

extend_fsm _extend_fsm(
    .clk            (clk            ),
    .rstn           (rstn           ),
    .load_seed      (load_seed      ),
    .data_done      (data_done      ),
    .get_random     (get_random     ),
    .state          (state          )
);


/////////////////////////////////////////////////////////////////////////////////
// lfsr 
/////////////////////////////////////////////////////////////////////////////////
assign seed = cnt == 2'd0
            ? 32'd0 | data_in
            : (lfsr << 4'd8) | data_in;

prng_lfsr _prng_lfsr(
    .clk            (clk            ),
    .rstn           (rstn           ),
    .seed_load      (state_seedload ),
    .seed           (seed           ),
    .shift_en       (state_shift    ),
    .lfsr           (lfsr           )
);

/////////////////////////////////////////////////////////////////////////////////
// counter 
/////////////////////////////////////////////////////////////////////////////////
prng_counter _prng_counter(
    .clk            (clk                            ),   
    .rstn           (rstn                           ),
    .cnt_en         (state_dataout | state_seedload ),
    .cnt            (cnt                            )
);

/////////////////////////////////////////////////////////////////////////////////
// output 
/////////////////////////////////////////////////////////////////////////////////
assign data_out = state_dataout ? lfsr >> {cnt,3'b0} : 8'b0;




endmodule
