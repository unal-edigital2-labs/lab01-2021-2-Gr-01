`timescale 1ns / 1ps

module restador(init, rm, rs, sal);

  input wire init;
  input wire [3:0] rm;
  input wire [3:0] rs;
  output wire [3:0] sal;
  
  assign sal  = (rm >= rs)? rm - rs : rs - rm;
  
endmodule