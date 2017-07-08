# perl6-Bencode
Encode and decode bencoding data (torrent files) lib for Perl 6

## Install
`zef -v install https://github.com/interlab/perl6-Bencode.git`

## Examples
### Encode data
```perl6
use Bencode;
my $bdata = bencode({bar => 'spam', foo => 42}, True);
say $bdata; # d3:bar4:spam3:fooi42ee
```

### Encode torrent file
```perl6
use Bencode;
my $path = 'ubuntu-17.04-desktop-amd64.iso.torrent'; # Change your path
my $new-path = 'ubuntu-17.04-desktop-amd64-copy.iso.torrent'; # Change your path
my %data = bdecode-file $path;
say %data<announce>.decode; # http://torrent.ubuntu.com:6969/announce
bencode-file($new-path, %data); # Dump file to new path
```

### Decode data
```perl6
use Bencode;
my $data = bdecode('13:Hello, World!', True);
say $data; # Hello, World!
```

### Decode torrent file
```perl6
use Bencode;
my $path = 'ubuntu-17.04-desktop-amd64.iso.torrent'; # Change your path
my %data = bdecode-file $path;
say %data<announce>.decode; # http://torrent.ubuntu.com:6969/announce
```

### Get info-hash of torrent file
```perl6
use Bencode;
use Digest::SHA;
use experimental :pack;

my $path = 'ubuntu-17.04-desktop-amd64.iso.torrent'; # Change your path
my %tfile = bdecode-file $path;
my $info-hash = sha1(bencode(%tfile<info>)).unpack('H*').uc;
say $info-hash; # 59066769B9AD42DA2E508611C33D7C4480B3857B
```