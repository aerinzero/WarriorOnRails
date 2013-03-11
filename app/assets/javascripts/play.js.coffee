# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery.ui.sortable
#= require jquery.ui.draggable
#= require jquery.ui.droppable


app = ->

  window.app = @

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
    $('.item.placeholder:not(.conditionContainer .item.placeholder)').droppable
      accept: '.item:not(.condition)'
      drop: (event, ui) =>
        target = $(event.target)
        token = ui.draggable
        target.replaceWith( token )
        token.attr('style','')
        @refreshBank()
    $('.conditionContainer .item.placeholder').droppable
      accept: '.item.condition'
      drop: (event, ui) =>
        target = $(event.target)
        token = ui.draggable
        target.replaceWith( token )
        token.attr('style','')
        @refreshBank()

  @parseDomIntoTree = ->
    # check for holes
    if $('#craftingField').find('.item.placeholder').length>0
      console.log "empty elements remain..."
    # 

  @setupPlaceHolders()




# app = ->

#   @updateNodeLength = (node) ->
#     flag = 40
#     childHeight = 60
#     buffer = 5
#     children = node.find('.item')
#     childCount = children.length
#     node.height( flag + childHeight * childCount + buffer * childCount )

#   $('.node .nodeitems').each (index,node) => @updateNodeLength( $(node) )

#   $('.node .nodeitems').sortable(
#     # items: '.item'
#     connectWith: '.node .nodeitems'
#     receive: (event, ui) =>
#       if ui.item.hasClass('flag')
#         ui.item.removeClass('flag').addClass('item')
#       @updateNodeLength $(event.target)
#     remove: (event, ui) =>
#       @updateNodeLength $(event.target)
#     out: (event, ui) =>
#       @updateNodeLength $(event.target)
#   ).disableSelection()

#   $( '.node .flagHolder' ).sortable(
#     # items: '.flag'
#     connectWith: '.node .nodeitems'
#     revert: true
#     remove: (event, ui) =>
#       # replace original
#       ui.item.clone().appendTo( event.target )

#   ).disableSelection()

#   $('.bank').sortable(
#     connectWith: '.node .nodeitems'
#     revert: true
#     remove: (event, ui) =>
#       # replace original
#       ui.item.clone().appendTo( event.target )
#   ).disableSelection()

#   $('.node,.bank').draggable()

$( app )