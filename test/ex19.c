//**0
int main()
{
    int x = 3;

    if ( x == 3 )
        if ( x < 1 )
            if ( x < 10 )
                if ( x < 9 )
                    x++;
                else x = 0;
            else x = 0;
        else x = 188;
    else x = 0;

    assert x == 188;
    x=3;

    if ( x == 3 )
        if ( x > 1 )
            if ( x > 10 )
                if ( x < 9 )
                    x++;
                else x = 0;
            else x = 200;
        else x = 188;
    else x = 0;

    assert x == 200;
    x=3;

    if ( x == 13 )
        if ( x > 1 )
            if ( x > 10 )
                if ( x < 9 )
                    x++;
                else x = 0;
            else x = 200;
        else x = 188;
    else x = 80;

    assert x == 80;
    x=3;

    if ( x == 3 )
        if ( x > 1 )
            if ( x < 10 )
                if ( x < 9 )
                    x++;
                else x = 0;
            else x = 200;
        else x = 188;
    else x = 80;

    assert x == 4;

    return 0;
}
