li $t1, -17
li $t2, 2

mult $t1, $t2
mflo $s0
mfhi $s1

multu $t1, $t2
mflo $s2
mfhi $s3

div $t1, $t2
mflo $s4
mfhi $s5

divu $t1, $t2
mflo $s6
mfhi $s7

mthi $t1
mtlo $t2

mfhi $t3
mflo $t4

nop