#!perl6

use v6;
use lib 'lib';
use Test;

use Bencode;
use Bencode::TorrentInfo;
use Digest::SHA;
use experimental :pack;

subtest {
    # normalize file path
    my IO $p = $?FILE.IO.absolute.IO.parent.parent.add('examples');
    my Str $path = $p.add('ubuntu-17.04-desktop-amd64.iso.torrent').Str;
    my %fi = bdecode-file $path;
    my $sha1-info = sha1(bencode(%fi{'info'})).unpack('H*').uc;
    ok $sha1-info eq '59066769B9AD42DA2E508611C33D7C4480B3857B', 'file info-hash compare';

    $path = $p.add('mt.torrent').Str;
    if $path.IO.e {
        %fi = bdecode-file $path;
        $sha1-info = sha1(bencode(%fi<info>)).unpack('H*').uc;
        is $sha1-info, '52F697ADF873006C87FA5D47F8447CC6EFCE1B49', 'file2 info-hash compare';
    }

    $path = $p.add('plesen.torrent').Str;
    if $path.IO.e {
        %fi = bdecode-file $path;
        $sha1-info = sha1(bencode(%fi<info>)).unpack('H*').uc;
        is $sha1-info, 'C2582EF39802CB8FD3930F044BA4672965D1837E', 'file3 info-hash compare';
    }
}, 'sha1 info-hash test';

subtest {
    my IO $p = $?FILE.IO.absolute.IO.parent.parent.add('examples');
    my Str $path = $p.add('ubuntu-17.04-desktop-amd64.iso.torrent').Str;
    my $tor-info = Bencode::TorrentInfo.new(path => $path);
    is $tor-info.info-hash, '59066769B9AD42DA2E508611C33D7C4480B3857B', '1. TorrentInfo info-hash compare';
    is $tor-info.num-files, 1, '1. TorrentInfo count files';
    is $tor-info.announce, 'http://torrent.ubuntu.com:6969/announce', '1. TorrentInfo announce check';
    is $tor-info.announce-list,
        ('http://torrent.ubuntu.com:6969/announce', 'http://ipv6.torrent.ubuntu.com:6969/announce'),
        '1. TorrentInfo announce check';

    $path = $p.add('mt.torrent').Str;
    if $path.IO.e {
        $tor-info = Bencode::TorrentInfo.new(path => $path);
        is $tor-info.info-hash, '52F697ADF873006C87FA5D47F8447CC6EFCE1B49', '2. TorrentInfo info-hash compare';
        is $tor-info.num-files, 45, '2. TorrentInfo count files';
    }

    $path = $p.add('plesen.torrent').Str;
    if $path.IO.e {
        $tor-info = Bencode::TorrentInfo.new(path => $path);
        is $tor-info.info-hash, 'C2582EF39802CB8FD3930F044BA4672965D1837E', '3. TorrentInfo info-hash compare';
        is $tor-info.num-files, 1179, '3. TorrentInfo count files';
    }
}, 'TorrentInfo test';

subtest {
    my $v = {'mydata' => ('scooter', 100500, 888), 'testint' => 100500, 'Василий Уткин' => 567};
    is bencode(-42, True), 'i-42e', '-42 == i-42e';
    is bencode(0, True), 'i0e', '0 == i0e';
    is bencode({bar => 'spam', foo => 42}, True), 'd3:bar4:spam3:fooi42ee', 'd3:bar4:spam3:fooi42ee';
    is bencode($v, True), 'd6:mydatal7:scooteri100500ei888ee7:testinti100500e25:Василий Уткинi567ee', 'dictionary bencode test';
}, 'bencode test';

subtest {
    is bdecode('13:Hello, World!', True), 'Hello, World!', '13:Hello, World! == Hello, World!';
    is bdecode('0:', True), '', '0: == empty string';
    dies-ok { bdecode('4:kek', True) }, "Bad string 4:kek dies";
    dies-ok { bdecode('4:kekss', True) }, "Big string 4:kekss dies";
    is bdecode('i0e'), 0, 'i0e == 0';
    is bdecode('i42e'), 42, 'i42e == 42';
    is bdecode('i-42e'), -42, 'i-42e == -42';
    dies-ok { bdecode('i-0111e') }, "Bad num i-0111e dies";
    dies-ok { bdecode('i-0e') }, "Bad num i-0e dies";
    dies-ok { bdecode('ie') }, "Bad num \"ie\" dies";
    is bdecode('le'), [], 'le == []';
    is bdecode('l4:spami42ee', True), ('spam', 42), 'l4:spami42ee == (\'spam\', 42)';
    is bdecode('de'), {}, 'de == {}';
    is bdecode('d3:bar4:spam3:fooi42ee', True), {bar => 'spam', foo => 42}, 'd3:bar4:spam3:fooi42ee == {bar => \'spam\', foo => 42}';
    dies-ok { bdecode 'd6:qwertyi100500e', True }, "Bad dict";
    dies-ok { bdecode 'd6:qwertyi100500', True }, "Bad dict";
}, 'bdecode test';

done-testing;