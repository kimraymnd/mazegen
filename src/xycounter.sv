`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2018 10:48:31 PM
// Design Name: 
// Module Name: xycounter
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


module xycounter #(parameter width=2, height=2)(
    input wire clock,
    input wire enable,
    output logic [$clog2(width)-1:0] x=0,
    output logic [$clog2(height)-1:0] y=0
    );
    
    always_ff @(posedge clock) begin
        if(enable) begin
            if(x==width-1) begin
                x<=0;
                if(y==height-1)
                    y<=0;
                else
                    y<=y+1;
            end
            else
                x<=x+1;
        end
    end
    
endmodule
