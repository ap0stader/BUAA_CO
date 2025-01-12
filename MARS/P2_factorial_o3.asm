.data
# 优化第三版：将伪指令修改为基本指令，让赋值只进行一次

# space后面的数字的单位是Byte！
# int result[167];
result: .space 668

.text
li $v0, 5
syscall
# int n;
# scanf("%d", &n);
addiu $s0, $v0, 1

# result[0] = 1;
li $t0, 1
sw $t0, result

# int width = 0;
li $s1, 4

# for (int i = 2; i <= n; i++) {
li $t0, 2
# div 1000000
li $a0, 1000000
# ! do not forget 0 !
beq $s0, 1, for_end_1
for_begin_1:
	beq $t0, $s0, for_end_1
	# int upper = 0;
	li $t1, 0
	
	# for (int j = 0; j <= width; j++) {
	li $t2, 0
	for_begin_2:
		beq $t2, $s1, for_end_2
		
		# int part_result = result[j] * i + upper;
		lw $t3, 0($t2)
		mult $t3, $t0
		mflo $t3
		addu $t3, $t3, $t1
		# result[j] = part_result % 1000000;
		div $t3, $a0
		mfhi $t3
		sw $t3, 0($t2)
		# upper = part_result / 1000000;
		mflo $t1
		
		addiu $t2, $t2, 4
		j for_begin_2
		
	for_end_2:
		# if(j == width && upper > 0){
		beqz $t1, if_end_1
		# width++;
		addiu $s1, $s1, 4
		# 回到循环当中
		j for_begin_2
		
		if_end_1:
			addiu $t0, $t0, 1
			j for_begin_1
	
for_end_1:	
	li $v0, 1
	
	# printf("%d", result[width]);
	lw $a0, -4($s1)
	syscall
	
	# for (int i = width - 1; i >= 0; i--) {
	addiu $t0, $s1, -8
	
	li $t2, 100000
	li $t3, 10000
	li $t4, 1000
	li $t5, 100
	li $t6, 10
	
	for_begin_4:
		bltz $t0, for_end_4

		# printf("%06d", result[i]);
		lw $t1, 0($t0)
		move $a0, $0
		bge $t1, $t2, if_end
		syscall
		bge $t1, $t3, if_end
		syscall
		bge $t1, $t4, if_end
		syscall
		bge $t1, $t5, if_end
		syscall
		bge $t1, $t6, if_end
		syscall
		if_end:
			move $a0, $t1
			syscall
			addiu $t0, $t0, -4
			j for_begin_4
		
		for_end_4:
			li $v0, 10
			syscall
