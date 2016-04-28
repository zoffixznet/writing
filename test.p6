my $orig = 'meowmix';
my $new = S/me/c/ given $orig;
say $orig;
say $new;

my @orig = <meow cow sow vow>;
my @new = do for @orig { S/\w+ )> 'ow'/w/ };
say @orig;
say @new;