class Game
 def initialize(player_hand:, dealer_hand:, player_balance:, dealer_balance:)
  @player_hand = player_hand
  @dealer_hand = dealer_hand

  @dealer_balance = dealer_balance
  @player_balance = player_balance
 end

  def hand
    return :player_bust if @player_hand.bust?
    return :dealer_bust if @dealer_hand.bust?

    return :player_wins_round if @player_hand.sum > @dealer_hand.sum
    return :dealer_wins_round if @dealer_hand.sum > @player_hand.sum

    :tie
  end

  def game(player_balance:, dealer_balance:)
    return :player_wins if dealer_balance <= 0
    return :dealer_wins if player_balance <= 0

    nil
  end

end