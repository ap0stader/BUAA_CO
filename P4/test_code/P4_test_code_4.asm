.text
ori $s0,10
ori $s7,$s0,10
loop:
 beq $t0,$s0,loopout
 lw $s1,0($t1)
 addu $t1,$t1,4
 lw $s2,0($t1)
 addu $s3,$s1,$s7
 addu $s2,$s2,$s3
 sw $s2,0($t1)
 addu $t0,$t0,1
 jal loop
loopout:
