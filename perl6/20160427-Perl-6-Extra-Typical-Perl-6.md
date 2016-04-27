Extra-Typical Perl 6

Have you ever grabbed an [`Int`](http://docs.perl6.org/type/Int) and thought, "Boy! I should would enjoy having an .even method on it!" Before you beg the core developers [on IRC](irc://irc.freenode.net/#perl6) to add it to Perl 6, let's review some user-space recourse available to you.

## *But... But... But...*

The `but` infix operators creates a copy of an object and mixes in a given role:

    my $x = 42 but role { method even { self %% 2 } };
    say $x.even;

    # OUTPUT:
    # True

The role doesn't have to be inlined, of course. Here's another example with a pre-defined role that also shows that our object is indeed a copy:

    role Better {
        method better { 'Yes, I am better' }
    }

    class Foo {
        has $.attr is rw
    }

    my $original = Foo.new: :attr<original>;

    my $copy = $original but Better;
    $copy.attr = 'copy';

    say $original.attr;  # still 'original'
    say $copy.attr;      # this one is 'copy'

    say $copy.better;
    say $original.better; # fatal error: can't find method

    # OUTPUT:
    # original
    # copy
    # Yes, I am better
    # Method 'better' not found for invocant of class 'Foo'
    #   in block <unit> at test.p6 line 18

This is great and all, but as far as our original goal is concerned, this solution is rather weak:

    my $x = 42 but role { method even { self %% 2 } };
    say $x.even; # True
    $x = 72;
    say $x.even; # No such method

The role is mixed into our object stored inside the container, so as soon as we put a new value into the container, or fancy-pants `.even` method is gone.

## *My Grandpa Left Me a Fortune*