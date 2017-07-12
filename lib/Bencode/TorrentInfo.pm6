use Bencode;
use Digest::SHA;
use experimental :pack;

# htmlspecialchars
# https://github.com/moznion/p6-HTML-Escape
sub escape-html(Str $raw) returns Str
{
    return $raw.trans([ '&', '<', '>', q{"}, q{'}, q{`}, '{', '}' ] =>  [
        '&amp;', '&lt;',  '&gt;', '&quot;', '&#39;', '&#96;', '&#123;', '&#125;'
    ]);
}

class Bencode::TorrentInfo
{
    has %!data;

    submethod BUILD(Str :$path)
    {
        %!data = bdecode-file($path);
        if ! (%!data<info><pieces>.bytes %% 20) {
            die 'Torrent incorrectly coded!';
        }
    }

    method info-hash(Bool $bin=False)
    {
        return $bin ?? sha1(bencode(%!data<info>))
            !! sha1(bencode(%!data<info>)).unpack('H*').uc;
    }

    method num-files(--> Int)
    {
        return self.file-list()<count>;
    }

    method size(--> Int)
    {
        return self.file-list()<size>;
    }

    # todo htmlspecialchars
    method file-list()
    {
        my Int $fCount = 0;
        my Int $fSize = 0;
        my @fList;
        # single
        if ! (%!data<info><files>:exists) {
            $fCount = 1;
            $fSize = %!data<info><length>;
            @fList.push({
                name => escape-html(%!data<info><name>.decode),
                size => $fSize
            });
        }
        # multi
        else {
            $fCount = %!data<info><files>.elems;
            for %!data<info><files>.values -> $f {
                $fSize += $f<length>;
                my Str $fName = escape-html(
                    $f<path>.map({$_.decode}).join('/').subst(/ ^\/ /, '')
                );
                @fList.push({name => $fName, size => $f<length>});
            }
            @fList = @fList.sort({$^a<name> cmp $^b<name>});
        }

        return {'count' => $fCount, 'size' => $fSize, 'files' => @fList};
    }

    method announce()
    {
        if %!data<announce>:exists {
            return escape-html(%!data<announce>.decode);
        } else {
            return Nil;
        }
    }

    method announce-list()
    {
        my @res;
        if %!data<announce>:exists {
            @res.push(escape-html(%!data<announce>.decode));
        }
        # dd %!data<announce-list>;
        if %!data<announce-list>:exists {
            for %!data<announce-list>.values -> $val {
                my $v = escape-html($val[0].decode);
                next if $v (elem) @res;
                @res.push($v);
            }
        }
        @res;
    }
}

# use Bencode::TorrentInfo;
# my $path = 'F:\b\perl6-Bencode\examples\ubuntu-17.04-desktop-amd64.iso.torrent';
# my $tor-info = Bencode::TorrentInfo.new(path => $path);
# say $tor-info.info-hash;
# say 'announce ', $tor-info.announce;
# .say for $tor-info.announce-list;
# say 'Файлов: ', $tor-info.num-files;
# say $_<name> for $tor-info.file-list<files>.values;
