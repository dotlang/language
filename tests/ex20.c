//**0
int main()
{
    int x = 3;
    int y;

    assert y ==0;
    assert x == y+3;

    assert x+5>y;
    assert y <x;

    y++;
    y++;
    y++;
    assert 2*y > x;

    if ( x == y +1 ) assert 1==0;
    if ( x > y+1 ) assert 1==0;

    return 0;
}
