//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 9/12/2017 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.vh"

module vgadisplaydriver #(
    parameter Nloc = 1200,
    parameter dim,
    parameter bmem_init = "bmem_final.mem"
    )(
    input wire clk,
    input wire [3:0] chcode,
    output wire [$clog2(Nloc)-1:0] screenaddr,
    output wire [3:0] red, green, blue,
    output wire hsync, vsync
    );

    wire [`xbits-1:0] x; // [9:0]
    wire [`ybits-1:0] y; // [9:0]
    wire activevideo;

    vgatimer myvgatimer(clk, hsync, vsync, activevideo, x, y);
    
    wire [5:0] row = y[`ybits-1:4];
    wire [5:0] col = x[`xbits-1:4];
    // [12:0]
    assign screenaddr[$clog2(Nloc)-1:0] = (row << 5) + (row << 3) + col;
    
    wire [3:0] x_offset = x[3:0];
    wire [3:0] y_offset = y[3:0];
    wire [11:0] bmem_addr = {chcode, y_offset, x_offset};
    
    wire [11:0] bmem_color;
    bitmap #(.initfile(bmem_init)) bMem (bmem_addr, bmem_color);
       
    assign red[3:0]   = (activevideo == 1) ? bmem_color[11:8] : 4'b0;
    assign green[3:0] = (activevideo == 1) ? bmem_color[7:4] : 4'b0;
    assign blue[3:0]  = (activevideo == 1) ? bmem_color[3:0] : 4'b0;

endmodule
