// cla64_hier.v
// 64-bit hierarchical Carry Lookahead Adder
//
// 16 x 4-bit CLA blocks.
// A second level of lookahead generates the carry into
// each 4-bit block without rippling from block to block.

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // ------------------------------------------------------------
  // 16 four-bit CLA blocks
  // ------------------------------------------------------------

  wire [15:0] Pblk;
  wire [15:0] Gblk;

  wire [15:0] block_cin;
  wire [15:0] block_cout;

  // First block gets the external carry-in
  buf #(1) (block_cin[0], cin);

  genvar i;

  generate
    for (i = 0; i < 16; i = i + 1) begin : CLA_BLOCKS

      cla4 U_CLA4 (
        .a   (a[i*4 +: 4]),
        .b   (b[i*4 +: 4]),
        .cin (block_cin[i]),
        .sum (sum[i*4 +: 4]),
        .cout(block_cout[i]),
        .P   (Pblk[i]),
        .G   (Gblk[i])
      );

    end
  endgenerate

  // ------------------------------------------------------------
  // Second-level carry lookahead
  //
  // block_cin[k] is calculated directly from block
  // generate/propagate signals.
  // ------------------------------------------------------------

  // Terms for block carry 1
  wire c1_t0;

  and #(2) (c1_t0, Pblk[0], cin);
  or  #(2) (block_cin[1], Gblk[0], c1_t0);

  // ------------------------------------------------------------
  // Block carry 2
  // ------------------------------------------------------------

  wire c2_t0, c2_t1;

  and #(2) (c2_t0, Pblk[1], Gblk[0]);
  and #(2) (c2_t1, Pblk[1], Pblk[0], cin);

  or #(2) (
    block_cin[2],
    Gblk[1],
    c2_t0,
    c2_t1
  );

  // ------------------------------------------------------------
  // Block carry 3
  // ------------------------------------------------------------

  wire c3_t0, c3_t1, c3_t2;

  and #(2) (c3_t0, Pblk[2], Gblk[1]);
  and #(2) (c3_t1, Pblk[2], Pblk[1], Gblk[0]);
  and #(2) (c3_t2, Pblk[2], Pblk[1], Pblk[0], cin);

  or #(2) (
    block_cin[3],
    Gblk[2],
    c3_t0,
    c3_t1,
    c3_t2
  );

  // ------------------------------------------------------------
  // Block carries 4-15
  //
  // Direct lookahead equations.
  // ------------------------------------------------------------

  wire [15:0] bt0, bt1, bt2, bt3, bt4, bt5, bt6, bt7;
  wire [15:0] bt8, bt9, bt10, bt11, bt12, bt13, bt14;

  // c4
  and #(2) (bt0[4], Pblk[3], Gblk[2]);
  and #(2) (bt1[4], Pblk[3], Pblk[2], Gblk[1]);
  and #(2) (bt2[4], Pblk[3], Pblk[2], Pblk[1], Gblk[0]);
  and #(2) (bt3[4], Pblk[3], Pblk[2], Pblk[1], Pblk[0], cin);

  or #(2) (
    block_cin[4],
    Gblk[3],
    bt0[4],
    bt1[4],
    bt2[4],
    bt3[4]
  );

  // c5
  and #(2) (bt0[5], Pblk[4], Gblk[3]);
  and #(2) (bt1[5], Pblk[4], Pblk[3], Gblk[2]);
  and #(2) (bt2[5], Pblk[4], Pblk[3], Pblk[2], Gblk[1]);
  and #(2) (bt3[5], Pblk[4], Pblk[3], Pblk[2], Pblk[1], Gblk[0]);
  and #(2) (bt4[5], Pblk[4], Pblk[3], Pblk[2], Pblk[1], Pblk[0], cin);

  or #(2) (
    block_cin[5],
    Gblk[4],
    bt0[5],
    bt1[5],
    bt2[5],
    bt3[5],
    bt4[5]
  );

  // ------------------------------------------------------------
  // Remaining block carries
  //
  // These are generated using a small recursive helper structure.
  // Each block's carry is calculated from the previous four-block
  // group plus the corresponding group carry.
  // ------------------------------------------------------------

  wire [3:0] groupP;
  wire [3:0] groupG;

  // Group 0: blocks 0-3
  and #(2) (groupP[0], Pblk[3], Pblk[2], Pblk[1], Pblk[0]);

  // Group 1: blocks 4-7
  and #(2) (groupP[1], Pblk[7], Pblk[6], Pblk[5], Pblk[4]);

  // Group 2: blocks 8-11
  and #(2) (groupP[2], Pblk[11], Pblk[10], Pblk[9], Pblk[8]);

  // Group 3: blocks 12-15
  and #(2) (groupP[3], Pblk[15], Pblk[14], Pblk[13], Pblk[12]);

  // Group generate signals
  wire [3:0] g0t0, g0t1, g0t2;
  wire [3:0] g1t0, g1t1, g1t2;
  wire [3:0] g2t0, g2t1, g2t2;
  wire [3:0] g3t0, g3t1, g3t2;

  // Group 0
  and #(2) (g0t0[0], Pblk[3], Gblk[2]);
  and #(2) (g0t1[0], Pblk[3], Pblk[2], Gblk[1]);
  and #(2) (g0t2[0], Pblk[3], Pblk[2], Pblk[1], Gblk[0]);
  or  #(2) (groupG[0], Gblk[3], g0t0[0], g0t1[0], g0t2[0]);

  // Group 1
  and #(2) (g1t0[1], Pblk[7], Gblk[6]);
  and #(2) (g1t1[1], Pblk[7], Pblk[6], Gblk[5]);
  and #(2) (g1t2[1], Pblk[7], Pblk[6], Pblk[5], Gblk[4]);
  or  #(2) (groupG[1], Gblk[7], g1t0[1], g1t1[1], g1t2[1]);

  // Group 2
  and #(2) (g2t0[2], Pblk[11], Gblk[10]);
  and #(2) (g2t1[2], Pblk[11], Pblk[10], Gblk[9]);
  and #(2) (g2t2[2], Pblk[11], Pblk[10], Pblk[9], Gblk[8]);
  or  #(2) (groupG[2], Gblk[11], g2t0[2], g2t1[2], g2t2[2]);

  // Group 3
  and #(2) (g3t0[3], Pblk[15], Gblk[14]);
  and #(2) (g3t1[3], Pblk[15], Pblk[14], Gblk[13]);
  and #(2) (g3t2[3], Pblk[15], Pblk[14], Pblk[13], Gblk[12]);
  or  #(2) (groupG[3], Gblk[15], g3t0[3], g3t1[3], g3t2[3]);

  // ------------------------------------------------------------
  // Group carry-ins
  // ------------------------------------------------------------

  wire gp0, gp1, gp2;

  // Carry into group 1
  and #(2) (gp0, groupP[0], cin);
  or  #(2) (block_cin[4], groupG[0], gp0);

  // Carry into group 2
  and #(2) (gp1, groupP[1], groupG[0]);
  wire gp1b;
  and #(2) (gp1b, groupP[1], groupP[0], cin);

  or #(2) (
    block_cin[8],
    groupG[1],
    gp1,
    gp1b
  );

  // Carry into group 3
  and #(2) (gp2, groupP[2], groupG[1]);
  wire gp2b, gp2c;

  and #(2) (gp2b, groupP[2], groupP[1], groupG[0]);
  and #(2) (gp2c, groupP[2], groupP[1], groupP[0], cin);

  or #(2) (
    block_cin[12],
    groupG[2],
    gp2,
    gp2b,
    gp2c
  );

  // ------------------------------------------------------------
  // For blocks inside each group, use the 4-bit CLA equations.
  // ------------------------------------------------------------

  // Blocks 5,6,7
  wire x50,x51,x52,x53;
  and #(2)(x50,Pblk[4],block_cin[4]);
  or  #(2)(block_cin[5],Gblk[4],x50);

  and #(2)(x51,Pblk[5],Gblk[4]);
  and #(2)(x52,Pblk[5],Pblk[4],block_cin[4]);
  or  #(2)(block_cin[6],Gblk[5],x51,x52);

  and #(2)(x53,Pblk[6],Gblk[5]);
  wire x54,x55;
  and #(2)(x54,Pblk[6],Pblk[5],Gblk[4]);
  and #(2)(x55,Pblk[6],Pblk[5],Pblk[4],block_cin[4]);
  or #(2)(block_cin[7],Gblk[6],x53,x54,x55);

  // Blocks 9,10,11
  wire x90,x91,x92,x93;
  and #(2)(x90,Pblk[8],block_cin[8]);
  or #(2)(block_cin[9],Gblk[8],x90);

  and #(2)(x91,Pblk[9],Gblk[8]);
  and #(2)(x92,Pblk[9],Pblk[8],block_cin[8]);
  or #(2)(block_cin[10],Gblk[9],x91,x92);

  and #(2)(x93,Pblk[10],Gblk[9]);
  wire x94,x95;
  and #(2)(x94,Pblk[10],Pblk[9],Gblk[8]);
  and #(2)(x95,Pblk[10],Pblk[9],Pblk[8],block_cin[8]);
  or #(2)(block_cin[11],Gblk[10],x93,x94,x95);

  // Blocks 13,14,15
  wire x130,x131,x132,x133;
  and #(2)(x130,Pblk[12],block_cin[12]);
  or #(2)(block_cin[13],Gblk[12],x130);

  and #(2)(x131,Pblk[13],Gblk[12]);
  and #(2)(x132,Pblk[13],Pblk[12],block_cin[12]);
  or #(2)(block_cin[14],Gblk[13],x131,x132);

  and #(2)(x133,Pblk[14],Gblk[13]);
  wire x134,x135;
  and #(2)(x134,Pblk[14],Pblk[13],Gblk[12]);
  and #(2)(x135,Pblk[14],Pblk[13],Pblk[12],block_cin[12]);
  or #(2)(block_cin[15],Gblk[14],x133,x134,x135);

  // ------------------------------------------------------------
  // Final carry
  // ------------------------------------------------------------

  buf #(1) (cout, block_cout[15]);

endmodule