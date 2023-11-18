from flask import Flask, request
from openai import OpenAI
from io import BytesIO
import os, base64, nft_storage
from nft_storage.api import nft_storage_api

client = OpenAI()

api_key = os.environ.get('NFT_STORAGE_API_KEY')

configuration = nft_storage.Configuration(
    access_token = api_key
)

app = Flask(__name__)

@app.route('/process_string', methods=['POST'])
def generate_image_and_put_onIPFS():
    data = request.json
    image_prompt = data.get('image_prompt')

    openai_response = client.images.generate(
        model="dall-e-3",
        prompt=image_prompt,
        size="1024x1024",
        quality="standard",
        n=1,
        user="minter",
        response_format="b64_json"
    )
    image_json = openai_response.data[0].b64_json
    image_data = base64.b64decode(image_json)
    file_name = 'hagia_sophia.jpeg'
    with open(file_name, 'wb') as f:
        f.write(image_data)

    api_client = nft_storage.ApiClient(configuration)
    # Create an instance of the API class
    api_client.set_default_header('Content-Type', 'image/jpeg')
    api_instance = nft_storage_api.NFTStorageAPI(api_client)
    body = open(file_name, 'rb') # file_type | 
    try:
        # Store a file
        api_response = api_instance.store(body)
        return api_response.to_dict()['value']['cid']
    except nft_storage.ApiException as e:
        print("Exception when calling NFTStorageAPI->store: %s\n" % e)
        return {'error': e}

if __name__ == '__main__':
    app.run(debug=True)