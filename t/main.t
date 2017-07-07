#!perl6

use v6;
use lib 'lib';
use Test;

use Bencode;
use Digest::SHA;
use experimental :pack;

subtest {
    # normalize file path
    my IO $p = $?FILE.IO.absolute.IO.parent.parent.add('examples');
    my Str $path = $p.add('ubuntu-17.04-desktop-amd64.iso.torrent').Str;
    my %fi = bdecode-file $path;
    my $sha1-info = sha1(bencode(%fi{'info'})).unpack('H*').uc;
    ok $sha1-info eq '59066769B9AD42DA2E508611C33D7C4480B3857B', 'file info-hash compare';

    # my Str $path2 = $p.add('mt.torrent').Str;
    # my %fi2 = bdecode-file $path2;
    # my $sha1-info2 = sha1(bencode(%fi2<info>)).unpack('H*').uc;
    # is $sha1-info2, '52F697ADF873006C87FA5D47F8447CC6EFCE1B49', 'file2 info-hash compare';
}, 'sha1 info-hash check';

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
    dies-ok { bdecode('4:kek', True) }, "Bad string dies";
    dies-ok { bdecode('4:kekss', True) }, "Big string dies";
    dies-ok { bdecode('i-0111e') }, "Bad num dies";
    dies-ok { bdecode('i-0e') }, "Bad num dies";
    is bdecode('i-42e'), -42, 'i-42e == -42';
    is bdecode('le'), [], 'le == []';
    is bdecode('l4:spami42ee', True), ('spam', 42), 'l4:spami42ee == (\'spam\', 42)';
    is bdecode('de'), {}, 'de == {}';
    is bdecode('d5:qwertl10:qwertyuiopee', True), (qwert => ('qwertyuiop',)), 'd5:qwertl10:qwertyuiopee == {qwert => (\'qwertyuiop\',)}';
}, 'bdecode test';

done-testing;