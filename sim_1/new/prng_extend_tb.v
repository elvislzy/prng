`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 10:37:42
// Design Name: 
// Module Name: prng_extend_tb
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


module prng_extend_tb;
parameter PERIOD    = 10   ;
parameter RSTN_TIME = PERIOD*7400;      //set reset time
//parameter seed      = 32'h02468acd;
parameter seed      = 32'h830ADB1C;

//I/O
reg             clk         = 0; 
reg             rstn        = 0;
reg             load_seed   = 0;
reg     [7:0]   data_in     = 0;
reg             get_random  = 0;

wire    [7:0]   data_out;   

//file flag
integer         data_cnt    = 0;
reg     [31:0]  file_dout   = 32'd0;
reg     [31:0]  file_tmp    = 32'd0;
reg     [31:0]  dout        = 32'd0;
integer         file_pointer;

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
prng_extend_top u_prng_extend_top (
    .clk                     (clk               ),
    .rstn                    (rstn              ),
    .load_seed               (load_seed         ),
    .data_in                 (data_in           ),
    .get_random              (get_random        ),
    .data_out                (data_out          )
);


///////////////////////////////////////////////////////////////////       
//rstn test
////////////////////////////////////////////////////////////////////  
reg     rstn_flag = 1'b0;
reg [2:0] get_cnt = 3'd0;

//set reset time
initial begin
    #(RSTN_TIME)
    rstn = 1'b0;
    #(PERIOD*1)
    rstn = 1'b1;
end

//gererate rstn flag
initial begin
    forever begin
        if(!rstn) begin 
            rstn_flag = 1'b1;
            $fclose(file_pointer);                          //reset test file
            file_pointer= $fopen("default_seed.txt","r"); 
            $fscanf(file_pointer,"%h",file_dout);
        end 
        #(PERIOD*1);
    end
end

///////////////////////////////////////////////////////////////////       
//Default seed test     
////////////////////////////////////////////////////////////////////    
//period get random
initial
begin

    while (!$feof(file_pointer)) begin
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
    end
    get_cnt = 3'd0;
    get_random = 1'b0;

    //load seed flag
    #(PERIOD*10)
    data_in = seed[31:24];
    #(PERIOD*5)
    load_seed = 1'b1;
    #(PERIOD*1)
    load_seed = 1'b0;   
end

//read file
initial begin
    //open txt file
    file_pointer= $fopen("default_seed.txt","r");
    if(file_pointer==0) begin
        $display("Can't open the file.");
        $finish;
    end
    
    $fscanf(file_pointer,"%h",file_dout);
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

        //compare output
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
    $display("All default seed test cases passed successfully!");

    //reset reg
    data_cnt = 0;
    file_dout = 32'd0;
    file_tmp = 32'd0;
    dout = 32'd0;
end

///////////////////////////////////////////////////////////////////       
//Custom seed test     
////////////////////////////////////////////////////////////////////    
integer i = 0;
reg [31:0]  seed_shift;

//period get random
initial
begin
    //load seed
    @(posedge load_seed);
    #(PERIOD*1);
    while(i  <= 3 ) begin
        seed_shift = seed << {i,3'b0};
        data_in = seed_shift[31:24];
        i = i + 1;
        #(PERIOD*1);
    end

    //generate get random
    while (!$feof(file_pointer)) begin
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
    end

end

//read file 
initial begin
    @(posedge load_seed);
    file_pointer= $fopen("830ADB1C.txt","r"); 
    if(file_pointer==0) begin
        $display("Can't open the file.");
        $finish;
    end
   
    $fscanf(file_pointer,"%h",file_dout);
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
        while(data_cnt <= 3 &(rstn))begin
            dout = dout>>{1'b1,3'b0}^{data_out,24'd0};
            data_cnt = data_cnt + 1'b1;
            #(PERIOD*1); 
        end
    
        //Compare output
        if(rstn_flag) begin
            rstn_flag = 1'b0;
            
            //$fseek(file_pointer,0,0);
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
    $display("All custom seed test cases passed successfully!");
    $display("seed = %h",seed); 
    $finish;
end

endmodule
