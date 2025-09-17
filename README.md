## Name: Edward (YuKai) Huang, NetId: yh475
I using two 16 bits CLA to implement this project. And in the 16 bits CLA module, input 16 bits a and b plus carry-in cin, it would have a 16 bits carry out.
By computing propagate and generate for each bit using primitive gates. Then carry for each bit. Final sum for each bit is propagate ^ carry and carry out is the last cary in that chain. 

Then combine two 16 bits CLA to a 32-bits CLA. First CLA computes the lower 16 bits and the second one computes the upper 16 bits.

Since it cannot using == !=....., I must use logic gates. So I build some signals to help.

-Extract sign bits
```
wire sign_a, sign_b, sign_res;
assign sign_a   = data_operandA[31]; 
assign sign_b   = data_operandB[31]; 
assign sign_res = sum[31]; 
```
-Helper XOR Signals
```
wire ab_xor, res_diff_a;
xor (ab_xor, sign_a, sign_b); 
xor (res_diff_a, sign_res, sign_a); 
```

-Addition Overflow: = (~(sign_a ^ sign_b)) & (sign_res ^ sign_a)
```
wire not_ab_xor, ovf_add;
not (not_ab_xor, ab_xor);
and (ovf_add, not_ab_xor, res_diff_a);
```

-Subtraction Overflow = (sign_a ^ sign_b) & (sign_res ^ sign_a)
```
wire ovf_sub;
and (ovf_sub, ab_xor, res_diff_a);
```

-Opcode Decoding
```
wire ovf_add_sel, ovf_sub_sel;
and (ovf_add_sel, ovf_add, is_add);
and (ovf_sub_sel, ovf_sub, is_sub);
or  (overflow, ovf_add_sel, ovf_sub_sel);
```

The overflow is only asserted for add and sub opcodes, all other operations would forced to 0.
