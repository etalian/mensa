set ::env(DESIGN_NAME) "bfloat16_fma"
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/bfloat16_fma/src/*.v]
set ::env(CLOCK_PERIOD) 0
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 3

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 275 275"

set ::env(PL_TARGET_DENSITY) 0.60
#default is 0.55
