module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt,
           data_result, isNotEqual, isLessThan, overflow);

    input  [31:0] data_operandA, data_operandB;
    input  [4:0]  ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output        isNotEqual, isLessThan, overflow;

    wire [31:0] B_in, sum;
    wire [31:0] carry;
    wire        add_sub;
    wire        c_out;

    // ALU opcode
    assign add_sub = ctrl_ALUopcode[0]; 

    assign B_in = data_operandB ^ {32{add_sub}}; 

    cla32 adder32 (.a(data_operandA), .b(B_in), .cin(add_sub), .sum(sum), .cout(c_out));

    assign data_result = sum;

	 // Overflow
    wire sign_a, sign_b, sign_res;
    assign sign_a   = data_operandA[31];
    assign sign_b   = data_operandB[31];  // original B (not inverted)
    assign sign_res = sum[31];

    // XOR helpers
    wire ab_xor, res_diff_a;
    xor (ab_xor, sign_a, sign_b);      // 1 if signs differ
    xor (res_diff_a, sign_res, sign_a);// 1 if result sign != A sign

    // ADD overflow = (~(sign_a ^ sign_b)) & (sign_res ^ sign_a)
    wire not_ab_xor, ovf_add;
    not (not_ab_xor, ab_xor);
    and (ovf_add, not_ab_xor, res_diff_a);

    // SUB overflow = (sign_a ^ sign_b) & (sign_res ^ sign_a)
    wire ovf_sub;
    and (ovf_sub, ab_xor, res_diff_a);

    // Decode opcodes structurally
    wire not_op0, not_op1, not_op2, not_op3, not_op4;
    not (not_op0, ctrl_ALUopcode[0]);
    not (not_op1, ctrl_ALUopcode[1]);
    not (not_op2, ctrl_ALUopcode[2]);
    not (not_op3, ctrl_ALUopcode[3]);
    not (not_op4, ctrl_ALUopcode[4]);

    // is_add = 00000
    wire is_add;
    and (is_add, not_op0, not_op1, not_op2, not_op3, not_op4);

    // is_sub = 00001
    wire is_sub;
    and (is_sub, ctrl_ALUopcode[0], not_op1, not_op2, not_op3, not_op4);

    // Select overflow only for ADD or SUB
    wire ovf_add_sel, ovf_sub_sel;
    and (ovf_add_sel, ovf_add, is_add);
    and (ovf_sub_sel, ovf_sub, is_sub);
    or  (overflow, ovf_add_sel, ovf_sub_sel);

endmodule


