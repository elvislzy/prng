`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/23 16:51:18
// Design Name: 
// Module Name: prng_tb1
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


module prng_tb1;

parameter PERIOD   = 10         ;
parameter seed     = 32'h02468acd;

//I/O
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   get_random                           = 0 ;

wire  [7:0]  data_out                      ;


//file flag
integer data_cnt = 0;
reg [31:0] file_dout;
reg [31:0] file_tmp;
reg [31:0] dout = 32'd0;
integer file_pointer;


//clk
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

//rstn
initial
begin
    #(PERIOD*3) rstn  =  1;
end

//instance
prng_top u_prng_top(
    .clk                    (clk               ),
    .rstn                   (rstn              ),
    .get_random             (get_random        ),
    .data_out               (data_out          )
);

reg [2:0] get_cnt = 3'd0;
//period get random
initial
begin
    forever begin
        if(!rstn) begin
            get_cnt = 3'd0;
            get_random = 1'b0;
            #(PERIOD*1);
        end
        else if(get_cnt == 3'd0)begin
            get_random = 1'b1;
            get_cnt = get_cnt + 1'b1;
        end
        else begin
            get_cnt = get_cnt + 1'b1;
            get_random = 1'b0;
            if(get_cnt == 3'd5)
                get_cnt = 3'd0;
        end
        #(PERIOD*1);
       // #(PERIOD*4)                
       // get_random = 1'b1;
       // #(PERIOD*1)
       // get_random = 1'b0;
    end
end

//rstn test
reg     rstn_flag = 1'b0;

initial begin
    #(PERIOD*500)
    rstn = 1'b0;
    #(PERIOD*1)
    rstn = 1'b1;
end

initial begin
    forever begin
        if(!rstn) begin 
            rstn_flag = 1'b1;
        end 
        #(PERIOD*1);
    end
end

initial begin
    //open txt file
    file_pointer= $fopen("default_seed.txt","r");
    if(file_pointer==0) begin
        $display("Can't open the file.");
        $finish;
    end
    
    $fscanf(file_pointer,"%h",file_dout);

    //read file
    while (!$feof(file_pointer)) begin
        if(rstn_flag) begin
            @(posedge rstn);
        end
        else begin
            @(posedge get_random);
        end
        @(posedge clk);
        #1;
        dout = 32'd0;

        $fseek(file_pointer,-8,1);               //set the file_pointer to the previous line(32 bits = 8 bytes)
        $fscanf(file_pointer,"%h",file_dout);
        $fscanf(file_pointer,"%h",file_tmp);     //the txt will have a blank line at the end of the file(since i use /n to divide each data)
                                                 //this line is to let the pointer point to the next two line 
                                                 //so that the while loop would be able to stop at the right position 

        //load data from prng
        while(data_cnt <= 3 &(!rstn_flag))begin
            dout = dout>>{1'b1,3'b0}^{data_out,24'd0};
            data_cnt = data_cnt + 1'b1;
            #(PERIOD*1); 
        end

        //test
        if(rstn_flag) begin
            rstn_flag = 1'b0;
            $fseek(file_pointer,0,0);
        end
        else begin
            if(dout!=file_dout) begin
                $fatal("Test Case failed!"); 
                $finish;
            end
        end
        data_cnt = 0;
    end

    $fclose(file_pointer);
    $display("All test case passed successfully!");
    $finish;
end

endmodule
