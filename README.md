# TeXCHR

Welcome to TeXCHR (spoken as "tech-cher")! To run the example you just need plain, good-old TeX. Run:

```shell
tex example.tex
```

I've written this more as a joke than a real piece of good TeX software, you could do a lot better and several macros are now over-generalized (most do not need arguments, as we could just lock a name like `\constraints` for each program).
The main file is [`chr.tex`](chr.tex), which includes everything desired to get chr for your (_plain_) TeX project.

Feel free to improve it or to criticize it, I'm open to suggestions.

## Origins

This is based on the [Python FreeCHR implementation](https://gist.github.com/SRechenberger/739683a23f8a9978ae601c6c815d61c4) by Sascha Rechenberger.

## Work in Progress

You want fibonacci? You can have fibonacci!

```tex
\chr{fib test}{%
   \LimitCycles{25}
   \Compose{
      \Rule{main}%
      {} % empty kept head
      {{\true}} % removed head
      {\true}
      {% poor man's tuple
         \tuple{\c{0}}%
         \add{\fst}{\snd}%
         % ebody expands its argument to replace
         \ebody{\snd:\res}%
      }
   }
   \Run{{0:1}}
}
```

To work with tuples you need some helpers:

```tex
\def\tuplehelper#1:#2\@nil{\def\fst{#1}\def\snd{#2}}
\def\tuple#1{\edef\@tmp{#1}\expandafter\tuplehelper\@tmp\@nil}
\def\add#1#2{\chr@tempcount=#1\relax\advance\chr@tempcount by #2\relax\edef\res{\the\chr@tempcount}}
```

See the [`example.tex`](example.tex) for a full example or the [`playground.tex`](playground.tex) for more.

Please note, that integer arithmetic is limited by TeX and `compose` is limited to once-per-program (I was too lazy to implement proper nesting).
