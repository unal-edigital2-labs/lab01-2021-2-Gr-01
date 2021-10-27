`timescale 1ns / 1ps

module divisor(  input wire [2:0] DV, 
					       input wire [2:0] DS, 
					       input wire init, 
					       input wire clk,  
					       output reg [3:0] C
                        );

reg done;
reg sh;
reg rst;
reg rest;
reg [2:0] B;
reg [5:0] R;
wire x;
wire z;


reg [2:0] status = 0;

//bloque comparador A
assign x = (R[5:3] >= B)? 1 : 0;

// bloque comparador B
assign z = (R[2:0] == 0)? 1 : 0;


//bloques de registros de desplazamiento para R y C
always @(posedge clk) begin
	if (rst) begin
		B = DS;
		C = 4'b0;
		R = {3'b0, DV};
	end
	else begin 
		if (sh) begin
			R = R << 1;
			C = C << 1;
		end
	end
//bloque de resta
    if (rest) begin
        C[0] = x;
        R[5:3] = R[5:3] - B; 
    end
end 


// FSM 
parameter START = 3'd0, SHIFT= 3'd1, RESTA = 3'd2, CHECK = 3'd3, END = 3'd4;

always @(posedge clk) begin
	case (status)
	START: begin
		sh = 0;
		rest = 0;
		if (init) begin
			status = SHIFT;
			done = 0;
			rst = 1;
		end
		end
	SHIFT: begin 
		done = 0;
		rst = 0;
		sh = 1;
		rest = 0;
		if (x == 1)
			status = RESTA;
		else
			status = CHECK;
		end
	RESTA: begin
		done = 0;
		rst = 0;
		sh = 0;
		rest = 1;
		status = CHECK;
		end
	CHECK: begin
		done = 0;
		rst = 0;
		sh = 0;
		rest = 0;
		if(z == 1)
			status = END;
		else
			status = SHIFT;
		end
	END: begin
		done = 1;
		rst = 0;
		sh = 0;
		rest = 0;
		status = START;
	end
	 default:
		status = START;
	endcase 
end 

endmodule
