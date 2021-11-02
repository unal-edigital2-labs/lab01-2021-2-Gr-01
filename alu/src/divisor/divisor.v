`timescale 1ns / 1ps

module divisor(  input wire [2:0] DV, 
					       input wire [2:0] DS, 
					       input wire init, 
					       input wire clk,  
					       output reg [3:0] C,
					       output reg done
                        );

reg sh;
reg rst;
reg rest;
reg cnt;
reg [1:0] count;
reg [2:0] B;
reg [5:0] R;
reg [2:0] status;
reg [2:0] statusPrev;
reg initD;
reg aux;
wire x;
wire z;

initial begin
    sh = 1'b0;
    rst = 1'b0;
    rest = 1'b0;
    cnt = 1'b0;
    count = 2'b11;
    B = DS;
    R = {3'b0, DV};
    status = 3'b0;
    statusPrev = 3'b0;
    initD = 1'b0;
    aux = 1'b0;
end

//bloque comparador 1
assign x = (R[5:3] >= B)? 1 : 0;

// bloque comparador 2
assign z = (count == 2'b0)? 1 : 0;

always @(posedge clk) begin
    if (init & aux)begin
        initD = 1'b1;
        aux = 0;
    end else begin
        initD = 1'b0;
    end
    
    if (!init) begin
        aux = 1;
    end
end

always @(posedge clk) begin
//bloques de registros de desplazamiento para R y C
	if (rst) begin
		B = DS;
		C = 4'b0;
		R = {3'b0, DV};
		count = 2'b11;
	end
	else begin 
		if (sh) begin
			R = R << 1;
			C = C << 1;
		end
	end
	
//bloque contador
    if  (cnt) begin
        count = count - 1;
    end

//bloque de resta
    if (rest) begin
        C[0] = x;
        R[5:3] = R[5:3] - B; 
    end
    
end 


// FSM 
parameter START = 3'd0, SHIFT= 3'd1, ESPERAR = 3'd2, CONTADOR = 3'd3, RESTA = 3'd4, CHECK = 3'd5, END = 3'd6;

always @(posedge clk) begin

	case (status)
	START: begin
		sh = 0;
		rest = 0;
		cnt = 0;
		if (initD) begin
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
		cnt = 0;
		statusPrev = SHIFT;
		status = ESPERAR;
	   end
	ESPERAR: begin
	    done = 0;
		rst = 0;
		sh = 0;
		rest = 0;
		cnt = 0;
		if (statusPrev == SHIFT)begin
		  status = CONTADOR;
		end else begin
		  status = CHECK;
		end		
	    end 
	CONTADOR:  begin
	   done = 0;
	   rst = 0;
	   sh = 0;
	   rest = 0;
	   cnt = 1;
	   if (x) begin
	       status= RESTA;
	   end
	   else begin
	       statusPrev = CONTADOR;
	       status = ESPERAR;
	   end
	   end
	RESTA: begin
		done = 0;
		rst = 0;
		sh = 0;
		rest = 1;
		cnt = 0;
		status = CHECK;
		end
	CHECK: begin
		done = 0;
		rst = 0;
		sh = 0;
		rest = 0;
		cnt = 0;
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
		cnt = 0;
		status= START;
	end
	 default:
		status = START;
	endcase 
end 

endmodule