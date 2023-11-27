## Search engines which can be used via the address bar.  Maps a search
## engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}`
## placeholder. The placeholder will be replaced by the search term, use
## `{{` and `}}` for literal `{`/`}` braces.  The following further
## placeholds are defined to configure how special characters in the
## search terms are replaced by safe characters (called 'quoting'):  *
## `{}` and `{semiquoted}` quote everything except slashes; this is the
## most   sensible choice for almost all search engines (for the search
## term   `slash/and&` this placeholder expands to `slash/and%26amp`).
## * `{quoted}` quotes all characters (for `slash/and&` this
## placeholder   expands to `slash%2Fand%26amp`). * `{unquoted}` quotes
## nothing (for `slash/and&` this placeholder   expands to
## `slash/and&`). * `{0}` means the same as `{}`, but can be used
## multiple times.  The search engine named `DEFAULT` is used when
## `url.auto_search` is turned on and something else than a URL was
## entered to be opened. Other search engines can be used by prepending
## the search engine name to the search term, e.g. `:open google
## qutebrowser`.
## Type: Dict
c.url.searchengines = {
    '!dis': 'https://www.discogs.com/search/?q={}',
    '!du': 'https://www.duckduckgo.com/?q={}',
    '!g': 'https://searx.be/search?q={}',
    '!ia': 'https://archive.org/search?query={}',
    '!imdb': 'https://www.imdb.com/find/?q={}',
    '!git': 'https://github.com/search?type=Repositories&q={}',
    '!rym': 'https://rateyourmusic.com/search?searchterm={}',
    '!yt': 'https://yewtu.be/search?q={}',
    'DEFAULT': 'https://searx.be/search?q={}'
}
