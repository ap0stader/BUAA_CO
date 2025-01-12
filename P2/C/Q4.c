#include <stdio.h>

int output[6];
int used[6];
int n;

void Full(int index) {
    if (index == n) {
        for (int i = 0; i < n; ++i) {
            printf("%d ", output[i] + 1);
        }
        printf("\n");
    } else {
        for (int i = 0; i < n; ++i) {
            if (used[i] == 0) {
                output[index] = i;
                used[i] = 1;
                Full(index + 1);
                used[i] = 0;
            }
        }
    }
}

int main() {
    scanf("%d", &n);
    Full(0);
    return 0;
}
