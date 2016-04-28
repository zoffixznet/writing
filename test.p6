    given 'Lörem Ipsum Dolor Sit Amet' {
        say S:g      /m/g/;  # Löreg Ipsug Dolor Sit Aget
        say S:i      /l/b/;  # börem Ipsum Dolor Sit Amet
        say S:ii     /l/b/;  # Börem Ipsum Dolor Sit Amet
        say S:samemark     /o/u/;  # Lürem Ipsum Dolor Sit Amet
        say S:nth(2) /m /g/; # Lörem Ipsug Dolor Sit Amet
        say S:x(2)   /m /g/; # Löreg Ipsug Dolor Sit Amet
        say S:ss/Ipsum Dolor/Gipsum\nColor/; # Lörem Gipsum Color Sit Amet
        say S:g:ii:nth(2) /m/g/; # Lörem Ipsug Dolor Sit Amet
    }
