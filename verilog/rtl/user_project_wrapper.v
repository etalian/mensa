// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
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

//TODO: only bits 31:0 of the logic analyzer are available

module user_project_wrapper (
`ifdef USE_POWER_PINS
  inout vdda1,  // User area 1 3.3V supply
  inout vdda2,  // User area 2 3.3V supply
  inout vssa1,  // User area 1 analog ground
  inout vssa2,  // User area 2 analog ground
  inout vccd1,  // User area 1 1.8V supply
  inout vccd2,  // User area 2 1.8v supply
  inout vssd1,  // User area 1 digital ground
  inout vssd2,  // User area 2 digital ground
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

  // Analog (direct connection to GPIO pad---use with caution)
  // Note that analog I/O is not available on the 7 lowest-numbered
  // GPIO pads, and so the analog_io indexing is offset from the
  // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
  inout [`MPRJ_IO_PADS-10:0] analog_io,

  // Independent clock (on independent integer divider)
  input   user_clock2,

  // User maskable interrupt signals
  output [2:0] user_irq
);
  wire clk;
  wire rst;

  wire [`MPRJ_IO_PADS-1:0] io_in;
  wire [`MPRJ_IO_PADS-1:0] io_out;
  wire [`MPRJ_IO_PADS-1:0] io_oeb;

  wire [31:0] rdata;
  wire [31:0] wdata;
  //wire [BITS-1:0] count;
  wire [9:0] exceptionFlags;
  wire [31:0] out;

  wire valid;
  wire [3:0] wstrb;
  wire [31:0] la_write;

  // WB MI A
  assign valid = wbs_cyc_i && wbs_stb_i;
  assign wstrb = wbs_sel_i & {4{wbs_we_i}};
  assign wbs_dat_o = rdata;
  assign wdata = wbs_dat_i;

  // IO
  assign io_out = out;
  assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

  // IRQ
  assign user_irq = 3'b000;  // Unused

  // LA
  //assign la_data_out = {{(127-BITS){1'b0}}, count};
  assign la_data_out[15:0] = out[15:0];
  assign la_data_out[20:16] = exceptionFlags[4:0];
  // Assuming LA probes [63:32] are for controlling the count register
  //assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
  //assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};

  assign la_write = ~la_oenb[31:0] & ~{32{valid}};

  ///assign la_write[15:0] = ~la_oenb[14:0] & ~{15{valid}};
  ///assign la_write[29:16] = ~la_oenb[30:16] & ~{13{valid}};
  // Assuming LA probes [65:64] are for controlling the count clk & reset
  // Assuming LA probes [31] [15] are for controlling the count reset & clk
  //assign rst = (~la_oenb[65]) ? la_data_in[65] : wb_rst_i;

  // Assuming LA probes [31:30] are for controlling the clk & reset
  assign clk = (~la_oenb[31]) ? la_data_in[31] : wb_clk_i;
  assign rst = (~la_oenb[30]) ? la_data_in[30] : wb_rst_i;

  bfloat16_fma_wb fma_wb (
    .clk(clk),
    .reset(rst),
    .ready(wbs_ack_o),
    .valid(valid),
    .addr(wbs_adr_i),
    .rdata(rdata),
    .wdata(wbs_dat_i),
    .wstrb(wstrb),
    .la_write(la_write),
    //.la_input(la_data_in[63:32]),
    .la_input(la_data_in[31:0] & 32'h3FFFFFFF),
    .exceptionFlags(exceptionFlags),
    .out(out)
    //.count(count)
  );

endmodule

`default_nettype wire
