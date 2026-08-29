module dut(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // Option 1: RCA
  rca64 U_IMPL (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  // Option 2: flat CLA
  // cla64_flat U_IMPL (
  //   .a(a),
  //   .b(b),
  //   .cin(cin),
  //   .sum(sum),
  //   .cout(cout)
  // );

  // Option 3: blocked CLA
  // cla64_blocked U_IMPL (
  //   .a(a),
  //   .b(b),
  //   .cin(cin),
  //   .sum(sum),
  //   .cout(cout)
  // );

endmodule