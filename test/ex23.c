//**0
int main()
{
    int x = 3;
    int y;

    if (  x== 3 and y==0 ) x++;
    assert x==4;

    if (  x== y+4 and y == x-4 ) y++;
    assert y==1;

    x= 4;
    y = 9;

    if ( x == 4 and y == 9 and x < y and y > x) x++;
    assert x==5;

    if ( x == 5 and y > 9 and x < y and y > x) x++;
    assert x==5;

    if ( x == 5 and y == 9 and x < y and y == x) x++;
    assert x==5;
    assert y==9;

    if ( x == 5 and y == 9 and x < y and y > x) y++;
    assert x==5;
    assert y==10;

    return 0;
}
