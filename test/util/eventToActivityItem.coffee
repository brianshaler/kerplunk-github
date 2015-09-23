eventToActivityItem = require '../../src/util/eventToActivityItem'

describe 'eventToActivityItem', ->

  before ->
    @events = @fixture 'events.json'

  it 'should turn an event into an ActivityItem', ->
    event = @events[0]
    activityItem = eventToActivityItem event
    Should(activityItem?.data?.id).equal event.id
    Should(activityItem.platform).equal 'github'
    Should(activityItem.message).equal 'created a new repo monteslu/bggapp'
