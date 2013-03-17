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
    frames.forEach (frame,index) ->
      setTimeout (->
        formattedLevelMap = frame.levelMap
        formattedLevelMap = formattedLevelMap+"\n"+frame.actionsMessage
        formattedLevelMap = formattedLevelMap.split('\n').join('<br />')
        $('.map').html(formattedLevelMap)
      ),300*index

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
    $('.item:not(.conditionContainer .item):not(.conditional)').droppable
      accept: '.item:not(.condition)'
      drop: (event, ui) =>
        target = $(event.target)
        token = ui.draggable
        target.replaceWith( token )
        token.attr('style','')
        @refreshBank()
        @updateCodeBox()
    # conditionals
    $('.conditionContainer .item.placeholder').droppable
      accept: '.item.condition'
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

    playTurnCode = "@actionQueue ||= []"+"\n"
    playTurnCode += "if @actionQueue.length==0"+"\n"
    playTurnCode += @indent("self.next_actions(warrior)")+"\n"
    playTurnCode += "end"+"\n"
    playTurnCode += "@actionQueue.pop.call(warrior)"
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
        code += "@actionQueue.push Proc.new {|warrior| warrior.rest!}"+"\n"
        code += "@actionQueue.push Proc.new {|warrior| warrior.walk!(:backward)}"
    return code

  @setupPlaceHolders()

$( app )