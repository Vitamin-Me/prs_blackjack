# README
Welcome to my game of BlackJack where you gamble your heart out until you have removed every dollar from the Dealer! (He's evil its okay)

The goal is simple: set a balance for yourself (the Player) and the Dealer, set your win ratio, and use YOUR balance to reduce the DEALERS balance down to ZERO or BELOW. 

The game uses one deck, renews and shuffles it each session, and allows the player to place a BET, and HIT or STAND depending on their hand.

Everything runs in the browser session: state, deck, hand, balance, bets, logs, etc. This was not meant to be the long term solution, but protoyping with session variables turned out to be acceptable in the current product. 

Additional features in the future would be better reactivity, adding SPLIT, INSURANCE, and additional actions that resemble the real life game. Also, qualitfy of life features such as animations, color coded logging, nicer cards, and choosing the number of decks. The original scope included user accounts with game history, settings, and a persistant balance, but by the end of development I realized that was not in the cards (get it). 

The game is lightweight, it uses less than 4kb of data to live in the session, and is split into a few core classes and a primary controller. 

There are only two pages: a setup page and the home page, which acts as the game table.

Here are the projects dependencies:

    Ruby version: 3.4.7

    Rails version: 8.0.5.1, Bundler 2.6.9

NOTICE: I am hosting the game LIVE at https://prs-blackjack.onrender.com. I hope this is useful for instant demonstration and testing purposes, especially in the case the local build is not working correctly.

NOTE: The live site does NOT work well on mobile devices, I HIGHLY recommend using a desktop screen or tablet equivalent.

Here is the setup for running the game locally:

Linux/Mac:

    git clone https://github.com/Vitamin-Me/prs_blackjack.git

    cd prs_blackjack

    bin/setup

    bin/setup installs the gems, and starts the server

    Open http://localhost:3000

    Anytime after that instance, use bin/dev to boot the server

    If port 3000 is not available, run the server with 'PORT={3001} bin/dev' (Or any open port)

Windows:

    Powershell will not correctly run the project, it requires a ruby interpreter, and I could not find the right version this project requires on windows and I don't think it would install the bundle correctly anyways.

    I recommend WSL, which is what I am using for this project, or refer to my live program at https://prs-blackjack.onrender.com, which is of course platform independent. Also, because it is attached to the public repo, it stays current.


Thank you for playing!


