//**0
int main()
{
    int x = 3;
    int y;

    if (x== 4 or y==0) x++;
    assert x==4;

    if (x!= y+4 or y >= x-4) y++;
    assert y==1;

    if ( x >= y+3 and x <= y+3) x++;
    assert x==5;

    if ( ((x==5 and y==12) or (y==1 and x==5)) )x++;
    assert x==6;

    return 0;
}
