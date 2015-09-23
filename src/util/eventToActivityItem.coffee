module.exports = (event) ->
  guid: "github-#{event.id}"
  platform: 'github'
  attributes: {}
  message: if event.type is 'CreateEvent'
    "created a new repo #{event.repo.name}"
  else if event.type is 'WatchEvent'
    "started watching #{event.repo.name}"
  else if event.type is 'ForkEvent'
    "forked #{event.repo.name}"
  else
    event.type
  postedAt: new Date Date.parse event.created_at
  data: event
