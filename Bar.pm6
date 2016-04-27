unit module App::Config;
multi trait_mod:<is> (Variable $v, :$config!) is export {
    my $conf = from-json slurp 'test-config.json';
    my $name = $config ~~ Str ?? $config !! $v.var.VAR.name.substr: 1;
    $v.var   = $conf{ $name } // die 'Unknown configuration variable';
}
