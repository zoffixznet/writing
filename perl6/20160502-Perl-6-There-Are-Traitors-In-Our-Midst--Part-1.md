# Perl 6: There Are Traitors In Our Midst!

*Ahoy, matey! I heard thar be traitors in our ranks! We need t' search t' ship 'n find every last one o' them, put them through exquisite torture, 'n then make them swim t' plank. Now t' ye, I gift a task! Learn everythin' ye can 'bout these traitors 'n all o' t' "traits" they use. Ye succeed, a full barrel o' spiced rum gunna be me generous gift t' ye!*

# PART I: Built-In Traits

Traits! In Perl 6, they're subs executed at compile time that make your code tight and sexy. Let's look at some of the traits you get from the bare Perl 6 and then learn how to create your very own!

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

##

*Oi, Matey! Seems th' traitors be way more advanced than us 'n their code be much cleaner, powerful, 'n beautiful! It'd be suicide to be off against all 'o them! ye still want that spiced rum? Find out how we could use th' trators' methods 'n improve upon them! Do that 'n a chest 'o gold gunna be yours, as well as th' hooch!*