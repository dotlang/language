//if with and and or and ...
package ex10 {
    int main() {
        int x = 12;
        const int t=10;

        for(int y=0;y<10;y++) {
            if ( y ==7) continue;
            x++;
        }

        if ( x > 10 and y == 10 ) {
            return 1;
        } else if ( y==10 or x < 2) {
            return 2;
        }
    }
}
