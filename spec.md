# A short spec for the UnNatural Semantic Metalanguage

UNSM is a LISP-like take on the Natural Semantic Metalanguage, a theorized
‘universal syntax of meaning’ leveraging semantic primes and linguistic
universals.

> **NOTE:** UNSM has no reference implementation as of yet.

## Design choices and their whys and forwhats

UNSM should read pretty well, being a blend between LISP and free-form syntax.
It should also be less than annoying to convert to pure S-expressions, and
possible (at whatever cost) to represent in NSM.

UNSM is predicate-oriented – it has no notion of a ‘noun’, just like how NSM
hardly has any noun primes. All quantification is restricted; consequently,
UNSM is a strongly language. This is for two reasons: 

1. Nouns enable a lot of corner cases involving quantification and hermeneutics
   that are tricky to formalize, which results in exponential growth in the
   formalism itself. The closest thing that UNSM has to nouns is variables –
   ‘objects’ – which are always understood to be a product of the type and
   property restraints placed on them (e.g., ‘people’ are ‘things that
   are.people’; ‘people’ is a variable, while ‘are.people’ is a semantic
   prime’). 

2. Unrestricted quantification is not in line with the way <del>I</del>
   <ins>humans</ins> think. By defauly, UNSM views all descriptions as claims
   that can only be substantiated within a specific domain; there is strong
   emphasis put on the distinction between category errors and falsehoods
   (which are fully applicable to human cognition, not to mention that they
   almost directly correspond to topic and focus).

## The specification itself

### Syntax

#### Tokens

There are four kinds of identifiers in UNSM:

1. Plain identifiers, consisting of lowercase Roman letters, hyphens, and/or
   lowercase Greek letters. They are always used for semantic primes or
   molecules; they are always semantic and are not expected to ‘expand’.
2. Variables, constructed by taking a valid identifier and preceding it with an
   apostrophe (`'`). Variables are always bound; their semantics are dictated
   by the syntactic structure that they were bound with.
3. Macros, constructed by appending an exclamation mark (`!`) to a valid
   identifier. Macros are almost always syntactic and expandable, the two
   notable exceptions being `λ!` and `def!`, which are akin to semantic primes
   in that they do not expand.
4. Preprocessing instructions, constructed by appending two exclamation marks
   (`!!`) to a valid identifier. Currently, the only valid preprocessing
   instruction is `include!!`, used for ‘importing’ definitions.

In addition, the following syntactic components are used:

1. The opening and closing parentheses (`(` and `)`), for grouping.
2. The semicolon (`;`), for separating definitions in a file.
3. The percent sign (`%`), for comments.

Spaces are required between consecutive identifiers, variables, or macros.

```peg
ident ⇐ [a-zα-ω-]+
var   ⇐ "'" ident
macro ⇐ ident "!"
dir   ⇐ ident "!!"

open  ⇐ "("
close ⇐ ")"
semi  ⇐ ";"
note  ⇐ "%"
```

#### Productions

The main syntactic structure in UNSM is the proposition, just like the list in
LISP.

* Each proposition takes one *predicate* and any amount of *arguments*. The
  predicate must not be a proposition; arguments may be either propositions or
  values.

* The predicate determines the number of arguments. A macro takes 0 or more
  arguments, taking as many as it can. An identifier or variable takes as many
  arguments as required by its type signature; it is invalid to place a value
  whose type is unknown or not predicative in predicate position.

* Multiple propositions, when in apposition, are considered as one and
  implicitly connected with a ‘zero conjunction’: `A B` = ‘A, B’ or ‘A and B’
  (except that NSM lacks ‘and’).

Note: while macros may take any amount of arguments of any kind, not all
combinations thereof are pragmatically valid with all macros. This is resolved
at compilation time, rather than syntactically, for simplicity.

A semicolon terminates a top-level proposition.

```peg
file  ⇐ (prop' semi?)*

props ⇐ prop'+
prop' ⇐ open prop close
      / prop
prop  ⇐ (ident / var) arg{*}
      / macro arg*
arg   ⇐ ident / var / prop'
```

\* – as many arguments as determined by inspecting the type of the preceding
     expression

### Type system

UNSM is typed; each value carries a so-called *trace* – a list of propositions
that it is involved in, kept for the purposes of pattern-matching with type
constraint definitions. (No reasoning is performed on the trace of a value when
it is pattern-matched; one could say that UNSM’s type checking model is dumb.
This is intentional.)

* ⊤, denoted `any`, is a type. Everything is an `any`; `any` itself is a unary
  predicate that returns true no matter the argument.
* If τ₁, τ₂… are types (any amount, including 0), then (τ₁ × τ₂ × …) → **B** is
  a type – one of a *predicate*. `type!` is the associated type predicate –
  more specifically, `p` is a predicate type iff `type! p τ₁ τ₂…`.

Colloquially, values that are not meant to be used as type predicates may be
called *objects* and type predicates *kinds*; however, there is no fundamental
difference in syntax or semantics between the two.

#### Type hints

Type hints are only allowed in variable *bindings*. A type-hinted variable
follows one of the two following syntaxes:

1. `predicate-name'variable-name`. `predicate-name` may be a macro or another
   variable. There may be no space between the two constituents of this
   syntactic form – this is in contrast with `predicate-name 'variable-name`
   (two terms one after the other.)
2. `(predicate args…)'variable-name`. The associated type hint is
   `(predicate 'variable-name args…)`.

```peg
bind  ⇐ (ident / var / macro) var
      / open prop close var
      / var
```

#### Specificity

UNSM requires all quantification and variable bindings (including arguments to
predicates) to be restricted, the following two facilities are provided to
restrict a variable:

1. With a type hint (see above);
2. By including the variable in a *preamble*.

A variable is restricted if it appears as an argument in a proposition. (Type
hints always have their variable complements as their first argument; thus,
they alone suffice to restrict them, unless new variables are introduced in
their body, like `'τ'x` or `(type! 'σ)'x`.) The preamble is required if – and
continues for as long as – the type hints so far provided do not restrict all
variables or if new variables are introduced.

Type hints are expanded into preamble items at compile time – for example,

> **def!** (only *'τ'x* **anytype!***'τ* (**type!** *'τ*)*'f*) [body…]

expands to

> **def!** (only *'x* *'τ* *'f*) <sup>% Untyped bindings</sup>
>   (*'τ 'x*)
>   (**anytype!** *'τ*)
>   (**type!** *'f* *'τ*) <sup>% Preamble ends here – no more bindings to restrict</sup>
>   [body…]

### Definitions

> **λ!** (predicate bindings…) *preamble…* body…

Predicate definition.

> **def!** (predicate bindings…) *preamble…* body…

Named predicate definition; only valid at the top level.

> **some!** (predicate bindings…) *preamble…* body…

Expands to `(some (λ! …))`. (Yes, `some` as a semantic prime is a predicate
*functor*. Lovely, innit.)

> **anytype!** x

Same as `(type! x any)`.

> **let!** variable value body…

## Examples

### ‘To lie’

| UNSM (base form)                                  | NSM                                                      |
| :------------------------------------------------ | :------------------------------------------------------- |
| def! (lie person'liar words'lie person'liee)      | X lies about Y to Z :=                                   |
|   some! words'disinformation                      |                                                          |
|   want 'liar (know 'liee 'disinformation)         |   X wants Z to know something                            |
|   know 'liar (not (true 'disinformation))         |   X knows that something is not true                     |
|   some! words'said                                |                                                          |
|   say-to 'liar 'said 'liee                        |   X says some words to Z                                 |
|   let! 'cause (like 'said (true 'disinformation)) |                                                          |
|   let! 'result (think 'liee 'disinformation)      |                                                          |
|     'cause                                        |   those words are like that something                    |
|     because 'cause (maybe 'result)                |   because of this, maybe Z thinks that something is true |
|     want 'liar 'result;                           |     …as X wanted                                         |

```scheme
(def (lie liar lie liee)
  (and (person liar)
       (words  lie)
       (person liee))
  (some (λ (disinformation)
           (words disinformation)
           (and (want liar (know liee disinformation))
                (know liar (not (true disinformation)))
                (some (λ (said)
                         (words said)
                         (and (say-to liar said liee)
                              (like said (true disinformation))
                              (because (like said (true disinformation))
                                       (maybe (think liee disinformation)))
                              (want liar (think liee disinformation)))))))))
```

### Dative semantic role

| UNSM (base form)                                                | NSM                                                               |
| :-------------------------------------------------------------- | :--                                                               |
| def! (dative person'who person'whom (type! person person)'what) |                                                                   |
|   let! 'action ('what 'who 'whom)                               | someone did something to something                                |
|   some! (type! person)'goal                                     |                                                                   |
|   let! 'result ('goal 'whom)                                    |                                                                   |
|   because (want 'who 'result) 'did-so                           |   because this someone wanted something to happen to someone else |
|   because 'did-so 'result;                                      | something happened to this other someone because of it            |

```scheme
(def (dative who whom what)
  (and (person who)
       (person whom)
       (type what person person))
  (some (λ (goal)
           (type goal person)
           (and (because (want who (goal whom)) (what who whom))
                (because (what who whom) (goal whom))))))
```
