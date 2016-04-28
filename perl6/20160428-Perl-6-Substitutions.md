# Perl 6: Substitutions

Coming from a Perl 5 background, my first experience with Perl 6's substitutions looked something like this:

<p style="text-align: center">
    <small><i>(artist's impression)</i></small>
    <img src="stock/20160428-Substitutions.gif" style="display: block; margin: 20px auto;">
</p>

You'll fare better, I'm sure. Not only have the error messages improved when you try to use Perl 5's approach, but I'll also explain everything right here and now.

## First, Forget Everything You Know

The reason I had issues is because, seeing familiar-looking operators, I
simply translated Perl 5's *binding* operator (`=~`) to Perl 6's
*smartmatch* operator (`~~`) and expected things to work. The operator I was trying to use was ([is?](https://github.com/perl6/doc/issues/437)) not documented and combined with the confusing (at the time) error message this was the source of my pain:

    my $orig = 'meowmix';
    my $new = $orig ~~ S/me/c/;
    say $new;

    # OUTPUT error:
    # Smartmatch with S/// can never succeed

The error suggests the `~~` operator is the wrong choice here and it is. The
`~~` isn't the equivalent of Perl 5's `=~`. It aliases the left hand side
to `$_` and then calls `.ACCEPTS($_)` on the right hand side. That is all there is to [its magic](http://docs.perl6.org/routine/~~).

## In-Place Search-Replace

The in-place search-replace using `s///` is nearly identical to Perl 5:

    $_ = 'meowmix';
    s/me/c/;
    .say; # cowmix

    my $mix = 'cowmix';
    $mix ~~ s/c/ch/;
    $mix.say; # chowmix

The `s///` operates on the `$_` variable, modifying it in-place. Note that
I'm not saying "by default"—it does the same in the second example. The `~~`
operator aliases `$mix` to `$_`.

## Adverbs

To substitute all matches and not just the first one (`/g` flag in Perl 5),
simply use the `:g` adverb:

    $_ = 'meow meow meow';
    s:g/me/c/;
    .say; # cow cow cow

## Methods