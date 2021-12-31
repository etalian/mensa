set ::env(DESIGN_NAME) "bfloat16_fma"
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/bfloat16_fma/src/*.v]
set ::env(CLOCK_PERIOD) 100
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 3

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 300 300"

set ::env(PL_TARGET_DENSITY) 0.5
