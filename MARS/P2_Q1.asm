.data
# int M1[8][8];
M1: .space 256
# int M2[8][8];
M2: .space 256
# int R[8][8];
R: .space 256
# " "
white_space: .asciiz " "
# "\n"
next_line: .asciiz "\n"

# &__[x][y]
.macro get_address(%column, %x, %y, %dst)
	mult %x, %column
	mflo %dst
	addu %dst, %dst, %y
	sll %dst, %dst, 2
.end_macro 

.text
# int n;
# scanf("%d", &n);
li $v0, 5
syscall
move $s0, $v0

# for (int i = 0; i < n; ++i) {
li $t0, 0
for_M1_i_begin:
	beq $t0, $s0, for_M1_i_end
	
	# for (int i = 0; i < n; ++i) {
	li $t1, 0
	for_M1_j_begin:
		beq $t1, $s0, for_M1_j_end
		# scanf("%d", &M1[i][j]);
		li $v0, 5
		syscall
		get_address($s0, $t0, $t1, $t2)
		# 可以使用更为清晰的标签，而不是手动写一个偏移地址
		sw $v0, M1($t2)

		addiu $t1, $t1, 1
		j for_M1_j_begin
	
	for_M1_j_end:
	addiu $t0, $t0, 1
	j for_M1_i_begin

for_M1_i_end:

# for (int i = 0; i < n; ++i) {
li $t0, 0
for_M2_i_begin:
	beq $t0, $s0, for_M2_i_end
	
	# for (int i = 0; i < n; ++i) {
	li $t1, 0
	for_M2_j_begin:
		beq $t1, $s0, for_M2_j_end
		# scanf("%d", &M2[i][j]);
		li $v0, 5
		syscall
		get_address($s0, $t0, $t1, $t2)
		sw $v0, M2($t2)

		addiu $t1, $t1, 1
		j for_M2_j_begin
	
	for_M2_j_end:
	addiu $t0, $t0, 1
	j for_M2_i_begin

for_M2_i_end:

# for (int i = 0; i < n; ++i) {
li $t0, 0
for_R_i_begin:
	beq $t0, $s0, for_R_i_end
	
	# for (int i = 0; i < n; ++i) {
	li $t1, 0
	for_R_j_begin:
		beq $t1, $s0, for_R_j_end
		
		# for (int k = 0; k < n; ++k) {
		li $t2, 0
		for_R_k_begin:
			# 复制的时候漏了这一行，应该先搭好结构再写具体的内容
			beq $t2, $s0, for_R_k_end
			
			# R[i][j] += M1[i][k] * M2[k][j];
			# M1[i][k]
			get_address($s0, $t0, $t2, $t3)
			lw $t3, M1($t3)
			# M2[k][j]
			get_address($s0, $t2, $t1, $t4)	
			lw $t4, M2($t4)
			# M1[i][k] * M2[k][j]
			mult $t3, $t4
			mflo $t3
			# R[i][j]
			get_address($s0, $t0, $t1, $t4)
			lw $t5, R($t4)
			# +=
			addu $t5, $t5, $t3
			sw $t5, R($t4)

			addiu $t2, $t2, 1
			j for_R_k_begin
		
		for_R_k_end:
		addiu $t1, $t1, 1
		j for_R_j_begin
	
	for_R_j_end:
	addiu $t0, $t0, 1
	j for_R_i_begin

for_R_i_end:

# for (int i = 0; i < n; ++i) {
li $t0, 0
for_out_i_begin:
	beq $t0, $s0, for_out_i_end
	
	# for (int i = 0; i < n; ++i) {
	li $t1, 0
	for_out_j_begin:
		beq $t1, $s0, for_out_j_end
		# printf("%d ", R[i][j]);
		get_address($s0, $t0, $t1, $t2)
		lw $a0, R($t2)
		li $v0, 1
		syscall
		li $v0, 4
		la $a0, white_space
		syscall
		
		addiu $t1, $t1, 1
		j for_out_j_begin
	
	for_out_j_end:
	# printf("\n");
	li $v0, 4
	la $a0, next_line
	syscall
	
	addiu $t0, $t0, 1
	j for_out_i_begin

for_out_i_end:
	li $v0, 10
	syscall
