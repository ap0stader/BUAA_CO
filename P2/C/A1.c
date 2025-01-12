#include <stdio.h>

int G[81] = {};
int ARRIVED[81] = {};

int ans = 0;
int n, m;
int end_x, end_y;

void search(int x, int y) {
    if (x == end_x && y == end_y) {
        ans = ans + 1;
    } else if (G[x * (m + 2) + y] == 0 && ARRIVED[x * (m + 2) + y] == 0) {
        ARRIVED[x * (m + 2) + y] = 1;
        search(x, y - 1);
        search(x, y + 1);
        search(x - 1, y);
        search(x + 1, y);
        ARRIVED[x * (m + 2) + y] = 0;
    }
}

int main() {
    scanf("%d%d", &n, &m);

    for (int i = 0; i < (n + 2) * (m + 2); ++i) {
        G[i] = 1;
    }

    for (int i = 1; i <= n; ++i) {
        for (int j = 1; j <= m; ++j) {
            scanf("%d", &G[i * (m + 2) + j]);
        }
    }

    int start_x, start_y;
    scanf("%d%d%d%d", &start_x, &start_y, &end_x, &end_y);

    search(start_x, start_y);

    printf("%d", ans);
}
