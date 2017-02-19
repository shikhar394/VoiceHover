from gtts import gTTS
from os import system

def speak(input_text):
    tts = gTTS(text = input_text, lang = 'en')
    tts.save("Speech.mp3")
    system("mpg321 Speech.mp3")

def file_input(File):
    File_text = open(File)
    for line in File_text:
        speak(line)
        
file_input("talk.txt")
    
    

    