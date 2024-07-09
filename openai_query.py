# -*- coding: utf-8 -*-

#!pip install openai==0.28


from openai import OpenAI
from textblob import TextBlob
import sys
import io

# OpenAI API 키 설정
openai_api_key = YOUR_API_KEY

sys.stdout = io.TextIOWrapper(sys.stdout.detach(), encoding ='utf-8')

def analyze_sentiment(text):
    blob = TextBlob(text)
    polarity = blob.sentiment.polarity
    if polarity > 0.1:
        return "positive"
    elif polarity < -0.1:
        return "negative"
    else:
        return "neutral"

def get_response(user_input):
    client = OpenAI(api_key = openai_api_key)
    response = client.completions.create(
        model="gpt-3.5-turbo-instruct",
        prompt = user_input,
        max_tokens=150,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
        #messages=[
        #    {"role": "system", "content": "You are a helpful assistant."},
        #    {"role": "user", "content": user_input}
            #{"role": "user", "content": "Who won the world series in 2020?"},
            #{"role": "assistant", "content": "The Los Angeles Dodgers won the World Series in 2020."},
            #{"role": "user", "content": "Where was it played?"}
       # ]
        )
    return response.choices[0].text.strip()

# def generate_response(user_input):
#     response = get_response(user_input)
#     sentiment = analyze_sentiment(user_input)
#     return response, sentiment

if __name__ == "__main__":
    user_input = sys.argv[1] if len(sys.argv) > 1 else "I'm not sure how to respond to that."
    if sys.argv[2] == "response":
        print(get_response(user_input))
    elif sys.argv[2] == "sentiment":
        print(analyze_sentiment(user_input))

# if __name__ == "__main__":
#     user_input = sys.argv[1]
#     response, sentiment = generate_response(user_input)
#     print(response)
#     print(sentiment)

# if __name__ == "__main__":
#     import sys
#     user_input = sys.argv[1] if len(sys.argv) > 1 else "I'm not sure how to respond to that."
#     print(get_response(user_input))