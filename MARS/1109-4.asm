.text
# $t0表示判断的结果
li $a0, 0

# 获取输入的年份，保存在$t1
li $v0, 5
syscall
move $t1, $v0

# $3 判断1：是否能被4整除
li $t2, 4
div	$t1, $t2
mfhi $t3

# $4 判断2：能否被100整除
li $t2, 100
div $t1, $t2
mfhi $t4

# $5 判断3：能否被400整除
li $t2, 400
div $t1, $t2
mfhi $t5

# 能被100整除则跳转
beq $t4, $0, if_1_else
    # 不能被100整除，判断是否能被4整除
    bne $t3, $0, if_1_end
    li $a0, 1

if_1_else:
    # 能被100整除，判断能否能否被400整除
    bne $t5, $0, if_1_end
    li $a0, 1

if_1_end:
    li $v0, 1
    syscall

    li $v0, 10
    syscall
