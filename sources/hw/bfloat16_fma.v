`include "HardFloat_consts.vi"

module bfloat16_fma #(
  parameter expWidth = 8,
  parameter sigWidth = 8,
  parameter inWidth = 2,
  parameter opWidth = 2,
  parameter roundingModeWidth = 3,
  parameter exceptionFlagsWidth = 5
) (
  input [inWidth * (`floatControlWidth - 1) - 1:0] control,
  input [inWidth * opWidth - 1:0] op,
  input [inWidth * (expWidth + sigWidth) - 1:0] a,
  input [inWidth * (expWidth + sigWidth) - 1:0] b,
  input [inWidth * (expWidth + sigWidth) - 1:0] c,
  input [inWidth * roundingModeWidth - 1:0] roundingMode,
  output [inWidth * (expWidth + sigWidth) - 1:0] out,
  output [inWidth * exceptionFlagsWidth - 1:0] exceptionFlags
);

  localparam formatWidth = expWidth + sigWidth;

  genvar i;

  for (i = 0; i < inWidth; i = i + 1) begin : fma_i
    wire [`floatControlWidth - 1:0] recControl;
    wire [opWidth - 1:0] recOp;
    wire [formatWidth:0] recA, recB, recC, recOut;
    wire [roundingModeWidth - 1:0] recRoundingMode;
    wire [exceptionFlagsWidth - 1:0] recExceptionFlags;

    assign recControl = control[`floatControlWidth * (i + 1) - 1:`floatControlWidth * i];
    assign recOp = op[opWidth * (i + 1) - 1:opWidth * i];
    fNToRecFN#(expWidth, sigWidth) fNToRecFN_a(a[16 * (i + 1) - 1:16 * i], recA);
    fNToRecFN#(expWidth, sigWidth) fNToRecFN_b(b[16 * (i + 1) - 1:16 * i], recB);
    fNToRecFN#(expWidth, sigWidth) fNToRecFN_c(c[16 * (i + 1) - 1:16 * i], recC);
    assign recRoundingMode = roundingMode[roundingModeWidth * (i + 1) - 1:roundingModeWidth * i];
    recFNToFN#(expWidth, sigWidth) recFNToFN_out(recOut, out[16 * (i + 1) - 1:16 * i]);
    assign recExceptionFlags = exceptionFlags[exceptionFlagsWidth * (i + 1) - 1:exceptionFlagsWidth * i];

    mulAddRecFN #(expWidth, sigWidth)
      fma (
        .control (recControl),
        .op (recOp),
        .a (recA),
        .b (recB),
        .c (recC),
        .roundingMode (recRoundingMode),
        .out (recOut),
        .exceptionFlags (recExceptionFlags)
      );
  end

endmodule
