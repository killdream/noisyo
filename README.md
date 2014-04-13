# Noisyo 

[![Build Status](https://secure.travis-ci.org/robotlolita/noisyo.png?branch=master)](https://travis-ci.org/robotlolita/noisyo)
[![NPM version](https://badge.fury.io/js/noisyo.png)](http://badge.fury.io/js/noisyo)
[![Dependencies Status](https://david-dm.org/robotlolita/noisyo.png)](https://david-dm.org/robotlolita/noisyo)
[![stable](http://hughsk.github.io/stability-badges/dist/stable.svg)](http://github.com/hughsk/stability-badges)

**Note that this only works in Node 0.10 now, using the new Streams.**

Drinks and vomits Stream contents. Promised to be really noisy.

As you could probably guess, this is totes influenced by the [Clojure core
library](http://clojuredocs.org/clojure_core/clojure.core/slurp). But more
general :D


## Example

```js
var noisyo = require('noisyo')
var spit   = noisyo.spit
var slurp  = noisyo.slurp

// Slurp takes a Stream and returns a Promise of its contents.
// Spit takes a Stream, and some contents, and returns a Promise of the
// eventual draining.
spit(process.stdout, slurp(process.stdin))

// So, why not just `.pipe()` you faggot?
// Well, these work with both Strings and Streams interchangeably.
var input = slurp(process.stdin)
input.then(function(data) {
  console.log(data)
  spit(fs.createWriteStream('foo.txt'), data)
})

// Obviously, you *will* want to use Streams directly if you're interested in
// piping between them, this is not a substitute for Streams, just a nice,
// high-level way of getting to its contents in one-shot quickly and
// asynchronously. But it will buffer the whole thing in memory, which might be
// *bad* in certain cases.
```


## Installing

Just grab it from NPM:

    $ npm install noisyo


## Documentation

A quick reference of the API can be built using [Calliope][]:

    $ npm install -g calliope
    $ calliope build


## Tests

You can run all tests using Mocha:

    $ npm test


## Licence

MIT/X11. ie.: do whatever you want.

[Calliope]: https://github.com/robotlolita/calliope
[es5-shim]: https://github.com/kriskowal/es5-shim
