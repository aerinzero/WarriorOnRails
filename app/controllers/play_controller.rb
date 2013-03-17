require 'ruby_warrior'
require 'json'

class PlayController < ApplicationController

  # def index
  #   defaultWarrior = Warrior.first
  #   redirect_to :show, {warrior_id: defaultWarrior.id}
  #   # render :show, id: defaultWarrior.id
  # end

  # for json response
  def continue

    @warrior = Warrior.find( params[:id] )
    @warrior.update_attributes( params[:warrior] )

    params[:warrior_id] = params[:id]
    # render :show, id: params[:id]
    self.show

  end

  def show
    
    # binding.pry
    @warrior = Warrior.find( params[:warrior_id] )

    @ios = StringIO.new

    # @runner = RubyWarrior::Runner.new(ARGV, STDIN, @ios)
      @game = RubyWarrior::Game.new

    # @runner.run
      # RubyWarrior::Config.in_stream = STDIN
      RubyWarrior::Config.out_stream = @ios
      RubyWarrior::Config.delay = 0

    # @game.start
      RubyWarrior::UI.puts "Welcome to Ruby Warrior!\n"
      # @profile = RubyWarrior::Profile.load( ... )
      if @warrior.data
        @game.profile = RubyWarrior::Profile.decode( @warrior.data )
      else
        @game.profile = RubyWarrior::Profile.new
        @game.profile.warrior_name = @warrior.name
      end


    # @game.play_normal_mode
      # if @game.current_level.number.zero?
      # ^ skipping the if for now, as we are always starting at 0
        # prepare_next_level
          # @next_level.generate_player_files
            # @game.next_level.generate_player_files
              @game.next_level.load_level
              playerGenerator = RubyWarrior::PlayerGenerator.new(@game.next_level)
              @readme = playerGenerator.read_template(playerGenerator.templates_path + '/README.erb')
              # playerGenerator.generate
                level = playerGenerator.level
                # if level.number == 1
                #   FileUtils.mkdir_p(level.player_path) unless File.exists? level.player_path
                #   # FileUtils.cp(playerGenerator.templates_path + '/player.rb', level.player_path) unless File.exists? (level.player_path + '/player.rb')
                # end
                
                File.open(level.player_path + '/README', 'w') do |f|
                  f.write playerGenerator.read_template(playerGenerator.templates_path + '/README.erb')
                end

                File.open(level.player_path + '/player.rb', 'w') do |f|
                  f << @warrior.code
                end

              @game.profile.level_number += 1 if @game.profile.level_number == 0

          # profile.save # this saves score and new abilities too
            # dont want to save the results from the first run until we have 'play_current_level' built out
            # @warrior.update_attributes(data:@game.profile.encode)
        RubyWarrior::UI.puts "First level has been generated.\n"
      # else
        # play_current_level
          current_level = @game.current_level
          continue = true
          current_level.load_player
          # ^ this is where we use the updated code

          RubyWarrior::UI.puts "Starting Level #{current_level.number}"

          @gameFrames = current_level.play

          @frameJSON = @gameFrames.to_json

          if current_level.passed?
            if @game.next_level.exists?
              RubyWarrior::UI.puts "Success! You have found the stairs."
              @game.profile.level_number += 1
            else
              RubyWarrior::UI.puts "CONGRATULATIONS! You have climbed to the top of the tower and rescued the fair maiden Ruby."
              continue = false
            end
            current_level.tally_points

            if @game.profile.epic?
              RubyWarrior::UI.puts final_report if final_report && !continue
            else
              @game.request_next_level
            end
          else
            continue = false
            RubyWarrior::UI.puts "Sorry, you failed level #{current_level.number}. Change your script and try again."
            if current_level.clue # && RubyWarrior::UI.ask("Would you like to read the additional clues for this level?") !RubyWarrior::Config.skip_input? &&
              RubyWarrior::UI.puts current_level.clue.hard_wrap
            end
          end

      @warrior.data = @game.profile.encode
      @warrior.level = @game.profile.level_number
      @warrior.save

    @message = @ios.string
    
    responseJSON = {}
    responseJSON[:frame_data] = @frameJSON

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: responseJSON }
    end
  end

end
