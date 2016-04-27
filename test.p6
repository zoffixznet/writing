multi trait_mod:<is> (Variable $v, :$from-config!) is export {
    my $conf = from-json slurp 'test-config.json';
    my $name = $from-config ~~ Str ?? $from-config !! $v.var.VAR.name.substr: 1;
    $v.var   = $conf{ $name } // die 'Unknown configuration variable';
}

my $name  is from-config;
my $input is from-config;
my $robot is from-config('name');
say "$robot\'s name is $name and he likes $input";
