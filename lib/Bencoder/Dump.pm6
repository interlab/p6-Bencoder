use Bencoder::Util;

class Bencoder::Dump
{
    has Buf $!stack = Buf.new();
    has $!data;
    has %!b =
        e => tobuf('e'), colon => tobuf(':'), i => tobuf('i'),
        l => tobuf('l'), d => tobuf('d');

    submethod BUILD(:$data)
    {
        $!data := $data;
    }

    method benc-dump()
    {
        self.bencode($!data);

        $!stack;
    }

    multi method bencode(Buf:D $val)
    {
        $!stack.push: tobuf $val.bytes;
        $!stack.push: %!b<colon>;
        $!stack.push: $val;
    }

    multi method bencode(Str:D $val)
    {
        self.bencode: tobuf $val;
    }

    multi method bencode(Int:D $val)
    {
        $!stack.push: %!b<i>;
        $!stack.push: tobuf $val;
        $!stack.push: %!b<e>;
    }

    multi method bencode(List:D $list)
    {
        $!stack.push: %!b<l>;
        $list.map: { self.bencode($_) };
        $!stack.push: %!b<e>;
    }

    multi method bencode(Hash:D $dict)
    {
        $!stack.push: %!b<d>;
        for $dict.keys.sort {
            self.bencode($_);
            self.bencode($dict{$_})
        }
        $!stack.push: %!b<e>;
    }
}
