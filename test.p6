role Better {
    method better { 'Yes, I am better' }
}

class Foo {
    has $.attr is rw
}

my $original = Foo.new: :attr<original>;

my $copy = $original but Better;
$copy.attr = 'meow';

say $original.attr;
say $copy.attr;

say $copy.better;
say $original.better; # fatal error: can't find method

# OUTPUT:
# original
# meow
# Yes, I am better
# Method 'better' not found for invocant of class 'Foo'
#   in block <unit> at test.p6 line 18