use MONKEY-TYPING;
augment class Cool {
    method even { self %% 2 }
}

.^compose for Int, Num, Rat, Str, IntStr, NumStr, RatStr;

.say for 72.even, '72'.even, pi.even, ½.even, now.even;

