`timescale 1ns / 1ps
`default_nettype none


module dmem #(
    parameter Nloc = 64,                      // Number of memory locations
    parameter Dbits = 32,                      // Number of bits in data
    parameter initfile = "dmem_screentest.mem"          // Name of file with initial values
)(
    input wire clock,
    input wire wr,                            // WriteEnable:  if wr==1, data is written into mem
    
    input wire [$clog2(Nloc)-1 : 0] cpu_addr,     // Address for specifying memory location
    //input wire [31:0] addr,
                                             //   num of bits in addr is ceiling(log2(number of locations))
    input wire [Dbits-1 : 0] cpu_writedata,             // Data for writing into memory (if wr==1)
    output logic [Dbits-1 : 0] dmem_readdata           // Data read from memory (asynchronously, i.e., continuously)
    );

    logic [Dbits-1 : 0] mem [Nloc-1 : 0];     // The actual storage where data resides
    initial $readmemh(initfile, mem, 0, Nloc-1); // Initialize memory contents from a file

    always_ff @(posedge clock)                // Memory write: only when wr==1, and only at posedge clock
        if(wr)
            mem[cpu_addr] <= cpu_writedata;

    assign dmem_readdata = mem[cpu_addr];                  // Memory read: read continuously, no clock involved

endmodule