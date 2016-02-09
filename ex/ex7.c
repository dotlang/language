package ex7 {
    int main() {
        int x = 12;
        const int t=10;

        t++;

        for(int y=0;y<10;y++) {
            x++;
        }

        if ( x > 10 ) {
            return 1;
        } else {
            return 2;
        }
    }
}
