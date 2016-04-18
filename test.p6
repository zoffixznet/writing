sub trait_mod:<is> (Variable $v, :$double) {
    return $v does role {
        method double { self * 2 }
    };
}

my Int $x is double = 42;
say $x.double;
