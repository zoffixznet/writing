    sub postcircumfix:<᚜  ᚛> ($before, $inside) is rw {
        $before{$inside};
    }
    my %hash = :foo<bar>;
    %hash᚜'foo'᚛ = 42;
    say %hash<foo>