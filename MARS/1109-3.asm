.data
# 矩阵最大为49x49，占用空间为49x49x4=9604
matrix: .space 9604
space: .asciiz " "
enter: .asciiz "\n"

# 计算得到给定行列后的地址，保存到$t7
# 行列均从0开始
.macro get_address(%element_of_row, %row, %column)
    mult %row, %element_of_row
    mflo $t7
    addu $t7, $t7, %column
    sll $t7, $t7, 2
.end_macro

.text

# $t0 行数n
li $v0, 5
syscall
move $t0, $v0

# $t1 列数m
li $v0, 5
syscall
move $t1, $v0


# $t2 外层循环变量
li $t2, 0
for_begin_1:
    slt $t3, $t2, $t0
    beq $t3, $zero, for_end_1

    # $t3 内层循环变量
    li $t3, 0
    for_begin_2:
        slt $t4, $t3, $t1
        beq $t4, $zero, for_end_2

        # $t4 暂存读到的数据
        li $v0, 5
        syscall
        move $t4, $v0
        
        get_address($t1, $t2, $t3)
        
        sw $t4, 0($t7)
    
        addi $t3, $t3, 1
        j for_begin_2

    for_end_2:
        addi $t2, $t2, 1
        j for_begin_1

for_end_1:
# 反向进行for循环

# $t2 外层循环变量
addiu $t2, $t0, -1
for_begin_3:
    sge $t3, $t2, $zero
    beq $t3, $zero, for_end_3

    # $t3 内层循环变量
    addiu $t3, $t1, -1
    for_begin_4:
        sge $t4, $t3, $zero
        beq $t4, $zero, for_end_4

        get_address($t1, $t2, $t3)

        lw $t4, 0($t7)

        beq $t4, $zero, if_1_end
        
        addi $a0, $t2, 1
        li $v0, 1
        syscall

        la $a0, space
        li $v0, 4
        syscall

        addi $a0, $t3, 1
        li $v0, 1
        syscall

        la $a0, space
        li $v0, 4
        syscall

        move $a0, $t4
        li $v0, 1
        syscall

        la $a0, enter
        li $v0, 4
        syscall

        if_1_end:
            addiu $t3, $t3, -1
            j for_begin_4

    for_end_4:
    addiu $t2, $t2, -1
    j for_begin_3

for_end_3:
    li $v0, 10
    syscall
