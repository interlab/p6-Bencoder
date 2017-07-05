use v6;
use lib 'lib';
use Test;

use Bencode::Dump;
use Bencode::Parse;
use Digest::SHA;
use experimental :pack;

# ok(1);

# subtest {
    # my $d = IO::Path.new($?FILE.IO.absolute.IO.dirname).dirname;
    # my $path = $d ~ '/examples/ubuntu-17.04-desktop-amd64.iso.torrent';
    # my %fi = bdecode-file $path;
    # my $sha1-info = sha1(bencode(%fi{'info'})).unpack('H*').uc;
    # ok $sha1-info eq '59066769B9AD42DA2E508611C33D7C4480B3857B', 'file info-hash compare';
# }, 'sha1 info-hash check';

subtest {
    my $v = {'mydata' => ('scooter', 100500, 888), 'testint' => 100500, 'Василий Уткин' => 567};
    is bencode(-42, True), 'i-42e', '-42 == i-42e';
    is bencode(0, True), 'i0e', '0 == i0e';
    is bencode({bar => 'spam', foo => 42}, True), 'd3:bar4:spam3:fooi42ee', 'd3:bar4:spam3:fooi42ee';
    is bencode($v, True), 'd6:mydatal7:scooteri100500ei888ee7:testinti100500e25:Василий Уткинi567ee', 'dictionary bencode test';
}, 'bencode test';

subtest {
    is bdecode('i-42e'), -42, 'i-42e == -42';
    is bdecode('le'), [], 'le == []';
    is bdecode('le'), [], 'le == []';
    is bdecode('de'), {}, 'de == {}';
    is bdecode('10:qwertyuiop', True), 'qwertyuiop', '10:qwertyuiop == qwertyuiop';
    is bdecode('l10:qwertyuiope', True), ('qwertyuiop',), 'l10:qwertyuiope == [\'qwertyuiop\']';
    is bdecode('d5:qwertl10:qwertyuiopee', True), (qwert => ('qwertyuiop',)), 'd5:qwertl10:qwertyuiopee == {qwert => (\'qwertyuiop\',)}';
}, 'bdecode test';

done;