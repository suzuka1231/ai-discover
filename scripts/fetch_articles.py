#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI Discover - 記事自動収集スクリプト
RSSフィードから生成AI関連の記事を収集し、HTMLサイトを更新します
"""

import json
import re
import feedparser
import requests
from datetime import datetime, timedelta
from bs4 import BeautifulSoup
from urllib.parse import urlparse
import time
import hashlib

class ArticleCollector:
    def __init__(self, config_path='config.json'):
        with open(config_path, 'r', encoding='utf-8') as f:
            self.config = json.load(f)
        
        self.articles = []
        self.seen_urls = set()
        
    def fetch_all_sources(self):
        """全てのソースから記事を収集"""
        print("📡 記事の収集を開始...")
        
        for source in self.config['sources']:
            try:
                print(f"  ↳ {source['name']} を取得中...")
                
                if source['type'] == 'rss':
                    self.fetch_rss(source)
                elif source['type'] == 'note_rss':
                    self.fetch_note_api(source)
                    
                time.sleep(1)  # レート制限対策
                
            except Exception as e:
                print(f"  ⚠️  エラー: {source['name']} - {str(e)}")
        
        # 手動追加記事を追加
        self.add_manual_articles()
        
        print(f"✅ 合計 {len(self.articles)} 件の記事を収集")
        
    def fetch_rss(self, source):
        """標準RSSフィードから記事を取得"""
        feed = feedparser.parse(source['url'])
        
        for entry in feed.entries:
            # 日付チェック
            if not self.is_recent(entry):
                continue
            
            # キーワードフィルタリング
            if not self.matches_keywords(entry, source['keywords']):
                continue
            
            # URLの重複チェック
            url = entry.link
            if url in self.seen_urls or url in self.config.get('blacklist', []):
                continue
            
            # 記事データを作成
            article = self.create_article_data(entry, source)
            if article:
                self.articles.append(article)
                self.seen_urls.add(url)
    
    def fetch_note_api(self, source):
        """noteのAPIから記事を取得"""
        try:
            # noteの特定クリエイターのRSSを取得
            # URLからユーザー名を抽出
            match = re.search(r'creators/([^/]+)/', source['url'])
            if not match:
                return
            
            username = match.group(1)
            rss_url = f"https://note.com/{username}/rss"
            
            feed = feedparser.parse(rss_url)
            
            for entry in feed.entries:
                if not self.is_recent(entry):
                    continue
                
                if not self.matches_keywords(entry, source['keywords']):
                    continue
                
                url = entry.link
                if url in self.seen_urls or url in self.config.get('blacklist', []):
                    continue
                
                article = self.create_article_data(entry, source)
                if article:
                    self.articles.append(article)
                    self.seen_urls.add(url)
                    
        except Exception as e:
            print(f"    note API エラー: {str(e)}")
    
    def create_article_data(self, entry, source):
        """記事データを構造化"""
        try:
            # タイトルと説明
            title = entry.get('title', '').strip()
            description = self.extract_description(entry)
            
            # サムネイル画像を取得
            thumbnail = self.extract_thumbnail(entry, source['platform'])
            
            # AIツールを自動検出
            ai_tools = self.detect_ai_tools(title + ' ' + description)
            
            # タグを生成
            tags = self.generate_tags(title, description, ai_tools)
            
            # 公開日時
            published = self.get_published_time(entry)
            
            article = {
                'id': hashlib.md5(entry.link.encode()).hexdigest()[:8],
                'title': title,
                'description': description,
                'url': entry.link,
                'platform': source['platform'],
                'author': self.extract_author(entry),
                'time': self.format_time_ago(published),
                'timestamp': published.isoformat() if published else None,
                'thumbnail': thumbnail,
                'tags': tags,
                'aiTools': ai_tools
            }
            
            return article
            
        except Exception as e:
            print(f"    記事データ作成エラー: {str(e)}")
            return None
    
    def extract_description(self, entry):
        """記事の説明文を抽出"""
        # summary または description から取得
        desc = entry.get('summary', entry.get('description', ''))
        
        # HTMLタグを除去
        if desc:
            soup = BeautifulSoup(desc, 'html.parser')
            desc = soup.get_text().strip()
            # 長すぎる場合は切り詰め
            if len(desc) > 200:
                desc = desc[:197] + '...'
        
        return desc
    
    def extract_thumbnail(self, entry, platform):
        """サムネイル画像を抽出"""
        # media:thumbnail または enclosure から取得
        if hasattr(entry, 'media_thumbnail'):
            return entry.media_thumbnail[0]['url']
        
        if hasattr(entry, 'enclosures') and entry.enclosures:
            for enclosure in entry.enclosures:
                if 'image' in enclosure.get('type', ''):
                    return enclosure['href']
        
        # コンテンツ内の最初の画像を探す
        content = entry.get('content', [{}])[0].get('value', '')
        if content:
            soup = BeautifulSoup(content, 'html.parser')
            img = soup.find('img')
            if img and img.get('src'):
                return img['src']
        
        # プラットフォーム別のデフォルト画像
        return self.get_default_thumbnail(platform)
    
    def get_default_thumbnail(self, platform):
        """プラットフォーム別のデフォルトサムネイル"""
        defaults = {
            'note': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjU2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iODAwIiBoZWlnaHQ9IjU2MCIgZmlsbD0iIzQxYzliNCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iNDgiIGZpbGw9IndoaXRlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkeT0iLjNlbSI+bm90ZTwvdGV4dD48L3N2Zz4=',
            'zenn': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjU2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iODAwIiBoZWlnaHQ9IjU2MCIgZmlsbD0iIzNlYThmZiIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iNDgiIGZpbGw9IndoaXRlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkeT0iLjNlbSI+WmVubjwvdGV4dD48L3N2Zz4=',
            'blog': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjU2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iODAwIiBoZWlnaHQ9IjU2MCIgZmlsbD0iIzY2NjY2NiIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iNDgiIGZpbGw9IndoaXRlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkeT0iLjNlbSI+QmxvZzwvdGV4dD48L3N2Zz4='
        }
        return defaults.get(platform, defaults['blog'])
    
    def extract_author(self, entry):
        """著者名を抽出"""
        return entry.get('author', entry.get('dc:creator', '不明'))
    
    def get_published_time(self, entry):
        """公開日時を取得"""
        for time_field in ['published_parsed', 'updated_parsed']:
            if hasattr(entry, time_field):
                time_struct = getattr(entry, time_field)
                if time_struct:
                    return datetime(*time_struct[:6])
        return datetime.now()
    
    def format_time_ago(self, pub_time):
        """相対時間表記に変換"""
        if not pub_time:
            return '不明'
        
        now = datetime.now()
        diff = now - pub_time
        
        if diff.days > 30:
            return f"{diff.days // 30}ヶ月前"
        elif diff.days > 0:
            return f"{diff.days}日前"
        elif diff.seconds > 3600:
            return f"{diff.seconds // 3600}時間前"
        else:
            return f"{diff.seconds // 60}分前"
    
    def is_recent(self, entry):
        """最近の記事かチェック"""
        pub_time = self.get_published_time(entry)
        if not pub_time:
            return True
        
        days_limit = self.config['settings']['days_to_keep']
        cutoff = datetime.now() - timedelta(days=days_limit)
        
        return pub_time >= cutoff
    
    def matches_keywords(self, entry, source_keywords):
        """キーワードマッチング"""
        title = entry.get('title', '').lower()
        description = self.extract_description(entry).lower()
        content = title + ' ' + description
        
        # グローバルフィルター
        global_filter = self.config['keywords_filter']
        
        # 除外キーワードチェック
        for exclude in global_filter['exclude']:
            if exclude.lower() in content:
                return False
        
        # 必須キーワードチェック（どれか1つ含む）
        all_keywords = source_keywords + global_filter['required_any']
        
        # キーワードが指定されていない場合は全て許可
        if not all_keywords:
            return True
        
        for keyword in all_keywords:
            if keyword.lower() in content:
                return True
        
        return False
    
    def detect_ai_tools(self, text):
        """AIツールを自動検出"""
        text_lower = text.lower()
        tools = []
        
        ai_patterns = {
            'chatgpt': ['chatgpt', 'gpt-4', 'gpt-3', 'gpt4', 'gpt3'],
            'claude': ['claude', 'anthropic'],
            'gemini': ['gemini', 'bard', 'google ai'],
            'sora': ['sora', 'openai sora'],
            'midjourney': ['midjourney', 'mj'],
            'stable-diffusion': ['stable diffusion', 'sd'],
            'dall-e': ['dall-e', 'dalle']
        }
        
        for tool, patterns in ai_patterns.items():
            for pattern in patterns:
                if pattern in text_lower:
                    tools.append(tool)
                    break
        
        return list(set(tools))  # 重複除去
    
    def generate_tags(self, title, description, ai_tools):
        """タグを自動生成"""
        text = (title + ' ' + description).lower()
        tags = []
        
        # AI ツール名をタグに
        tool_names = {
            'chatgpt': 'ChatGPT',
            'claude': 'Claude',
            'gemini': 'Gemini',
            'sora': 'Sora',
            'midjourney': 'Midjourney'
        }
        
        for tool in ai_tools:
            if tool in tool_names:
                tags.append(tool_names[tool])
        
        # カテゴリタグ
        if any(word in text for word in ['プロンプト', 'prompt']):
            tags.append('プロンプト')
        
        if any(word in text for word in ['画像生成', 'image generation', '画像']):
            tags.append('画像生成')
        
        if any(word in text for word in ['動画生成', 'video generation', '動画', 'sora']):
            tags.append('動画生成')
        
        if any(word in text for word in ['gpt作成', 'gpts', 'カスタムgpt']):
            tags.append('GPT作成')
        
        if any(word in text for word in ['効率化', '自動化', 'automation']):
            tags.append('効率化')
        
        # 最大5つまで
        return tags[:5]
    
    def add_manual_articles(self):
        """手動追加記事を読み込む"""
        manual = self.config.get('manual_articles', [])
        for article in manual:
            if article.get('url') and article['url'] not in self.seen_urls:
                # 必須フィールドがあるか確認
                if article.get('title'):
                    self.articles.append(article)
                    self.seen_urls.add(article['url'])
    
    def sort_and_limit(self):
        """記事をソートして件数制限"""
        # タイムスタンプでソート（新しい順）
        self.articles.sort(
            key=lambda x: x.get('timestamp', ''), 
            reverse=True
        )
        
        # 最大件数で制限
        max_articles = self.config['settings']['max_articles']
        self.articles = self.articles[:max_articles]
    
    def save_to_json(self, output_path='data/articles.json'):
        """JSON形式で保存"""
        self.sort_and_limit()
        
        data = {
            'last_updated': datetime.now().isoformat(),
            'total': len(self.articles),
            'articles': self.articles
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"💾 {output_path} に保存しました")
        return data

def main():
    print("🤖 AI Discover - 記事収集を開始")
    print("=" * 50)
    
    collector = ArticleCollector('config.json')
    collector.fetch_all_sources()
    data = collector.save_to_json('data/articles.json')
    
    print("=" * 50)
    print(f"✨ 完了！ {data['total']} 件の記事を収集しました")

if __name__ == '__main__':
    main()
