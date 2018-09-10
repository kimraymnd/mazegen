//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 3/19/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter imem_init="imem_finalMaze.mem",		// correct filename inherited from parent/tester
    parameter dmem_init="dmem_finalMaze.mem",		// correct filename inherited from parent/tester
    parameter smem_init="smem_final16.mem",
    parameter bmem_init="bmem_final16.mem",
    parameter res = 1200,
    parameter dim = 16
)(
    input wire clk, reset,
    
    // keyboard
    input wire ps2_data, ps2_clk,
    
    // screen
    output wire [3:0] red, green, blue,
    output wire hsync, vsync,
    
    // audio
    output wire audPWM,
    output wire audEn,
    
    // accel
    output wire aclSCK,
    output wire aclMOSI,
    input wire aclMISO,
    output wire aclSS,
    
    // segmented display
    output wire [7:0] segments,
    output wire [7:0] digitselect,
    
    // LED
    output wire [15:0] LED
);
   
   wire [31:0] pc, instr, mem_readdata, mem_writedata, mem_addr;
   wire mem_wr;
   wire clk100, clk50, clk25, clk12;
   
   wire [31:0] period;
   wire [31:0] accel_val;
   wire [8:0] accelX;
   wire [8:0] accelY;
   wire [11:0] accelTmp;
   wire [10:0] smem_addr;
   wire [3:0] charcode;
   wire [31:0] keyb_char;
   assign audEn = 1;
   wire enable = 1'b1;			// we will use this later for debugging

   // Uncomment *only* one of the following two lines:
   //    when synthesizing, use the first line
   //    when simulating, get rid of the clock divider, and use the second line
   //
   clockdivider_Nexys4 clkdv(clk, clk100, clk50, clk25, clk12);   // use this line for synthesis/board deployment
//   assign clk100=clk; assign clk50=clk; assign clk25=clk; assign clk12=clk;  // use this line for simulation/testing

   // For synthesis:  use an appropriate clock frequency(ies) below
   //   clk100 will work for hardly anyone
   //   clk50 or clk 25 may work for some
   //   clk12 should work for everyone!  So, please use clk12 for your processor and data memory.
   //
   // Important:  Use the same clock frequency for the MIPS and the memIO modules.
   // The I/O devices, however, should keep the 100 MHz clock.
   // For example:

   mips mips(clk12, reset, enable, pc, instr, mem_wr, mem_addr, mem_writedata, mem_readdata);
   imem #(.Nloc(512), .Dbits(32), .initfile(imem_init)) imem(pc[31:2], instr);
   
   wire [10:0] vga_addr;
   wire [3:0] vga_readdata;
   assign accel_val = {7'b0, accelX, 7'b0, accelY};
   
   memIO #(.Nloc(16), .Dbits(32), .dmem_init(dmem_init), .smem_init(smem_init), .res(res)) 
        //memIO(clk12, mem_wr, mem_addr, mem_readdata, mem_writedata, vga_addr, vga_readdata);
        memIO(clk12, mem_wr, mem_addr, mem_readdata, mem_writedata, LED, period, keyb_char,accel_val, smem_addr, charcode);
   
   
   // I/O devices
   //
   // Note: All I/O devices were developed assuming a 100 MHz clock.
   //   Therefore, the clock sent to them must be clk100, not any of the
   //   slower clocks generated by the clock divider.
   // 76800
   vgadisplaydriver #(.Nloc(res), .dim(dim), .bmem_init(bmem_init)) display(clk100, charcode, smem_addr, red, green, blue, hsync, vsync);

   // Uncomment the following to instantiate these other I/O devices.
   //   You will have to declare all the wires that connect to them.
   
   keyboard keyb(clk100, ps2_clk, ps2_data, keyb_char);
   wire [31:0] disp_acc;
   assign disp_acc[31:0] = {7'b0, accelX, 7'b0, accelY};
   display8digit disp(disp_acc, clk100, segments, digitselect);
   accelerometer accel(clk100, aclSCK, aclMOSI, aclMISO, aclSS, accelX, accelY, accelTmp);
   montek_sound_Nexys4 sound(clk100, period, audPWM);

endmodule