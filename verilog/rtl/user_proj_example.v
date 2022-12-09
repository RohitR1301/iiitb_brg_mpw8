// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;
    wire clk,reset, [1:0]sel, clkout;
    iiitb_brg mod1(clk,reset,sel,clkout);
    

    // IO
    assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    

    
endmodule

// Code your design here
`timescale 100ps / 100ps

module iiitb_brg( clk,reset,sel,clkout);
	 
input clk,reset;
input [1:0]sel;
output reg clkout;

parameter DIV1=34;//fsystem/f1152*2,fsystem=125Mhz

reg[5:0] cnt1=0;
reg[1:0] cnt2=0;
reg[2:0] cnt3=0;
reg[3:0] cnt4=0;
always@(posedge clk)
	case(sel)
		//clk for 115200bps
	2'b00:
		begin
		if(reset)
			begin
			cnt1<=0;
			cnt2<=0;
			cnt3<=0;
			cnt4<=0;
			clkout<=0;
			end
		else
		begin
			if(cnt1==(DIV1-1))
				begin
				cnt1 <= 0;
				clkout<=~clkout;
				end
			else
				cnt1<=cnt1+1;
		end
		end

		//clk for 38400bps
	2'b01:
		begin
		if(reset)
			begin
			cnt2<=0;
			clkout<=0;
			end
		else
			begin
			if(cnt1==(DIV1-1))
				begin
					cnt1<=0;
					if(cnt2==2)
						begin
						cnt2<=0;
						clkout<=~clkout;
						end
					else
						cnt2<=cnt2+1;
				end
			else
				cnt1<=cnt1+1;
		end
		
		end


		//clk for 19200bps
	2'b10:
		begin
		if(reset)
			begin
			cnt3<=0;
			clkout<=0;
			end
		else
		begin
		if(cnt1==(DIV1-1))
			begin
			cnt1<=0;
			
			if(cnt3==5)
				begin
				cnt3<=0;
				clkout<=~clkout;
				end
			else
				cnt3<=cnt3+1;
			end
		else 
			cnt1<=cnt1+1;
		end
		
		end

		//clk for 9600bps
	2'b11:
		begin
		if(reset)
			begin
			cnt4<=0;
			clkout<=0;
			end
		else
			begin
			if(cnt1==(DIV1-1))
				begin
					cnt1<=0;
					if(cnt4==11)
					begin
					cnt4<=0;
					clkout<=~clkout;
					end
					else
					cnt4<=cnt4+1;
				end
			else
				cnt1<=cnt1+1;
			end
		end
	
	endcase
endmodule

`default_nettype wire
