.data
# 优化第一版：每一次循环只乘到当前的最高位，不再乘完1000位

# 没有影响，但是是错误！space后面的数字的单位是Byte！这里的space要乘4
# int result[MAXN];
result: .space 1000

.text
# int n;
# scanf("%d", &n);
li $v0, 5
syscall
move $s0, $v0

# result[0] = 1;
li $t0, 1
sw $t0, result

# int width = 0;
li $s1, 0

# for (int i = 2; i <= n; i++) {
li $t0, 2
for_begin_1:
	bgt $t0, $s0, for_end_1
	# int upper = 0;
	li $t1, 0
	
	# for (int j = 0; j <= width; j++) {
	li $t2, 0
	# div 10
	li $a0, 10
	for_begin_2:
		bgt $t2, $s1, for_end_2

		# int part_result = result[j] * i + upper;
		lw $t3, 0($t2)
		mult $t3, $t0
		mflo $t3
		addu $t3, $t3, $t1
		# result[j] = part_result % 10;
		div $t3, $a0
		mfhi $t3
		sw $t3, 0($t2)
		# upper = part_result / 10;
		mflo $t1
		
		# if(j == width && upper > 0){
		bne $t2, $s1, if_end_1
		beqz $t1, if_end_1
		# width++;
		addiu $s1, $s1, 4
		
		if_end_1:
			addiu $t2, $t2, 4
			j for_begin_2

	for_end_2:
		addiu $t0, $t0, 1
		j for_begin_1
	
for_end_1:
	li $v0, 1
	
	# for (int i = width; i >= 0; i--) {
	move $t0, $s1
	for_begin_4:
		bltz $t0, for_end_4

		# printf("%d", result[i]);
		lw $a0, 0($t0)
		syscall

		addiu $t0, $t0, -4
		j for_begin_4
		
		for_end_4:
			li $v0, 10
			syscall
