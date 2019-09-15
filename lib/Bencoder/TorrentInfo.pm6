use Bencoder;
use Digest::SHA1::Native;

# htmlspecialchars
# https://github.com/moznion/p6-HTML-Escape
sub escape-html(Str $raw --> Str)
{
    $raw.trans([ '&', '<', '>', q{"}, q{'}, q{`}, '{', '}' ] =>  [
        '&amp;', '&lt;',  '&gt;', '&quot;', '&#39;', '&#96;', '&#123;', '&#125;'
    ]);
}

class Bencoder::TorrentInfo
{
    has %!data;

    submethod BUILD(Str :$path)
    {
        %!data = bdecode-file($path);
        die 'Torrent incorrectly coded!' unless %!data<info><pieces>.bytes %% 20;
    }

    method info-hash(Bool $bin=False)
    {
        $bin
            ?? sha1(bencode(%!data<info>))
            !! sha1-hex(bencode(%!data<info>)).uc;
    }

    method num-files(--> Int)
    {
        self.file-list()<count>;
    }

    method size(--> Int)
    {
        self.file-list()<size>;
    }

    method file-list(--> Hash)
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

        {'count' => $fCount, 'size' => $fSize, 'files' => @fList};
    }

    method announce()
    {
        %!data<announce>:exists
            ?? escape-html(%!data<announce>.decode)
            !! Nil;
    }

    method announce-list(--> Array)
    {
        my @res;
        if %!data<announce>:exists {
            @res.push(escape-html(%!data<announce>.decode));
        }
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
