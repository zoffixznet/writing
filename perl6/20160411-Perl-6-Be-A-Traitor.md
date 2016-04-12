# Perl 6: Be a Traitor!

Traits! They're roles composed at compile time that make your code tight and
sexy. Let's look at some of the traits you get from the bare Perl 6 and then
learn how to create your very own!

# `is ...`

```perl6
    sub foo is export { ... }
    has $.foo is rw is required;
```
