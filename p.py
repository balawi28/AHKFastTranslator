import pyperclip

# Read the long text from file.txt
with open('file.txt', 'r') as file:
    long_text = file.read()

# Divide the long text into 50-character chunks
chunks = [long_text[i:i+80] for i in range(0, len(long_text), 80)]

# Add quotes and dot before the first quotation mark in each line
formatted_text = '. "' + '"\n. "'.join(chunks) + '"'

# Copy the formatted text to the clipboard
pyperclip.copy(formatted_text)

print("Formatted text copied to clipboard.")


