import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout
from cocotb.result import TestSuccess

@cocotb.test()
async def test_active(dut):
  clk = Clock(dut.clk, 25, units="ns") # 40M
  cocotb.fork(clk.start())

  dut.RSTB <= 0
  dut.power1 <= 0;
  dut.power2 <= 0;
  dut.power3 <= 0;
  dut.power4 <= 0;

  await ClockCycles(dut.clk, 8)
  dut.power1 <= 1;
  await ClockCycles(dut.clk, 8)
  dut.power2 <= 1;
  await ClockCycles(dut.clk, 8)
  dut.power3 <= 1;
  await ClockCycles(dut.clk, 8)
  dut.power4 <= 1;

  await ClockCycles(dut.clk, 80)
  dut.RSTB <= 1

  dut._log.info("Waiting for active...")

  # wait with a timeout for the project to become active
  await with_timeout(RisingEdge(dut.uut.mprj.wrapped_project.active), 1800, 'us')

  dut._log.info("Project activated");

@cocotb.test()
async def test_wb(dut):
  clk = Clock(dut.clk, 25, units="ns") # 40M
  cocotb.fork(clk.start())

  for i in range(100000):
    await ClockCycles(dut.clk, 1)

    wbs_adr_i = int(dut.uut.mprj.wrapped_project.wbs_adr_i.value)
    wbs_dat_o = int(dut.uut.mprj.wrapped_project.wbs_dat_o.value)
    wbs_ack_o = int(dut.uut.mprj.wrapped_project.wbs_ack_o.value)
    wbs_dat_i = int(dut.uut.mprj.wrapped_project.wbs_dat_i.value)

    regs = {
      0x30000000: "CTRL",
      0x30000004: "OP",
      0x30000008: "A",
      0x3000000C: "B",
      0x30000010: "C",
      0x30000014: "RMODE",
      0x30000018: "OUT",
      0x3000001C: "FLAGS",
      0x30000020: "COCO" # Dummy address for cocotb
    }
    reg_str = regs.get(wbs_adr_i, None)
    if not reg_str:
      continue

    dut._log.info(f"adr_i:{hex(wbs_adr_i)}({reg_str}) dat_i:{hex(wbs_dat_i)}, dat_o:{hex(wbs_dat_o)}, ack_o:{wbs_ack_o}")

    if (wbs_adr_i == 0x30000020):
      assert (wbs_dat_i == 0xC00D)
      break
