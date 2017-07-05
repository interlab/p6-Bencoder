
# 31.10.2016 - 04.11.2016 - 30.06.2017
# https://docs.perl6.org/type/Blob
# https://github.com/rakudo/rakudo/blob/nom/src/core/Buf.pm

multi sub tobytes(Buf $val)
{
    return $val;
}

multi sub tobytes(Int $val)
{
    return Buf.new(Str($val).encode('UTF-8'));
}

multi sub tobytes(Str $val)
{
    return Buf.new($val.encode('UTF-8'));
}

class Bencode::Dump
{
    has Buf $!stack = Buf.new();
    has $.data;

    submethod BUILD(:$data)
    {
        $!data := $data;
    }

    method benc-dump()
    {
        self.bencode($.data);

        return $!stack;
    }

    multi method bencode(Buf $val)
    {
        $!stack.push(tobytes($val.bytes));
        $!stack.push(tobytes(':'));
        $!stack.push($val);
    }

    multi method bencode(Str:D $val)
    {
        my $bval = tobytes($val);
        $!stack.push(tobytes($bval.bytes));
        $!stack.push(tobytes(':'));
        $!stack.push($bval);
    }

    multi method bencode(Int:D $val)
    {
        $!stack.push(tobytes('i'));
        $!stack.push(tobytes($val));
        $!stack.push(tobytes('e'));
    }

    multi method bencode(List:D $list)
    {
        $!stack.push(tobytes('l'));
        $list.map({ self.bencode($_) });
        $!stack.push(tobytes('e'));
    }

    multi method bencode(Hash:D $dict)
    {
        $!stack.push(tobytes('d'));
        for $dict.keys.sort {
            self.bencode($_);
            self.bencode($dict{$_})
        }
        $!stack.push(tobytes('e'));
    }
}

sub bencode($data, $decode=False) is export
{
    if $decode {
        return Bencode::Dump.new(:data($data)).benc-dump().decode;
    }
    else {
        return Bencode::Dump.new(:data($data)).benc-dump();
    }
}

sub bencode-file(Str $fname, $val) is export
{
    spurt $fname, bencode($val), :bin;
}

