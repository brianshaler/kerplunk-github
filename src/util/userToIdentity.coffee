PLATFORM = 'github'

module.exports = (user) ->
  nickName = user.login
  fullName = user.name ? user.login

  [firstName, lastNames...] = fullName.split ' '
  lastName = lastNames.join ' '

  userPhoto = user.avatar_url

  user.nickName = nickName
  user.fullName = fullName
  user.firstName = firstName
  user.lastName = lastName

  user.profileUrl = user.html_url
  user.platformId = String user.id

  guid: ["#{PLATFORM}-#{user.id}"]
  platform: [PLATFORM]
  # platformId: user.id
  fullName: user.fullName
  firstName: user.firstName
  lastName: user.lastName
  nickName: user.nickName
  photo: if userPhoto then [{url: userPhoto}] else []
  data:
    github: user?.github ? user

# user =
#   login: 'octocat'
#   id: 1
#   avatar_url: 'https://github.com/images/error/octocat_happy.gif'
#   gravatar_id: ''
#   url: 'https://api.github.com/users/octocat'
#   html_url: 'https://github.com/octocat'
#   followers_url: 'https://api.github.com/users/octocat/followers'
#   following_url: 'https://api.github.com/users/octocat/following{/other_user}'
#   gists_url: 'https://api.github.com/users/octocat/gists{/gist_id}'
#   starred_url: 'https://api.github.com/users/octocat/starred{/owner}{/repo}'
#   subscriptions_url: 'https://api.github.com/users/octocat/subscriptions'
#   organizations_url: 'https://api.github.com/users/octocat/orgs'
#   repos_url: 'https://api.github.com/users/octocat/repos'
#   events_url: 'https://api.github.com/users/octocat/events{/privacy}'
#   received_events_url: 'https://api.github.com/users/octocat/received_events'
#   type: 'User'
#   site_admin: false
#   name: 'monalisa octocat'
#   company: 'GitHub'
#   blog: 'https://github.com/blog'
#   location: 'San Francisco'
#   email: 'octocat@github.com'
#   hireable: false
#   bio: 'There once was...'
#   public_repos: 2
#   public_gists: 1
#   followers: 20
#   following: 0
#   created_at: '2008-01-14T04:33:35Z'
#   updated_at: '2008-01-14T04:33:35Z'
#   total_private_repos: 100
#   owned_private_repos: 100
#   private_gists: 81
#   disk_usage: 10000
#   collaborators: 8
#   plan:
#     name: 'Medium'
#     space: 400
#     private_repos: 20
#     collaborators: 0
