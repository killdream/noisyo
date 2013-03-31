stream = require 'stream'
{slurp, spit} = require '../lib'

(require 'mocha-as-promised')!
chai = require 'chai'
chai.use (require 'chai-as-promised')
{expect} = chai

o = it
x = xit

duplex = ->
  d = new stream.Duplex
  data = ''
  ready = false
  d.write = (buf, enc, f) ->
                  data := buf
                  process.next-tick -> do
                                       ready := true
                                       if f => f!
                                       d.emit 'readable'



  d.read  = ->
            if ready
               process.next-tick -> d.emit 'end'
               ready := false
               return data
            else
               return null

  return d

d = null
before-each -> d := duplex!

text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'


describe 'λ slurp' ->
  o 'Should fulfill with the full contents of the stream.' ->
     d.write text
     expect (slurp d) .to.become text

  x 'Should fail if the stream errors.' ->
     d.write text
     d.haz-error = true
     expect (slurp d) .to.be.rejected.with /no u/     

describe 'λ spit' ->
  describe 'with Stream' ->
    o 'Should fulfill after contents have been piped.' (done) ->
       t = duplex!
       d.write text
       expect ((spit t, d).then slurp) .to.become text

    o 'Should fulfill after source is read if it\'s a standard output stream.' ->
       d.write text
       expect (spit process.stdout, d) .to.be.fulfilled

  describe 'with Strings' ->
    o 'Should fulfill after writing to the source.' ->
       expect ((spit d, text).then slurp) .to.become text

       
