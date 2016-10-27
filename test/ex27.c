//**0
int main()
{
    int x = 81416;
    int y = 3;
    
    //&= |= ^= %= **= >>= <<=
    assert x%10 == 6;

    y <<= 2;
    assert y==12;

    y >>=2;
    assert y==3;


    return 0;
}
