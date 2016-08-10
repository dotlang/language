//**0
int main()
{
    int x = 3;
    int y;

    if ( x < y+1 ) assert 1==0;
    else x++;

    assert x == 4;

    if ( x < y ) x++;
    else if ( x== y) y++;
    else if ( x == 4) x++;
    else y++;

    assert x==5;
    assert y==0;


    return 0;
}
