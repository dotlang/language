//**0
int main()
{
    int x = 81416;
    int y = 3190;

    assert x&y == 3072;
    assert x|y == 81534;
    assert x^y == 78462;
    assert x^x == 0;
    assert x== 81416;
    assert y==3190; 

    assert y>>4 == 199;
    assert y<<7 == 408320;

    assert x%10 == 6;
    assert x%100 == 16;
    assert x%1000 == 416;

    x = 8;
    assert x**2 == 64;
    assert ~12121381416 == 763520471;


    return 0;
}
