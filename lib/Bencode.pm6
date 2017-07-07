unit module Bencode;

use Bencode::Dump;
use Bencode::Parse;
use Bencode::Util;

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

sub bdecode($data, Bool $decodestr=False) is export
{
    my Buf $bufdata = tobytes $data;

    return Bencode::Parse.new(data => $bufdata, decodestr => $decodestr).parse();
}

sub bdecode-file(Str $fname, Bool $decodestr=False) is export
{
    die("File $fname not found!") if !$fname.IO.e;
    my Buf $val = slurp $fname, :bin;

    return bdecode($val, $decodestr);
}
