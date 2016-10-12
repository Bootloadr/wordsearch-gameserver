App.game = App.cable.subscriptions.create "GameChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    #$('#status').html("Admin has not started the game!")
    #$('#currentturn').html("Its Admin Turn!")
  disconnected: ->
    # Called when the subscription has been terminated by the server
  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $('#status').html(data.gamestatus)
    $('#currentturn').html(data.turn)
    alert(data['msg'])
    

  move: (word) ->
    @perform 'move' , word: word

$(document).on 'keypress', '#game-move', (event) ->
  if event.keyCode is 13
    App.game.move(event.target.value)
    event.target.value = ""
    event.preventDefault()
