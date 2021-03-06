namespace :porkchop do
  desc "Pretend someone is pressing buttons on the table"
  task press_buttons: [:environment] do
    loop do
      sleep rand(3.0..5.0)
      match = Match.ongoing.first
      controls = PingPong::TableControls.new(match)
      case rand(2)
      when 0
        puts "Home button!"
        controls.home_button
      when 1
        puts "Away button!"
        controls.away_button
      end
      OngoingMatchChannel.broadcast_update
    end
  end

  desc "Generate sample data"
  task create_season: [:environment] do
    league = League.create! name: "PorkChop Club", table: Table.first
    season = Season.create! games_per_matchup: 4, league: league
    season.players << Player.all
  end

  task simulate_matches: [:environment] do
    require 'factory_girl_rails'

    Player.update_all active: true
    Match.setup!

    30.downto(0).each do |n|
      puts "Generating matches #{n} days ago."
      finalized_at =
        n.days.ago.at_beginning_of_day +
        rand(0..23).hours +
        rand(0..59).minutes +
        rand(0..59).seconds

      rand(0..8).times do
        match = Match.ongoing.last!

        scores = [11, rand(0..9)].shuffle
        FactoryGirl.create_list(:point,
                                scores[0],
                                victor: match.home_player,
                                match: match)
        FactoryGirl.create_list(:point,
                                scores[1],
                                victor: match.away_player,
                                match: match)

        MatchFinalizationJob.perform_now(match)

        EloRating.
          order(created_at: :desc).
          limit(2).
          update_all(created_at: finalized_at)

        match.update_column :finalized_at, finalized_at
      end
    end

    Match.ongoing.last.destroy
    Player.update_all active: false
  end
end
