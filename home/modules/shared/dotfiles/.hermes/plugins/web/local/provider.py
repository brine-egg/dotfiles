"""Local HTML extractor -- zero API keys, pure Python.

Uses httpx + html2text to fetch pages and convert them to clean markdown.
Designed to pair with any search-only backend (ddgs, brave-free, searxng).
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List

from agent.web_search_provider import WebSearchProvider

logger = logging.getLogger(__name__)


class LocalExtractProvider(WebSearchProvider):
    """Extract-only provider: fetches HTML via httpx, converts to markdown."""

    @property
    def name(self) -> str:
        return "local"

    @property
    def display_name(self) -> str:
        return "Local (html2text)"

    def is_available(self) -> bool:
        try:
            import html2text  # noqa: F401
            import httpx      # noqa: F401
            return True
        except ImportError:
            return False

    def supports_search(self) -> bool:
        return False

    def supports_extract(self) -> bool:
        return True

    def search(self, query: str, limit: int = 5) -> Dict[str, Any]:
        return {"success": False, "error": "local is extract-only"}

    def extract(self, urls: List[str], **kwargs: Any) -> List[Dict[str, Any]]:
        import httpx
        import html2text

        converter = html2text.HTML2Text()
        converter.ignore_links = False
        converter.ignore_images = True
        converter.body_width = 0
        converter.skip_internal_links = False

        results: List[Dict[str, Any]] = []
        for url in urls:
            try:
                resp = httpx.get(
                    url,
                    headers={"User-Agent": "Hermes/1.0"},
                    timeout=30,
                    follow_redirects=True,
                )
                resp.raise_for_status()
                final_url = str(resp.url)
                md = converter.handle(resp.text)

                # Extract title from HTML
                title = ""
                try:
                    from html.parser import HTMLParser
                    class TitleParser(HTMLParser):
                        def __init__(self):
                            super().__init__()
                            self.title = ""
                            self.in_title = False
                        def handle_starttag(self, tag, attrs):
                            if tag == "title":
                                self.in_title = True
                        def handle_data(self, data):
                            if self.in_title:
                                self.title += data
                        def handle_endtag(self, tag):
                            if tag == "title":
                                self.in_title = False
                    tp = TitleParser()
                    tp.feed(resp.text)
                    title = tp.title.strip()
                except Exception:
                    pass

                results.append({
                    "url": final_url,
                    "title": title,
                    "content": md,
                    "raw_content": md,
                })
            except Exception as exc:
                logger.warning("Local extract failed for %s: %s", url, exc)
                results.append({
                    "url": url,
                    "title": "",
                    "content": "",
                    "error": str(exc),
                })

        return results

    def get_setup_schema(self) -> Dict[str, Any]:
        return {
            "name": "Local (html2text)",
            "badge": "free . local",
            "tag": "Zero-config local extraction via httpx + html2text. No API keys.",
            "env_vars": [],
        }
