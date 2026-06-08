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
//  File Name           : AsyncAxiNxtGray8.v,v
//  File Revision       : 1.3
//
//  Release Information : PL301-r1p1-00rel0
//
//  ----------------------------------------------------------------------------
//  Purpose             : Calculates the next 16 value Gray value.
//
//  --========================================================================--


module AsyncAxiNxtGray8
  (
   Curr,
   Nxt
   );
   
   input  [3:0] Curr; // Current gray encoded signal
   output [3:0] Nxt;  // Next gray encoded signal
   
   reg [3:0]    Nxt;
   
   // compute the next value in the Gray code
   always @(Curr)
     begin : p_NextG8
        case (Curr)
          4'b0000  : Nxt = 4'b0001;
          4'b0001  : Nxt = 4'b0011;
          4'b0011  : Nxt = 4'b0010;
          4'b0010  : Nxt = 4'b0110;
          4'b0110  : Nxt = 4'b0111;
          4'b0111  : Nxt = 4'b0101;
          4'b0101  : Nxt = 4'b0100;
          4'b0100  : Nxt = 4'b1100;
          4'b1100  : Nxt = 4'b1101;
          4'b1101  : Nxt = 4'b1111;
          4'b1111  : Nxt = 4'b1110;
          4'b1110  : Nxt = 4'b1010;
          4'b1010  : Nxt = 4'b1011;
          4'b1011  : Nxt = 4'b1001;
          4'b1001  : Nxt = 4'b1000;
          4'b1000  : Nxt = 4'b0000;
          default : Nxt = 4'bxxxx;
        endcase
     end // block: p_NextG8
   
endmodule // AsyncAxiNxtGray8

//  --=============================== End =================================--
