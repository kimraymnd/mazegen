`timescale 1ns / 1ps
`default_nettype none


module memIO #(
    parameter Nloc = 256,
    parameter Dbits = 32, 
    parameter dmem_init = "dmem_full-IO-test.mem",
    parameter smem_init = "smem_screentest.mem",
    parameter res
    )(
    
    input wire clk,
    input wire cpu_wr,
    input wire [Dbits-1:0] cpu_addr,
    output wire [Dbits-1:0] cpu_readdata,
    input wire [Dbits-1:0] cpu_writedata,
    
    output logic [15:0] lights,
    output logic [31:0] period,
    input wire [31:0] keyb_char,
    input wire [31:0] accel_val,
    input wire [10:0] vga_addr,
    output wire [3:0] vga_readdata
    );
    
    wire lights_wr;
    wire sound_wr;
    wire dmem_wr;
    wire smem_wr;
    wire [3:0] smem_readdata;
    wire [Dbits-1:0] dmem_readdata;
    //input wire 
    
    wire [1:0] mem_code1;
    wire [1:0] mem_code2;
    assign mem_code1 = cpu_addr[17:16];
    assign mem_code2 = cpu_addr[3:2];
    
    assign cpu_readdata = (mem_code1 == 2'b10) ? smem_readdata //{ {(Dbits-4){1'b0}}, smem_readdata}
                        : (mem_code1 == 2'b01) ? dmem_readdata 
                        : (mem_code1 == 2'b11 && mem_code2 == 2'b01) ? accel_val
                        : (mem_code1 == 2'b11 && mem_code2 == 2'b00) ? keyb_char
                        : {32'b0};
    
    assign dmem_wr   = (cpu_wr && (mem_code1 == 2'b01)) ? 1'b1 : 1'b0;
    assign smem_wr   = (cpu_wr && (mem_code1 == 2'b10)) ? 1'b1 : 1'b0;
    assign lights_wr = (cpu_wr && (mem_code1 == 2'b11 && mem_code2 == 2'b11)) ? 1'b1 : 1'b0;
    assign sound_wr  = (cpu_wr && (mem_code1 == 2'b11 && mem_code2 == 2'b10)) ? 1'b1 : 1'b0;
    
    
    led_reg   #() led_reg(clk, lights_wr, cpu_writedata, lights);
    sound_reg #() sound_reg(clk, sound_wr, cpu_writedata, period);
    screenmem #(.Nloc(res), .Dbits(4), .initfile(smem_init)) scrnm( clk, smem_wr, vga_addr, cpu_addr[31:2], cpu_writedata, vga_readdata, smem_readdata );
    dmem      #(.Nloc(64),  .Dbits(32), .initfile(dmem_init)) datam( clk, dmem_wr, cpu_addr[31:2], cpu_writedata, dmem_readdata );
   
    
endmodule
