`timescale 1ns / 1ps



module pipline(
    input logic clk, reset,
    output logic[31:0] instrD, resultW, aluout, WriteDataM, pc,
    output logic MemWriteM, StallD, StallF
    );

    logic [31:0]  instr;

    mips mips1(clk, reset,
             pc,
             instr,
             aluout, resultW,
             instrD, WriteDataM,
             StallD, StallF);
             

     imem imem1(pc[7:2],
                instr);

endmodule


module PipeFtoD(input logic[31:0] instr, PcPlus4F,
                input logic EN, clk, reset,		// StallD will be connected as this EN
                output logic[31:0] instrD, PcPlus4D);

    always_ff @(posedge clk, posedge reset)begin
        if (reset)begin
            instrD <= 0;
            PcPlus4D <= 0;
        end
        else if(EN)
            begin
            instrD<=instr;
            PcPlus4D<=PcPlus4F;
            end
        else begin
            instrD <= instrD;
            PcPlus4D <= PcPlus4D;
        end
    end
endmodule

// Similarly, the pipe between Writeback (W) and Fetch (F) is given as follows.

module PipeWtoF(input logic[31:0] PC,
                input logic EN, clk, reset,		// StallF will be connected as this EN
                output logic[31:0] PCF);

    always_ff @(posedge clk, posedge reset)begin
        if (reset)
            PCF <= 0;
        else if(EN)
            begin
            PCF<=PC;
            end
        else
            PCF <= PCF;
    end
endmodule



module PipeDtoE(input logic clr, clk, reset, RegWriteD, MemtoRegD, MemWriteD,
                input logic[2:0] AluControlD,
                input logic AluSrcD, RegDstD, BranchD,
                input logic[31:0] RD1D, RD2D,
                input logic[4:0] RsD, RtD, RdD,
                input logic[31:0] SignImmD,
                input logic[31:0] PCPlus4D,
                    output logic RegWriteE, MemtoRegE, MemWriteE,
                    output logic[2:0] AluControlE,
                    output logic AluSrcE, RegDstE, BranchE,
                    output logic[31:0] RD1E, RD2E,
                    output logic[4:0] RsE, RtE, RdE,
                    output logic[31:0] SignImmE,
                    output logic[31:0] PCPlus4E);

    always_ff @(posedge clk, posedge reset)begin

        if(reset)
        begin
            RegWriteE <= 0;
            MemtoRegE <= 0;
            MemWriteE <= 0;
            AluControlE <= 0;
            AluSrcE <= 0;
            RegDstE <= 0;
            BranchE <= 0;
            RD1E <= 0;
            RD2E <= 0;
            RsE <= 0;
            RtE <= 0;
            RdE <= 0;
            SignImmE <= 0;
            PCPlus4E <= 0;
        end
        else if(clr)
        begin
            RegWriteE <= 0;
            MemtoRegE <= 0;
            MemWriteE <= 0;
            AluControlE <= 0;
            AluSrcE <= 0;
            RegDstE <= 0;
            BranchE <= 0;
            RD1E <= 0;
            RD2E <= 0;
            RsE <= 0;
            RtE <= 0;
            RdE <= 0;
            SignImmE <= 0;
            PCPlus4E <= 0;
        end
        else
        begin
            RegWriteE <= RegWriteD;
            MemtoRegE <= MemtoRegD;
            MemWriteE <= MemWriteD;
            AluControlE <= AluControlD;
            AluSrcE <= AluSrcD;
            RegDstE <= RegDstD;
            BranchE <= BranchD;
            RD1E <= RD1D;
            RD2E <= RD2D;
            RsE <= RsD;
            RtE <= RtD;
            RdE <= RtD;
            SignImmE <= SignImmD;
            PCPlus4E <= PCPlus4D;
        end
    end
endmodule

module PipeEtoM(input logic clk, reset, RegWriteE, MemtoRegE, MemWriteE, BranchE, Zero,
                input logic[31:0] ALUOut,
                input logic [31:0] WriteDataE,
                input logic[4:0] WriteRegE,
                input logic[31:0] PCBranchE,
                    output logic RegWriteM, MemtoRegM, MemWriteM, BranchM, ZeroM,
                    output logic[31:0] ALUOutM,
                    output logic [31:0] WriteDataM,
                    output logic[4:0] WriteRegM,
                    output logic[31:0] PCBranchM);

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
        begin
            RegWriteM <= 0;
            MemtoRegM <= 0;
            MemWriteM <= 0;
            BranchM <= 0;
            ZeroM <= 0;
            ALUOutM <= 0;
            WriteDataM <= 0;
            WriteRegM <= 0;
            PCBranchM <= 0;
        end
        else
        begin
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;
            MemWriteM <= MemWriteE;
            BranchM <= BranchE;
            ZeroM <= Zero;
            ALUOutM <= ALUOut;
            WriteDataM <= WriteDataE;
            WriteRegM <= WriteRegE;
            PCBranchM <= PCBranchE;
        end
    end
endmodule

module PipeMtoW(input logic clk, reset, RegWriteM, MemtoRegM,
                input logic[31:0] ReadDataM, ALUOutM,
                input logic[4:0] WriteRegM,
                    output logic RegWriteW, MemtoRegW,
                    output logic[31:0] ReadDataW, ALUOutW,
                    output logic[4:0] WriteRegW);

		always_ff @(posedge clk, posedge reset) begin
		    if(reset)
            begin
                RegWriteW <= 0;
                MemtoRegW <= 0;
                ReadDataW <= 0;
                ALUOutW <= 0;
                WriteRegW <= 0;
            end
            else
            begin
                RegWriteW <= RegWriteM;
                MemtoRegW <= MemtoRegM;
                ReadDataW <= ReadDataM;
                ALUOutW <= ALUOutM;
                WriteRegW <= WriteRegM;
            end
        end
endmodule



module datapath (input  logic clk, reset,
		         input logic [31:0] PCF, instr,
		         input logic RegWriteD, MemtoRegD, MemWriteD,
		         input logic [2:0] ALUControlD,
		         input logic AluSrcD, RegDstD, BranchD,
		             output logic PCSrcM, StallD, StallF,
		             output logic[31:0] PCBranchM, PCPlus4F, instrD, ALUOut, ResultW, WriteDataM);

	// ********************************************************************
	// Here, define the wires (logics) that are needed inside this pipelined datapath module
    // You are given the wires connecting the Hazard Unit.
    // Notice that StallD and StallF are given as output for debugging
	// ********************************************************************

	logic ForwardAD, ForwardBD,  FlushE;
	logic [1:0] ForwardAE, ForwardBE;
    logic [31:0] RD1E, RD2E, ALUOutM, SrcAE, SrcBE, WriteDataE, RD1D, RD2D, SignImmEShifted, SignImmD, PCBranchE, PCPlus4D, SignImmE, PCPlus4E;
    logic [2:0] AluControlE;
    logic Zero, RegWriteE, MemtoRegE, MemWriteE;
    logic AluSrcE, RegDstE, BranchE;
    logic [4:0] WriteRegE, WriteRegM, WriteRegW;
    logic RegWriteM, MemtoRegM, MemWriteM, BranchM, ZeroM;
    logic [31:0] ReadDataM, ReadDataW, ALUOutW;
    logic RegWriteW, MemtoRegW;
    logic [4:0] RsD, RdD, RtD, RsE, RtE, RdE;

	assign PCSrcM = (BranchM & ZeroM);
	assign RsD = instrD[25:21];
    assign RtD = instrD[20:16];
    assign RdD = instrD[15:11];

	PipeFtoD ftd(instr, PCPlus4F, ~StallD, clk, reset, instrD, PCPlus4D);

	regfile rf (clk, RegWriteW, instrD[25:21], instrD[20:16],
            WriteRegW, ResultW, RD1D, RD2D);

    adder adderPC(PCF, 32'd4, PCPlus4F);
    signext signExt(instrD[15:0], SignImmD);
    PipeDtoE dte(FlushE, clk, reset, RegWriteD, MemtoRegD, MemWriteD,
                    ALUControlD,
                    AluSrcD, RegDstD, BranchD,
                    RD1D, RD2D,
                    RsD, RtD, RdD,
                    SignImmD,
                    PCPlus4D,
                    RegWriteE, MemtoRegE, MemWriteE,
                    AluControlE,
                    AluSrcE, RegDstE, BranchE,
                    RD1E, RD2E,
                    RsE, RtE, RdE,
                    SignImmE,
                    PCPlus4E);
    mux2 #(5) mux2EWriteReg(RtE, RdE,
                 RegDstE,
                  WriteRegE);

    mux2 #(32) mux2ESrcBE(WriteDataE, SignImmE,
                AluSrcE,
                SrcBE);
    mux4 #(32) mux3ESrcAE(RD1E, ResultW, ALUOutM, 0,
                  ForwardAE,
                  SrcAE);

    mux4 #(32) mux3EWriteDataE(RD2E, ResultW, ALUOutM, 0,
               ForwardBE,
                WriteDataE);

    sl2 shiftSignImmE(SignImmE,
                SignImmEShifted);

    adder adderPCBranchM(SignImmEShifted, PCPlus4E, PCBranchE);

    alu alu1(SrcAE, SrcBE,
               AluControlE,
               ALUOut,
               Zero, reset);
    PipeEtoM etm( clk, reset, RegWriteE, MemtoRegE, MemWriteE, BranchE, Zero,
                    ALUOut,
                    WriteDataE,
                    WriteRegE,
                    PCBranchE,
                    RegWriteM, MemtoRegM, MemWriteM, BranchM, ZeroM,
                    ALUOutM,
                    WriteDataM,
                    WriteRegM,
                    PCBranchM);

    dmem dataMemory( clk, MemWriteM,
                 ALUOutM, WriteDataM,
                 ReadDataM);

    PipeMtoW mtw(clk, reset, RegWriteM, MemtoRegM,
                    ReadDataM, ALUOutM,
                    WriteRegM,
                    RegWriteW, MemtoRegW,
                    ReadDataW, ALUOutW,
                    WriteRegW);

    mux2 #(32) mux2WResultW( ALUOutW, ReadDataW, 
                MemtoRegW,
                ResultW);
                
    HazardUnit hazardUnit( RegWriteW,
                 WriteRegW,
                RegWriteM,MemtoRegM,
                WriteRegM,
                RegWriteE,MemtoRegE,
                RsE,RtE,
                RsD,RtD,
                ForwardAE,ForwardBE,
                FlushE,StallD,StallF);


endmodule


module HazardUnit( input logic RegWriteW,
                input logic [4:0] WriteRegW,
                input logic RegWriteM,MemToRegM,
                input logic [4:0] WriteRegM,
                input logic RegWriteE,MemtoRegE,
                input logic [4:0] rsE,rtE,
                input logic [4:0] rsD,rtD,
                output logic [1:0] ForwardAE,ForwardBE,
                output logic FlushE,StallD,StallF);

    logic lwstall;
    always_comb begin

        // ********************************************************************
        // Here, write equations for the Hazard Logic.
        // If you have troubles, please study pages ~420-430 in your book.
        // ********************************************************************

        lwstall = ((rsD == rtE) | (rtD == rtE)) & MemtoRegE;
        StallF <= lwstall;
        StallD <= lwstall;
        FlushE <= lwstall;

        // for forwarding
        if ((rsE != 5'd0) & (rsE == WriteRegM) & RegWriteM)
        begin
         ForwardAE = 2'b10;
        end
        else if ((rsE != 5'd0) & (rsE == WriteRegW) & RegWriteW)
        begin
            ForwardAE = 2'b01;
        end
        else
            ForwardAE = 2'b00;
            
        if ((rtE != 5'd0) & (rtE == WriteRegM) & RegWriteM)
        begin
         ForwardBE = 2'b10;
        end
        else if ((rtE != 5'd0) & (rtE == WriteRegW) & RegWriteW)
        begin
            ForwardBE = 2'b01;
        end
        else
            ForwardBE = 2'b00;
    end

endmodule


module mips (input  logic clk, reset,
             output logic[31:0]  PCF,
             input  logic[31:0]  instr,
             output logic[31:0]  aluout, resultW,
             output logic[31:0]  instrOut, WriteDataM,
             output logic StallD, StallF);

    logic memtoreg, zero, alusrc, regdst, regwrite, jump, PCSrcM, branch, memwrite;
    logic [31:0] PCPlus4F, PCm, PCBranchM, instrD;
    logic [2:0] alucontrol;
    assign instrOut = instr;

    
    controller c (instrD[31:26], instrD[5:0],
                        memtoreg, memwrite,
                        alusrc,
                        regdst, regwrite,
                        jump,
                        alucontrol,
                        branch);

    datapath dp (clk, reset,
    		     PCF, instr,
    		      regwrite, memtoreg, memwrite,
    		      alucontrol,
    		      alusrc, regdst, branch,
    		      PCSrcM, StallD, StallF,
    		      PCBranchM, PCPlus4F, instrD, aluout, resultW, WriteDataM);

    PipeWtoF wtf(PCm,
            ~StallF, clk, reset,
            PCF);

    mux2 #(32) pcsrcmux(PCPlus4F, PCBranchM,
                PCSrcM,
                PCm);
endmodule




module imem ( input logic [5:0] addr, output logic [31:0] instr);

// imem is modeled as a lookup table, a stored-program byte-addressable ROM
	always_comb
	   case ({addr,2'b00})		   	// word-aligned fetch

            8'h00: instr = 32'h00008020;
            8'h04: instr = 32'h20090005;
            8'h08: instr = 32'h02115025;
            8'h0c: instr = 32'h0149a02a;
            8'h10: instr = 32'h018a6822;
            8'h14: instr = 32'h00004020;
            8'h18: instr = 32'h21090004;
            8'h1c: instr = 32'h8d310000;
            8'h20: instr = 32'h01115020;
            8'h24: instr = 32'h00004020;
            8'h28: instr = 32'h20090005;
            8'h2c: instr = 32'h8d100000;
            8'h30: instr = 32'h200a0001;
            8'h34: instr = 32'h2011000a;
            8'h38: instr = 32'h01097020;
            8'h3c: instr = 32'h0149a82a;
            8'h40: instr = 32'h022a6025;
	     default:  instr = {32{1'bx}};	// unknown address
	   endcase
endmodule



module controller(input  logic[5:0] op, funct,
                  output logic     memtoreg, memwrite,
                  output logic     alusrc,
                  output logic     regdst, regwrite,
                  output logic     jump,
                  output logic[2:0] alucontrol,
                  output logic branch);

   logic [1:0] aluop;

   maindec md (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite,
         jump, aluop);

   aludec  ad (funct, aluop, alucontrol);

endmodule

// External data memory used by MIPS single-cycle processor

module dmem (input  logic        clk, we,
             input  logic[31:0]  a, wd,
             output logic[31:0]  rd);

   logic  [31:0] RAM[63:0];

   assign rd = RAM[a[31:2]];    // word-aligned  read (for lw)

   always_ff @(posedge clk)
     if (we)
       RAM[a[31:2]] <= wd;      // word-aligned write (for sw)

endmodule

module maindec (input logic[5:0] op,
	              output logic memtoreg, memwrite, branch,
	              output logic alusrc, regdst, regwrite, jump,
	              output logic[1:0] aluop );
   logic [8:0] controls;

   assign {regwrite, regdst, alusrc, branch, memwrite,
                memtoreg,  aluop, jump} = controls;

  always_comb
    case(op)
      6'b000000: controls <= 9'b110000100; // R-type
      6'b100011: controls <= 9'b101001000; // LW
      6'b101011: controls <= 9'b001010000; // SW
      6'b000100: controls <= 9'b000100010; // BEQ
      6'b001000: controls <= 9'b101000000; // ADDI
      6'b000010: controls <= 9'b000000001; // J
      default:   controls <= 9'bxxxxxxxxx; // illegal op
    endcase
endmodule

module aludec (input    logic[5:0] funct,
               input    logic[1:0] aluop,
               output   logic[2:0] alucontrol);
  always_comb
    case(aluop)
      2'b00: alucontrol  = 3'b010;  // add  (for lw/sw/addi)
      2'b01: alucontrol  = 3'b110;  // sub   (for beq)
      default: case(funct)          // R-TYPE instructions
          6'b100000: alucontrol  = 3'b010; // ADD
          6'b100010: alucontrol  = 3'b110; // SUB
          6'b100100: alucontrol  = 3'b000; // AND
          6'b100101: alucontrol  = 3'b001; // OR
          6'b101010: alucontrol  = 3'b111; // SLT
          default:   alucontrol  = 3'bxxx; // ???
        endcase
    endcase
endmodule

module regfile (input    logic clk, we3,
                input    logic[4:0]  ra1, ra2, wa3,
                input    logic[31:0] wd3,
                output   logic[31:0] rd1, rd2);

  logic [31:0] rf [31:0];

  // three ported register file: read two ports combinationally
  // write third port on rising edge of clock. Register0 hardwired to 0.

  always_ff @(negedge clk)
     if (we3)
         rf [wa3] <= wd3;

  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;

endmodule

module alu(input  logic [31:0] a, b,
           input  logic [2:0]  alucont,
           output logic [31:0] result,
           output logic zero, input logic reset);

    always_comb begin
        case(alucont)
            3'b010: result = a + b;
            3'b110: result = a - b;
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b111: result = (a < b) ? 1 : 0;
            default: result = {32{1'bx}};
        endcase
        if(reset)
            result <= 0;
        end

    assign zero = (result == 0) ? 1'b1 : 1'b0;

endmodule

module adder (input  logic[31:0] a, b,
              output logic[31:0] y);

     assign y = a + b;
endmodule

module sl2 (input  logic[31:0] a,
            output logic[31:0] y);

     assign y = {a[29:0], 2'b00}; // shifts left by 2
endmodule

module signext (input  logic[15:0] a,
                output logic[31:0] y);

  assign y = {{16{a[15]}}, a};    // sign-extends 16-bit a
endmodule

// parameterized register
module flopr #(parameter WIDTH = 8)
              (input logic clk, reset,
	       input logic[WIDTH-1:0] d,
               output logic[WIDTH-1:0] q);

  always_ff@(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule


// paramaterized 2-to-1 MUX
module mux2 #(parameter WIDTH = 8)
             (input  logic[WIDTH-1:0] d0, d1,
              input  logic s,
              output logic[WIDTH-1:0] y);

   assign y = s ? d1 : d0;
endmodule

// paramaterized 4-to-1 MUX
module mux4 #(parameter WIDTH = 8)
             (input  logic[WIDTH-1:0] d0, d1, d2, d3,
              input  logic[1:0] s,
              output logic[WIDTH-1:0] y);

   assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0);
endmodule
