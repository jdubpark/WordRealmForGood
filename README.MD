# Pro-Active Public Goods Funding

![cover image](https://github.com/jdubpark/WordRealmForGood/blob/main/CoverImage.png)

Disaster relief funding pre-emptively distributed to local aid organisations based on a trigger of imminent disastrous weather (hurricane or strong winds) -- all funded by educational, free-to-play generative NFT gaming.

## Demo

Check out the [demo here](https://youtu.be/4kVkL8W3j-o)!

## Player Experience

A Player is presented with a random selection of words, through API3 QRNG, organized into three categories popular in their local region, Turkey: Landmarks, Cuisine, and Carpets. Player selects words that teach them about cultural elements from the local region -- the selected words are then used to create a sentence portayed a turkish cat eating the cuisine selected on a flying version of the carpet selected inside the landmark selected. This sentence is passed through DALL-E to generate an NFT that portrays the sentence constructed by the Player. This image is stored in decentralized manner on IPFS through NFT.Storage. Nouns NFT art and style is featured prominently -- given the game exists to fund public goods in a whimsical, cryptographic method, there is no art more fitting than Nouns. The player can choose to mint the NFT whose proceeds are then sent to a disaster relief contract on Base Goerli. Player can choose to sell the NFT -- proceeds from royalties are sent to the same disaster relief contract on Base Goerli. To allow only human players to experience the game, the app uses Worldcoin's anonymous actions for the action of minting an NFT.

## Funding DisasterRelief.eth

Chainlink CCIP is used to transfer tokens from the disaster relief contract on Base Goerli to DisasterRelief.eth address on Ethereum Sepolia. Chainlink Automation is used with a Chainlink Function that performs an API call to the [MET Norway Weather API](https://app.digitalpublicgoods.net/a/10219), a Digital Public Good that provides free access to high-quality 10-day weather forecast data for any geolocation in the world. When the player initially selected a location in WordRealm, the geolocation was passed to the Chainlink Function so that the DisasterRelief contract funded was the DisasterRelief contract designated to support that geolocation.

The Chainlink Automation is triggered when a disaster threshold for a parameter in the weather data is hit for a forecast five to ten days in advance -- in this project, we designate the disaster threshold trigger as a hurricane or excessively strong winds. The Automation calls the weather API on an hourly basis. When the Automation is triggered, money in the DisasterRelief.eth contract is sent to the Arx NFC chip wallet. This allows for direct distribution of accumulated funds to the Arx NFC chip wallet of a local non-profit aid organization without the need for Internet connectivity two days in advance of the forecasted inclement weather.

## Cross-Cultural Ties

NFT holders are connected with members of the local region by a token-gated channel supported by Push Protocol. When disaster strikes, NFT holders are in direct contact with locals in the disaster stricken zone. This allows for real-time communication and coordination, directly from the NFT holders' MetaMask wallet connected by a MetaMask Snap. NFT holders can opt in and define what notifications they receive on an ongoing situation with disastrous weather conditions.

## Running the server

1. Install the required packages by running `pip install -r requirements.txt`.
2. Set the environment variable `NFT_STORAGE_API_KEY` with your NFT Storage API key.
3. Set the environment variable `OPENAI_API_KEY` with your OpenAI API key.
4. Run the Flask application with the command `python app.py`.

## Interacting with the server

1. Send a POST request to the `/process_string` endpoint with a JSON body containing the `image_prompt` key. The value of this key should be the text prompt you want to generate an image from.

```bash
curl -X POST http://127.0.0.1:5000/process_string -H "Content-Type: application/json" -d '{"image_prompt": "Eating Turkish Ice Cream in Hagia Sophia"}'
```

2. The application will return a CID (Content Identifier) which can be used to retrieve the generated image from the IPFS (InterPlanetary File System) via NFT.Storage.

## How The Game Is Built

We used Worldcoin IDKit to add anonymous action to the mint NFT action to WordRealm. Worldcoin integration was imperative to this project because funds generated from players are donated to local non-profit aid organizations--hence, proof of personhood is important to prevent sybil attacks that would render the game unplayable and donations fraudulent.

The contract requests three random numbers from API3 QRNG by using the ```endpointIdUint256Array``` of the QRNG provider while making the request. This returns an array of three random numbers. These random numbers are then used as random indices to select from a larger list of words within respective cultural categories (in the Turkey example, the categories are landmarks, cuisine, and carpets). The user then selects words--these words are then passed to DALL-E to generate an image that is then stored on IPFS through NFT.storage.

The player can then mint the NFT with mint fee sent to a contract address on Base Goerli (base.disasterrelief.eth). The player can sell the NFT with royalties sent to base.disasterrelief.eth.

## Relevant Contract Addresses

Base Goerli API3 QRNG: 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd
