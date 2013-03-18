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
    if ( warrior.health < 10 )
      @actionQueue.push Proc.new {|warrior| warrior.rest!}
      @actionQueue.push Proc.new {|warrior| warrior.rest!}
      @actionQueue.push Proc.new {|warrior| warrior.rest!}
      @actionQueue.push Proc.new {|warrior| warrior.rest!}
      @actionQueue.push Proc.new {|warrior| warrior.rest!}
      @actionQueue.push Proc.new {|warrior| warrior.rest!}
      @actionQueue.push Proc.new {|warrior| warrior.walk!(:backward)}
      @actionQueue.push Proc.new {|warrior| warrior.walk!(:backward)}
    else
      if ( warrior.feel().wall? )
        @actionQueue.push Proc.new {|warrior| warrior.pivot!}
      else
        if ( warrior.feel().empty? )
          @actionQueue.push Proc.new {|warrior| warrior.walk!}
        else
          @actionQueue.push Proc.new {|warrior| warrior.attack!}
        end
      end
    end
  end
end