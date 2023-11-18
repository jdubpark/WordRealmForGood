# Pro-Active Public Goods Funding
![cover image](https://github.com/jdubpark/WordRealmForGood/blob/main/CoverImage.png)

Disaster relief funding pre-emptively distributed to local aid organizations before inclement weather strikes -- all funded by educational, generative NFT gaming.

## Player Experience
Player signs into the WordRealm with WorldCoin Sign In. Player selects which region they would like to learn about and are then presented with a random selection of words organized into three categories. API3 QRNG provides on-chain quantum randomness to the selection of words presented to the player from which to select. Player selects words that teaches her about cultural elements from the local region -- the selected words are then used to generate an NFT that visualizes the chosen words. Nouns NFT art and style is featured prominently -- given the game exists to fund public goods in a whimsical, cryptographic method, there is no art more fitting than Nouns. Players can enjoy Nouns art uniquely incorporated in different geographic locations. The player can choose to mint the NFT -- proceeds are then sent to a disaster relief contract on Base Goerli. Player can choose to sell the NFT -- proceeds from royalties are sent to the same disaster relief contract on Base Goerli. 

## Funding DisasterRelief.eth
Chainlink CCIP is used to transfer tokens from the disaster relief contract on Base Goerli to DisasterRelief.eth address on Ethereum Sepolia. Chainlink Automation is used with a Chainlink Function that performs an API call to the [MET Norway Weather API](https://app.digitalpublicgoods.net/a/10219), a Digital Public Good that provides free access to high-quality 10-day weather forecast data for any geolocation in the world. When the player initially selected a location in WordRealm, the geolocation was passed to the Chainlink Function so that the DisasterRelief contract funded was the DisasterRelief contract designated to support that geolocation. 

The Chainlink Automation is triggered when a disaster threshold for a parameter in the weather data is hit for a forecast two days in advance -- in this project, we designate the disaster threshold trigger as precipitation for xyz number of hours. When the Automation is triggered, money in the DisasterRelief.eth contract is sent to an Arx NFC chip wallet. This allows for direct distribution of accumulated funds to the NFC chip wallet of a local non-profit aid organization without the need for Internet connectivity two days in advance of the forecasted inclement weather. 

## Running the server

1. Install the required packages by running `pip install -r requirements.txt`.
2. Set the environment variable `NFT_STORAGE_API_KEY` with your NFT Storage API key.
3. Set the environment variable `OPENAI_API_KEY` with your OpenAI API key.
4. Run the Flask application with the command `python app.py`.

## Interacting with the server
1. Send a POST request to the `/process_string` endpoint with a JSON body containing the `image_prompt` key. The value of this key should be the text prompt you want to generate an image from.
```
curl -X POST http://127.0.0.1:5000/process_string -H "Content-Type: application/json" -d '{"image_prompt": "Eating Turkish Ice Cream in Hagia Sophia"}'
```
2. The application will return a CID (Content Identifier) which can be used to retrieve the generated image from the IPFS (InterPlanetary File System) through NFT Storage.

## How It's Built
We used the Auth0 Integration to add Sign In with Worldcoin to WordRealm. Worldcoin integration was imperative to this project because funds generated from players is donated to local non-profit aid organizations--hence, proof of personhood is important to prevent sybil attacks that would render the game unplayable and donations fraudulent. 
