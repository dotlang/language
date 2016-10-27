//**0
int main()
{
    int x = 3;
    int y;

    y+= 10;

    assert y==10;

    x+=y;
    assert x == (y+3);
    assert x==13;

    x-=1;
    assert x==12;

    y=2;
    x-=y;
    assert x==10;

    x*=2;
    assert x==20;

    x/= 5;
    assert x==4;

    y=5;
    x*=y;
    assert x==20;

    x=1;
    y=2;
    x++;
    x *= (y+1);
    assert 6==x;

    return 0;
}
