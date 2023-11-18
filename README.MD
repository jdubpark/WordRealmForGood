# Running the server

1. Install the required packages by running `pip install -r requirements.txt`.
2. Set the environment variable `NFT_STORAGE_API_KEY` with your NFT Storage API key.
3. Set the environment variable `OPENAI_API_KEY` with your OpenAI API key.
4. Run the Flask application with the command `python app.py`.

# Interacting with the server
1. Send a POST request to the `/process_string` endpoint with a JSON body containing the `image_prompt` key. The value of this key should be the text prompt you want to generate an image from.
```
curl -X POST http://127.0.0.1:5000/process_string -H "Content-Type: application/json" -d '{"image_prompt": "Eating Turkish Ice Cream in Hagia Sophia"}'
```
2. The application will return a CID (Content Identifier) which can be used to retrieve the generated image from the IPFS (InterPlanetary File System) through NFT Storage.
