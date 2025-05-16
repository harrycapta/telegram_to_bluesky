# install.sh
#!/bin/bash

# Setup virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install requirements
pip install --upgrade pip
pip install -r requirements.txt

# Create initial config
if [ ! -f config.py ]; then
    echo "Creating initial config.py..."
    cat <<EOL > config.py
TELEGRAM_BOT_TOKEN = "INSERT_YOUR_TOKEN"
BLUESKY_HANDLE = "your.handle.bsky.social"
BLUESKY_APP_PASSWORD = "your-app-password"
BLUESKY_PDS = "https://your.pds.domain"
EOL
    echo "Edit config.py with your credentials before running the bot."
fi

# requirements.txt
cat <<REQ > requirements.txt
python-telegram-bot==20.7
atproto>=0.0.60
httpx
Pillow
python-dotenv
REQ

# bot.py
cat <<PYTHON > bot.py
import logging
import os
import datetime
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, filters, ContextTypes
from config import TELEGRAM_BOT_TOKEN
from bluesky_publisher import publish_to_bluesky

logging.basicConfig(level=logging.INFO)

MEDIA_DIR = "media"
os.makedirs(MEDIA_DIR, exist_ok=True)

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    if update.message.text:
        content = update.message.text
        await update.message.reply_text("Messaggio ricevuto. Invio a Bluesky...")
        success = publish_to_bluesky(content)
        reply = "Pubblicato su Bluesky!" if success else "Errore nella pubblicazione."
        await update.message.reply_text(reply)

    elif update.message.photo:
        photo_file = await update.message.photo[-1].get_file()
        filename = os.path.join(MEDIA_DIR, f"{datetime.datetime.now().isoformat()}.jpg")
        await photo_file.download_to_drive(filename)
        await update.message.reply_text("Immagine ricevuta. Invio a Bluesky...")
        success = publish_to_bluesky(text="", image_path=filename)
        reply = "Pubblicato su Bluesky!" if success else "Errore nella pubblicazione."
        await update.message.reply_text(reply)

if __name__ == '__main__':
    app = ApplicationBuilder().token(TELEGRAM_BOT_TOKEN).build()
    app.add_handler(MessageHandler(filters.ALL, handle_message))
    app.run_polling()
PYTHON

# bluesky_publisher.py
cat <<PYTHON > bluesky_publisher.py
from atproto import Client
from config import BLUESKY_HANDLE, BLUESKY_APP_PASSWORD, BLUESKY_PDS
import os

def publish_to_bluesky(text: str = "", image_path: str = None) -> bool:
    try:
        client = Client(base_url=BLUESKY_PDS)
        client.login(BLUESKY_HANDLE, BLUESKY_APP_PASSWORD)

        if image_path and os.path.exists(image_path):
            with open(image_path, "rb") as f:
                uploaded_img = client.com.atproto.repo.upload_blob(f)
            client.send_post(text=text or "", embed={'$type': 'app.bsky.embed.images', 'images': [{
                'alt': 'Image',
                'image': uploaded_img.blob
            }]})
        else:
            client.send_post(text=text or "(messaggio vuoto)")
        return True
    except Exception as e:
        print(f"Errore Bluesky: {e}")
        return False
PYTHON
