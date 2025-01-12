#include <stdio.h>

char c[22];

int main() {
    int n;
    scanf("%d", &n);

    // for (int i = 0; i < n; ++i) {
    //     scanf(" %c", &c[i]);
    // }

    // C语言中行尾换行符用fgets一次
    getchar();

    for (int i = 0; i < n; ++i) {
        fgets(&c[i], 3, stdin);
    }

    for (int i = 0; i < n / 2; ++i) {
        if (c[i] != c[n - i - 1]) {
            printf("0");
            return 0;
        }
    }

    printf("1");
    return 0;
}
