module RubyWarrior
  class Floor
    attr_accessor :width, :height, :grid
    attr_reader :stairs_location
    
    def initialize
      @width = 0
      @height = 0
      @units = []
      @stairs_location = [-1, -1]
    end
    
    def add(unit, x, y, direction = nil)
      @units << unit
      unit.position = Position.new(self, x, y, direction)
    end
    
    def place_stairs(x, y)
      @stairs_location = [x, y]
    end
    
    def stairs_space
      space(*@stairs_location)
    end
    
    def units
      @units.reject { |u| u.position.nil? }
    end
    
    def other_units
      units.reject { |u| u.kind_of? Units::Warrior }
    end
    
    def get(x, y)
      units.detect do |unit|
        unit.position.at?(x, y)
      end
    end
    
    def space(x, y)
      Space.new(self, x, y)
    end
    
    def out_of_bounds?(x, y)
      x < 0 || y < 0 || x > @width-1 || y > @height-1
    end
    
    def character
      rows = []
      rows << " " + ("-" * @width)
      @height.times do |y|
        row = "|"
        @width.times do |x|
          row << space(x, y).character
        end
        row << "|"
        rows << row
      end
      rows << " " + ("-" * @width)
      rows.join("\n") + "\n"
    end

    def tile_map
      warrior = {type:'player'}
      thick_slime = {type:'thickslime'}
      small_slime = {type:'smallslime'}
      archer = {type:'archer'}
      floor = {type:'floor'}
      wall = {type:'wall'}
      stairs = {type:'stairs'}

      rows = []

      # add all-wall top row
      top_row = []
      (@width+2).times do |x|
        top_row << wall
      end
      rows << top_row

      @height.times do |y|
        row = []
        row << wall
        @width.times do |x|
          square = space(x, y)
          # if square.wall?
          # elsif square.warrior?
          # elsif square.golem?
          # elsif square.player?
          # elsif square.enemy?
          # elsif square.captive?
          # elsif square.empty?
          # elsif square.stairs?
          tile = nil
          case
          when square.unit.class == RubyWarrior::Units::Warrior
            tile = warrior
          when square.unit.class == RubyWarrior::Units::Sludge
            tile = small_slime
          when square.unit.class == RubyWarrior::Units::ThickSludge
            tile = thick_slime
          when square.unit.class == RubyWarrior::Units::Archer
            tile = archer
          else
            if square.stairs?
              tile = stairs
            else
              tile = floor
            end
          end

          row << tile
        end
        row << wall
        rows << row
      end

      # add all-wall bottom row
      bottom_row = []
      (@width+2).times do |x|
        bottom_row << wall
      end
      rows << bottom_row
    end
    
    def unique_units
      unique_units = []
      units.each do |unit|
        unique_units << unit unless unique_units.map { |u| u.class }.include?(unit.class)
      end
      unique_units
    end
  end
end
