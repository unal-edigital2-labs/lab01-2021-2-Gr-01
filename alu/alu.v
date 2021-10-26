`timescale 1ns / 1ps


module alu(
    input [2:0] portA,
    input [2:0] portB,
    input [1:0] opcode,
    output [0:6] sseg,
    output [3:0] an,
    input clk,
    input rst
 );

// Declaraci�n de salidas de cada bloque 
wire [3:0] sal_suma;
wire [3:0] sal_resta;
wire [3:0] sal_div;
wire [5:0] sal_mult;


// Declaraci�n de las entradas init de cada bloque 
reg [3:0] init; 
wire init_suma;
wire init_resta;
wire init_mult;
wire init_div;

// 

assign init_suma = init[0];
assign init_resta = init[1];
assign init_mult = init[2];
assign init_div = init[3];

reg [15:0]int_bcd;

wire [3:0] operacion;

// descripci�n del decodificacion de operaciones
always @(*) begin
	case(opcode) 
		2'b00: init<=4'b0001;
		2'b01: init<=4'b0010;
		2'b10: init<=4'b0100;
		2'b11: init<=4'b1000;
	default:
		init <= 4'b0000;
	endcase
	
end
// Descripcion del miltiplexor
always @(*) begin
	case(opcode) 
		2'b00: int_bcd <={8'd0,sal_suma};
		2'b01: int_bcd <={8'd0,sal_resta};
		2'b10: int_bcd <={8'd0,sal_mult};
		2'b11: int_bcd <={8'd0,sal_div};
	default:
		int_bcd <= 16'd0;
	endcase
	
end


//instanciación de los componnetes 

sum4b sum(  .init(init_suma), 
            .xi({1'b0,portA}),
            .yi({1'b0,portB}),
            .sal(sal_suma));
            
restador res(   .init(init_resta),
                .rm({1'b0,portA}), 
                .rs({1'b0,portB}), 
                .sal(sal_resta));

multiplicador mul(  .MR(portA),
                    .MD(portB),
                    .init(init_mult),
                    .clk(clk),
                    .pp(sal_mult));
                    
display dp( .num(int_bcd),
            .clk(clk),
            .sseg(sseg),
            .an(an),
            .rst(rst));

endmodule
