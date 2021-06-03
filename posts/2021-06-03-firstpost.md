---

title: A Statement of the Problem
date: June 2nd, 2021
description: Kind of a test post to see how Hakyll works.
tags: haskell, generics, compiler

---

So one of the projects I am working on in my free time when I want to write some code is a Racket/Scheme (some gross syntactical combination of the two) to x86 compiler written in haskell. 
I can talk more about how its built later, but that isn't the focus of this post. 
Recently, I refactored the parsing/lexing from using the monadic parsing library Parsec to using Alex/Happy lexer/parser generators.
This allowed me to have a far cleaner AST where I didn't have to match on lists and such. This is an Improvement.
However, what did result is a large mutually recursive data type that defines my AST.
My implementation of Lambdas requires a lot of operations on the AST, from folding to find free variables to transformation to naming/renaming each lambda.
Obviously writing hundreds of lines of boilerplate for each operation, and then having it be extremely unextensible isn't the programmer way, much less the haskell way so I set out to find the generic data type manipulator in haskell.
I figured, since haskell data types can be pretty much defined as Sum and Product types then there should be some straightforwards way to do it, but it turns out there has been a lot of different strategies written to do this.
So I built a sort of mini example of my recursive datatype and set out to find the best solution.

~~~~~{.haskell}
data Sexpr 
    = Expr Expr
    | Const Const
    deriving (Eq, Show)

data Const
    = I Int
    | B Bool
    deriving (Eq, Show)
    
data Expr
    = If Sexpr
    | Lambda String Sexpr
    deriving (Eq, Show)

test = Expr (Lambda "ex" (Const (B True)))
~~~~~

Given an AST like this, I wanted (at the minimum) a library that can take a Sexpr (or a list of Sexpr is probably more ideal) and change the String on the Lambda. 
Ideally it would also let me thread a simple state monad through it so I can ensure that the symbol is unique across the program. 

Haskell has a ton of these; I am not qualified to explain half of them or thier histories, but I will recount what I know as of right now.

- SYB (Scrap Your Boilerplate): An old library that does runtime analysis on the structure of the program and then generates traversals based on that. However, every time I mentioned it to more experienced haskell developers, they told me that it was old (and slow? I have read conflicting material on this stuff), and that GHC.Generics was the more preferred/modern generic library. I will admit however, it does do what I wanted to do; but there was something in me that wanted to use more 'conventional' libraries
- GHC.Generics: Seems pretty modern. The generation of the typeclass made a lot of sense to me once I sort of understood the (U1, V1, K1, etc....) but I could not understand how to write an instance declaration that would a. typecheck and b. actually modify the string
- Lens: I believe that this should work, but the size of the library was a bit of an obstacle, and I am under the impression that it requires record types, and my AST is not based on records.
- Uniplate: Actually one library that I would work, but the fact that I had several data types depending on each other meant that Unicomp did not like what I was doing. Admittedly it is possible that I messed it up, but the existence of Biplate and Multiplate makes me less convinced.
- Strafunsky: This seemed similar to SYB (and I believe that it actually is in use in some small languages) but I had a hard time finding practical examples for me to actually base my code (which is my fault to be honest)
- Free Monad: This strategy was recommended to me, but after a lot of reading of ncatlab-esqe pages, I believe that they are more aimed towards generating ASTs and modifying from the start, which wouldn't work for my use case since I was planning on using Happy to generate my ASTs
- Multiplate: The same strategy as Uniplate, but specifically written so that it could work on mutually recursive datatypes, like the kind I was using for my AST

When I actually get a full working implementation down, I'll write it out, but I wanted to list sort of the main ones I found here since I find that there is not a lot of information out there on how to use haskell generics. 

Obviously - I have no Idea what I am doing here, and my category theory is weak enough that talk of comonads makes me glaze over slightly. If you want to correct me please email. I will admit however, I wish there were more examples of these libraries, as they are abstract enough that reading documentation is frequently not enough for a newcomer to this field.
