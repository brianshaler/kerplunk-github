Promise = require 'when'

PreSaveIdentity = require '../../src/util/preSaveIdentity'

System =
  getSettings: -> Promise.resolve {}

getGitHub = (users) ->
  (settings) ->
    api =
      user:
        getFrom: (obj) ->
          Promise.promise (resolve, reject) ->
            if obj?.user == 'derhuerst'
              return resolve users[2]
            if obj?.user == 'fail'
              return reject new Error 'because you told me to'
            resolve()


describe 'preSaveIdentity', ->

  before ->
    @users = @fixture 'users.json'

  beforeEach ->
    @preSaveIdentity = PreSaveIdentity System, getGitHub(@users)

  it 'should turn ignore an identity not from github', ->
    identity = 'notFromGithub'
    @preSaveIdentity(identity).should.equal identity

  it 'should turn fetch profile from API if identity.data.github is from user list', (done) ->
    identity =
      data:
        github: @users[0]

    promise = @preSaveIdentity identity
    Should.exist promise?.then
    promise.then (newIdentity) =>
      Should.exist newIdentity?.data?.github?.name
      newIdentity.data.github.name.should.equal @users[2].name
      done()
    .catch (err) -> done err

  it 'should turn fetch profile from API if identity.data.github is an actor', (done) ->
    identity =
      data:
        github: @users[1]

    promise = @preSaveIdentity identity
    Should.exist promise?.then
    promise.then (newIdentity) =>
      Should.exist newIdentity?.data?.github?.name
      newIdentity.data.github.name.should.equal @users[2].name
      done()
    .catch (err) -> done err

  it 'should populate name fields after fetching complete profile', (done) ->
    identity =
      data:
        github: @users[1]

    promise = @preSaveIdentity identity
    Should.exist promise?.then
    promise.then (newIdentity) =>
      {nickName, fullName, firstName, lastName} = newIdentity
      Should(nickName).equal 'derhuerst'
      Should(fullName).equal 'Jannis Redmann'
      Should(firstName).equal 'Jannis'
      Should(lastName).equal 'Redmann'
      done()
    .catch (err) -> done err
