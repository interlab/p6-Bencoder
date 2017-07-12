
multi sub tobuf(Buf $val --> Buf) is export
{
    $val;
}

multi sub tobuf(Int $val --> Buf) is export
{
    Buf.new(Str($val).encode('UTF-8'));
}

multi sub tobuf(Str $val --> Buf) is export
{
    Buf.new($val.encode('UTF-8'));
}
