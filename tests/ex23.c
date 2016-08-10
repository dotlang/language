//**0
int main()
{
    int x = 3;
    int y;

    if (  x== 3 and y==0 ) x++;
    assert x==4;

    if (  x== y+4 and y == x-4 ) y++;
    assert y==1;

    return 0;
}
