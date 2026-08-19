//`timescale 1ns/1ps
`include "defines.svh"
interface alu_if(input logic clk,input logic rst);
	logic [`DW-1:0]OPA;
	logic [`DW-1:0]OPB;
	logic CE;
	logic MODE;
	logic CIN;
	logic [`CW-1:0]CMD;
	logic [1:0]INP_VALID;
	logic [`DW*2-1:0]RES;
	logic COUT;
	logic OFLOW;
	logic G;
	logic E;
	logic L;
	logic ERR;

	clocking drv@(posedge clk);
		default input #1 output #1;
		output OPA,OPB,CE,MODE,CMD,INP_VALID,CIN;
		input RES,COUT,OFLOW,G,L,E,ERR;
	endclocking

	clocking mon@(posedge clk);
		default input #1;
         	input OPA,OPB,CE,MODE,CMD,INP_VALID,CIN;
		input RES,COUT,OFLOW,G,L,E,ERR;
	endclocking


	modport DRV(clocking drv,input rst);
	modport MON(clocking mon,input rst);
endinterface 
/*`timescale 1ns/1ps
`include "defines.svh"

interface alu_if(input logic clk, input logic rst);
    logic [`DW-1:0]   OPA;
    logic [`DW-1:0]   OPB;
    logic             CE;
    logic             MODE;
    logic             CIN;
    logic [`CW-1:0]   CMD;
    logic [1:0]       INP_VALID;
    logic [`DW*2-1:0] RES;
    logic             COUT;
    logic             OFLOW;
    logic             G;
    logic             E;
    logic             L;
    logic             ERR;

    clocking drv @(posedge clk);
        default input #1 output #1;
        output OPA, OPB, CE, MODE, CMD, INP_VALID, CIN;
        input  RES, COUT, OFLOW, G, E, L, ERR;
    endclocking

    modport DRV (clocking drv, input clk, input rst);

    modport MON (input clk, rst, OPA, OPB, CE, MODE, CMD, CIN,
                  INP_VALID, RES, COUT, OFLOW, G, E, L, ERR);
endinterface */



	
