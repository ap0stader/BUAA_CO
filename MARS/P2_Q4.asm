.data
# 最大指令数：6 -> 130149，完全不会抄

# int output[6];
output: .space 6
# int used[6];
used: .space 6
# " "
white_space: .asciiz " "
# "\n"
next_line: .asciiz "\n"

.macro push(%src)
	addiu $sp, $sp, -4
	sw %src, ($sp)
.end_macro

.macro pop (%dst)
	lw %dst, ($sp)
	addiu $sp, $sp, 4
.end_macro

.text
# int n;
# scanf("%d", &n);
li $v0, 5
syscall
move $s0, $v0

# Ann(0);
li $a0, 0
jal Ann_begin

li $v0, 10
syscall

# void Ann(int index) {
Ann:
	push($ra)
	# if (index == n) {
	bne $a0, $s0, if_else_1
		# for (int i = 0; i < n; ++i) {
		li $t0, 0
		for_begin_1:
			beq $t0, $s0, for_end_1
			# printf("%d ", output[i] + 1);
			li $v0, 1
			lb $a0, output($t0)
			addiu $a0, $a0, 1
			syscall
			
			li $v0, 4
			la $a0, white_space
			syscall
			
			addiu $t0, $t0, 1
			j for_begin_1
		
		for_end_1:
		# printf("\n");
		li $v0, 4
		la $a0, next_line
		syscall
		j if_end_1

	# } else {
	if_else_1:
		# for (int i = 0; i < n; ++i) {
		li $t0, 0
		for_begin_2:
			beq $t0, $s0, if_end_1
			# if (used[i] == 0) {
			lb $t1, used($t0)
			bnez $t1, if_end_2
				# output[index] = i;
				sb $t0, output($a0)
				# used[i] = 1;
				li $t1, 1
				sb $t1, used($t0)
				
				# Ann(index + 1);
				push($a0)
				push($t0)
				
				# 翻译的时候没有做到一一对应
				addu $a0, $a0, 1
				jal Ann
				
				pop($t0)
				pop($a0)
				
				# used[i] = 0;
				sb $0, used($t0)
				
			if_end_2:
				addiu $t0, $t0, 1
				j for_begin_2
	
	if_end_1:	
		pop($ra)
		jr $ra
