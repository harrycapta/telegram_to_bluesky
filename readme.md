# Telegram → Bluesky Bot

Questo bot riceve messaggi e immagini da Telegram e li pubblica automaticamente su un account Bluesky.

## ✅ Funzionalità
- Riceve messaggi di testo o immagini da Telegram
- Salva i file in locale
- Pubblica istantaneamente il contenuto su Bluesky
- Conferma ricezione e pubblicazione all’utente

## ⚙️ Requisiti
- Python 3.10+
- Ubuntu 22+ (testato)

## 🚀 Installazione

```bash
git clone <repo>
cd telegram_bluesky_bot
chmod +x install.sh
./install.sh
```

Edit `config.py` with your credential:
```python
TELEGRAM_BOT_TOKEN = "<token_bot>"
BLUESKY_HANDLE = "your.handle.bsky.social"  # or custom domain
BLUESKY_APP_PASSWORD = "xxxx-xxxx-xxxx-xxxx"
BLUESKY_PDS = "https://your.pds.com"         # https://bsky.social or custom PDS
```

## ▶️ Avvio bot
```bash
source venv/bin/activate
python bot.py
```

## 📂 File structure
- `bot.py`: bot Telegram
- `bluesky_publisher.py`
- `config.py`: cred
- `media/`: images

## 📣 Licenza
MIT
DOC
