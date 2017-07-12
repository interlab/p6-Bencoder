use Bencode::Util;

# helper function via Str.index
sub indexBuf(Buf $data, Str $key, Int $position --> Int)
{
    my Int $find = -1;
    my Int $max = $data.bytes;
    my Buf $k = tobuf $key;

    if $position >= $max {
        return Nil;
    } 

    for $position..$max -> $i {
        if $data.subbuf($i, 1) eq $k {
            $find = $i;
            last;
        }
    }

    return $find == -1 ?? Nil !! $find;
}

# helper function via Str.substr
sub substrBuf(Buf $data, Int $pos, Int $len --> Str)
{
    # say 'substrBuf() :: ', $len, ' ', $pos, ' ', $data.subbuf($pos, $len), ' ', $data.subbuf($pos, $len).decode('UTF-8');
    return $data.subbuf($pos, $len).decode('UTF-8');
}

class Bencode::Parse
{
    has Buf $!data;
    has Int $!pos = 0;
    has Int $!len;
    has Bool $!decodestr;
    has Buf $!bend = tobuf 'e';
    has @!intvals = '0'..'9';

    submethod BUILD(:$data, :$decodestr=False)
    {
        $!data := $data;
        $!len = $data.bytes;
        $!decodestr = $decodestr;
    }

    method parse()
    {
        my $result = self.parse2();
        # say '$!len - 1 ', $!len - 1, ' len: ',  $!len, ' pos: ', $!pos, ' == ', $!pos == $!len;
        if $!pos < $!len {
            die('Found multiple entities outside list or dict definitions: ' ~ substrBuf($!data, 0, 10));
        }

        return $result;
    }

    method parse2()
    {
        my Str $t = substrBuf($!data, $!pos, 1);
        # dd 'parse2():: ', $t;

        if $t (elem) @!intvals {
            return self.bdecodeStr();
        }

        given $t {
            when 'i' { return self.bdecodeInt(); } 
            when 'l' { return self.bdecodeList(); }
            when 'd' { return self.bdecodeDict(); }
            default  { die "{$t.perl} - huh?"; }
        }
    }

    # Строка байт: <размер>:<содержимое(цепочка байт)>
    # Размер — это положительное число в 10СС, может быть нулём
    # 4:spam
    method bdecodeStr(Bool $utf8=False)
    {
        my Int $stop = indexBuf($!data, ':', $!pos);
        die 'Bad string' if !$stop.defined;
        my Int $len = substrBuf($!data, $!pos, $stop - $!pos).Int;
        my Int $start = $!pos + $len.Str.chars + 1;
        # say "Data: Pos: $!pos Stop: $stop, Len $len, ", $stop - $!pos, ' start: ', $start;
        my Buf $bufresult = $!data.subbuf($start, $len);
        if $bufresult.bytes != $len {
            die('Bad string.');
        }
        $!pos = $start + $bufresult.bytes;
        my Bool $to-str = $!decodestr || $utf8;
        my Str $strresult = $to-str ?? $bufresult.decode('UTF-8') !! Nil;

        return $to-str ?? $strresult !! $bufresult;
    }

    # Целое число: i<число в десятичной системе счисления>e
    # !Число не должно начинаться с нуля!
    # i0e
    # i42e
    # i-42e
    method bdecodeInt()
    {
        $!pos += 1;
        my Int $end = indexBuf($!data, 'e', $!pos);
        die 'Bad integer' if !$end.defined;
        die 'Empty integer' if $!pos == $end;
        my Str $snum = substrBuf($!data, $!pos, $end - $!pos);
        my Int $result = $snum.Int;
        # say 'Int -->', $end - $!pos, ' --> ', $result.Str.chars;
        if $snum != $result || $end - $!pos > $result.Str.chars {
            die 'Leading zeroes or negative zero detected ' ~ $snum;
        }
        $!pos = $end + 1;

        return $result;
    }

    # Список (массив): l<содержимое>e
    # Содержимое включает в себя любые Bencode типы, следующие друг за другом
    # l4:spami42ee
    method bdecodeList()
    {
        $!pos += 1;
        my @result;
        while $!data.subbuf($!pos, 1) ne $!bend {
            @result.push: self.parse2();
        }
        $!pos += 1;

        return @result;
    }

    # Словарь: d<содержимое>e
    # Содержимое состоит из пар ключ-значение, которые следуют друг за другом
    # Ключи могут быть только строкой байт и должны быть упорядочены в лексикографическом порядке
    # Значение может быть любым Bencode элементом
    # «d3:bar4:spam3:fooi42ee»
    method bdecodeDict()
    {
        $!pos += 1;
        my %result;
        while $!data.subbuf($!pos, 1) ne $!bend {
            my $key = self.bdecodeStr(True);
            %result{$key} = self.parse2();
        }
        $!pos += 1;

        return %result;
    }
}
