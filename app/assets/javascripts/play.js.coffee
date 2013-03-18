# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery.ui.sortable
#= require jquery.ui.draggable
#= require jquery.ui.droppable


app = ->
  window.app = @

  # animation mechanism for map+etc 
  @animateFrames = (frames) ->
    # ghetto clear timeout
    i = 0
    clearTimeout i++ while i < 100000

    # build html for frames
    frames.forEach (frame,index) ->
      setTimeout (->
        map = JSON.parse frame.levelMap
        mapHTML = ""
        map.forEach (row) ->
          mapHTML+="<div class='row'>"
          row.forEach (tile) ->
            mapHTML+="<div class='tile #{tile.type}'></div>"
          mapHTML+="</div>"
        $('#map').html(mapHTML)

        message = frame.actionsMessage.split('\n').join('<br />')
        $('#actionsMessage').html(message)
      ),500*index

  # begin start-of-app frame animation
  @animateFrames JSON.parse( window.frameJSON )

  # setup update code response handler
  $('form').bind 'ajax:complete', (evt,xhr,status) =>
    response = JSON.parse(xhr.responseText)
    frames = JSON.parse(response.frame_data)
    @animateFrames frames

  

  # bank + tiles

  console.log "creating bank backup"
  @bankStock = $('.bank').clone()
  console.log "bank options: "+@bankStock.children().length

  @refreshBank = ->
    console.log "refresh bank with "+@bankStock.children().length+"items"
    console.log @bankStock.children()
    # replace bank with clone
    bankStyles = $('.bank').attr('style')
    $('.bank').replaceWith( @bankStock.clone() )
    $('.bank').attr('style',bankStyles)
    # init bank
    $('.bank').draggable()
    # init bank items
    $('.bank .item:not(.item.placeholder)').draggable( revert: "invalid" )
    @setupPlaceHolders()

  $('.bank').draggable()
  $('.item:not(.item.placeholder)').draggable( revert: "invalid" )
  
  @setupPlaceHolders = ->
    # action items
    # $('.item.placeholder:not(.conditionContainer .item.placeholder)').droppable
    $('.item:not(.conditionContainer .item):not(.macro)').droppable
      accept: '.item:not(.condition)'
      drop: (event, ui) =>
        target = $(event.target)
        token = ui.draggable
        target.replaceWith( token )
        token.attr('style','')
        @refreshBank()
        @updateCodeBox()
    # conditionals
    $('.conditionContainer .item').droppable
      accept: '.item.condition:not(.conditionContainer .item)'
      drop: (event, ui) =>
        target = $(event.target)
        token = ui.draggable
        target.replaceWith( token )
        token.attr('style','')
        @refreshBank()
        @updateCodeBox()

  @updateCodeBox = ->
    console.log "updating code box"
    $('textarea').val( @parseDomIntoRuby() )
    $('textarea').text( @parseDomIntoRuby() )

  @parseDomIntoRuby = ->
    # check for holes
    if $('#craftingField').find('.item.placeholder').length>0
      console.log "empty elements remain..."
    # recursively parse each element
    root = $('#craftingField').children('.item')
    
    code = ""
    # building warrior boilerplate
    playTurnCode = "@actionQueue ||= []"+"\n"
    playTurnCode += "if @actionQueue.length==0"+"\n"
    playTurnCode += @indent("self.next_actions(warrior)")+"\n"
    playTurnCode += "end"+"\n"
    playTurnCode += "if @actionQueue.length>0"+"\n"
    playTurnCode += @indent("@actionQueue.pop.call(warrior)")+"\n"
    playTurnCode += "end"

    code += "def play_turn(warrior)\n"+@indent( playTurnCode )+"\nend"
    code += "\n\n"

    nextActionCode = ""
    # nextActionCode += "binding.pry\n"
    nextActionCode += @parseElementIntoRuby( root )
    code += "def next_actions(warrior)\n"+@indent( nextActionCode )+"\nend"

    code = "class Player\n"+@indent( code )+"\nend"
    code = "require 'pry'\n\n"+ code

  @indent = (input) ->
    space = "  "
    space+input.replace(/\n/g,"\n"+space);

  @parseElementIntoRuby = ( root ) ->
    code = ""
    if root.hasClass('conditional')
      condition = root.children('.conditionContainer').children('.condition')
      trueBlock = root.children('.path-true').children('.item')
      falseBlock = root.children('.path-false').children('.item')
      code += "if ( "+@parseElementIntoRuby( condition )+" )\n"
      code += @indent @parseElementIntoRuby( trueBlock )
      code += "\nelse\n"
      code += @indent @parseElementIntoRuby( falseBlock )
      code += "\nend"
    else if root.hasClass('stack')
      paths = root.children('.path')
      paths.toArray().reverse().forEach (path,index) =>
        code += "\n" if index>0
        code += @parseElementIntoRuby $(path).children()
    else if root.hasClass('condition')
      if root.hasClass('condition-empty')
        code += "warrior.feel().empty?"
      else if root.hasClass('condition-enemy')
        code += "warrior.feel().enemy?"
      else if root.hasClass('condition-wall')
        code += "warrior.feel().wall?"
      else if root.hasClass('condition-lowHealth')
        code += "warrior.health < 5"
    else if root.hasClass('action')
      if root.hasClass('action-move')
        code += "@actionQueue.push Proc.new {|warrior| warrior.walk!}"
      else if root.hasClass('action-turn')
        code += "@actionQueue.push Proc.new {|warrior| warrior.pivot!}"
      else if root.hasClass('action-attack')
        code += "@actionQueue.push Proc.new {|warrior| warrior.attack!}"
      else if root.hasClass('action-heal')
        code += "@actionQueue.push Proc.new {|warrior| warrior.rest!}"
      else if root.hasClass('action-retreat')
        code += "@actionQueue.push Proc.new {|warrior| warrior.walk!(:backward)}"
    else
      # should never reach here with root.length>0
      if root.length>0 && !root.hasClass('placeholder')
        debugger 
    return code

  @setupPlaceHolders()

$( app )