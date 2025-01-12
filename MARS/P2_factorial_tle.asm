.data
# 没有影响，但是是错误！space后面的数字的单位是Byte！这里的space要乘4
# int result[MAXN];
result: .space 1000

.macro get_result(%shift, %temp, %des)
	sll %temp, %shift, 2
	lw %des, 0(%temp)
.end_macro

.macro save_result(%shift, %temp, %src)
	sll %temp, %shift, 2
	sw %src, 0(%temp)
.end_macro

.text
# #define MAXN 1000
li $s0, 1000

li $v0, 5
syscall
# int n;
# scanf("%d", &n);
move $s1, $v0

# result[0] = 1;
li $t0, 1
sw $t0, result

# for (int i = 2; i <= n; i++) {
li $t0, 2
for_begin_1:
	bgt $t0, $s1, for_end_1
	# int upper = 0;
	li $t1, 0
	
	# for (int j = 0; j < MAXN; j++) {
	li $t2, 0
	li $t4, 10
	for_begin_2:
		bge $t2, $s0, for_end_2
		
		# int part_result = result[j] * i + upper;
		get_result($t2, $t9, $t3)
		mult $t3, $t0
		mflo $t3
		addu $t3, $t3, $t1
		# result[j] = part_result % 10;
		div $t3, $t4
		mfhi $t5
		save_result($t2, $t9, $t5)
		# upper = part_result / 10;
		mflo $t1
		
		addiu $t2, $t2, 1
		j for_begin_2
	
	for_end_2:
		addiu $t0, $t0, 1
		j for_begin_1
	
for_end_1:
	# int upper_number = 0;
	li $t0, 0
	
	# for (int i = MAXN - 1; i >= 0; i--) {
	addiu $t1, $s0, -1
	for_begin_3:
		beqz $t1, for_end_3
		# if (result[i] != 0) {
		get_result($t1, $t9, $t2)
		beqz $t2 if_end
		# upper_number = i;
		move $t0, $t1
		# break;
		j for_end_3
		
		if_end:
			addiu $t1, $t1, -1
			j for_begin_3
		
	for_end_3:
		# for (int i = upper_number; i >= 0; i--) {
		li $v0, 1

		for_begin_4:
			bltz $t0, for_end_4
			
			# printf("%d", result[i]);
			get_result($t0, $t9, $a0)
			syscall

			addiu $t0, $t0, -1
			j for_begin_4
		
		for_end_4:
			li $v0, 10
			syscall
