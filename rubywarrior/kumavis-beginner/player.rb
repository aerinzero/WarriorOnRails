require 'pry'

class Player
  def play_turn(warrior)
    @actionQueue ||= []
    if @actionQueue.length==0
      self.next_actions(warrior)
    end
    @actionQueue.pop.call(warrior)
  end
  
  def next_actions(warrior)
    if ( warrior.feel().empty? )
      @actionQueue.push Proc.new {|warrior| warrior.walk!}
    else
      if ( warrior.health < 5 )
        @actionQueue.push Proc.new {|warrior| warrior.rest!}
@actionQueue.push Proc.new {|warrior| warrior.walk!(:backward)}
      else
        @actionQueue.push Proc.new {|warrior| warrior.attack!}
      end
    end
  end
end