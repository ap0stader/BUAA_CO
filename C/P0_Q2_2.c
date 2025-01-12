#include<stdio.h>

void curcuit(int x, int y, int number) {
    printf("    <wire from=\"(%d,%d)\" to=\"(%d,%d)\"/>\n"
           "    <wire from=\"(%d,%d)\" to=\"(%d,%d)\"/>\n"
           "    <wire from=\"(%d,%d)\" to=\"(%d,%d)\"/>\n"
           "    <wire from=\"(%d,%d)\" to=\"(%d,%d)\"/>\n",
           x - 10, y + 20, x - 10, y + 60,
           x - 20, y + 20, x - 20, y + 30,
           x - 60, y + 10, x - 30, y + 10,
           x + 00, y + 00, x + 20, y + 00
    );

    printf("    <comp lib=\"4\" loc=\"(%d,%d)\" name=\"Register\">\n"
           "      <a name=\"width\" val=\"32\"/>\n"
           "    </comp>\n",
           x + 00, y + 00);

    printf("    <comp lib=\"0\" loc=\"(%d,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"facing\" val=\"north\"/>\n"
           "      <a name=\"label\" val=\"reset\"/>\n"
           "    </comp>\n",
           x - 10, y + 60);

    printf("    <comp lib=\"0\" loc=\"(%d,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"facing\" val=\"north\"/>\n"
           "      <a name=\"label\" val=\"clk\"/>\n"
           "    </comp>\n",
           x - 20, y + 30);

    printf("    <comp lib=\"0\" loc=\"(%d,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"facing\" val=\"east\"/>\n"
           "      <a name=\"width\" val=\"32\"/>\n"
           "      <a name=\"label\" val=\"WD\"/>\n"
           "    </comp>",
           x - 30, y + 00);

    printf("    <comp lib=\"0\" loc=\"(%d,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"facing\" val=\"east\"/>\n"
           "      <a name=\"width\" val=\"1\"/>\n"
           "      <a name=\"label\" val=\"E%02d\"/>\n"
           "    </comp>\n",
           x - 60, y + 10, number);

    printf("    <comp lib=\"0\" loc=\"(%d,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"width\" val=\"32\"/>\n"
           "      <a name=\"label\" val=\"O%02d\"/>\n"
           "    </comp>\n",
           x + 20, y + 00, number);
}

void outputlabel(int number){
    printf("    <comp lib=\"0\" loc=\"(100,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"facing\" val=\"east\"/>\n"
           "      <a name=\"width\" val=\"32\"/>\n"
           "      <a name=\"label\" val=\"O%02d\"/>\n"
           "    </comp>\n",
           number * 20 + 60, number);
}

void enablelabel(int number){
    printf("    <comp lib=\"0\" loc=\"(100,%d)\" name=\"Tunnel\">\n"
           "      <a name=\"facing\" val=\"west\"/>\n"
           "      <a name=\"width\" val=\"1\"/>\n"
           "      <a name=\"label\" val=\"E%02d\"/>\n"
           "    </comp>\n",
           number * 20 + 60, number);
}

int main() {
    for (int row = 0; row < 4; ++row) {
        for (int column = 0; column < 8; ++column) {
            int x = 100 + column * 150;
            int y = 50 + row * 150;
            int number = row * 8 + column;

            curcuit(x,y, number);
            outputlabel(number);
            enablelabel(number);
        }
    }
    return 0;
}