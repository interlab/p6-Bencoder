
proto sub tobuf($val) returns Buf is export {*}

multi sub tobuf(Buf:D $val)
{
    $val;
}

multi sub tobuf(Int:D $val)
{
    Buf.new($val.Str.encode('UTF-8'));
}

multi sub tobuf(Str:D $val)
{
    Buf.new($val.encode('UTF-8'));
}
