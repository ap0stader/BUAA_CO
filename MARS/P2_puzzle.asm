.data
# space后面的数字的单位是Byte！
# int G[81] = {};
G: .space 324
# int ARRIVED[81] = {};
ARRIVED: .space 324

.macro push(%src)
	addiu $sp, $sp, -4
	sw %src, ($sp)
.end_macro 
 
.macro pop(%des)
	# 一开始写反了！先延长栈再压入，先弹出再缩回栈
	lw %des, ($sp)
	addiu $sp, $sp, 4
.end_macro 
   
# Global Variable
# ans <= $s0
# n <= $s1
# (m + 2) <= $s2
# end_x <= $s3
# end_y <= $s4

.text
# int ans = 0;
li $s0, 0
# int n, m;
# scanf("%d%d", &n, &m);
li $v0, 5
syscall
move $s1, $v0

li $v0, 5
syscall
addiu $s2, $v0, 2
# int end_x, end_y;

# ---- INIT ---- 
# for (int i = 0; i < (n + 2) * (m + 2); ++i) {
la $t0, G
# int i = 0
li $t1, 0
# (n + 2) * (m + 2) <= $t2
addiu $t2, $s1, 2
mult $t2, $s2
mflo $t2
sll $t2, $t2, 2
# 1
li $t3, 1
for_init_begin:
	bge $t1, $t2, for_init_end
	# G[i] = 1;
	sw $t3, ($t1)
	addiu $t1, $t1, 4
	j for_init_begin

for_init_end:

# ---- INPUT GRAPH ----
# for (int i = 1; i <= n; ++i) {
# int i = 1
li $t1, 1
# m <= $t3
addiu $t3, $s2, -2
# i * (m + 2) + j <= $t4
addiu $t4, $s2, 1
sll $t4, $t4, 2
for_scan_1_begin:
	bgt $t1, $s1, for_scan_1_end
	# for (int j = 1; j <= m; ++j) {
	# int j = 1
	li $t2, 1
	for_scan_2_begin:
		bgt $t2, $t3, for_scan_2_end
		# scanf("%d", &G[i * (m + 2) + j]);
		li $v0, 5
		syscall
		sw $v0, ($t4)
		
		addiu $t4, $t4, 4
		addiu $t2, $t2, 1
		j for_scan_2_begin
	
	for_scan_2_end:
	addiu $t4, $t4, 8
	addiu $t1, $t1, 1
	j for_scan_1_begin

for_scan_1_end:

# --- INPUT START END ----
# int start_x, start_y;
# scanf("%d%d%d%d", &start_x, &start_y, &end_x, &end_y);
li $v0, 5
syscall
move $a0, $v0

li $v0, 5
syscall
move $a1, $v0

li $v0, 5
syscall
move $s3, $v0

li $v0, 5
syscall
move $s4, $v0

# search(start_x, start_y);
jal search

# printf("%d", ans);
move $a0, $s0
li $v0, 1
syscall

li $v0, 10
syscall

# void search(int x, int y) {
search:
	push($ra)
	
	# if (x == end_x && y == end_y) {
	bne $a0, $s3, if_else
	bne $a1, $s4, if_else
	# ans = ans + 1;
	addiu $s0, $s0, 1
	j search_return
	
	if_else:
	# x * (m + 2) + y <= $t0
	mult $a0, $s2
	mflo $t0
	addu $t0, $t0, $a1
	sll $t0, $t0, 2
	# } else if (G[x * (m + 2) + y] == 0 && ARRIVED[x * (m + 2) + y] == 0) {
	# G[x * (m + 2) + y]
	lw $t1, 0($t0)
	bne $t1, $0, search_return
	# ARRIVED[x * (m + 2) + y]
	lw $t1, 324($t0)
	bne $t1, $0, search_return
	li $t1, 1
	# ARRIVED[x * (m + 2) + y] = 1;
	sw $t1, 324($t0)
	
	push($t0)
	
	# search(x, y - 1);
	push($a0)
	push($a1)
	
	addiu $a1, $a1, -1
	jal search
	
	# 一开始写反了！正着进栈，倒着弹栈
	pop($a1)
	pop($a0)

	# search(x, y + 1);
	# 这样弹栈再进栈纯粹是为了格式规范，可以进行优化
	push($a0)
	push($a1)
	
	addiu $a1, $a1, 1
	jal search
	
	pop($a1)
	pop($a0)
	
	# search(x - 1, y);
	push($a0)
	push($a1)
	
	addiu $a0, $a0, -1
	jal search
	
	pop($a1)
	pop($a0)
	
	# search(x + 1, y);
	push($a0)
	push($a1)
	
	addiu $a0, $a0, 1
	jal search
	
	pop($a1)
	pop($a0)
	
	pop($t0)
	# ARRIVED[x * (m + 2) + y] = 0;
	sw $0, 324($t0)

search_return:
	pop($ra)
	jr $ra
