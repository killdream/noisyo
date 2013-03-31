## Module noisyo
#
# Drinks and vomits Stream contents. Promised to be really noisy.
#
# 
# Copyright (c) 2013 Quildreen "Sorella" Motta <quildreen@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### -- Dependencies ----------------------------------------------------
pinky = require 'pinky'
stream = require 'stream'


### -- Helpers ---------------------------------------------------------

#### λ is-stream
# Checks if something is a Stream.
#
# :: a -> Bool
is-stream = (a) -> typeof a?.pipe is 'function'

#### λ is-standard-output
# Checks if a Stream is a standard output stream.
#
# :: a -> Bool
is-standard-output = (a) -> (a is process.stdout) or (a is process.stderr)


### -- Helpers for writing to Streams ----------------------------------

#### λ pipe-from
# Pipes a Stream from source to destination.
#
# :: Stream -> Stream -> Promise Stream Error
pipe-from = (source, dest) ->
  promise = pinky!

  # Node doesn't close standard output streams when piping to them, so
  # we just assume things will be correctly written by the time we
  # finished draining the input.
  if is-standard-output dest => source.on 'end' fulfill-read
  else                       => dest.on 'finish' fulfill

  source.on 'error' handle-errors
  source.pipe dest

  return promise

  function handle-errors(err)
    promise.reject err
  
  function cleanup()
    source.remove-listener 'error' handle-errors
  
  function fulfill-read()
    promise.fulfill dest
    source.remove-listener 'end' fulfill-read
  
  function fulfill()
    promise.fulfill dest
    dest.remove-listener 'finish' fulfill


#### λ write-to
# Writes plain strings/buffers to the output Stream.
#
# :: Stream -> String | Buffer -> Encoding -> Promise Stream Error
write-to = (dest, source, encoding) ->
  promise = pinky!

  dest.write source, encoding, (err) ->
    | err => promise.reject err
    | _   => promise.fulfill dest
  
  return promise




### -- Core implementation ---------------------------------------------

#### λ slurp
# Drains the contents of a Stream and returns a promise for it.
#
# :: Stream -> Promise String Error
slurp = (source) ->
  promise = pinky!
  data    = (source.read! || '').to-string!

  source.on 'readable' grab-chunk
  source.on 'error' handle-failure
  source.on 'end' fulfill
  source.on 'end' clean-up

  return promise

  function grab-chunk()
    chunk = source.read!
    if chunk isnt null => data += chunk.to-string!

  function handle-failure(err)
    promise.reject err

  function fulfill()
    promise.fulfill data

  function clean-up()
    source.remove-listener 'readable' grab-chunk
    source.remove-listener 'end' fulfill
    source.remove-listener 'end' clean-up


#### λ spit
# Vomits some contents (String or Stream) into a Stream.
#
# :: Stream -> String -> Promise Stream Error
# :: Stream -> Stream -> Promise Stream Error
spit = (dest, source) -->
  | is-stream source => pipe-from source, dest
  | otherwise        => write-to dest, source, arguments[2]




### -- Exports ---------------------------------------------------------
module.exports = { slurp, spit }
