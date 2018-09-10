`timescale 1ns / 1ps
`default_nettype none


module sound_reg #(
   parameter Nloc = 32,                      // Number of memory locations
   parameter Dbits = 32                      // Number of bits in data
)(

   input wire clock,
   input wire wr,                            // WriteEnable:  if wr==1, data is written into mem
   //input wire [$clog2(Nloc)-1 : 0] ReadAddr1, ReadAddr2, WriteAddr, 	
                                             // 3 addresses, two for reading and one for writing
   input wire [Dbits-1 : 0] cpu_writedata,       // Data for writing into memory (if wr==1)
   output logic [Dbits-1 : 0] period
                                             // 2 output ports
   );

//   logic [Dbits-1:0] rf [Nloc:0];                     // The actual registers where data is stored
                                             // initial $readmemh(initfile, ..., ..., ...);  
                                             // Usually no need to initialize register file

   always_ff @(posedge clock)                // Memory write: only when wr==1, and only at posedge clock
      if(wr)
         period <= cpu_writedata;

   // MODIFY the two lines below so if register 0 is being read, then the output
   // is 0 regardless of the actual value stored in register 0
   
//   assign ReadData1 = ... ? ... rf[...];     // First output port
//   assign ReadData2 = ... ? ... rf[...];     // Second output port
   
endmodule