# Pro-Active Public Goods Funding
Disaster relief funding pre-emptively distributed to local aid organizations before inclement weather strikes -- all funded by educational, generative NFT gaming.

## Player Experience
The player signs into the WordRealm with WorldCoin Sign In. Players select which region they would like to learn about and are then presented with a random selection of words organized into categories. Players then select words that teaches them about cultural elements from the local region -- the selected words are then used to generate an NFT that visualizes the chosen words. The player can choose to mint the NFT -- proceeds are then sent to a disaster relief contract on Base. Later on, the player can choose to sell the NFT -- proceeds from royalties are sent to the disaster relief contract on Base. 

## How It's Built
We followed the Auth0 Integration to add Sign In with Worldcoin to WordRealm. Worldcoin integration was imperative to this project because funds generated from players is donated to local non-profit aid organizations--hence, proof of personhood is important to prevent sybil attacks that would render the game unplayable and donations fraudulent. 

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
