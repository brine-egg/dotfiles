"""Register the local HTML extract provider."""

from .provider import LocalExtractProvider


def register(ctx):
    ctx.register_web_search_provider(LocalExtractProvider())
