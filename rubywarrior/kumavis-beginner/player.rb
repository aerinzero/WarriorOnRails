require 'pry'

class Player
  def play_turn(warrior)
    @actionQueue ||= []
    if @actionQueue.length==0
      self.next_actions(warrior)
    end
    if @actionQueue.length>0
      @actionQueue.pop.call(warrior)
    end
  end
  
  def next_actions(warrior)
    @actionQueue.push Proc.new {|warrior| warrior.attack!}
    @actionQueue.push Proc.new {|warrior| warrior.rest!}
    @actionQueue.push Proc.new {|warrior| warrior.rest!}
    @actionQueue.push Proc.new {|warrior| warrior.rest!}
  end
end