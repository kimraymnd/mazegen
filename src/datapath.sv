`timescale 1ns / 1ps
`default_nettype none

module datapath #(
    parameter Dbits = 32,
    parameter Nloc = 32
    )(
    input wire clk,
    input wire reset,
    input wire enable,
    output logic [31:0] pc = 32'h00400000,
    input wire [31:0] instr,
    input wire [1:0] pcsel,
    input wire [1:0] wasel,
    input wire sext, bsel,
    input wire [1:0] wdsel,
    input wire [4:0] alufn,
    input wire werf,
    input wire [1:0] asel,
    output wire Z,
    
//    input wire [$clog2(Nloc)-1 : 0] ReadAddr1, ReadAddr2, WriteAddr, 
//    input wire [4:0] ALUFN,
//    input wire [Dbits-1:0] WriteData,
    output wire [Dbits-1:0] mem_addr,
    output wire [Dbits-1:0] mem_writedata,
    input wire [Dbits-1:0] mem_readdata
    );
    
    logic [$clog2(Nloc)-1 : 0] ReadAddr1, ReadAddr2, reg_writeaddr;
    assign ReadAddr1 = instr[25:21];
    assign ReadAddr2 = instr[20:16];
    wire [Dbits-1:0] ReadData1, ReadData2, alu_result;
    wire [Dbits-1:0] aluA, aluB;
    wire [Dbits-1:0] JT, BT;
    wire [31:0] pcPlus4;
    wire [31:0] newPC;
    wire [Dbits-1:0] signImm;
    wire [25:0] J;
    logic [15:0] Imm;
    logic [Dbits-1:0] reg_writedata;
    
    assign Imm = instr[15:0];
    assign J = instr[25:0];
    assign signImm = {{16{sext & Imm[15]}}, Imm};
    assign BT = (signImm << 2) + pcPlus4;
    assign newPC = (pcsel == 3) ? ReadData1
                    : (pcsel == 2) ? {pc[31:28], J[25:0], 2'b00}
                    : (pcsel == 1) ? BT
                    : pcPlus4;
    
    always_ff @(posedge clk) begin
        if(reset)
            pc <= 32'h00400000;
        else if(enable) 
            pc <= newPC;
    end
    
    assign pcPlus4 = pc + 4;
    
    assign reg_writeaddr = (wasel == 0) ? instr[15:11]
                         : (wasel == 1) ? instr[20:16]
                         : 31;
                         
    assign mem_writedata = ReadData2;
    
    assign aluA = (asel == 0) ? ReadData1
                : (asel == 1) ? instr[10:6]
                : 16;
    assign aluB = (bsel == 0) ? ReadData2
                : signImm;
              
    assign mem_addr = alu_result;
    assign reg_writedata = (wdsel == 0) ? pcPlus4
                         : (wdsel == 1) ? alu_result
                         : mem_readdata;
                
    ALU #(Dbits) myAlu(aluA, aluB, alu_result, alufn, Z);
    register_file #(Nloc, Dbits) regFile(clk, werf, ReadAddr1, ReadAddr2, reg_writeaddr, reg_writedata, ReadData1, ReadData2);                     
    
endmodule
