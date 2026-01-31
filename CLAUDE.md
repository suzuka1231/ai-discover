# CLAUDE.md - AI Assistant Guide for AI Discover

This document provides comprehensive guidance for AI assistants working with the AI Discover (あいまと) codebase.

## Project Overview

**AI Discover** is an automated Japanese AI news curation website that:
- Collects AI-related articles from 25+ RSS feeds (note, Zenn, Qiita, YouTube, tech blogs)
- Filters content using keyword matching
- Auto-detects AI tools mentioned in articles
- Deploys as a static site on GitHub Pages
- Updates automatically every 2 hours via GitHub Actions

**Primary Language**: Japanese (UI, documentation, and content)
**License**: MIT

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend Script | Python 3.10+ |
| Frontend | Pure HTML/CSS/JavaScript (no framework) |
| Data Format | JSON |
| CI/CD | GitHub Actions |
| Hosting | GitHub Pages |

### Python Dependencies
- `feedparser==6.0.10` - RSS feed parsing
- `requests==2.31.0` - HTTP requests
- `beautifulsoup4==4.12.2` - HTML parsing
- `lxml==4.9.3` - XML processing

## Directory Structure

```
ai-discover/
├── .github/workflows/
│   └── update.yml              # GitHub Actions workflow (2-hour schedule)
├── scripts/
│   └── fetch_articles.py       # Main article collection script (~393 lines)
├── data/
│   └── articles.json           # Generated article data (auto-updated)
├── index.html                  # Single-page frontend application (~842 lines)
├── config.json                 # All configuration (sources, keywords, settings)
├── requirements.txt            # Python dependencies
├── setup.sh                    # macOS/Linux setup script
├── setup.ps1                   # Windows PowerShell setup script
├── README.md                   # Main documentation (Japanese)
├── QUICKSTART.md               # Quick setup guide
└── CLAUDE_CODE_SETUP.md        # Claude Code integration guide
```

## Key Files

### `config.json` - Central Configuration

```json
{
  "sources": [...],           // RSS feed sources (25+ entries)
  "manual_articles": [...],   // Manually added articles (YouTube, X/Twitter)
  "keywords_filter": {
    "required_any": [...],    // Include articles with any of these keywords
    "exclude": [...]          // Exclude articles containing these keywords
  },
  "blacklist": [...],         // URLs to exclude
  "settings": {
    "max_articles": 400,      // Maximum articles to keep
    "days_to_keep": 90,       // Article retention period
    "auto_detect_ai_tools": true,
    "fetch_thumbnails": true
  }
}
```

### `scripts/fetch_articles.py` - Article Collector

Key class: `ArticleCollector`

Important methods:
- `fetch_all_sources()` - Orchestrates collection from all RSS sources
- `fetch_rss(source)` - Standard RSS feed parsing
- `fetch_note_api(source)` - Special handling for note.com platform
- `matches_keywords(entry, source_keywords)` - Keyword filtering logic
- `detect_ai_tools(text)` - Pattern matching for 18+ AI tools
- `generate_tags(title, description, ai_tools)` - Auto-tag generation
- `save_to_json(output_path)` - Saves to `data/articles.json`

### `index.html` - Frontend SPA

Features:
- Card-based article display with thumbnails
- Platform badges (note, Zenn, Qiita, YouTube, blog, x)
- AI tool filtering (ChatGPT, Claude, Gemini, etc.)
- Full-text search
- Pagination (20 articles per page)
- Article deletion with blacklist clipboard copy

CSS customization via `:root` variables:
```css
:root {
    --color-bg: #f8f9ff;
    --color-accent: #ff6b9d;
    --color-text-primary: #2d3748;
}
```

### `.github/workflows/update.yml` - Automation

- **Schedule**: Every 2 hours (`cron: '0 */2 * * *'`)
- **Triggers**: Schedule, manual dispatch, push to main
- **Actions**: Fetch articles → Commit → Push (auto-deploys to GitHub Pages)

## Common Tasks

### Run Article Collection Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run the collector
python scripts/fetch_articles.py

# Check output
cat data/articles.json | head -50
```

### Add a New RSS Source

Edit `config.json`:
```json
{
  "sources": [
    {
      "name": "Source Name",
      "type": "rss",           // or "note_rss" for note.com
      "url": "https://example.com/feed.xml",
      "keywords": ["AI", "ChatGPT"],  // Optional source-specific keywords
      "platform": "blog"        // note, zenn, qiita, blog, youtube, x
    }
  ]
}
```

### Add Manual Article (YouTube, X/Twitter)

Edit `config.json` → `manual_articles`:
```json
{
  "title": "Article Title",
  "description": "Short description",
  "url": "https://youtube.com/watch?v=xxxxx",
  "platform": "youtube",
  "author": "Author Name",
  "thumbnail": "https://i.ytimg.com/vi/xxxxx/maxresdefault.jpg",
  "tags": ["Tag1", "Tag2"],
  "aiTools": ["chatgpt", "claude"]
}
```

### Blacklist an Article

Add URL to `config.json` → `blacklist`:
```json
{
  "blacklist": [
    "https://note.com/spam/n/xxxxx"
  ]
}
```

### Modify Keywords

Edit `config.json` → `keywords_filter`:
- `required_any`: Articles must contain at least one of these
- `exclude`: Articles with these keywords are filtered out

### Trigger Manual Update

```bash
gh workflow run update.yml
```

### Preview Locally

```bash
python -m http.server 8000
# Open http://localhost:8000
```

## Article Data Structure

Each article in `data/articles.json`:

```json
{
  "id": "4a76d86f",              // MD5 hash of URL (first 8 chars)
  "title": "Article Title",
  "description": "Summary (max 200 chars)",
  "url": "https://source.com/article",
  "platform": "qiita",           // note, zenn, qiita, blog, youtube, x
  "author": "Author Name",
  "time": "52分前",              // Relative time in Japanese
  "timestamp": "2026-01-31T03:09:03",
  "thumbnail": "https://... or data:image/svg+xml;base64,...",
  "tags": ["Tag1", "Tag2"],
  "aiTools": ["claude", "chatgpt"]
}
```

## Detected AI Tools

The system auto-detects these AI tools via pattern matching in `fetch_articles.py:259`:

| Tool ID | Patterns |
|---------|----------|
| `chatgpt` | chatgpt, gpt-4, gpt-3, gpt4, gpt3, gpt-4o |
| `claude` | claude, anthropic |
| `gemini` | gemini, bard, google ai |
| `copilot` | copilot, github copilot, microsoft copilot |
| `perplexity` | perplexity, perplexity ai |
| `sora` | sora, openai sora |
| `midjourney` | midjourney, mj |
| `dall-e` | dall-e, dalle, dall·e |
| `stable-diffusion` | stable diffusion, sd, sdxl |
| `runway` | runway, runway ml, gen-2, gen-3 |
| `notebooklm` | notebooklm, notebook lm |
| `cursor` | cursor, cursor ai |
| `llama` | llama, llama 2, llama 3, meta llama |
| `deepseek` | deepseek, deep seek |
| `grok` | grok, xai |
| `v0` | v0, v0.dev |
| `bolt` | bolt.new, bolt |
| `windsurf` | windsurf, codeium windsurf |

## Development Conventions

### Code Style
- Python: Standard Python 3.10+ conventions
- JavaScript: Vanilla JS, no frameworks
- CSS: CSS variables for theming, mobile-first responsive design

### Git Workflow
- Main branch: `main`
- Automated commits by `github-actions[bot]` with message: `🤖 Update articles - YYYY-MM-DD HH:MM`

### Error Handling
- The article collector continues on source failures (graceful degradation)
- Errors are logged to console with `⚠️` prefix
- Rate limiting: 1-second delay between source fetches

### Data Integrity
- Articles are deduplicated by URL
- Blacklisted URLs are excluded
- Articles older than `days_to_keep` are filtered out
- Maximum `max_articles` retained (sorted by newest first)

## Important Notes for AI Assistants

1. **Language**: UI and most documentation is in Japanese. Maintain Japanese for user-facing content unless requested otherwise.

2. **No Build Step**: The frontend is pure HTML/CSS/JS with no bundling or compilation.

3. **Static Data**: `data/articles.json` is generated by the Python script, not the frontend. The frontend only reads it.

4. **GitHub Pages**: The site auto-deploys from the `main` branch root. Changes to `main` trigger deployment.

5. **Automation**: Do not manually edit `data/articles.json` - it will be overwritten by the next scheduled run.

6. **Testing Changes**:
   - For Python changes: Run `python scripts/fetch_articles.py`
   - For frontend changes: Use `python -m http.server 8000`

7. **Adding New AI Tools**: Update `ai_patterns` dict in `fetch_articles.py:264` and `tool_names` dict in `fetch_articles.py:299`.

8. **Config Validation**: When modifying `config.json`, ensure valid JSON syntax. The Python script will fail on malformed JSON.

## Quick Reference Commands

```bash
# Run article collection
python scripts/fetch_articles.py

# Local preview server
python -m http.server 8000

# Check GitHub Actions status
gh run list --workflow=update.yml

# Trigger manual workflow run
gh workflow run update.yml

# Check article count
cat data/articles.json | python -c "import sys,json; print(json.load(sys.stdin)['total'])"

# View recent commits
git log --oneline -10
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No articles collected | Check `keywords_filter` - may be too restrictive |
| RSS feed errors | Verify feed URL is accessible; check for rate limiting |
| Old articles appearing | Adjust `days_to_keep` in settings |
| Missing thumbnails | Default SVG thumbnails are used as fallback |
| GitHub Actions failure | Check Actions log; usually network/rate limiting issues |
