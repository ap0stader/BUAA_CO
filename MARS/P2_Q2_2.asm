.data
# char c[22];
c: .space 22

.text
# int n;
# scanf("%d", &n);
li $v0, 5
syscall
move $s0, $v0

# 无需getchar()，读取数字的时候已经把后面的换行符给吃掉了

# for (int i = 0; i < n; ++i) {
li $t0, 0
for_read_begin:
	beq $t0, $s0, for_read_end
	
	# fgets(&c[i], 3, stdin);
	# 文档当中说了类似于fgets的用法
	move $a0, $t0
	li $a1, 3
	li $v0, 8
	syscall
	
	addiu $t0, $t0, 1
	j for_read_begin

for_read_end:
	
# for (int i = 0; i < n / 2; ++i) {
li $t0, 0
# m / 2
div $t1, $s0, 2
for_judge_begin:
	
	beq $t0, $t1, for_judge_end
	
	# if (c[i] != c[n - i - 1]) {
	# c[i]
	lb $t2, ($t0)
	
	# c[n - i - 1]
	subu $t3, $s0, $t0
	subu $t3, $t3, 1
	lb $t3, ($t3)
	
	beq $t2, $t3, if_end
	# printf("0");
	li $a0, 0
	li $v0, 1
	syscall
	
	# return 0;
	li $v0, 10
	syscall
	
	if_end:
	addiu $t0, $t0, 1
	j for_judge_begin

for_judge_end:
# printf("1");
li $a0, 1
li $v0, 1
syscall

# return 0;
li $v0, 10
syscall
