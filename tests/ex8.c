package ex8 {
    int main() {
        int x = 12;
        const int t=10;

        t++; //should throw error

        for(int y=0;y<10;y++) {
            if ( y ==7) break;
            x++;
        }

        if ( x > 10 ) {
            return 1;
        } else {
            return 2;
        }
    }
}
