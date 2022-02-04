`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/23 15:37:59
// Design Name: 
// Module Name: prng_counter
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


module prng_counter(
    clk,
    rstn,
    cnt_en,
    cnt
);

input                   clk;
input                   rstn;
input                   cnt_en;
output  reg     [1:0]   cnt;


always @(posedge clk or negedge rstn) begin
    if(!rstn)
        cnt <= 2'b0;
    else if(cnt_en)
        cnt <= cnt + 1'b1;
end

endmodule
