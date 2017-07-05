unit module Bencode;

use Bencode::Dump;
use Bencode::Parse;

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

sub bdecode($data, $decodestr=False) is export
{
    return Bencode::Parse.new(:data($data), :decodestr($decodestr)).parse();
}

sub bdecode-file(Str $fname, $decodestr=False) is export
{
    die if !$fname.IO.e;
    my $val = slurp $fname, :bin;

    return bdecode($val, $decodestr);
}
