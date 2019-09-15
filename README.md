# perl6-Bencoder
Encode and decode bencoding data (torrent files) lib for Perl 6

## Install
`zef -v install https://github.com/interlab/perl6-Bencoder.git`

## Examples
### Encode data
```perl6
use Bencoder;
my $bdata = bencode({bar => 'spam', foo => 42}, True);
say $bdata; # d3:bar4:spam3:fooi42ee
```

### Encode torrent file
```perl6
use Bencoder;
my $path = 'F:\examples\ubuntu-19.04-desktop-amd64.iso.torrent';
my $new-path = 'F:\examples\ubuntu-19.04-copy.torrent';
my %data = bdecode-file $path;
say %data<announce>.decode; # http://torrent.ubuntu.com:6969/announce
bencode-file($new-path, %data); # Dump file to new path
```

### Decode data
```perl6
use Bencoder;
my $data = bdecode('13:Hello, World!', True);
say $data; # Hello, World!
```

### Decode torrent file
```perl6
use Bencoder;
my $path = 'F:\examples\ubuntu-19.04-desktop-amd64.iso.torrent'; # Change your path
my %data = bdecode-file $path;
say %data<announce>.decode; # http://torrent.ubuntu.com:6969/announce
```

### Get info-hash of torrent file
```perl6
use Bencoder::TorrentInfo;
my $tor-info = Bencoder::TorrentInfo.new(path => 'ubuntu-19.04-desktop-amd64.iso.torrent'); # Change your path
say $tor-info.info-hash; # D540FC48EB12F2833163EED6421D449DD8F1CE1F
```