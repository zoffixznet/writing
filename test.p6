$_ = '42';
say &('S///');

=finish

my $orig = 'meowmix';
my $new = $orig ~~ S/me/c/;
say $new;

=finish

my $original = 'foo';
my $new = S/o/a/ given $original;
say $original;
say $new;