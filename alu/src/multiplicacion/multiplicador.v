`timescale 1ns / 1ps

module multiplicador( MR, MD, init, clk, pp, done );

input wire [2:0] MR;
input wire [2:0] MD;
input wire init;
input wire clk;

output reg [5:0] pp;
output reg done;
                         
reg sh;
reg rst;
reg add;
reg [5:0] A;
reg [2:0] B;
reg [2:0] status;

wire z;

//Inicializar todos los registros
initial begin
    pp = 6'b0;
    done = 1'b0;
    sh = 1'b0;
    rst = 1'b0;
    add = 1'b0;
    A = {3'd0, MD};
	B = MR;
    status = 3'd0;
end

// bloque comparador 
assign z = (B == 0)? 1'b1 : 1'b0;

//bloques de registros de desplazamiento para A y B
always @(negedge clk) begin
	if (rst) begin
		A = {3'd0, MD};
		B = MR;
	end
	else begin 
		if (sh) begin
			A = A << 1;
			B = B >> 1;
		end
	end
end 

//bloque de add pp
always @(negedge clk) begin
	if (rst) begin
		pp = 6'd0;
	end
	else begin 
		if (add) begin
		pp = pp + A;
		end
	end
end

// FSM 
parameter START = 3'd0, CHECK = 3'd1, ADD = 3'd2, SHIFT = 3'd3, END = 3'd4;

always @(posedge clk) begin
	case (status)
	START: begin
		sh = 0;
		add = 0;
		if (init) begin
			status = CHECK;
			done = 0;
			rst = 1;
		end
		end
	CHECK: begin 
		done  = 0;
		rst = 0;
		sh = 0;
		add = 0;
		if (B[0] == 1)
			status = ADD;
		else
			status = SHIFT;
		end
	ADD: begin
		done = 0;
		rst = 0;
		sh = 0;
		add = 1;
		status = SHIFT;
		end
	SHIFT: begin
		done = 0;
		rst = 0;
		sh = 1;
		add = 0;
		if(z == 1)
			status = END;
		else
			status = CHECK;
		end
	END: begin
		done = 1;
		rst = 0;
		sh = 0;
		add = 0;
		status = START;
	end
	 default:
		status = START;
	endcase 
end 

endmodule
