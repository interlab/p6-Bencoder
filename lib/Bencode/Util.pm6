
multi sub tobuf(Buf:D $val --> Buf) is export
{
    $val;
}

multi sub tobuf(Int:D $val --> Buf) is export
{
    Buf.new($val.Str.encode('UTF-8'));
}

multi sub tobuf(Str:D $val --> Buf) is export
{
    Buf.new($val.encode('UTF-8'));
}
