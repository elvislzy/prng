`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 02:04:12
// Design Name: 
// Module Name: extend_fsm
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


module extend_fsm(
    clk,
    rstn,
    load_seed,
    data_done,
    get_random,
    state
);

input               clk;
input               rstn;
input               load_seed;
input               data_done;
input               get_random;
output  reg [1:0]   state;

parameter   IDLE = 2'b00;
parameter   SHIFT = 2'b01;
parameter   DATAOUT = 2'b10;
parameter   SEEDLOAD = 2'b11;

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
            else if(load_seed)
                next_state = SEEDLOAD;
            else
                next_state = SHIFT;
        end
        SHIFT: begin
            if(!rstn)
                next_state = IDLE;
            else if(get_random)
                next_state = DATAOUT;
            else if(load_seed)
                next_state = SEEDLOAD;
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
        SEEDLOAD: begin
            if(!rstn)           
                next_state = IDLE;
            else if(data_done)           
                next_state = SHIFT;
            else
                next_state = SEEDLOAD;
        end

    endcase            
end

endmodule
