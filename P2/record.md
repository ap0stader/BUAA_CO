# P2课下-做题记录

## P2.Q1 P2_L0_matrix 题目编号 1121-37

### 源代码文件
- [P2_Q1.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_Q1.asm)

### 思考
这道题一是熟悉教程中二维数组内存操作的`.macro`写法，二是复习for循环的汇编写法。矩阵相乘的C语言写法，在大一程设时已经写过了（当时写的还是[矩阵的幂次mini](https://accoding.buaa.edu.cn/problem/6343/index)）。  
编写时以下几点需要留意：
1. `.space`后的数字的单位是bytes，如果在C语言中使用了长度为100的int型数组，`.space`后需要为400。
2. 如果使用`lw`和`sw`指令，访问的地址必须是4的非负整数倍。**在`.data`中应该先写`.space`，再写`.asciiz`**。因为`.asciiz`不会对齐到4的整数倍。
3. for循环嵌套for循环时容易出现结构混乱、标签混乱、寄存器混乱等情况。像C语言一样，先把`for (int i = 0; i < n; ++i)`这一部分的结构写好，再去填充循环内的逻辑能有效避免最后返工修改的麻烦。嵌套或复用时**框架**上更改**循环变量的寄存器4处**和**标签4处**。我的for循环模板如下。
    ```mipsasm
    # 先前步骤：
    # n <= $s0

    # for (int i = 0; i < n; ++i)
    # int i = 0
    li $s1, 0
    # for循环标签模板
    # for_(任务)_(循环变量名称)_begin/end
    for_input_i_begin:
        # i < n
        beq $s1, $s0, for_input_i_end

        # do something

        # ++i
        addiu $s1, $s1, 1
        j for_input_i_begin

    for_input_i_end:
    # do something
    ```

### C语言代码
- [Q1.c](./C/Q1.c)


## P2.Q2 P2_L0_judge 题目编号 1121-34

### 源代码文件
- [P2_Q2_1.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_Q2_1.asm) : $v0 = 12版本
- [P2_Q2_2.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_Q2_2.asm) : $v0 = 8版本

### 思考
这道题是熟悉MARS中读取字符的syscall的特性（题目中有测评机与MARS表现不同的相关说明）。
1. 使用`li $v0, 5`读取数字，会“吃”掉行尾的换行符。这与`scanf("%d", &n)`不同。在C语言中，`scanf("%d", &n)`后应该用`getchar()`“吃”掉行尾的换行符再循环调用`fgets()`，否则第一次`fgets()`只读取换行符。
2. MARS的帮助文档中说明`li $v0, 8`与`fgets()`行为相同。如果`li $a0, 1`，不会有内容写入到内存中。如果`li $a0, 2`，将会一次读取字母，一次读取换行符。如果`li $a0, 3`，那么将一次性读取一个字母加换行符。因为只关心字母，下一读取时写入的内存地址只需+1，覆盖掉换行符。

### C语言代码
- [Q2.c](./C/Q2.c)


## P2.Q3 P2_L0_conv 题目编号 1121-281

### 源代码文件
- [P2_Q3.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_Q3.asm)

### 思考
P2.Q1的加强版，嵌套循环4层。编写时应十分注意标签的修改和寄存器与循环变量的对应关系。

### C语言代码
- [Q3.c](./C/Q3.c)


## P2.Q4 P2_L0_full_1 题目编号 1121-36

### 源代码文件
- [P2_Q4.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_Q4.asm)

### 思考
这道题是复习递归函数的写法。全排列的C语言写法，在大一程设时已经编写过了（[重炮的数学时间](https://accoding.buaa.edu.cn/problem/6020/index)）。  
1. 和一般函数调用一样，应在开头和返回前对`$ra`和`$s`类的值进行保存和恢复。
2. **要格外注意对于`$a`类和`$t`类寄存器的值的保存和恢复**。一般函数调用时这些寄存器大都不做保护，但是递归时因为执行相同的指令，这些寄存器的值一定会被改变。若这些值在递归后还需要使用，一定要对其进行保存和恢复。

### C语言代码
- [Q4.c](./C/Q4.c)

### 问题
1. 翻译C语言的时候漏翻译了一个对于中间变量的操作，导致WA了一次。


## P2.附加题1 P2_L1_puzzle 题目编号 1121-38

### 源代码文件
- [P2_puzzle.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_puzzle.asm)

### 思考
1. 题目提示使用深度优先搜索。比较简单的实现方式是“图数组 + 是否已经访问的标记数组”的数据结构以及“出发 -> 判断是否可行&是否已经访问 -> 递归调用四个方向”的算法。
2. 为了使算法逻辑更加简单，在整个图的四个边加上了一圈表示不可以走的1，这样就不用判断这个值是否是边界值从而决定是否不向某个方向递归。实现的方法是先将一个(n + 2) * (m + 2)的二维数组置1，然后再把数据输入到中间的n * m的区域中。
3. 由于在内存中二维数组是线性存储的，故在进行顺序访问时不必使用两个for循环以及计算二维数组内存地址的`.macro`。使用一个for循环，从起始地址循环到终止地址即可。如：按照上一点读取输入的图，同一行内的两个相邻数字循环变量加4，换到下一行第一个数字循环变量加12，从0循环到`(n * m) << 2`即可。
4. 题目中要求了*每组数据最多执行5,000,000条指令*，似乎需要一些高效的算法和优化，但是测试数据应该比较友善，基础的递归算法也能通过。~~变态的测试数据例如6 x 6的迷宫，全为0，从(1,1)到(6,6)，有1262816种走法。~~
5. ~~[accoding上与这题类似的古老题目](https://accoding.buaa.edu.cn/problem/178/index)~~

### C语言代码
- [A1.c](./C/A1.c)

### 问题
1. 入栈时先延长栈，再写入数据。出栈时先读取数据，再缩短栈。先进栈的后出栈。第一次编写时，写了两处错误的代码，导致了程序运行表现混乱。
    ```mipsasm
    .macro pop (%dst)
        addiu $sp, $sp, 4
        lw %dst, ($sp)
    .end_macro
    ```
    ```mipsasm
    push($a0)
    push($a1)
    # do something
    pop($a0)
    pop($a1)
    ```


## P2.附加题2 P2_L1_factorial 题目编号 1121-418

### 源代码文件
- [P2_factorial_tle.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_factorial_tle.asm) : TLE版本
- [P2_factorial_o1.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_factorial_o1.asm) : 优化第一版
- [P2_factorial_o2.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_factorial_o2.asm) : 优化第二版
- [P2_factorial_o3.asm](https://gitee.com/ap0stader/CO_2023_Fall/blob/main/3_P2/MARS/P2_factorial_o3.asm) : 优化第三版

### 思考
本题的思想基础是高精度乘法。高精度乘法的C语言写法，在大一程设时已经编写过了（[求求你了帮帮可莉吧！](https://accoding.buaa.edu.cn/problem/6386/index)）。比较简单的实现方法是从1循环到输入给定的数值，每一轮都与之前的结果进行低精度乘高精度乘法。题目中保证***输出字符串长度小于等于1000***，即不会计算大于449的阶乘。第一版C语言代码如下。
```C
#include <stdio.h>
#define N 1000
int result[N];
int main() {
    int n;
    scanf("%d", &n);
    result[0] = 1;
    for (int i = 2; i <= n; i++) {
        int in = 0;
        for (int j = 0; j < N; j++) {
            int temp_result = result[j] * i + in;
            result[j] = temp_result % 10;
            in = temp_result / 10;
        }
    }
    int top_number = 0;
    for (int i = N - 1; i >= 0; i--) {
        if (result[i] != 0) {
            top_number = i;
            break;
        }
    }
    for (int i = top_number; i >= 0; i--) {
        printf("%d", result[i]);
    }
}
```

### 优化
在MARS中，可以通过菜单栏中`Tools`->`Instruction Counter`或`Instruction Statistics`查看运行的指令数和不同类型的指令的分布情况。使用前点击`Connect to MIPS`。该计数器在复位之后的值不会清零，会继续累加，需要手动点击`Reset`重置计数器。
题目中要求***步数限制为200,000***，若直接按照上述代码翻译，将会获得**TLE**。  
1. TLE -> O1（已经能AC）: **限长**  
    TLE版之所以步数特别多，主要来源于`for (int j = 0; j < N; j++)`，每一次循环时都要对1000个位做乘法。但是实际上很多时候都是在做没有意义的乘0。故设一变量保存当前最高位的数组下标。这个值在已经乘到了最高位，但是进位仍不为0的情况下+1，继续循环直到进位为0。
    ```C
     int size = 0;
     for (int i = 2; i <= n; i++) {
         int in = 0;
         for (int j = 0; j <= size; j++) {
             int temp_result = result[j] * i + in;
             result[j] = temp_result % 10;
             in = temp_result / 10;
             if (j == size && in > 0) {
                 size++;
             }
         }
     }
    ```
    优化之后，因为测试数据也比较友善，已经能够AC了。TLE版本计算82位的60!需要832552步，O1版本只需要29295步。能在要求步数内计算完的值达到了242位的140!。

2. O1 -> O2 : **压位**  
    虽然已经AC了，但是受到了<http://cscore.buaa.edu.cn/#/discussion_area/1027/1158/posts>的启发，故继续在O1版上进行优化。  
    O1版中虽然已经限制了每次计算的位数，但是计算机并不是只能计算1位乘3位的乘法的。如果每个int单元都保存多位数字，在做乘法时就能一次性对多位进行乘法，保存的位数越多，能减少的计算步数就越多。由题目的限制可知，不会计算超过449的阶乘，而  
        `999999 x 449 = 44899951 < 2147483647`  
        `9999999 x 449 = 4489999551 > 2147483647`  
    故为了保证计算安全，每个int单元保存6位数字，只需要长度为167的int数组。
    ```C
    int result[167];

    int size = 0;
    for (int i = 2; i <= n; i++) {
        int in = 0;
        for (int j = 0; j <= size; j++) {
            int temp_result = result[j] * i + in;
            result[j] = temp_result % 1000000;
            in = temp_result / 1000000;
            if (j == size && in > 0) {
                size++;
            }
        }
    }
    ```
    每个int单元保存6位数字，但每个单元可能高位为0，故输出时应该补0到6位。
    ```C
    printf("%06d", result[i]);
    ```
    汇编中可以通过连续判断以及输出0实现`%06d`的效果。
    ```mipsasm
    bge $t0, 1000, output
	li $v0 -> li $a0 -> syscall
    bge $t0, 100, output
	li $v0 -> li $a0 -> syscall
    ......
    ```
    优化之后，O1版本需要198291步计算的242位的140!，在O2版本只需要35451步。能在要求步数内计算完的值达到了637位的309!。

3. O2 -> O3 : **换指令**  
    距离题目给定的最大值1000位还有距离，还可以在什么地方进行优化呢？换指令！步数的大头来源于这两个for循环。
    ```C
    for (int i = 2; i <= n; i++) {
        // do something
        for (int j = 0; j <= size; j++) {
            // do something
            if (j == size && in > 0) {
                size++;
            }
        }
    }
    ```
    我在汇编中实现for循环中的`i <= n`使用其逆关系所对应的分支指令`bgt`。然而`bgt`并不是基本指令，在编译之后会变为`slt`和`bne`两条基本指令，即每次循环时这一处都会执行两步。但是，若for循环中的判断逻辑是`i < n`，则可以用`beq`实现在`i == n`时跳转到`for_end`。故外层的for循环可以做如下修改。
     ```C
    for (int i = 2; i < n + 1; i++) {
        // do something
    }
     ```
    但是要注意，此时我们用`beq`，如果`n == 0`的话，**i无论如何自增都不可能触发beq的分支，需要特判。**因为在循环之前已经通过`result[0] = 1;`赋了初值，直接跳转到输出部分即可。
    
    但是内层的for循环在`j == size`时需要执行`size++`，并且循环有可能继续。此时直接使用`beq`指令跳转到`for_end`并不合适。此时汇编语言相比高级编程语言灵活的一点体现出来了，那就是灵活的跳转。虽然C语言存在goto语句，但是在几乎所有情况下我们都不会使用goto，因为这会破坏结构化程序设计的模式。但是在汇编中我们经常使用各种跳转。故内层的for循环可以做如下修改。
    ```C
    int size = 1;
    for (int i = 2; i < n + 1; i++) {
        // do something
        int j = 0;
        loop_begin:
        while (j < size){
            // do something
            j++;
        }
        if (in > 0) {
            size++;
            goto loop_begin;
        }
    }
    ```
    我将判断逻辑修改为了`j < size`以使用`beq`指令。**同时将`size` 的初值设置为1**，当`j == size`时`result[j]`指向可能要增加的新的单元。此时若进位`in`不为零，则`size++`。再跳转回循环中，`j < size`成立，可以继续执行循环内的语句。这样同时减少了`bgt`指令导致的拓展指令占用步数的问题，还解决了在for循环中反复进行if判断的问题。

    除此之外，删除了循环对一个寄存器赋值立即数。在最后进行输出时是一直在输出数字，不必每次都完成`li $v0 -> li $a0 -> syscall`的路径，在循环开始前`li $v0 1`即可。对于上一点实现`printf("%06d", result[i]);`中的立即数也可以先赋值给一个寄存器。这样可以避免对于**大于等于32768的立即数使用bge指令会被翻译成四条基本指令。**

    优化之后，O2版本需要198821步计算的637位的309!，在O3版本只需要181119步。能在要求步数内计算完的值达到了700位的334!。

    虽然距离题目给定的最大值1000位还有距离，输出部分虽然还可再优化，但输出部分的步数只有几千步，优化的意义不大。每一条指令都已经是压着MIPS指令集设计的规范，个人分析也没有重复的判断和运算。在不修改算法的情况下，已经基本达到了我的极限了。  
    忽然想起《庄子》中写道“吾生也有涯，而知也无涯。以有涯随无涯，殆已！”，这一次的优化就到这里吧~~，还有OO作业要写。~~

总结：
1. 各版本对比
    | 版本 | 计算60!的步数 |
    | :--: | :-----------: |
    | TLE  |    832552     |
    |  O1  |     29295     |
    |  O2  |     5878      |
    |  O3  |     4879      |

2. O3版优化结果
    | 计算数字 | 结果位数 |  步数  |
    | :------: | :------: | :----: |
    |   60!    |    82    |  4879  |
    |   334!   |   700    | 198906 |
    |   335!   |   703    | 200215 |
    |   449!   |   999    | 380022 |

### 问题
1. 忘记了`.space`后的数字的单位是bytes，`int result[1000]`翻译成了`result: .space 1000`，虽然并不会导致程序的运行出现异常，但是者本身就是个错误。
