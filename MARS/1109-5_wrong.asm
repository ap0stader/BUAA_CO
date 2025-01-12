.data
# 用于记录每个点是否已经走过，最多8个顶点，占用8x4=32个地址
book: .space 32
# 保存图
# 照常计算，每个的偏移量都要加上32
G: .space 256
ans: .word 1

.macro exit
    li $v0, 10
    syscall
.end_macro

.macro getInt(%des)
    li $v0, 5
    syscall
    move %des, $v0
.end_macro

# 计算得到给定行列后的地址，保存到%des
# 注意使用时要偏移32个地址
.macro get_address(%element_of_row, %row, %column, %des)
    mult %row, %element_of_row
    mflo %des
    addu %des, %des, %column
    sll %des, %des, 2
.end_macro

.macro get_book(%i, %des)
    sll %des, %i, 2
    lw %des, 0(%des)
.end_macro

.macro push(%src)
    sw %src, 0($sp)
    subi $sp, $sp, 4
.end_macro

.macro pop(%des)
    addi $sp, $sp, 4
    lw %des, 0($sp)
.end_macro

.text
main:
    # $s0-$s1此处当成了不能动的全局常量了

    # $s0 n
    getInt($s0)
    # $s1 m
    getInt($s1)

    # 初始化ans
    li $t0, 0
    sw $t0, ans
    
    # $t0 循环变量
    li $t0, 0
    for_begin_1:
        slt $t1, $t0, $s1
        beq $t1, $zero, for_end_1

        # 编号从0开始，不用考虑溢出的问题
        # $t1 = x - 1
        getInt($t1)
        subi $t1, $t1, 1
        # $t2 = y - 1
        getInt($t2)
        subi $t2, $t2, 1

        # 保存图
        li $t4, 1
        get_address($s0, $t1, $t2, $t3)
        sw $t4, 32($t3)
        get_address($s0, $t2, $t1, $t3)
        sw $t4, 32($t3)

        addi $t0, $t0, 1
        j for_begin_1

    for_end_1:
        # dfs(0);
        li $a0, 0
        jal dfs

        # printf("%d", ans);
        lw $a0, ans
        li $v0, 1
        syscall
        exit

dfs:
    # book[x] = 1;
    # $t0 x，要保存
    move $t0, $a0
    #！！！改变了$t0的含义！导致后面的各种逻辑都出现了错误
    sll $t0, $t0, 2
    li $t1, 1
    sw $t1, 0($t0)
    # int flag = 1，刚好在这里解决了
    # $t1 flag

    # $t2 循环变量
    li $t2, 0
    for_begin_2:
        slt $t3, $t2, $s0
        beq $t3, $zero, for_end_2

        # $t3 = book[i]
        get_book($t2, $t3)
        # flag &= book[i];
        and $t1, $t1, $t3

        addi $t2, $t2, 1
        j for_begin_2

    for_end_2:
        # $t3 = G[x][0]
        get_address($s0, $t0, $zero, $t3)
        #！！！偏移值忘了，下次还是不要搞什么偏移值了，直接在宏里面就加了挺好的
        lw $t3, 0($t3)
        # if (flag && G[x][0])
        and $t1, $t1, $t3
        beq $t1, $zero, else_1

        if_1:
            # ans = 1;
            li $t2, 1
            sw $t2, ans
            # return;
            jr $ra

        else_1:
            # $t1循环变量，要保存
            li $t1, 0
            for_begin_3:
                slt $t2, $t1, $s0
                #！！！标签使用错误
                beq $t2, $zero, for_end_2

                # $t2 = !book[i]
                #！！！逻辑错误了，这样操作本来是1还是1，本来是0还是0
                get_book($t2, $t1)
                addi $t2, $t2, 1
                srl $t2, $t2, 1

                # $t3 = G[x][i]
                get_address($s0, $t0, $t1, $t3)
                #！！！偏移值忘了，下次还是不要搞什么偏移值了，直接在宏里面就加了挺好的
                lw $t3, 0($t3)

                #！！！此处风格不对，新开了一个寄存器，而不是用现在能用的最小的寄存器
                # $t4 = !book[i] && G[x][i]
                and $t4, $t3, $t3
                
                #if (!book[i] && G[x][i])
                beq $t4, $zero, else_2
                if_2:
                    # dfs(i);
                    # 要保存的变量 $t0、$t1、$ra
                    push($t1)
                    push($t0)
                    push($ra)

                    #！！！忘记传递参数了
                    jal dfs

                    pop($ra)
                    pop($t0)
                    pop($t1)

                else_2:
                #无论是否是else都要执行
                addi $t1, $t1, 1
                j for_begin_3

            for_end_3:
                # book[x] = 0;
                #！！！前面恢复了t0的含义，此处要跟着修改
                sw $zero, 0($t0)
                # (return)
                jr $ra
