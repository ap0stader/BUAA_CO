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
