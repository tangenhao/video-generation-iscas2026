//  --========================================================================--
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from ARM Limited
//     (C) COPYRIGHT 2003-2006 ARM Limited
//           ALL RIGHTS RESERVED
//  The entire notice above must be reproduced on all authorised
//  copies and copies may only be made to the extent permitted
//  by a licensing agreement from ARM Limited.
//
//  ----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Name           : AsyncAxiFifo8.v,v
//  File Revision       : 1.3
//
//  Release Information : PL301-r1p1-00rel0
//
//  ----------------------------------------------------------------------------
//  Purpose             : 8-deep FIFO for AXI to AXI asynchronous bridge
//                        with bypass
//
//  --========================================================================--


module AsyncAxiFifo8
  (
   // Inputs
   CLKU,
   RESETUn,
   VALIDU,
   DATAU,
   CLKD,
   RESETDn,
   READYD,
   SYNCMODEREQ,
   // Outputs
   READYU,
   VALIDD,
   DATAD,
   SYNCMODEACK
   );
   
   parameter               DATAWIDTH = 64;

   parameter               PTRWIDTH = 4;
   
   input                   CLKU;        // upstream CLK
   input                   RESETUn;     // upstream RESETn
   input                   VALIDU;      // upstream VALID
   input [DATAWIDTH-1:0]   DATAU;       // upstream DATA
   
   input                   CLKD;        // downstream CLK
   input                   RESETDn;     // downstream RESETn
   input                   READYD;      // downstream READY
   
   input                   SYNCMODEREQ; // request entry to bypass mode
   
   output                  READYU;      // upstream READY
   output                  VALIDD;      // downstream VALID
   output [DATAWIDTH-1:0]  DATAD;       // downstream DATA
   
   output                  SYNCMODEACK; // acknowledge entry to bypass mode

   wire                    WrBy;        // the SYNCMODEACK from write to 
                                        // SYNCMODEREQ for read
   wire [PTRWIDTH-1:0]     RdPtrG;      // read pointer between read and write
   wire [PTRWIDTH-1:0]     WrPtrG;      // write pointer between write and read
   wire [DATAWIDTH-1:0]    Reg0;        // data0
   wire [DATAWIDTH-1:0]    Reg1;        // data1
   wire [DATAWIDTH-1:0]    Reg2;        // data2
   wire [DATAWIDTH-1:0]    Reg3;        // data3
   wire [DATAWIDTH-1:0]    Reg4;        // data4
   wire [DATAWIDTH-1:0]    Reg5;        // data5
   wire [DATAWIDTH-1:0]    Reg6;        // data6
   wire [DATAWIDTH-1:0]    Reg7;        // data7
   wire                    VALIDBypass; // bypassed VALID
   wire                    READYBypass; // bypassed READY
   wire [DATAWIDTH-1:0]    DATABypass;  // bypassed DATA
   
   AsyncAxiFifo8Wr #(DATAWIDTH) uWr
     (
      .RESETn(RESETUn),
      // the Axi i/f
      .CLK(CLKU),
      .VALID(VALIDU),
      .READY(READYU),
      .DATA(DATAU),
      // the data flow stuff
      .WrPtrG(WrPtrG),
      .RdPtrG(RdPtrG),
      .Reg0(Reg0),
      .Reg1(Reg1),
      .Reg2(Reg2),
      .Reg3(Reg3),
      .Reg4(Reg4),
      .Reg5(Reg5),
      .Reg6(Reg6),
      .Reg7(Reg7),
      // the bypass stuff
      .ByReq(SYNCMODEREQ),
      .ByAck(WrBy),
      .VALIDBypass(VALIDBypass),
      .READYBypass(READYBypass),
      .DATABypass(DATABypass)
     );
   
   AsyncAxiFifo8Rd #(DATAWIDTH) uRd
     (
      .RESETn(RESETDn),
      // the Axi i/f
      .CLK(CLKD),
      .VALID(VALIDD),
      .READY(READYD),
      .DATA(DATAD),
      // the data flow stuff
      .WrPtrG(WrPtrG),
      .RdPtrG(RdPtrG),
      .Reg0(Reg0),
      .Reg1(Reg1),
      .Reg2(Reg2),
      .Reg3(Reg3),
      .Reg4(Reg4),
      .Reg5(Reg5),
      .Reg6(Reg6),
      .Reg7(Reg7),
      // the bypass stuff
      .ByReq(WrBy),
      .ByAck(SYNCMODEACK),
      .VALIDBypass(VALIDBypass),
      .READYBypass(READYBypass),
      .DATABypass(DATABypass)
     );

endmodule // AsyncAxiFifo8

//  --=============================== End =================================--
