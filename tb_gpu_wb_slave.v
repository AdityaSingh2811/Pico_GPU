`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2026 02:13:44 PM
// Design Name: 
// Module Name: tb_gpu_wb_slave
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


module tb_gpu_wb_slave;
// -------------------------------------------------------------------------
    // 1. Declare Signals to connect to the Device Under Test (DUT)
    // -------------------------------------------------------------------------
    reg clk; 
    reg rst;
    
    //Wishbone Master Signals (We drive these)
    reg wb_cyc;
    reg wb_stb;
    reg wb_we;
    reg [31:0] wb_adr;
    reg [31:0] wb_dat_i; //Data Going to the slave
    
    //Wishbone Slave signals (we read these)
    wire [31:0] wb_dat_o; //Data Coming from the slave 
    wire wb_ack;
    
    //Internal GPU Registers(To check if the logic worked) 
    wire[31:0] status;
    wire[31:0] ctrl;
    wire[15:0] reg_x;
    wire[15:0] reg_y;
    // -------------------------------------------------------------------------
    // 2. Instantiate the DUT (Device Under Test)
    // -------------------------------------------------------------------------
    gpu_wb_slave #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(32)
    ) dut (
    .clk_i(clk),
    .rst_i(rst),
    .wb_cyc_i(wb_cyc),
    .wb_stb_i(wb_stb),
    .wb_we_i(wb_we),
    .wb_adr_i(wb_adr),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_ack_o(wb_ack),
    .reg_status_o(status),
    .reg_ctrl_o(ctrl),
    .reg_x_o(reg_x),
    .reg_y_o(reg_y)
    );
    // -------------------------------------------------------------------------
    // 3. Clock Generation (100 MHz = 10ns period)
    // -------------------------------------------------------------------------
    always #5 clk = ~clk;
    // -------------------------------------------------------------------------
    // 4. Helper Tasks (To make the test code readable)
    // -------------------------------------------------------------------------
    
    //Task is to write to the register
    task wb_write(input [31:0] addr, input [31:0] data);
    begin 
    @(posedge clk);
    wb_cyc<= 1;
    wb_stb<=1;
    wb_we<=1;
    wb_adr<=addr;
    wb_dat_i<=data;
    
    //Wait for acknowledge
    
    wait(wb_ack==1);
    
    @(posedge clk); //We wait for one clock cycle
     wb_cyc<=0;
    wb_stb<=0;
    wb_we<=0;
    @(posedge clk);//Gap between transactions
    
    end 
    endtask
    
    //Next task is to read from the Register
    task wb_read(input[31:0] addr);
    begin
    @(posedge clk);
    wb_cyc<= 1;
    wb_stb<=1;
    wb_we<=0; //Read mode
    wb_adr<=addr;
    
    wait(wb_ack==1);
    
    //Sample data upon Ack
    
    $display("Read address :%h| Data : %h", addr, wb_dat_o);
    
    @(posedge clk);
    wb_cyc<=0;
    wb_stb<=0;
    @(posedge clk);
    end 
    endtask
// -------------------------------------------------------------------------
    // 5. Main Test Sequence
    // -------------------------------------------------------------------------
initial begin
clk=0;
rst=1;
wb_cyc=0; 
wb_stb=0;
wb_we=0;
wb_adr=0;
wb_dat_i=0;

#20 rst=0;
#20;
$display("Begin-------Simulation-------");

//Test 1: Write to control Register
$display("Writing 0XCAFEBABE to control register...");
wb_write(32'h0000_0004, 32'hCAFEBABE);

//Check if the DUT is updated its internal register
if(ctrl==32'hCAFEBABE) $display("SUCCESS: Control register Updated");
else $display("FAILURE: Expected CAFEBABE, got %h)", ctrl);

//Test 2: Write X and Y coordinates
wb_write(32'h0000_0008, 32'h0000_0140); //X=320
wb_write(32'h0000_000C, 32'h0000_00F0); //Y=240

//Test 3: Read back the X coordinate
$display("Reading the X coordinate");
wb_read(32'h0000_0008);

//Test 4: Try to write to Status register (Should Fail/ Do nothing)
//Status is at 0x00 and is Read-only 
wb_write(32'h0000_0000, 32'hFFFF_FFFF);

#50;
$display("--- Simulation Complete ---");
        $finish;
    end

endmodule
       
       
    
    
    
    
    

