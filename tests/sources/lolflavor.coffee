require('../_init')

fs = require 'fs'
glob = require 'glob'
nock = require 'nock'
path = require 'path'
should = require('chai').should()
_ = require('lodash')

nocked = null
lolflavor = require '../../lib/sources/lolflavor'

RESPONSES_FIXTURES = {}
_.each glob.sync(path.join(__dirname, 'fixtures/lolflavor/responses/*.json')), (fixture) ->
  var_name = path.basename(fixture).replace('.json', '')
  RESPONSES_FIXTURES[var_name] = require(fixture)

RESULTS_FIXTURES = {}
_.each glob.sync(path.join(__dirname, 'fixtures/lolflavor/results/*.json')), (fixture) ->
  var_name = path.basename(fixture).replace('.json', '')
  RESULTS_FIXTURES[var_name] = require(fixture)

describe 'lib/sources/lolflavor.coffee', ->
  before ->
    nocked = nock('http://www.lolflavor.com')

  afterEach ->
    nock.cleanAll()

  describe 'version', ->
    it 'should get the stubbed lolflavor version', (done) ->
      nocked
        .get('/champions/Ahri/Recommended/Ahri_lane_scrape.json')
        .reply(200, RESPONSES_FIXTURES.ahri_lane_scrape)

      lolflavor.version (err, version) ->
        should.not.exist(err)
        version.should.equal('9/21/2015')
        done()

  describe 'aram', ->
    beforeEach ->
      window.cSettings = {}
      nock.cleanAll()

    it 'should get default ARAM item sets for Katarina', (done) ->
      nocked
        .get('/data/statsARAM.json')
        .reply(200, RESPONSES_FIXTURES.statsARAM)
        .get('/champions/Katarina/Recommended/Katarina_aram_scrape.json')
        .reply(200, RESPONSES_FIXTURES.katarina_aram_scrape)

      lolflavor.aram (err, results) ->
        should.not.exist(err)
        results.should.eql(RESULTS_FIXTURES.katarina_aram)
        done()

      , {riotVer: '5.18', manaless: ['katarina']}
