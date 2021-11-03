`timescale 1ns / 1ps

module sum4b(init, xi, yi, co, sal);

  input wire init;
  input wire [3:0] xi;
  input wire [3:0] yi;
  
  output wire co;
  output wire [3:0] sal;
  
  wire [4:0] st;
  
  assign st  = 	xi + yi;
  
  assign sal = st[3:0];
  assign Cout = st[4];

endmodule