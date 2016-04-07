# Perl 6 Is Slower Than My Fat Momma!

I notice several groups of people:
folks who wish Perl 6's performance weren't mentioned;
folks who are confused about Perl 6's perfomance;
folks who gleefully chuckle at Perl 6's performance,
reassured the threat to their favourite language XYZ
hasn't yet arrived.

So I'm here to talk about the elephant in the room
and get the first group out of hiding,
I'll explain things to the second group, and to the
third group... well, this post isn't about them.

## Why is it slow?

The simplest answer: Perl 6's brand new. The 
*language spec* was finished less than 4
months ago (Dec 25, 2015). While *some* optimization
has been done, the core team focused on getting
things right first. It's simply unrealistic to
evaluate Perl 6's performance as that of an extremely
polished product at this time.

The second part of the answer: Perl 6 is big.
It's easy to come up with a couple of one-liners that
are much faster in other languages. However, the
Perl 6 one-liner loads the comprehensive object
model, list tools, set tools, large arsenal of async
and concurrency tools... When in a real program you have to load
a dozen of modules in language XYZ, but still stay
with bare Perl 6, that's when performance will
start to even out.

## What can ***you*** do about it?

Now that we got things right, we can focus on making
them fast. Perl 6 uses a modern compiler, so
*in theory* it can be optimized quite a lot. It
remains to see whether theory will match reality,
but looking through numerous optimization commits
made since the start of 2016, a few gems stand out:

* [Make Parameter.sigil about **20x faster**](https://github.com/rakudo/rakudo/commit/add25c771c5b82ab0ce5bd3f6c0e87a6e9334a2d)
* [Make Blob:D eq/ne Blob:D about **250x faster**](https://github.com/rakudo/rakudo/commit/1969a42525f69d930735009a1dbbc39f3e910888)
* [Make prefix ~^ Blob:D about **300x faster**](https://github.com/rakudo/rakudo/commit/fb74abc314efa2dcc7f4866f1378f40a17410a50)
* [Make ~|, ~& and ~^ about **600x faster**](https://github.com/rakudo/rakudo/commit/138441c97df2fc0603047b589e1fa71a126185f3)
* [Make int @a.append(1) **1800x faster**](https://github.com/rakudo/rakudo/commit/c70a18e9cd4aff36c2c7a6b8f9a62770c8c533b3)
* [Make Blob:D cmp/lt/gt/le/ge Blob:D **3800x faster**](https://github.com/rakudo/rakudo/commit/e3342da00e7cfca618acbab37b90f13a133c73f6)

Thus, the answer is we're working on it... and we're making good progress.

## What can ***I*** do about it?

I'll mention three main things to keep in mind when trying
to get your code to perform better:
pre-compilation, native types, and of course, concurrency.

#### Pre-Compilation

Currently, a large chunk of slowness you may notice comes
from parsing and compiling code. Luckily, Perl 6
automagically pre-compiles modules, as can be seen here, with
a large Foo.pm6 module I'm including:

    $ perl6 -I. -MFoo --stagestats -e ''
    Stage start      :   0.000
    Stage parse      :   4.262
    Stage syntaxcheck:   0.000
    Stage ast        :   0.000
    Stage optimize   :   0.002
    Stage mast       :   0.013
    Stage mbc        :   0.000
    Stage moar       :   0.000
    
    $ perl6 -I. -MFoo --stagestats -e ''
    Stage start      :   0.000
    Stage parse      :   0.413
    Stage syntaxcheck:   0.000
    Stage ast        :   0.000
    Stage optimize   :   0.002
    Stage mast       :   0.013
    Stage mbc        :   0.000
    Stage moar       :   0.000

The first run was a full run that pre-compiled my module, but the second one already had the
pre-compiled Foo.pm6 and the parse stage went down from
4.262 seconds to 0.413: a 1031% start-up improvement.

Modules you install from [the ecosystem](http://modules.perl6.org/) get
pre-compiled during installation, so you don't have to
worry about them. When writing your own modules, however,
they will be automatically re-pre-compiled every time you change their
code. If you make a change before each time you run
the program, it's easy to get the impression it's not
performing well, even though the compilation penalty
won't affect the program once you're done tinkering with it.

Just keep that in mind.

## Native Types

Perl 6 has several "native" machine types that can offer
performance boosts in some cases:

    my Int $x = 0;
    $x++ while $x < 30000000;
    say now - INIT now;

    # OUTPUT:
    # 4.416726

    my int $x = 0;
    $x++ while $x < 30000000;
    say now - INIT now;

    # OUTPUT:
    # 0.1711660

That's a 2580% boost we achieved all simply switching our counter to
a native `int` type.
    
The available types are: `int`, `int8`, `int16`, `int32`, `int64`,
`uint`, `uint8`, `uint16`, `uint32`, `uint64`, `num`, `num32`,
and `num64`. The number in the type name signifies the available
bits, with the numberless types being platform-dependent.

They aren't a magical solution to every problem, and won't offer huge
improvements in every case, but keep them in mind and look out
for cases where they can be used.

## Concurrency

Perl 6 makes it extremely easy to utilize multi-core CPUs with
[high-level APIs](http://docs.perl6.org/language/concurrency#High-level_APIs)
like Promises, Supplies, and Channels. Where language XYZ is fast,
but lacks ease of concurrency, Perl 6 can end up the winner in peformance
by distributing work over multiple cores.

I won't go into details; you can consult
[the documentation](http://docs.perl6.org/language/concurrency)
or watch [my talk that mentions them](https://youtu.be/paa3niF72Nw?t=32m14s)
([slides](http://tpm2016.zoffix.com/#/33)). I will show an example, though:

    await (
        start { say "One!";   sleep 1; },
        start { say "Two!";   sleep 1; },
        start { say "Three!"; sleep 1; },
    );
    say now - INIT now;

    # OUTPUT:
    # One!
    # Three!
    # Two!
    # 1.00665192

We use `start` keyword to create three
[Promises](http://docs.perl6.org/type/Promise) and then use the
`await` keyword to wait for all of them to complete. Inside our
Promises, we print out a string and then sleep for at least one second.

The result? Our program has three operations that take
at least 1 second each, yet the total runtime was
just above 1 second. From the output, we can
see it's not in order, suggesting code was executed
on multiple cores.


