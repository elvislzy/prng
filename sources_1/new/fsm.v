`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 01:24:55
// Design Name: 
// Module Name: fsm
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


module fsm(
    clk,
    rstn,
    data_done,
    get_random,
    state
);

input               clk;
input               rstn;
input               data_done;
input               get_random;
output  reg [1:0]   state;

parameter   IDLE = 2'b00;
parameter   SHIFT = 2'b01;
parameter   DATAOUT = 2'b10;

reg         [1:0]   next_state;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case(state)
        IDLE: begin
            if(!rstn)
                next_state = IDLE;
            else if(get_random)
                next_state = DATAOUT;
            else
                next_state = SHIFT;
        end
        SHIFT: begin
            if(!rstn)
                next_state = IDLE;
            else if(get_random)
                next_state = DATAOUT;
            else
                next_state = SHIFT;
        end
        DATAOUT: begin
            if(!rstn)
                next_state = IDLE;
            else if(data_done)
                next_state = SHIFT;
            else
                next_state = DATAOUT;
        end
        default:
            next_state = IDLE;
    endcase            
end

endmodule
