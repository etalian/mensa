/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

/*
  MPRJ LA Test:
    - Sets counter clk through LA[64]
    - Sets counter rst through LA[65]
    - Observes count value for five clk cycle through LA[31:0]
*/

int i;

void main()
{
  /* Set up the housekeeping SPI to be connected internally so  */
  /* that external pin changes don't affect it.      */

  reg_spimaster_config = 0xa002;  // Enable, prescaler = 2,
                                  // connect to housekeeping SPI

  // Connect the housekeeping SPI to the SPI master
  // so that the CSB line is not left floating.  This allows
  // all of the GPIO pins to be used for user functions.


  // All GPIO pins are configured to be output
  // Used to flag the start/end of a test

  reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

  reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_9  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_8  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_7  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_5  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_4  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_3  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_2  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_1  = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_0  = GPIO_MODE_USER_STD_OUTPUT;

  /* Apply configuration */
  reg_mprj_xfer = 1;
  while (reg_mprj_xfer == 1);

  // Configure All LA probes as inputs to the cpu
  reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF; // [31:0]
  reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF; // [63:32]
  reg_la2_oenb = reg_la2_iena = 0xFFFFFFFF; // [95:64]
  reg_la3_oenb = reg_la3_iena = 0xFFFFFFFF; // [127:96]

  // Flag start of the test
  reg_mprj_datal = 0xAB600000;

  // Configure highest 16 bits as inputs to the CPU
  // (high half will contain a and b operands)
  reg_la0_oenb = reg_la0_iena = 0x0000FFFF;

  // clk posedge, reset posedge
  reg_la0_data = 0xc0000000;

  // clk negedge, reset negedge
  reg_la0_data = 0x00000000;

  // clk posedge, ctrl reg
  reg_la0_data = 0x80000000;

  // clk negedge
  reg_la0_data = 0x00000000;

  // clk posedge, A reg (6.0)
  reg_la0_data = 0xA40C0000;

  // clk negedge
  reg_la0_data = 0x00000000;

  // clk posedge, B reg (7.0)
  reg_la0_data = 0xB40E0000;

  // clk negedge
  reg_la0_data = 0x00000000;

  // clk posedge
  reg_la0_data = 0x80000000;

  // out (42.0)
  if (reg_la0_data == 0x4228) {
    reg_mprj_datal = 0xAB610000;
  }
}

