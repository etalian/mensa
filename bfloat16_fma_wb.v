module bfloat16_fma_wb (
  input  clk,
  input  reset,
  input  valid,
  input  [31:0] addr,
  input  [3:0]  wstrb,
  input  [31:0] wdata,
  input  [31:0] la_write,
  input  [31:0] la_input,
  output ready,
  output [31:0] rdata,

  output [9:0]  exceptionFlags,
  output [31:0] out
);
  wire [31:0] tmpOut;
  wire [9:0]  tmpExceptionFlags;

  reg ready;
  reg [31:0] rdata;

  reg [1:0]  regControl;
  reg [3:0]  regOp;
  reg [31:0] regA;
  reg [31:0] regB;
  reg [31:0] regC;
  reg [5:0]  regRoundingMode;
  reg [31:0] regOut;
  reg [9:0]  regExceptionFlags;

  always @(posedge clk) begin
    if (reset) begin
      ready <= 0;
      rdata <= 0;

      regControl <= 0;
      regOp <= 0;
      regA <= 0;
      regB <= 0;
      regC <= 0;
      regRoundingMode <= 0;
      regOut <= 0;
      regExceptionFlags <= 0;
    end else begin
      ready <= 1'b0;
      rdata <= 0;
      if (valid && !ready) begin
        ready <= 1'b1;

        case (addr)
          32'h3000_0000: begin //ctrl1/ctrl2
            rdata[0] <= regControl[0];
            rdata[16] <= regControl[1];
            if (wstrb[0]) regControl[0]  <= wdata[0];
            if (wstrb[2]) regControl[1] <= wdata[16];
          end
          32'h3000_0004: begin //op1/op2
            rdata[1:0] <= regOp[1:0];
            rdata[17:16] <= regOp[3:2];
            if (wstrb[0]) regOp[1:0] <= wdata[1:0];
            if (wstrb[2]) regOp[3:2] <= wdata[17:16];
          end
          32'h3000_0008: begin //A1/A2
            rdata <= regA;
            if (wstrb[0]) regA[7:0]   <= wdata[7:0];
            if (wstrb[1]) regA[15:8]  <= wdata[15:8];
            if (wstrb[2]) regA[23:16] <= wdata[23:16];
            if (wstrb[3]) regA[31:24] <= wdata[31:24];
          end
          32'h3000_000C: begin //B1/B2
            rdata <= regB;
            if (wstrb[0]) regB[7:0]   <= wdata[7:0];
            if (wstrb[1]) regB[15:8]  <= wdata[15:8];
            if (wstrb[2]) regB[23:16] <= wdata[23:16];
            if (wstrb[3]) regB[31:24] <= wdata[31:24];
          end
          32'h3000_0010: begin //C1/C2
            rdata <= regC;
            if (wstrb[0]) regC[7:0]   <= wdata[7:0];
            if (wstrb[1]) regC[15:8]  <= wdata[15:8];
            if (wstrb[2]) regC[23:16] <= wdata[23:16];
            if (wstrb[3]) regC[31:24] <= wdata[31:24];
          end
          32'h3000_0014: begin //roundingmode1/roundingmode2
            rdata[2:0] <= regRoundingMode[2:0];
            rdata[18:16] <= regRoundingMode[5:3];
            if (wstrb[0]) regRoundingMode[2:0] <= wdata[2:0];
            if (wstrb[2]) regRoundingMode[5:3] <= wdata[18:16];
          end
          32'h3000_0018: begin //out1/out2
            rdata <= tmpOut;
          end
          32'h3000_001C: begin //flags1/flags2
            rdata <= tmpExceptionFlags;
          end
        endcase
        regOut <= tmpOut;
        regExceptionFlags <= tmpExceptionFlags;
      end else if (|la_write) begin
        case (la_input[29:28])
          0: begin //ctrl1
            regControl[0] <= la_write[16] & la_input[16];
          end
          1: begin //op1
            regOp[1:0] <= la_write[17:16] & la_input[17:16];
          end
          2: begin //A1
            regA[16:4] <= la_write[27:16] & la_input[27:16];
          end
          3: begin //B1
            regB[16:4] <= la_write[27:16] & la_input[27:16];
          end
          4: begin //C1
            regC[16:4] <= la_write[27:16] & la_input[27:16];
          end
        endcase
        regOut[15:0] <= tmpOut[15:0];
      end
    end
  end

  bfloat16_fma bfma (
    .control (regControl),
    .op (regOp),
    .a (regA),
    .b (regB),
    .c (regC),
    .roundingMode (regRoundingMode),
    .out (tmpOut),
    .exceptionFlags (tmpExceptionFlags)
  );

  assign exceptionFlags = tmpExceptionFlags;
  assign out = tmpOut;

endmodule
