#include <stdio.h>

int result[167];

int main() {
    int n;
    scanf("%d", &n);

    result[0] = 1;

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

    printf("%d", result[size]);

    for (int i = size - 1; i >= 0; i--) {
        printf("%06d", result[i]);
    }
}
