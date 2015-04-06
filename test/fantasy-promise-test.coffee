R = require 'ramda'
chai = require 'chai'
chai.should()
Promise = require 'bluebird'
FantasyPromise = require '../lib/fantasy-promise'

describe 'FantasyPromise', ->
  add1 = (n) -> n + 1
  promise = Promise.resolve(5)
  add1Async = (n) -> Promise.resolve n + 1
  makePromise = (val) -> FantasyPromise.of Promise.resolve(val)

  Given -> @subject = FantasyPromise.of(promise)

  describe '#map', ->
    When -> @subject.map(add1).then (@result) =>
    Then -> @result == 6

  describe '#chain', ->
    When -> @subject.chain(add1Async).then (@result) =>
    Then -> @result == 6

  describe '#then', ->

    describe '- error', ->
      e  = new Error 'someError'
      throwError = -> throw e
      When -> @subject.then(throwError).then null, (@result) =>
      Then -> @result == e

    describe '- success', ->
      When -> @subject.then(add1).then (@result) =>
      Then -> @result == 6

  describe '#ap', ->
    liftA2 = (f, m1, m2) -> m1.map(f).ap(m2)
    Given -> @promise2 = FantasyPromise.of Promise.resolve(7)
    When -> liftA2(R.add, @subject, @promise2).then (@result) =>
    Then -> @result == 12

  describe '#fork', ->

    describe '- error case', ->
      When ->
        @errorFuture = FantasyPromise.of Promise.reject new Error 'someError'
        @errorFuture.fork (@result) =>
      Then -> @result.message == 'someError'

    describe '- success case', ->
      When -> @subject.fork null, (@result) =>
      Then -> @result == 5

  describe 'common promise lib test', ->
    promises = R.times makePromise, 11

    describe 'all', ->
      When -> Promise.all(promises).then(R.reduce(R.add, 0)).then (@result) =>
      Then -> @result == 55

    describe 'props', ->
      obj =
        foo: makePromise 'foo'
        bar: makePromise 'bar'
      When -> Promise.props(obj).then (@result) =>
      Then -> @result.should.deep.equal foo: 'foo', bar: 'bar'

  describe 'composing with map', ->
    composed = R.compose(
      R.map(R.toUpper)
      R.map(R.head)
      R.map(R.split(' '))
    )
    Given -> @promise = makePromise 'hello world'
    When -> composed(@promise).then (@result) =>
    Then -> @result == 'HELLO'

  describe 'composing with chain', ->
    toUpperPromise = (s) -> FantasyPromise.of Promise.resolve R.toUpper s
    composed = R.compose(
      R.chain(toUpperPromise)
      R.map(R.head)
      R.map(R.split(' '))
    )
    Given -> @promise = makePromise 'hello world'
    When -> composed(@promise).then (@result) =>
    Then -> @result == 'HELLO'
