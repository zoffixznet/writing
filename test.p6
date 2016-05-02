use v6;

sub nth-prime(Int:D $x where * > 0) is cached {
    say "Calculating {$x}th prime";
    return (2..*).grep(*.is-prime)[$x - 1];
}

say nth-prime(43);
say nth-prime(43);
say nth-prime(43);