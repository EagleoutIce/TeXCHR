# TeXCHR

[![CI](https://github.com/EagleoutIce/TeXCHR/actions/workflows/ci.yml/badge.svg)](https://github.com/EagleoutIce/TeXCHR/actions/workflows/ci.yml) ![plain TeX](https://img.shields.io/badge/made_with-plain_TeX-purple) [![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa] [![latest tag](https://badgen.net/github/tag/EagleoutIce/TeXCHR?label=latest&color=blue)](https://github.com/EagleoutIce/TeXCHR/releases/latest)


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
Within the guard you can access all matched constraints using `\c` as a list (i.e., access them with `\c{0}`, `\c{1}`, ...) based on the order of your heads (additionally, you can name them using `\def\n{\c{0}}`, ...). The guard has to expand to a conditional too.
Similarly, in your body, you can access all matched constraints as `\c{i}` with i being their 0-based index.

That order is the FreeCHR one: kept heads first, removed heads after. So with `\Rule{r}{{k1},{k2}}{{r1}}{guard}{body}` the guard and the body see `\c{0}` for `k1`, `\c{1}` for `k2` and `\c{2}` for `r1`. The values matched by the removed heads leave the store, and what the body produces is put in front of the rest (`b(*matching) + constraints1` in the Python version).

All heads, the guard, and the body can have side effects, given that they still expand to a conditional/update the constraint list `chr@constraint`  in the case of the `body` (for this, you can use `\body` and `\ebody`, see below).

Additionally, there are helper functions like

* `\true` and `\false` for constant true and false guards or heads
* `\log{text...}` to output information during the execution. You have to call `\enablelog` so that logging works.
* `\body{constraints,...}` and `\ebody{constraints,...}` (expands with `\edef`) can be used in the `body` argument of `\Rule` (and `\rule`) to add new constraints more easily (to the main list `chr@constraints`). They are best used at the tail of the body.
* `\LimitCycles{number}` can be used to halt the execution after a maximum of `number` cycles (e.g. if your Rules have no guaranteed fixpoint). If you hit the limit, you get a warning in the log.
* `\makelist{list-name}{elements,...}` to construct lists (using them as `\name{index}` to access elements, setter and modifications functions are currently not exposed and live under the `\chr@...` namespace), see the [`list.tex`](https://github.com/EagleoutIce/TeXCHR/blob/main/list.tex).
* `\listequal{list-name1}{list-name2}` to compare lists element-wise, expands to `\iftrue`/`\iffalse` respectively
* `\permute{list-name}{length}` gives you every ordered selection of `length` pairwise distinct entries of the list, in the order of Python's `itertools.permutations(list, length)` - no entry twice, no selection twice, and nothing at all if `length` is bigger than the list. For each selection, this expands the `\chr@@output` macro, which has access to the `list-name` (its first `length` entries hold the current selection) and a shortened `\chr@list@coll` list-presentation (which can be used to copy the list with `\makelist{list-name}{\chr@list@coll}`).
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

See the [`example.tex`](example.tex) for a full example or the [`playground.tex`](playground.tex) for more. [`testfiles/`](testfiles) has a few small programs whose results are checked against the Python version, run them with `l3build check` (plain TeX, both `tex` and `pdftex`).

Please note, that integer arithmetic is limited by TeX.

### Which Semantics?

This follows the very abstract operational semantics of FreeCHR, which is what the Python version implements too:

* a rule fires if the store holds a distinct value for every head pattern and the guard likes them together,
* `\Compose` tries its rules in order and stops at the first one that changes the store,
* `\Run` applies the composed solver until the store stops changing.

There is no propagation history. The very abstract semantics has none (you only get one in the *refined* semantics), so a propagation rule with a non-empty body will never reach a fixpoint here, same as in the Python version. That is what `\LimitCycles` is for.

The store is a sequence and not a multiset, and the fixpoint check compares it element-wise (the Python version compares lists, so same thing). Removing a matched value removes its first occurrence.

[^1]: For the time being, `compose` is limited to once-per-program (I was too lazy to implement proper nesting).

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg