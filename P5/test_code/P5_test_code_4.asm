# TEST: F1
# Sel == 00 Tuse_rs == 1
# ==== PREPARE ====
ori $21, 4
ori $22, 8
# 等待准备过程彻底完成
nop
nop
nop
# ==== START ====
add $1, $21, $22
nop
nop
ori $11, $1, 0
# ==== RECOVER ====
andi $21, 0
andi $22, 0
andi $1, 0
andi $11, 0
# 等待准备过程彻底完成
nop
nop
nop
