class PagesController < ApplicationController
  def home
    return redirect_to root_path if session[:player_cards].blank?

    @game_over = session[:game_over]

    @round_start = session[:round_start]

    @player_bet = session[:player_bet] || 0

    @dealer_balance = session[:dealer_balance]
    @player_balance = session[:player_balance]

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

  def setup_game
    reset_session

    redirect_to root_path
  end

  def start_game
    deck = Deck.new
    deck.shuffle

    session[:game_start] = true

    session[:round_start] = false

    session[:player_balance] = params[:player_balance].to_i
    session[:dealer_balance] = params[:dealer_balance].to_i

    session[:game_messages] = ["Game has started!"]

    session[:dealer_revealed] = false
    
    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    redirect_to pages_home_path
  end

  def reset_game
    deck = Deck.new
    deck.shuffle

    session[:round_start] = false

    session[:game_start] = true

    session[:game_messages] = ["Game has started!"]

    session[:dealer_revealed] = false

    session[:player_bet] = params[:player_bet].to_i || 0
    
    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    redirect_to pages_home_path
  end

  def start_round
    # session[:dealer_revealed] = true

    bet = params[:player_bet].to_i || 0
    balance = session[:player_balance]

    if bet > session[:player_balance]
      message = session[:game_messages]
      message << "Your bet exceeds your balance!"
      return redirect_to pages_home_path
    end
    session[:round_start] = true

    session[:game_start] = false

    session[:player_bet] = bet

    session[:player_balance] = session[:player_balance] - session[:player_bet]

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
      session[:round_start] = false
      session[:game_start] = false
      message << "Bust! Dealer wins"
      session[:game_messages] = message

      game_result
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

    result = Game.new(player_hand: Hand.new(cards: player_cards), dealer_hand: Hand.new(cards: dealer_cards), 
    player_balance: session[:player_balance], dealer_balance: session[:dealer_balance], player_bet: session[:player_bet]).result

    case result
      when :player_bust
         then message << "BUST! Dealer wins!";
         sesion[:dealer_balance] = session[:dealer_balance] + session[:player_bet];
         session[:round_start] = false
         session[:game_start] = false
        
      when :dealer_bust
         then message << "Dealer BUST! You win!";
          session[:player_balance] = session[:player_balance] + (session[:player_bet] * 2);
          session[:dealer_balance] = session[:dealer_balance] - session[:player_bet];
          session[:round_start] = false
          session[:game_start] = false
          
      when :player_wins
         then message << "You win!";
          session[:player_balance] = session[:player_balance] + (session[:player_bet] * 2);
          session[:dealer_balance] = session[:dealer_balance] - session[:player_bet];
          session[:round_start] = false
          session[:game_start] = false

      when :dealer_wins
         then message << "Dealer wins :(";
         session[:dealer_balance] = session[:dealer_balance] + session[:player_bet];
         session[:round_start] = false
         session[:game_start] = false

      when :tie
         then message << "Same score, tie!";
         session[:player_balance] = session[:player_balance] + session[:player_bet];
         session[:round_start] = false
         session[:game_start] = false
    end

    session[:game_messages] = message

    game_result

    redirect_to pages_home_path
  end

  private

  def card_data(cards)
    cards.map { |card| { "rank" => card.rank, "suit" => card.suit } }
  end

  def cards_from(card_data)
    card_data.map { |data| Card.new(rank: data["rank"], suit: data["suit"]) }
  end

  def game_result
    message = session[:game_messages]
    player_balance = session[:player_balance]
    dealer_balance = session[:dealer_balance]

    if player_balance <= 0
      message << "You are out of money, it's game over!"
      session[:game_over] = true
    elsif dealer_balance <= 0
      message << "Dealer is out of money, you win the game!"
      session[:game_over] = true
    end
    
  end
end
