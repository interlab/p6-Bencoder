use Bencode::Util;

# helper function via Str.index
sub indexBuf(Buf $data, Str $key, Int $position)
{
    my Int $find = -1;
    my Int $max = $data.bytes;
    my Buf $k = tobytes $key;

    if $position >= $max {
        return Nil;
    } 

    for $position..$max -> $i {
        if $data.subbuf($i, 1) eq $k {
            $find = $i;
            last;
        }
    }

    if $find == -1 {
        return Nil;
    } else {
        return $find;
    }
}

# helper function via Str.substr
sub substrBuf(Buf $data, Int $pos, Int $len)
{
    # say 'substrBuf() :: ', $len, ' ', $pos, ' ', $data.subbuf($pos, $len), ' ', $data.subbuf($pos, $len).decode('UTF-8');
    return $data.subbuf($pos, $len).decode('UTF-8');
}

class Bencode::Parse
{
    has Buf $.data;
    has Int $!pos = 0;
    has Int $.len;
    has Bool $!decodestr = False;
    has Buf $!bend = tobytes 'e';
    has @!intvals = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');

    submethod BUILD(:$data, :$decodestr=False)
    {
        $!data := $data;
        $!len = $data.bytes;
        $!decodestr = $decodestr;
    }

    method parse()
    {
        my $result = self.parse2();
        # say '$.len - 1 ', $.len - 1, ' len: ',  $.len, ' pos: ', $!pos, ' == ', $!pos == $.len;
        if $!pos < $.len {
            die('Found multiple entities outside list or dict definitions: ' ~ substrBuf($.data, 0, 10));
        }

        return $result;
    }

    method parse2()
    {
        my $t = substrBuf($.data, $!pos, 1);
        # say 'parse2() :: ', $t; # , ' ', $t.WHAT, ' ', '1' eq $t, ' ', $!pos, ' ';

        if $t (elem) @!intvals {
            return self.bdecodeStr();
        }

        given $t {
            when 'i' { return self.bdecodeInt(); } 
            when 'l' { return self.bdecodeList(); }
            when 'd' { return self.bdecodeDict(); }
            default  { die "$t - huh?"; }
        }
    }

    # Строка байт: <размер>:<содержимое(цепочка байт)>
    # Размер — это положительное число в 10СС, может быть нулём
    # 4:spam
    method bdecodeStr(Bool $utf8=False)
    {
        my Str $result;
        my Buf $bufresult;
        my $stop = indexBuf($.data, ':', $!pos);
        if !$stop.defined {
            die('Bad string');
        }
        my Int $len = substrBuf($.data, $!pos, $stop - $!pos).Int;
        my Int $start = $!pos + $len.Str.chars + 1;
        # say "Data: Pos: $!pos Stop: $stop, Len $len, ", $stop - $!pos, ' start: ', $start;
        $bufresult = $.data.subbuf($start, $len);
        if $!decodestr || $utf8 {
        # if $utf8 {
            # $result = $bufresult.decode('UTF-8');
            $result = try $bufresult.decode('UTF-8');
            if $! {
                $result = '|...|';
            }
        }

        if $bufresult.bytes != $len {
            die('Bad string: '); # ~ substrBuf($.data, $!pos, $len + 1 + Str($len).chars + 10) ~ ' Pos: ' ~ $!pos ~ ' Chars: ' ~ $result.chars ~ ' Len: ' ~ $len ~ ' Result: "' ~ $result ~ '"')
        }
        $!pos = $start + $bufresult.bytes;
        # say 'pos: ', $!pos;
        if $!decodestr || $utf8 {
        # if $utf8 {
            # # say 'bdecodeStr() :: result: "', $result, '" start: ', $start, ' stop: ', $!pos, ' len: ', $len;
            return $result;
        } else {
            return $bufresult;
        }
    }

    # Целое число: i<число в десятичной системе счисления>e
    # !Число не должно начинаться с нуля!
    # i0e
    # i42e
    # i-42e
    method bdecodeInt()
    {
        $!pos += 1;
        my $end = indexBuf($.data, 'e', $!pos);
        die 'Bad integer' if !$end.defined;
        die 'Empty integer' if $!pos == $end;
        my $snum = substrBuf($.data, $!pos, $end - $!pos);
        my $result = $snum.Int;
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
        while $.data.subbuf($!pos, 1) ne $!bend {
            my $res = self.parse2();
            @result.push($res);
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
        while $.data.subbuf($!pos, 1) ne $!bend {
            my $key = self.bdecodeStr(True);
            %result{$key} = self.parse2();
        }
        $!pos += 1;

        return %result;
    }
}
