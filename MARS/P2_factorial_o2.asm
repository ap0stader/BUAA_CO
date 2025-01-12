.data
# 优化第二版：压位，每一个字存储六位数据

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
	# div 1000000
	li $a0, 1000000
	for_begin_2:
		bgt $t2, $s1, for_end_2

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
	
	# printf("%d", result[width]);
	lw $a0, 0($s1)
	syscall
	
	# for (int i = width - 1; i >= 0; i--) {
	addiu $t0, $s1, -4
	for_begin_4:
		bltz $t0, for_end_4

		# printf("%06d", result[i]);
		lw $t1, 0($t0)
		move $a0, $0
		bge $t1, 100000, if_end
		syscall
		bge $t1, 10000, if_end
		syscall
		bge $t1, 1000, if_end
		syscall
		bge $t1, 100, if_end
		syscall
		bge $t1, 10, if_end
		syscall
		if_end:
			move $a0, $t1
			syscall
			addiu $t0, $t0, -4
			j for_begin_4
		
		for_end_4:
			li $v0, 10
			syscall
