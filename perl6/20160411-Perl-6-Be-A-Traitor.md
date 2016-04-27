# Perl 6: There Are Traitors In Our Midst!

Traits! In Perl 6, they're subs executed at compile time that make your code tight and sexy. Let's look at some of the traits you get from the bare Perl 6 and then learn how to create your very own!

# PART I: Built-In Traits

# `is ...`

    sub foo ($bar is copy) is export { ... }
    has $.foo is rw is required;
    class Foo is Bar { ... }

There are several built-in traits that you apply with the `is` keyword. Let's
take a look some of the oft-used:

## `is export`

    # In Foo.pm6
    unit module Foo;
    sub foo is export           { }
    sub bar is export(:special) { }

    # In foo.p6
    use Foo; # only foo() available for use
    use Foo :special; # only bar() available for use
    use Foo :ALL; # both foo() and bar() available for use

The `is export` trait makes your things automatically exported, for use by
other packages using yours. You can also create categories by giving a named
argument to `export()`. That argument can be specified when `use`ing your
module to export that specific category. Three predefined categories exist:
`:ALL` that exports all of `is export` symbols, `:DEFAULT` that exports those
with bare `is export` without arguments, and `:MANDATORY` marks symbols that will be export regardless of what argument is given during `use`.

Of course, you can export constants, variables, and classes too:

    our constant Δ is export = 0.5;
    our $bar       is export = 10;
    our Class Bar is export { ... };

The trait is really just sugar for [UNIT::EXPORT::* magic](http://docs.perl6.org/language/modules#Exporting_and_Selective_Importing), which you can use
directly if you need more control.

## `is copy`

    sub foo ($x is copy) { $x = 42; }
    sub bar ($x        ) { $x = 42; }

    my $original = 72;
    foo $original; # works; $original is still 72
    bar $original; # fatal error;

When your subroutine or method recieves parameters, they are read-only. Any
attempt to modify them will result in a fatal error. At times when you do
wish to fiddle with them, simply apply `is copy` trait to them in the
signature. And don't worry, that won't affect the caller's data. To do that,
you'll need the `is rw` trait...

## `is rw`

The `rw` in `is rw` trait is short for "read-write" and this concise trait
packs a ton of value. Let's break it up:

#### modifying caller's values

    sub foo ($x is rw) { $x = 42 };

    my $original = 72;
    foo $original;
    say $original; # prints 42

If you apply `is rw` to a parameter of a sub or method, you'll have access
to caller's variable. Modifying this parameter will affect the caller, as can
be seen above, where we change the value of `$original` by assigning to the
parameter inside the sub.

#### writable attributes

    class Foo {
        has $.foo is rw;
        has $.bar;
    }

    Foo.new.foo = 42; # works
    Foo.new.bar = 42; # fatal error

Your classes' *public* attributes are read-only by default. By simply applying
the `is rw` trait, you can let the users of your class assign values to the
attribute after the object has been created. Keep in mind: this is only
relevant for the public interface; inside the class, you can still modify
the values of even the read-only attributes using the `$!` twigil
(i.e. `$!bar = 42`).

#### LHS subroutines/methods

    class Foo {
        has $!bar;
        method bar is rw { $!bar }
    }
    Foo.new.bar = 42;

    sub postcircumfix:<❨  ❩> ($before, $inside) is rw {
        $before{$inside};
    }
    my %hash = :foo<bar>;
    %hash❨'foo'❩ = 42;
    say %hash<foo>

The `is rw` trait applied to attibutes, as you've seen in previous section,
is just syntax sugar for automatically creating a private attribute and
a method for it. Notice, in the code above we applied `is rw` trait on the
*method*. This makes it return the writable container the caller can use to
assign to.

In the same manner, we can create subroutines that can be used on the left
hand side and be assigned to. A semi-elaborate example above creates a
custom operator (which is just a special sub) for using fancy-pants parentheses
to do hash look ups. The `is rw` trait makes it possible to assign to a
hash.

NOTE: if you use explicit `return` in your sub, the `is rw` trait won't work.
What you're supposed to be using is for this is `return-rw` keyword instead,
and if you do use it, `is rw` trait is not needed.
[I don't think that is the ideal behaviour](https://rt.perl.org/Ticket/Display.html?id=127924), but I've been wrong before.

## `is required`

    class Foo {
        has $.bar is required;
    }
    my $obj = Foo.new; # fatal error, asks for `bar`

    sub foo ( :$bar is required ) { }
    foo; # fatal error, asks for $bar named arg

As the name suggests, `is required` trait marks class attributes and
named parameters as mandatory. If those are not provided at object
instantiation or method/sub call, a fatal error will be thrown.

## `is Type/Class/Role`

    role  Foo { method zop { 'Foo' } }
    role  Bar { method zop { 'Bar' } }
    class Mer { method zop { 'Mer' } }

    class Meow is Int is Foo is Bar is Mer { };

    my $obj = Meow.new: 25;
    say $obj.sqrt; # 5
    say $obj.zop;  # Foo

First a note: this is NOT the way to apply Roles; you should use `does`. When
you use `is`, they simply [get punned](http://docs.perl6.org/language/objects#Automatic_Role_Punning) and applied as a class.

Using `is` keyword followed by a Type or Class inherits from them. The `Meow`
class constructed above is itself empty, but due to inherting from `Int` type
takes an integer and provides [all of `Int` methods](http://docs.perl6.org/type/Int). We also get method `zop`, which is provided by `Foo` class in
this case. And despite both roles providing it too, we don't get any errors,
because those roles got punned.

## `does`

Let's try out our previous example, but this type compose the roles correctly,
using the `does` trait:

    role  Foo { method zop { 'Foo' } }
    role  Bar { method zop { 'Bar' } }
    class Mer { method zop { 'Mer' } }

    class Meow is Int does Foo does Bar is Mer { };

    # OUTPUT:
    # ===SORRY!=== Error while compiling
    # Method 'zop' must be resolved by class Meow because it exists in multiple roles (Bar, Foo)

This time the composition correctly fails. The `does` trait is what you use
to compose roles.

## `of`

    subset Primes of Int where *.is-prime;
    my Array of Primes $foo;
    $foo.push: 2; # success
    $foo.push: 4; # fail, not a prime

The `of` trait gets an honourable mention. It's used in
[creation of subsets](http://blogs.perl.org/users/zoffix_znet/2016/04/perl-6-types-made-for-humans.html)
or, for example, restricting elements of an array to a particular type.

# PART II: Custom Traits

Custom traits obviously pack a lot of power into a few characters... wouldn't
it be awesome if you could create your own? It wouldn't be Perl if you couldn't!

## The Basics

Traits are subs that you simply declare with:

    multi trait_mod:<is> ( *signature goes here* ) { *body goes here* }

The signature specifies what the trait applies to and how it's used. One example
can be `Variable $v, :$config!`. Such a trait would apply to variables only
and would be specified as `is config` or `is config('some argument')`. Notice
how the name of the parameter and the word after `is` match.

The body is where the magic happens, but keep in mind:
traits are applied at *compile time*, so some things won't be available to your
traits.

While we saw traits using verbs other than `is`, custom traits can be created
only with `is`.

## Assign Default Values

Pretend you have an app that has a bunch of configuration. Let's
create App::Config module that exports a custom trait `is config` to load
that configuration from a JSON file:

    # ./test-config.json:
    {
        "name": "Bender",
        "input": "beer"
    }

    # ./App/Config.pm6
    1: unit module App::Config;
    2: multi trait_mod:<is> (Variable $v, :$config!) is export {
    3:     my $conf = from-json slurp '../../test-config.json';
    4:     my $name = $config ~~ Str ?? $config !! $v.var.VAR.name.substr: 1;
    5:     $v.var   = $conf{ $name } // die 'Unknown configuration variable';
    6: }

    # ./app.p6
    1: use App::Config;
    2: my $name  is config;
    3: my $input is config;
    4: my $robot is config('name');
    5: say "$robot\'s name is $name and he likes $input";

    # OUTPUT:
    # Bender's name is Bender and he likes beer

Before we examine the trait's definition, let's take a look at how it's used in
`app.p6`. On line 1 we simply `use` our config module.
On lines 2 and 3 we have `is config` next to variables and that's it.
So how does the trait figure out what config values to load? Thanks to Perl 6's
powerful Meta Object Protocol, the trait can actually look up what the variable
is called. We do that on line 4, in `App/Config.pm6`
in the `!!` condition. The `.substr` is used,
because the `.name` method returns the sigil as well.

Line 4 in `app.p6` also shows a way to pass arguments to traits. In this case,
we use the argument as the name of the config variable, to avoid using the name
of the variable it is assigned to. On line 4, in `App/Config.pm6`, we test
whether the `$config` parameter is a string, which would indicate the argument
was passed (the value is a `Bool` without any arguments).

The results are great! Our `app.p6`'s code is very clean, without any repetition
of names, and yet, we have awesome configuration capabilities. If you were to
switch from JSON to, say, database-driven configuration, just modify your
trait's definition. The rest of the app will still work the same.
