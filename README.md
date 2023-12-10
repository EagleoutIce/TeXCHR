# TeXCHR

Welcome to TeXCHR (spoken as "tech-cher")! To run the example you just need plain, good-old TeX. Run:

```shell
tex example.tex
```

## Origins

This is based on the [Python FreeCHR implementation](https://gist.github.com/SRechenberger/739683a23f8a9978ae601c6c815d61c4) by Sascha Rechenberger.

I've written this more as a joke than a real piece of good TeX software, you could do a lot better and several macros are now over-generalized (most do not need arguments, as we could just lock a name like `\constraints` for each program).
The main file is [`chr.tex`](chr.tex), which includes everything desired to get chr for your (_plain_) TeX project.

Feel free to improve it or to criticize it, I'm open to suggestions.

## How Does It Work?

Allows to use FreeCHR in plain TeX. Every program must be wrapped in `\chr{name}{program}` (results can be printed directly or stored using `\gdef`/`\xdef`).

Basic `\Rule{name}{kept-heads,...}{removed-heads,...}{guard}{body}`, `\Compose{rules,...}`, and `\Run{constraints,...}` with FreeCHR semantics.[^1]

Within the heads, you can use `\c` to access the current constraint! For example, if your constraints are just numbers,  you can use `{\ifnum\c>2}` to only allow numbers that are greater than `2` (in general, your heads have to each expand to or behave equivalently to either `\iftrue` or `\iffalse`).
Within the guard you can access all matched constraints using `\c` as a list (i.e., access them with `\c{0}`, `\c{1}`, ...) based on the order of your heads (additionally, you can name them using `\def\n{\c0}`, ...).
Similarly, in your body, you can access all matched constraints as `\c{i}` with i being their 0-based index.
All heads, the guard, and the body can have side effects, given that they still expand to a conditional/update the constraint list `chr@constraint`  in the case of the `body` (for this, you can use `\body` and `\ebody`, see below).

Additionally, there are helper functions like

* `\true` and `\false` for constant true and false guards or heads
* `\log{text...}` to output information during the execution. You have to call `\enablelog` so that logging works.
* `\body{constraints,...}` and `\ebody{constraints,...}` (expands with `\edef`) can be used in the `body` argument of `\Rule` (and `\rule`) to add new constraints more easily (to the main list `chr@constraints`). They are best used at the tail of the body.
* `\LimitCycles{number}` can be used to halt the execution after a maximum of `number` cycles (e.g. if your Rules have no guaranteed fixpoint).
* `\makelist{list-name}{elements,...}` to construct lists (using them as `\name{index}` to access elements, setter and modifications functions are currently not exposed and live under the `\chr@...` namespace), see the [`list.tex`](https://github.com/EagleoutIce/TeXCHR/blob/main/list.tex).
* `\listequal{list-name1}{list-name2}` to compare lists element-wise, expands to `\iftrue`/`\iffalse` respectively
* `\permute{list-name}{length}` which creates all permutations of the given length from the list (using a modified version of [heap's algorithm](https://en.wikipedia.org/wiki/Heap%27s_algorithm)) - currently it does not do fingerprinting (to avoid a problem with otherwise equal constraints) and therefore can produce the same combinations multiple times if `|list-name| < length`. For each combination, this expands the `\chr@@output` macro, which has access to the `list-name` with the current permutation and a shortened `\chr@list@coll` list-presentation (which can be used to copy the list with `\makelist{list-name}{\chr@list@coll}`.
* `\makeatletter` and `\makeatother` help you to access all internal macros (which use the `\chr@` namespace).
* Corresponding to `\Rule`, `\Compose`, and `\Run`, there are lowercase variants `\rule`, `\compose`, and `\run` which take the names of lists (created with `\makelist` instead of the lists directly.

### Fibonacci Example

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

Please note, that integer arithmetic is limited by TeX.

[^1]: For the time being, `compose` is limited to once-per-program (I was too lazy to implement proper nesting).
