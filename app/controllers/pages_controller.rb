class PagesController < ApplicationController
  def home
    return redirect_to root_path if session[:player_cards].blank?

    @game_messages = session[:game_messages] || []

    @dealer_revealed = session[:dealer_revealed]

    @dealer_cards = cards_from(session[:dealer_cards])
    @player_cards = cards_from(session[:player_cards])

    if @dealer_revealed
      @dealer_score = Hand.new(cards: @dealer_cards).sum
    else
      @dealer_score = Hand.new(cards: [@dealer_cards.first]).sum
    end

    @player_score = Hand.new(cards: @player_cards).sum

    @cards_remaining = session[:deck_cards].length

  end

  def start_game
    deck = Deck.new
    deck.shuffle

    session[:game_messages] = ["Game has started!"]

    session[:dealer_revealed] = false
    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    redirect_to pages_home_path
  end

  def hit
    deck = Deck.new(cards: cards_from(session[:deck_cards]))
    player_cards = cards_from(session[:player_cards])
    player_cards << deck.deal(1).first  

    session[:player_cards] = card_data(player_cards)
    session[:deck_cards] = card_data(deck.cards)


    message = session[:game_messages] || []
    message << "You hit!"
    session[:game_messages] = message

    if Hand.new(cards: player_cards).bust?
      session[:dealer_revealed] = true
      message << "Bust! Dealer wins"
      session[:game_messages] = message
    end

    redirect_to pages_home_path
  end

  def stand
    deck = Deck.new(cards: cards_from(session[:deck_cards]))
    dealer_cards = cards_from(session[:dealer_cards])
    player_cards = cards_from(session[:player_cards])

    session[:dealer_revealed] = true

    message = session[:game_messages] || []
    message << "You stand!"
    message << "Dealer reveals card"
    session[:game_messages] = message

    while Hand.new(cards: dealer_cards).sum < 17
      dealer_cards << deck.deal(1).first
    end

    session[:dealer_cards] = card_data(dealer_cards)
    session[:deck_cards] = card_data(deck.cards)

    result = Game.new(player_hand: Hand.new(cards: player_cards), dealer_hand: Hand.new(cards: dealer_cards)).result

    case result
    when :player_bust then message << "BUST! Dealer Wins!"
    when :dealer_bust then message << "Dealer BUST! You Win!"
    when :player_wins then message << "You Win!"
    when :dealer_wins then message << "Dealer Wins :("
    when :tie then message << "Same Score, Tie!"
    end

    session[:game_messages] = message

    redirect_to pages_home_path
  end


  private

  def card_data(cards)
    cards.map { |card| { "rank" => card.rank, "suit" => card.suit } }
  end

  def cards_from(card_data)
    card_data.map { |data| Card.new(rank: data["rank"], suit: data["suit"]) }
  end
end
