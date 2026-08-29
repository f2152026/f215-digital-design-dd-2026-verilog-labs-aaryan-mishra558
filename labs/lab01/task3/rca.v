// rca.v

// Full Adder Gate
module FA_Gate(
  input  a,
  input  b,
  input  cin,
  output sum,
  output cout
);

  wire x1;
  wire c1;
  wire c2;

  xor #(2) X1(x1, a, b);
  xor #(2) X2(sum, x1, cin);

  and #(2) A1(c1, a, b);
  and #(2) A2(c2, x1, cin);

  or #(2) O1(cout, c1, c2);

endmodule


// 4-bit Ripple Carry Adder
module rca(
  input  [3:0] a,
  input  [3:0] b,
  input        cin,
  output [3:0] sum,
  output       cout
);

  wire c1, c2, c3;

  FA_Gate FA0 (
    .a(a[0]),
    .b(b[0]),
    .cin(cin),
    .sum(sum[0]),
    .cout(c1)
  );

  FA_Gate FA1 (
    .a(a[1]),
    .b(b[1]),
    .cin(c1),
    .sum(sum[1]),
    .cout(c2)
  );

  FA_Gate FA2 (
    .a(a[2]),
    .b(b[2]),
    .cin(c2),
    .sum(sum[2]),
    .cout(c3)
  );

  FA_Gate FA3 (
    .a(a[3]),
    .b(b[3]),
    .cin(c3),
    .sum(sum[3]),
    .cout(cout)
  );

endmodule