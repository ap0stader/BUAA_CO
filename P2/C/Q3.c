#include <stdio.h>

int F[10][10];
int H[10][10];
int G[10][10];

int main() {
    int m1, n1, m2, n2;
    scanf("%d%d%d%d", &m1, &n1, &m2, &n2);
    int m3 = m1 - m2 + 1;
    int n3 = n1 - n2 + 1;

    for (int i = 0; i < m1; ++i) {
        for (int j = 0; j < n1; ++j) {
            scanf("%d", &F[i][j]);
        }
    }

    for (int i = 0; i < m2; ++i) {
        for (int j = 0; j < n2; ++j) {
            scanf("%d", &H[i][j]);
        }
    }

    for (int i = 0; i < m3; ++i) {
        for (int j = 0; j < n3; ++j) {
            for (int k = 0; k < m2; ++k) {
                for (int l = 0; l < n2; ++l) {
                    G[i][j] += F[i + k][j + l] * H[k][l];
                }
            }
        }
    }

    for (int i = 0; i < m3; ++i) {
        for (int j = 0; j < n3; ++j) {
            printf("%d ", G[i][j]);
        }
        printf("\n");
    }

    return 0;
}
