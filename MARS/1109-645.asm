func:
blez $a1, loop_end
nop

loop:
div $a0, $a1
mfhi $a0
xor $a0, $a0, $a1
xor $a1, $a1, $a0
xor $a0, $a0, $a1
bgtz $a1, loop
nop

loop_end:
move $v0, $a0
jr $ra
nop