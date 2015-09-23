userToIdentity = require '../../src/util/userToIdentity'

describe 'userToIdentity', ->

  before ->
    @users = @fixture 'users.json'

  it 'should turn a user into an identity', ->
    user = @users[0]
    identity = userToIdentity user
    Should.exist identity?.data?.github?.id
    Should.exist identity.nickName
    identity.nickName.should.equal user.login

  it 'should turn an actor into an identity', ->
    user = @users[0]
    identity = userToIdentity user
    Should.exist identity?.data?.github?.id
    Should.exist identity.nickName
    identity.nickName.should.equal user.login
