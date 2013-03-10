# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery.ui.sortable



app = ->

  @updateNodeLength = (node) ->
    flag = 40
    childHeight = 60
    buffer = 5
    children = node.find('.item')
    childCount = children.length
    node.height( flag + childHeight * childCount + buffer * childCount )

  $('.node .nodeitems').each (index,node) => @updateNodeLength( $(node) )

  $('.node .nodeitems').sortable(
    # items: '.item'
    connectWith: '.node .nodeitems'
    receive: (event, ui) =>
      if ui.item.hasClass('flag')
        ui.item.removeClass('flag').addClass('item')
      @updateNodeLength $(event.target)
    remove: (event, ui) =>
      @updateNodeLength $(event.target)
    out: (event, ui) =>
      @updateNodeLength $(event.target)
  ).disableSelection()

  $( '.node .flagHolder' ).sortable(
    # items: '.flag'
    connectWith: '.node .nodeitems'
    revert: true
    remove: (event, ui) =>
      # replace original
      ui.item.clone().appendTo( event.target )

  ).disableSelection()

  $('.bank').sortable(
    connectWith: '.node .nodeitems'
    revert: true
    remove: (event, ui) =>
      # replace original
      ui.item.clone().appendTo( event.target )
  ).disableSelection()

  $('.node,.bank').draggable()

$( app )