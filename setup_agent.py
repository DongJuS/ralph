import os

base_dir = "../personal-data-agent"

files_to_create = {
    f"{base_dir}/ARCHITECTURE.md": """# Personal Data Agent Architecture

## Overview
This project is an automated AI agent designed to manage personal information, scrape news and relevant data, refine and process that data, and store it securely (e.g., in Oracle Cloud). It provides interfaces for user interaction, primarily via Telegram, and is designed to run continuously on environments like a Mini PC.

## Core Components

### 1. Agent Core (`src/agent/`)
- **`main.py`**: The orchestrator. It schedules tasks, routes data between components, and handles the agent's primary decision-making loop.

### 2. Data Ingestion (`src/data/scraper/`)
- **`news_scraper.py`**: Crawls open-source news or RSS feeds to gather daily updates based on user interests.

### 3. Data Processing (`src/data/processor/`)
- **`refiner.py`**: Cleans, categorizes, and formats raw data (like news articles or unstructured personal notes) into a structured format (JSON/Markdown) suitable for storage and retrieval.

### 4. Storage (`src/storage/oracle/`)
- **`uploader.py`**: Handles secure connections to Oracle Cloud Infrastructure (OCI) Object Storage or an Oracle Database to persist the refined data.

### 5. Interfaces (`src/interfaces/telegram/`)
- **`bot.py`**: A Telegram bot interface for the user to send notes, receive news summaries, and issue commands to the agent.

## Deployment (Mini PC)
- The system is designed to be lightweight.
- Use `systemd` or Docker to keep the agent running in the background.
- Scheduled tasks (cron or Python's `schedule` library) handle daily scraping and Oracle syncing.
""",
    f"{base_dir}/requirements.txt": """oci>=2.115.0
python-telegram-bot>=20.6
beautifulsoup4>=4.12.2
requests>=2.31.0
schedule>=1.2.1
python-dotenv>=1.0.0
""",
    f"{base_dir}/.env.example": """TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
OCI_CONFIG_PROFILE=DEFAULT
OCI_BUCKET_NAME=personal-data-bucket
""",
    f"{base_dir}/src/agent/main.py": """import time
import schedule
import logging
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def daily_news_scrape():
    logger.info("Starting daily news scraping...")
    # TODO: Import news_scraper and run

def sync_to_oracle():
    logger.info("Syncing refined data to Oracle Cloud...")
    # TODO: Import uploader and run

def start_agent():
    logger.info("Personal Data Agent starting up...")
    
    # Schedule tasks
    schedule.every().day.at("08:00").do(daily_news_scrape)
    schedule.every().day.at("23:00").do(sync_to_oracle)
    
    # Run Telegram bot in a separate thread or async task
    # TODO: Start Telegram bot polling
    
    logger.info("Agent is running. Waiting for scheduled tasks...")
    while True:
        schedule.run_pending()
        time.sleep(60)

if __name__ == "__main__":
    load_dotenv()
    start_agent()
""",
    f"{base_dir}/src/data/scraper/news_scraper.py": """import requests
from bs4 import BeautifulSoup

def scrape_news(url):
    \"\"\"
    Basic scraper to fetch news articles from a given URL.
    \"\"\"
    response = requests.get(url)
    if response.status_code != 200:
        return []
    
    soup = BeautifulSoup(response.text, 'html.parser')
    headlines = []
    
    for h2 in soup.find_all('h2'):
        headlines.append(h2.text.strip())
        
    return headlines
""",
    f"{base_dir}/src/data/processor/refiner.py": """import json

def refine_raw_data(raw_data, source="unknown"):
    \"\"\"
    Refines raw data into a structured format for storage.
    \"\"\"
    refined = {
        "source": source,
        "content_length": len(str(raw_data)),
        "data": raw_data,
        "tags": [] # TODO: NLP or keyword extraction to add tags
    }
    return refined
""",
    f"{base_dir}/src/storage/oracle/uploader.py": """import os
import oci
import json
import logging

logger = logging.getLogger(__name__)

def upload_to_oci(data: dict, filename: str):
    \"\"\"
    Uploads a structured dictionary to Oracle Cloud Object Storage as JSON.
    \"\"\"
    try:
        config = oci.config.from_file()
        object_storage = oci.object_storage.ObjectStorageClient(config)
        namespace = object_storage.get_namespace().data
        
        bucket_name = os.getenv("OCI_BUCKET_NAME", "default-bucket")
        
        data_json = json.dumps(data).encode('utf-8')
        
        logger.info(f"Uploading {filename} to OCI bucket {bucket_name}...")
        object_storage.put_object(
            namespace,
            bucket_name,
            filename,
            data_json
        )
        logger.info("Upload successful.")
    except Exception as e:
        logger.error(f"Failed to upload to OCI: {e}")
""",
    f"{base_dir}/src/interfaces/telegram/bot.py": """import os
import logging
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, filters, ContextTypes

logger = logging.getLogger(__name__)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Hello! I am your Personal Data Agent. Send me notes to save, or use /news for today's updates.")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text
    logger.info(f"Received note: {text}")
    # TODO: Pass text to refiner and save to local queue for Oracle sync
    await update.message.reply_text(f"Note saved! (Length: {len(text)})")

def run_bot():
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    if not token:
        logger.error("No TELEGRAM_BOT_TOKEN provided.")
        return

    app = ApplicationBuilder().token(token).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    logger.info("Telegram bot is polling...")
    app.run_polling()
"""
}

for filepath, content in files_to_create.items():
    with open(filepath, "w") as f:
        f.write(content)

print("Setup complete.")
