//**0
int main()
{
    int x = 12; assert x==12;
    x++; assert x==13;
    x++; assert x==14;
    assert x > 0;
    assert x < 15;
    assert x > 13;

    if ( x == 14 ) x++;
    assert x == 15;

    if ( x == 19 ) x++;
    assert x == 15;

    int y = 10;
    x = x + y;
    assert x == 25;

    x = 2 * x + 1;
    assert x == 51;

    x = x/17;
    assert x == 3;

    if ( x == 3 )
        if ( x > 1 )
            if ( x < 10 )
                if ( x < 9 )
                    x++;
                else x = 0;
            else x = 0;
        else x = 0;
    else x = 0;

    assert x == 4;

    if ( x == 4 )
        if ( x < 1 )
            if ( x < 10 )
                if ( x < 9 )
                    x++;
                else x = 0;
            else x = 0;
        else x = 188;
    else x = 0;

    assert x == 188;

    return 0;
}
