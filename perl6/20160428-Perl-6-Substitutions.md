# Perl 6: The S/// Operator

Coming from a Perl 5 background, my first experience with Perl 6's non-destructive substitution operator `S///` looked something like this:

<p style="text-align: center">
    <small><i>(artist's impression)</i></small>
    <img src="stock/20160428-Substitutions.gif" style="display: block; margin: 20px auto;">
</p>

You'll fare better, I'm sure. Not only have the error messages improved, but I'll also explain everything right here and now.

## The Smartmatch

The reason I had issues is because, seeing familiar-looking operators, I
simply translated Perl 5's *binding* operator (`=~`) to Perl 6's
*smartmatch* operator (`~~`) and expected things to work. The `S///` was not documented and, combined with the confusing (at the time) error message, this was the source of my pain:

    my $orig = 'meowmix';
    my $new = $orig ~~ S/me/c/;
    say $new;

    # OUTPUT error:
    # Smartmatch with S/// can never succeed

The old error suggests the `~~` operator is the wrong choice here and it is.
The `~~` isn't the equivalent of Perl 5's `=~`. It aliases the left hand side
to `$_`, evaluates the right hand side, and then calls `.ACCEPTS($_)` on it. That is all there is to its magic.

So what's actually happening in the example above:

* By the time we get to `S///`, `$orig` is aliased to `$_`
* The `S///` non-destructively executes substitution on `$_` and **returns the resulting string**
* The smartmatch, following the [rules](http://docs.perl6.org/routine/~~)] for
`Str` against `Str`, will give `True` or `False` depending on whether
substitution happened (`True`, confusingly, meaning it didn't)

At the end of it all, we ain't getting what we actually want: the version of the string with substitution applied.

## With The Given

Now that we know that `S///` always works on `$_` and returns the result, it's
easy to come up with *a whole bunch* of methods that set `$_` to our original
string and someone gather back the return value of `S///`, but let's look
at just a couple of them:

    my $orig = 'meowmix';
    my $new = S/me/c/ given $orig;
    say $orig;
    say $new;

    my @orig = <meow cow sow vow>;
    my @new = do for @orig { S/\w+ )> 'ow'/w/ };
    say @orig;
    say @new;

    # OUTPUT:
    meowmix
    cowmix
    [meow cow sow vow]
    [wow wow wow wow]

The first one operates on a single value. We use the post-fix form of a
`given` block, which lets us avoid the curlies. From the output, you can see the original string remained intact.

The second example operates on a whole bunch of strings from an `Array` and we
use the `do` keyword to execute a regular `for` loop (that aliases to `$_` in this case) and assign the result to a `@new` array. Again, the output shows
the originals were not touched.