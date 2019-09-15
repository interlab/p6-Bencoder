unit module Bencoder;

use Bencoder::Dump;
use Bencoder::Parse;
use Bencoder::Util;

sub bencode($data, $decode=False) is export
{
    if $decode {
        return Bencoder::Dump.new(:$data).benc-dump().decode;
    } else {
        return Bencoder::Dump.new(:$data).benc-dump();
    }
}

sub bencode-file(Str $fname, $val) is export
{
    spurt $fname, bencode($val), :bin;
}

sub bdecode($data, Bool $decodestr=False) is export
{
    my Buf $bufdata = tobuf $data;

    return Bencoder::Parse.new(data => $bufdata, :$decodestr).parse();
}

sub bdecode-file(Str $fname) is export
{
    die("File $fname not found!") if !$fname.IO.e;
    my Buf $val = slurp $fname, :bin;

    return bdecode($val, False);
}
