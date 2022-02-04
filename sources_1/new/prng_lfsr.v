`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/23 15:33:39
// Design Name: 
// Module Name: prng_lfsr
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


module prng_lfsr(
    clk,
    rstn,
    seed_load,
    seed,
    shift_en,
    lfsr
);

input                   clk;
input                   rstn;
input                   seed_load;
input   wire    [31:0]  seed;
input                   shift_en;
output  reg     [31:0]  lfsr;

//////////////////////////////////////////////////////////////////////////////////
//xorshift
//////////////////////////////////////////////////////////////////////////////////
wire                    msb;
wire            [31:0]  r_tmp;
assign msb = lfsr[0]^lfsr[1]^lfsr[7]^lfsr[12]^lfsr[14]^lfsr[15]^lfsr[29]^lfsr[30];
assign r_tmp = {msb,lfsr[31:1]};

//////////////////////////////////////////////////////////////////////////////////
//reg
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        lfsr <= 32'h02468acd;
    else if (seed_load)
        lfsr <= seed;
    else if(shift_en)
        lfsr <= r_tmp; 
end


endmodule
