.data
# int F[10][10];
F: .space 400
# int H[10][10];
H: .space 400
# int G[10][10];
G: .space 400
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
# int m1, n1, m2, n2;
# scanf("%d%d%d%d", &m1, &n1, &m2, &n2);
li $v0, 5
syscall
move $s0, $v0

li $v0, 5
syscall
move $s1, $v0

li $v0, 5
syscall
move $s2, $v0

li $v0, 5
syscall
move $s3, $v0

# int m3 = m1 - m2 + 1;
subu $s4, $s0, $s2
addiu $s4, $s4, 1

# int n3 = n1 - n2 + 1;
subu $s5, $s1, $s3
addiu $s5, $s5, 1

# for (int i = 0; i < m1; ++i) {
li $t0, 0
for_F_i_begin:
	beq $t0, $s0, for_F_i_end
	
	# for (int i = 0; i < n1; ++i) {
	li $t1, 0
	for_F_j_begin:
		beq $t1, $s1, for_F_j_end
		# scanf("%d", &F[i][j]);
		li $v0, 5
		syscall
		get_address($s1, $t0, $t1, $t2)
		sw $v0, F($t2)

		addiu $t1, $t1, 1
		j for_F_j_begin
	
	for_F_j_end:
	addiu $t0, $t0, 1
	j for_F_i_begin

for_F_i_end:

# for (int i = 0; i < m2; ++i) {
li $t0, 0
for_H_i_begin:
	beq $t0, $s2, for_H_i_end
	
	# for (int i = 0; i < n2; ++i) {
	li $t1, 0
	for_H_j_begin:
		beq $t1, $s3, for_H_j_end
		# scanf("%d", &H[i][j]);
		li $v0, 5
		syscall
		get_address($s3, $t0, $t1, $t2)
		sw $v0, H($t2)

		addiu $t1, $t1, 1
		j for_H_j_begin
	
	for_H_j_end:
	addiu $t0, $t0, 1
	j for_H_i_begin

for_H_i_end:

# for (int i = 0; i < m3; ++i) {
li $t0, 0
for_G_i_begin:
	beq $t0, $s4, for_G_i_end
	
	# for (int i = 0; i < n3; ++i) {
	li $t1, 0
	for_G_j_begin:
		beq $t1, $s5, for_G_j_end
		
		# for (int k = 0; k < m2; ++k) {
		li $t2, 0
		for_G_k_begin:
			beq $t2, $s2, for_G_k_end

			# for (int l = 0; l < n2; ++l) {
			li $t3, 0
			for_G_l_begin:
				beq $t3, $s3, for_G_l_end

				# G[i][j] += F[i + k][j + l] * H[k][l];
				# F[i + k][j + l]
				addu $t4, $t0, $t2
				addu $t5, $t1, $t3
				get_address($s1, $t4, $t5, $t6)
				lw $t4, F($t6)
				# H[k][l]
				get_address($s3, $t2, $t3, $t5)	
				lw $t5, H($t5)
				# M1[i][k] * M2[k][j]
				mult $t4, $t5
				mflo $t4
				# G[i][j]
				get_address($s5, $t0, $t1, $t5)
				lw $t6, G($t5)
				# +=
				addu $t6, $t6, $t4
				sw $t6, G($t5)

				addiu $t3, $t3, 1
				j for_G_l_begin
				
			for_G_l_end:
			addiu $t2, $t2, 1
			j for_G_k_begin
		
		for_G_k_end:
		addiu $t1, $t1, 1
		j for_G_j_begin
	
	for_G_j_end:
	addiu $t0, $t0, 1
	j for_G_i_begin

for_G_i_end:

# for (int i = 0; i < m3; ++i) {
li $t0, 0
for_out_i_begin:
	beq $t0, $s4, for_out_i_end
	
	# for (int i = 0; i < n3; ++i) {
	li $t1, 0
	for_out_j_begin:
		beq $t1, $s5, for_out_j_end	
		# printf("%d ", G[i][j]);
		get_address($s5, $t0, $t1, $t2)
		lw $a0, G($t2)
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
