class PagesController < ApplicationController
  def home
    return redirect_to root_path if session[:player_cards].blank?

     # primary game state to control button interactibility in the view
    @game_stage = session[:game_stage]

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

  # New game has been created, player should only be able to place a bet and see no cards
  def start_game
    # New deck, resets each game
    deck = Deck.new
    deck.shuffle

    # I am chunking this into stages, because reading :game_start, :round_start, etc. is getting confusing
    # stage one is a new round, no cards revealed yet, waiting for players bet

    # stage two will be dealers one card is revealed and both players cards are revealed, enabling the player actions
    #   and disabling the bet and new round actions

    # stage three will be the round is over, bet and player actions are disabled with only new round enabled

    # new round will then go back into stage one

    session[:game_stage] = 1
    
    session[:dealer_revealed] = false

    # set the player and dealers balances from the setup page, default to 0
    # these will persist through the game, do not get reset after a round
    session[:player_balance] = params[:player_balance].to_i
    session[:dealer_balance] = params[:dealer_balance].to_i

    
    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    
    session[:game_messages] = ["Game has started!"]

    redirect_to pages_home_path
  end

  def reset_game
    deck = Deck.new
    deck.shuffle

    session[:game_stage] = 1

    session[:game_messages] = ["Game has started!"]

    session[:dealer_revealed] = false

    session[:player_bet] = params[:player_bet].to_i || 0
    
    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    redirect_to pages_home_path
  end

  def start_round

    # this is the beginning of stage two, revealing one dealer card and both players, while enabling player actions
    #   and disabling betting and new round
    
    bet = params[:player_bet].to_i || 0
    balance = session[:player_balance]

    if bet > session[:player_balance]
      message = session[:game_messages]
      message << "Your bet exceeds your balance!"
      return redirect_to pages_home_path
    end


    session[:game_stage] = 2

    session[:dealer_revealed] == true

    session[:player_bet] = bet

    session[:player_balance] = session[:player_balance] - session[:player_bet]

    redirect_to pages_home_path
  end

  def hit
    deck = Deck.new(cards: cards_from(session[:deck_cards]))
    player_cards = cards_from(session[:player_cards])
    dealer_cards = cards_from(session[:dealer_cards])
    player_cards << deck.deal(1).first  

    session[:player_cards] = card_data(player_cards)
    session[:deck_cards] = card_data(deck.cards)


    message = session[:game_messages] || []
    message << "You hit!"
    session[:game_messages] = message

    if Hand.new(cards: player_cards).bust?
      check_results()
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

    check_results()

    redirect_to pages_home_path
  end

  private

  def card_data(cards)
    cards.map { |card| { "rank" => card.rank, "suit" => card.suit } }
  end

  def cards_from(card_data)
    card_data.map { |data| Card.new(rank: data["rank"], suit: data["suit"]) }
  end

  def check_results()
    message = session[:game_messages]

    dealer_cards = cards_from(session[:dealer_cards])
    player_cards = cards_from(session[:player_cards])
      
    result = Game.new(player_hand: Hand.new(cards: player_cards), dealer_hand: Hand.new(cards: dealer_cards), 
    player_balance: session[:player_balance], dealer_balance: session[:dealer_balance])

    case result.hand
      when :player_bust
        then message << "BUST! Dealer wins this hand!";
        session[:dealer_balance] = session[:dealer_balance] + session[:player_bet];
        session[:game_stage] = 3
  
      when :dealer_bust
        then message << "Dealer BUST! You win this hand!";
        session[:player_balance] = session[:player_balance] + (session[:player_bet] * 2);
        session[:dealer_balance] = session[:dealer_balance] - session[:player_bet];
        session[:game_stage] = 3
        
      when :player_wins_round
        then message << "You win this hand!";
        session[:player_balance] = session[:player_balance] + (session[:player_bet] * 2);
        session[:dealer_balance] = session[:dealer_balance] - session[:player_bet];
        session[:game_stage] = 3

      when :dealer_wins_round
        then message << "Dealer wins this hand :(";
        session[:dealer_balance] = session[:dealer_balance] + session[:player_bet];
        session[:game_stage] = 3

      when :tie
         then message << "Same score, tie!";
         session[:player_balance] = session[:player_balance] + session[:player_bet];
         session[:game_stage] = 3
    end

    case result.game(player_balance: session[:player_balance], dealer_balance: session[:dealer_balance])
      when :player_wins
        message << "Dealer has no money left, you win!";
        session[:game_stage] = 4
      when :dealer_wins
        message << "Player has no money left, Dealer wins!";
        session[:game_stage] = 4
    end

    session[:game_messages] = message

  end
end
