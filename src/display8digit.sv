`timescale 1ns / 1ps
`default_nettype none

module display8digit(
    input wire [31:0] val,
    input wire clk,
    output logic [7:0] segments,
    output logic [7:0] digitselect
    );

	logic [31:0] c = 0;					// Used for round-robin digit selection on display
	logic [2:0] toptwo;
	logic [3:0] value4bit;
	
	always_ff @(posedge clk)
		c <= c + 1'b 1;
	
	assign toptwo[2:0] = c[19:17];		// Used for round-robin digit selection on display
	// assign toptwo[1:0] = c[23:22];   // Try this instead to slow things down!

	
	assign digitselect[7:0] = ~ (  			// Note inversion
					   toptwo == 3'b000 ? 8'b 00000001  
				     : toptwo == 3'b001 ? 8'b 00000010
				     : toptwo == 3'b010 ? 8'b 00000100
				     : toptwo == 3'b011 ? 8'b 00001000
				     : toptwo == 3'b100 ? 8'b 00010000  
                     : toptwo == 3'b101 ? 8'b 00100000
                     : toptwo == 3'b110 ? 8'b 01000000
                     : 8'b 10000000 );

	//assign digitselect[7:4] = ~ 4'b 0000;      // Since we are not using half of the display
		
	assign value4bit   =   (
				  toptwo == 3'b000 ? val[3:0]
				: toptwo == 3'b001 ? val[7:4]
				: toptwo == 3'b010 ? val[11:8]
				: toptwo == 3'b011 ? val[15:12] 
				: toptwo == 3'b100 ? val[19:16]
                : toptwo == 3'b101 ? val[23:20]
                : toptwo == 3'b110 ? val[27:24]
                : val[31:28]);
	
	hexto7seg myhexencoder(value4bit, segments);

endmodule
