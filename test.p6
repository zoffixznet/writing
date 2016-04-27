use App::Config;
my $name  is config;
my $input is config;
my $robot is config('name');
say "$robot\'s name is $name and he likes $input";
