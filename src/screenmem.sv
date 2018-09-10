`timescale 1ns / 1ps
`default_nettype none


module screenmem #(
    parameter Nloc = 4800,                      // Number of memory locations
    parameter Dbits = 4,                      // Number of bits in data
    parameter initfile = "smem_screentest.mem"          // Name of file with initial values
    )(
    
    input wire clock,
    input wire wr,                            // WriteEnable:  if wr==1, data is written into mem
    
    input wire [$clog2(Nloc)-1 : 0] vga_addr, cpu_addr,
    
    input wire [Dbits-1:0] cpu_writedata,
    
    output logic [Dbits-1:0] vga_readdata,
    output logic [Dbits-1:0] smem_readdata
    // Data read from memory (asynchronously, i.e., continuously)
    
    );
    
    logic [Dbits-1 : 0] mem [Nloc-1 : 0];     // The actual storage where data resides
    initial $readmemh(initfile, mem, 0, Nloc-1); // Initialize memory contents from a file
  
    always_ff @(posedge clock)
        if(wr)
            mem[cpu_addr] <= cpu_writedata;
    
    assign vga_readdata = mem[vga_addr];                  // Memory read: read continuously, no clock involved
    assign smem_readdata = mem[cpu_addr];
    
endmodule
