
multi sub tobytes(Buf $val) is export
{
    return $val;
}

multi sub tobytes(Int $val) is export
{
    return Buf.new(Str($val).encode('UTF-8'));
}

multi sub tobytes(Str $val) is export
{
    return Buf.new($val.encode('UTF-8'));
}
