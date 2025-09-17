module cla16 (
    input  [15:0] a, b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    wire [15:0] p, g; 
    wire [16:0] c;       

    assign c[0] = cin;

    // bitwise propagate and generate
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : pg_block
            xor (p[i], a[i], b[i]);  
            and (g[i], a[i], b[i]);  
        end
    endgenerate

    // carry lookahead logic
    generate
        for (i = 1; i <= 16; i = i + 1) begin : carry_block
            wire temp1, temp2;
            and (temp1, p[i-1], c[i-1]);
            or  (c[i], g[i-1], temp1);
        end
    endgenerate

    // sum bits
    generate
        for (i = 0; i < 16; i = i + 1) begin : sum_block
            xor (sum[i], p[i], c[i]);
        end
    endgenerate

    assign cout = c[16];

endmodule

// implement 16 + 16 Cla to 32 bits cla
module cla32 (
    input  [31:0] a, b,
    input         cin,
    output [31:0] sum,
    output        cout
);

    wire c16;

    cla16 cla_low (
        .a   (a[15:0]),
        .b   (b[15:0]),
        .cin (cin),
        .sum (sum[15:0]),
        .cout(c16)
    );

    cla16 cla_high (
        .a   (a[31:16]),
        .b   (b[31:16]),
        .cin (c16),
        .sum (sum[31:16]),
        .cout(cout)
    );

endmodule
