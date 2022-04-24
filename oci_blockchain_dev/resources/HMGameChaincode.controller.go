/**
 *
 * Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
 *
 */
package src

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"strings"
	"time"

	"hmgame.com/HMGameChainCode/lib/trxcontext"
)

type Controller struct {
	Ctx trxcontext.TrxContext
}

/*Initialize the Chaincode*/
func (t *Controller) Init(words []string) (interface{}, error) {
	// We Expect the list of words are present
	/*
	 */
	// Check if the list of words parameter is provided
	// Set default value for the list of words if it is not provided
	if len(words) == 0 {
		words = []string{"bird", "animal", "planet", "school"} // hard coded word list
		// in other words, if the parameters are not supplied, these are the words people would guess
	}

	// Step-2: Now we have to save these words into world state database
	// World State Database is a Barkely Database
	// Why would we store these words into the world state database?
	/*
		 - Because, later (not now), we might want to pick a different word
		 - Thats why if we store these words into world state database, we can get these back into the world state anypoint later
		 - But there is a problem ?
			 - These list of worlds are not actually an asset which we described in the HMGame.yml file.
			 - HMGame.yml has nothing named wordslist there
			 - So, when it comes to you writing something in the world state database and you are interrupting the underpinning shim API
			   manually without the assistance of the code generated during the Scruffolding process,
			   then this is what you do:
			   (i) You get the <stub> object which gets you to underlaying hyperladger shim apin and you are
					 writing logic directly against the Hyperladger Shim whithout using the sccruffolding wrapper around it

			   (ii) But the Hyperladger Shim API has a limilation. It cant directly operates on values (i.e. words) as string array.
					Instead, it operates on values as byte arrays.

	*/

	// Acquire Hyperladger shim stub object
	stub := t.Ctx.Model.GetNetworkStub()

	// 2.1 Convert the words list into Byte Array for ShimAPI
	// if it fails to convert the words into Byte Array, it will throw an error
	// Note: go doesnt have try catch functionality
	valueAsBytes, errMarshal := json.Marshal(words)

	if errMarshal != nil {
		return nil, fmt.Errorf("unable to convert the words into byte array:: marshal error %s", errMarshal.Error())

	}

	// if there are no processing error (i.e. processing "Words" into "ByteArray"), means if successful
	// then, try to put those in world state database using Hyperladger Shim API
	// (Optional) After the marshalling, if there are no error, what we can do fir further security is to encrypt the Byte Values before saving them in World State Database.

	errPut := stub.PutState("words", valueAsBytes)

	// however, if it fails to put the ByteArray into World State Database, then you have to return an error
	if errPut != nil {
		return nil, fmt.Errorf("error saving the byte array into state database: %s", errPut.Error())
	}

	return t.startNewGame(words)

}

//-----------------------------------------------------------------------------
//Player
//-----------------------------------------------------------------------------

func (t *Controller) CreatePlayer(asset Player) (interface{}, error) {
	return t.Ctx.Model.Save(&asset)
}

func (t *Controller) GetPlayerById(id string) (Player, error) {
	var asset Player
	_, err := t.Ctx.Model.Get(id, &asset)
	return asset, err
}
func (t *Controller) UpdatePlayer(asset Player) (interface{}, error) {
	return t.Ctx.Model.Update(&asset)
}
func (t *Controller) DeletePlayer(id string) (interface{}, error) {
	return t.Ctx.Model.Delete(id)
}
func (t *Controller) GetPlayerHistoryById(id string) (interface{}, error) {
	historyArray, err := t.Ctx.Model.GetHistoryById(id)
	return historyArray, err
}

//-----------------------------------------------------------------------------
//Game
// Step-3: Make the following Chaincode functions private (not invocable by clients)

/*
 ** In Go Langauge, a function is considered to be private if it starts with the lowercase character, rather then the uppercase character
 ** Oracle BlockChain App Builder always generates standard asset manipulation functions as public. However, we can make such operations private if we dont want to reveal certain asset details to Blockchain clients
 ** In this scenario, the word that needs to be guessed that is contained within the Game asset that we dont want to reveal.
 - CreateGame	--> createGame
	 - GetGameById	--> getGameById
	 - UpdateGame	--> updateGame
	 - DeleteGame	--> deleteGame
	 - CreateGuess	--> createGuess
*/

//-----------------------------------------------------------------------------

func (t *Controller) createGame(asset Game) (interface{}, error) {
	return t.Ctx.Model.Save(&asset)
}

func (t *Controller) getGameById(id string) (Game, error) {
	var asset Game
	_, err := t.Ctx.Model.Get(id, &asset)
	return asset, err
}
func (t *Controller) updateGame(asset Game) (interface{}, error) {
	return t.Ctx.Model.Update(&asset)
}
func (t *Controller) deleteGame(id string) (interface{}, error) {
	return t.Ctx.Model.Delete(id)
}
func (t *Controller) GetGameHistoryById(id string) (interface{}, error) {
	historyArray, err := t.Ctx.Model.GetHistoryById(id)
	return historyArray, err
}

//-----------------------------------------------------------------------------
//Guess
/* 3.1
In this scenario, a word that needs to be guessed for each game forms a part of the Game asset
and thus is saved into the BlockChain ledger and can be queried from this ledger.
Thus, it cannot really be considered a secret. Howeverm additional code may be provided to encrypt this
word before assigning it to the Game ibject and decryot the value everytime it is used by the application.
*/
//-----------------------------------------------------------------------------

func (t *Controller) createGuess(asset Guess) (interface{}, error) {
	return t.Ctx.Model.Save(&asset)
}

//-----------------------------------------------------------------------------
//Custom Methods
//-----------------------------------------------------------------------------

// Step-4: Custom Business Functiomn 01
/* Start New Game*/
/*This is custom defined function, private as declated in the specification file <HMGame.yml>*/
func (t *Controller) startNewGame(words []string) (interface{}, error) {
	// Check if the words array parameter in not available, means whether the wordList is present or not
	if len(words) == 0 {
		// then we will invoke the Hyperladger Shim API to fetch the words from world state db
		// 4.1.1 Acquire Hyperladger Shim stub object
		stub := t.Ctx.Model.GetNetworkStub()

		// 4.1.2 Get the list of words as Byte Array from the World State Database
		valueAsBytes, errGet := stub.GetState("words")
		// a. If there is an error fetching the words from the state database, means if errGet is not Nill, then
		// Note: Go Language has no try--catch functionality
		if errGet != nil {
			return nil, fmt.Errorf("error getting the words from state db: %s", errGet.Error())
		}

		// 4.1.3 Now, if there are no error in fetching, then
		// Covert the byte Array into a list of words - This is called unMarshalling
		// There are the words from which we have to make a guess
		errUnmarshal := json.Unmarshal(valueAsBytes, &words)

		// a. If there is an error in Unmarshalling
		if errUnmarshal != nil {
			return nil, fmt.Errorf("unmarshall error:: cant convert the bytevalues into words: %s", errUnmarshal.Error())
		}
	}

	// Step-4.2: Select a Random word from the list
	// Now, as we have successfully loaded the words from the state database into string format, this is the time to randomly select a word
	// Initialize the random number generator using seed() method
	// Randomnly select an index i.e. words[index] using rand.Intn(wordsLength) -> this returns an integer
	rand.Seed(time.Now().Unix())
	index := rand.Intn(len(words))

	// Now choose the word from words
	word := words[index]

	// Once a random word has chosen, next is to setup the Game Obejctas defined in Game Asset in HMGame.yml
	// Check then model: <HMGameChainCode.model>
	/*
	 We could define ChainCode to run multiple different game at the same time.
	 But for simplicity reasons, we just assumed that everybody's guessing the same word, thats just one game and we are running one game at a time.

	*/
	newGame := Game{
		GameId:            "TheGame",
		WordToGuess:       word,
		Used:              "",                     // Means, already guess a character
		CurrentGuessState: t.revealWord(word, ""), // which will show us which characters in the word are alreadt revealed or not
	}

	/*
	 How the CurrentGuessState works ?
	 - Suppose if the word was "animal" and player guessed the letters 'a' and 'm'
	 - then, this property would contain value of "a**ma*"
	 - However, this logic will be implemented by the revealWord() function
	*/

	// Check if the game with the same GameId already exists
	// If it doesn't exists, meaning an error <err>, the GameId not found, then create the Game with this GameId <TheGame>
	_, err := t.getGameById("TheGame")
	if err != nil {
		return t.createGame(newGame)
	}

	// But what if the game is already present, then override its properties with the <newGame>
	return t.updateGame(newGame)
}

// Step-6
// Custom Business Function 03
// userId -> Who is making a guess; Player
// guessedCharacter
func (t *Controller) MakeAGuess(userId string, guessedCharacter string) (interface{}, error) {
	// Get the current game object
	game, err := t.getGameById("TheGame")
	// return error if no game is currently running
	if err != nil {
		return nil, fmt.Errorf("no game is running: %s", err.Error())
	}

	// Get current player object
	player, err := t.GetPlayerById(userId)
	if err != nil {
		return nil, fmt.Errorf("player with id %s not found. error : %s", userId, err.Error())
	}

	// Reserve a variable for the result of this function execution to indicate the output of the operation
	var result string

	// Check if the guessed character exists in a word
	if strings.Index(game.WordToGuess, guessedCharacter) != -1 {
		// Check if this character was already guessed
		if strings.Index(game.Used, guessedCharacter) != -1 {
			// Set result indicate that charactr as already guessed
			result = "Character was already guessed " + game.CurrentGuessState
		} else {
			// This is a new correctly guessed character
			// Add this gussed character to the <Used> characters string
			game.Used = game.Used + guessedCharacter

			// reveal current state of gussed word
			game.CurrentGuessState = t.revealWord(game.WordToGuess, game.Used)

			// Increase Player Score
			player.Score += 1

			// Check if the word has been completely solved
			if game.CurrentGuessState == game.WordToGuess {
				result = "Congratulations you have gussed the word: " + game.WordToGuess

				// Start New Game when the word is solved
				t.startNewGame([]string{})
			} else {
				// Correct letter was guessed, but the word is not solved yet
				// Update game with new CurrentGuessState
				_, err = t.updateGame(game)
				// Return an error if the game cannot be updated
				if err != nil {
					return nil, fmt.Errorf("error updating game %s %s", game.GameId, err.Error())
				}

				// Set result to indicate a successful guess
				result = "You have made correct guess: " + game.CurrentGuessState

			}

		}
	} else {
		// Guessed Character is not present in the word
		// Decrease player score
		player.Score -= 1
		result = "Incorrect Guess: " + game.CurrentGuessState
	}

	// Update player object to reflect changes in the score
	t.UpdatePlayer(player)

	// Return <result> indicating the outcome of this function
	return result, nil
}

// Step-5 (Called inside in Step-4 )
// Custom Business Function 02
func (t *Controller) revealWord(word string, used string) string {
	revealedWord := ""
	letters := strings.Split(word, "")
	for _, wordLetter := range letters {
		// if letters are already guessed, then we will show them
		/*
		 strings.Index("Rajesh", "Raj") 			-> 0  // substring found at 0
		 strings.Index("Sheldon", "Shely")		-> -1 // no substring found

		*/

		// if wordLetter is in guessedList i.e. is not in <used>
		if strings.Index(used, wordLetter) != -1 {
			revealedWord += wordLetter
		} else {
			revealedWord += "*" // if not in the guessedList
		}
	}

	return revealedWord
}
