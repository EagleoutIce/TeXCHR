# TeXCHR

Welcome to TeXCHR (spoken as "tech-c-h-r")! To run the example you just need plain, good-old TeX. Run:

```shell
tex example.tex
```

I've written this more as a joke than a real piece of good TeX software, you could do a lot better and several macros are now over-generalized (most do not need arguments now, as we could just lock a name like `\constraints` for each program).
The main file is [`chr.tex`](chr.tex), which includes everything desired to get chr for your (plain) TeX project.

Feel free to improve it or to criticize it, I'm open to suggestions.

## Origins

This is based on the [Python FreeCHR implementation](https://gist.github.com/SRechenberger/739683a23f8a9978ae601c6c815d61c4) by Sascha Rechenberger.

## Work in Progress

For the time, `rule` is not implemented so you can only have fun with `match` and `compose` as well as many helper functions written to achieve the same result as the Python implementation.
The current happy news is that the following correctly finds all permutations that match the constraints:

```tex
\chr{Match Test}{%
   \makelist{constraints}{1,2,3}
   \makelist{patterns}{%
      {\ifnum\c>2},
      {\ifnum\c>0}% \c is the current constraint
   }
   \match{patterns}{constraints}
}
```

Besides, integer arithmetic is limited by TeX and `compose` is limited to once-per-program (I was to lazy implementing proper nesting).