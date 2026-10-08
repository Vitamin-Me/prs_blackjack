class Deck
    attr_reader :cards

    def initialize
        @cards = []
        suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
        ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

        suits.each do |suit|
            ranks.each do |rank|
                @cards << Card.new(rank: rank, suit: suit)
            end
        end
    end

    def shuffle
        @cards.shuffle!
    end

    def deal(num_cards)
        @cards.pop(num_cards)
    end
    
end