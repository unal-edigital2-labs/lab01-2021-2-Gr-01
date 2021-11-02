`timescale 1ns / 1ps
module display(
    input wire [15:0] num,
    input wire clk,
    input wire rst,
    output wire [0:6] sseg,
    output reg [3:0] an
    );

BCDtoSSeg bcdtosseg(.BCD(bcd), .SSeg(sseg));

reg [3:0] bcd = 0;
reg [26:0] cfreq = 0;
reg [1:0] count = 0;
wire enable;

// Divisor de frecuecia

assign enable = cfreq[16];
assign led = enable;

always @(posedge clk) begin
  if (rst == 1) begin
		cfreq <= 0;
	end else begin
		cfreq <= cfreq + 1;
	end
end

always @(posedge enable) begin
		if (rst == 1) begin
			count <= 0;
			an <= 4'b1111; 
		end else begin 
			count <= count + 1;
			case (count) 
				2'd0: begin bcd <= num[3:0];     an <= 4'b1110; end 
				2'd1: begin bcd <= num[7:4];     an <= 4'b1101; end 
				2'd2: begin bcd <= num[11:8];   an <= 4'b1011; end 
				2'd3: begin bcd <= num[15:12]; an <= 4'b0111; end 
			endcase
		end
end

endmodule
