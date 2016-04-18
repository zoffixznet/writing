sub trait_mod:<is> (Mu $v, :$double) {
    say $v.^methods;
    my $storage = 0;
    $v := Proxy.new(
        FETCH => method ()     { $storage * 2 },
        STORE => method ($new) { $storage = 2 * $new }
    )
}

my $x is double;
say $x = 42;
