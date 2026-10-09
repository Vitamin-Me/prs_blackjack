class Game
 def initialize(player_hand:, dealer_hand:, dealer_balance:, player_balance:, player_bet:)
  @player_hand = player_hand
  @dealer_hand = dealer_hand

  @dealer_balance = dealer_balance
  @player_balance = player_balance - player_bet
 end

  def result()
    return :player_bust if @player_hand.bust?
    return :dealer_bust if @dealer_hand.bust?

    return :player_wins if @player_hand.sum > @dealer_hand.sum
    return :dealer_wins if @dealer_hand.sum > @player_hand.sum

    :tie
  end
end