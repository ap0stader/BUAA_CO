.data
str1: .ascii "hello"
str2: .ascii " "
str3: .ascii "world"

.text
la $a0, str1
li $v0, 4
syscall