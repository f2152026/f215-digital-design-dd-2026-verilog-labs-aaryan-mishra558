// cla4.v
module cla4(
  input  [3:0] a,
  input  [3:0] b,
  input        cin,
  output [3:0] sum,
  output       cout
);

  wire p0, p1, p2, p3;
  wire g0, g1, g2, g3;
  wire c1, c2, c3;

  // Intermediate wires for the AND terms
  wire w_p0_cin;
  wire w_p1_g0, w_p1_p0_cin;
  wire w_p2_g1, w_p2_p1_g0, w_p2_p1_p0_cin;
  wire w_p3_g2, w_p3_p2_g1, w_p3_p2_p1_g0, w_p3_p2_p1_p0_cin;

  // Step 1: generate/propagate signals
  xor #(2) (p0, a[0], b[0]);
  and #(2) (g0, a[0], b[0]);
  
  xor #(2) (p1, a[1], b[1]);
  and #(2) (g1, a[1], b[1]);
  
  xor #(2) (p2, a[2], b[2]);
  and #(2) (g2, a[2], b[2]);
  
  xor #(2) (p3, a[3], b[3]);
  and #(2) (g3, a[3], b[3]);

  // Step 2: direct carry equations
  and #(2) (w_p0_cin, p0, cin);
  or  #(2) (c1, g0, w_p0_cin);

  and #(2) (w_p1_g0, p1, g0);
  and #(2) (w_p1_p0_cin, p1, p0, cin);
  or  #(2) (c2, g1, w_p1_g0, w_p1_p0_cin);

  and #(2) (w_p2_g1, p2, g1);
  and #(2) (w_p2_p1_g0, p2, p1, g0);
  and #(2) (w_p2_p1_p0_cin, p2, p1, p0, cin);
  or  #(2) (c3, g2, w_p2_g1, w_p2_p1_g0, w_p2_p1_p0_cin);

  and #(2) (w_p3_g2, p3, g2);
  and #(2) (w_p3_p2_g1, p3, p2, g1);
  and #(2) (w_p3_p2_p1_g0, p3, p2, p1, g0);
  and #(2) (w_p3_p2_p1_p0_cin, p3, p2, p1, p0, cin);
  or  #(2) (cout, g3, w_p3_g2, w_p3_p2_g1, w_p3_p2_p1_g0, w_p3_p2_p1_p0_cin);

  // Step 3: sum bits
  xor #(2) (sum[0], p0, cin);
  xor #(2) (sum[1], p1, c1);
  xor #(2) (sum[2], p2, c2);
  xor #(2) (sum[3], p3, c3);

endmodule