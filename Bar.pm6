unit module Bar;
use MONKEY-TYPING;
augment class Cool {
    method even { self.Int %% 2 }
}

.^compose for Int, Num, Rat, Str, IntStr, NumStr, RatStr;