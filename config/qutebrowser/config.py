# qutebrowser configuration
#
# qutebrowser 3.7.0
#
# This is intentionally a small configuration. Settings not specified here
# use qutebrowser's normal defaults.

# Do not load settings from autoconfig.yml.
# config.py is the authoritative configuration file.
config.load_autoconfig(False)


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ GENERAL                                                                  ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Use the recommended QtWebEngine backend.
c.backend = 'webengine'

# Never ask for confirmation when quitting.
c.confirm_quit = ['never']

# Do not automatically save/restore the current session.
# Use ZZ (defined below) when you explicitly want to save the session.
c.auto_save.session = False


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ START / NEW TABS                                                         ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Start with a completely blank page.
c.url.start_pages = ['about:blank']

# Also use a blank page whenever a new tab/window is opened without a URL.
c.url.default_page = 'about:blank'

# Background of otherwise-empty webpages.
c.colors.webpage.bg = '#313131'


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ DARK MODE                                                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Tell websites that the preferred color scheme is dark.
c.colors.webpage.preferred_color_scheme = 'dark'

# Enable qutebrowser's dark-mode transformation for pages which don't
# provide an adequate dark stylesheet themselves.
c.colors.webpage.darkmode.enabled = True

# Prefer not to invert images unnecessarily.
c.colors.webpage.darkmode.policy.images = 'never'


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ PRIVACY / SECURITY                                                       ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Keep JavaScript enabled for normal web compatibility.
c.content.javascript.enabled = True

# Accept cookies normally. Restricting third-party cookies can break sites
# such as Gmail, so don't use aggressive cookie blocking here.
c.content.cookies.accept = 'all'

# Store cookies between sessions.
c.content.cookies.store = True

# Allow canvas reading. Blocking it can break some websites.
c.content.canvas_reading = True

# Do not allow locally loaded documents to access remote URLs.
c.content.local_content_can_access_remote_urls = False

# Keep local storage enabled for normal web compatibility.
c.content.local_storage = True

# Ask before allowing websites to access geolocation.
c.content.geolocation = 'ask'

# Ask before allowing web notifications.
c.content.notifications.enabled = 'ask'

# Disable hyperlink auditing (<a ping>).
c.content.hyperlink_auditing = False

# Use qutebrowser's normal compatibility-oriented user agent.
# This is intentionally left at the qutebrowser default rather than
# pretending to be Firefox/Chrome.

# Built-in ad/host blocker.
c.content.blocking.enabled = True
c.content.blocking.method = 'auto'
c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
]


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ PERFORMANCE / UNNECESSARY FEATURES                                      ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Don't automatically start HTML5 videos.
c.content.autoplay = False

# Tell sites that reduced animation is preferred.
# This can reduce unnecessary visual activity without disabling JavaScript.
c.content.prefers_reduced_motion = True

# Don't use the built-in PDF.js viewer. PDFs can still be downloaded/opened.
c.content.pdfjs = False


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ COLORS                                                                   ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Palette shared with Sway, foot and Neovim.

BG = '#313131'
BG_DARK = '#101010'
FG = '#e1e1db'
MUTED = '#d8cfd8'
ACCENT = '#de7484'
GREEN = '#a8b89a'
YELLOW = '#c8b875'
BLUE = '#8fa7c7'
CYAN = '#8fb7b5'
URGENT = '#db3d3f'
GRAY = '#555555'


# Tabs

c.colors.tabs.bar.bg = BG_DARK

c.colors.tabs.even.bg = BG
c.colors.tabs.even.fg = MUTED

c.colors.tabs.odd.bg = BG
c.colors.tabs.odd.fg = MUTED

c.colors.tabs.selected.even.bg = FG
c.colors.tabs.selected.even.fg = BG

c.colors.tabs.selected.odd.bg = FG
c.colors.tabs.selected.odd.fg = BG

c.colors.tabs.indicator.start = ACCENT
c.colors.tabs.indicator.stop = ACCENT
c.colors.tabs.indicator.error = URGENT
c.colors.tabs.indicator.system = 'none'


# Status bar

c.colors.statusbar.normal.bg = BG_DARK
c.colors.statusbar.normal.fg = FG

c.colors.statusbar.insert.bg = ACCENT
c.colors.statusbar.insert.fg = BG

c.colors.statusbar.command.bg = BG_DARK
c.colors.statusbar.command.fg = FG

c.colors.statusbar.caret.bg = BG
c.colors.statusbar.caret.fg = FG

c.colors.statusbar.url.fg = FG
c.colors.statusbar.url.success.http.fg = FG
c.colors.statusbar.url.success.https.fg = FG
c.colors.statusbar.url.warn.fg = YELLOW
c.colors.statusbar.url.error.fg = URGENT


# Completion menu

c.colors.completion.even.bg = BG
c.colors.completion.odd.bg = BG_DARK

c.colors.completion.fg = [MUTED, MUTED, MUTED]

c.colors.completion.item.selected.bg = FG
c.colors.completion.item.selected.fg = BG

c.colors.completion.match.fg = ACCENT


# Hints

c.colors.hints.bg = ACCENT
c.colors.hints.fg = BG
c.colors.hints.match.fg = FG


# Keyhint widget

c.colors.keyhint.bg = BG_DARK
c.colors.keyhint.fg = FG
c.colors.keyhint.suffix.fg = ACCENT


# Messages

c.colors.messages.error.bg = URGENT
c.colors.messages.error.border = URGENT
c.colors.messages.error.fg = FG

c.colors.messages.warning.bg = YELLOW
c.colors.messages.warning.border = YELLOW
c.colors.messages.warning.fg = BG

c.colors.messages.info.bg = BG_DARK
c.colors.messages.info.border = GRAY
c.colors.messages.info.fg = FG


# Prompts

c.colors.prompts.bg = BG
c.colors.prompts.fg = FG
c.colors.prompts.border = '1px solid ' + GRAY


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ EDITOR                                                                   ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Use Neovim in a separate foot terminal for text editing.
c.editor.command = [
    'foot',
    '-e',
    'nvim',
    '{file}',
    '+{line}',
]


# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ CUSTOM KEYBINDINGS                                                       ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Explicitly save the current session and quit.
#
# Normal quitting does NOT save the current session.
# ZZ does.
config.bind('ZZ', 'quit --save')

# Open qutebrowser's config.py directly in Neovim.
config.bind(
    ',ce',
    'spawn foot nvim /home/mrcl/.config/qutebrowser/config.py'
)

config.bind(
    ',cs',
    'config-source'
)

# Put the current URL into the command line for editing.
config.bind(
    'eu',
    'edit-url'
)

# Close tabs with double d ('dd') instead of a single d keypress
config.unbind(
    'd'
)

config.bind(
    'dd',
    'tab-close'
)

# Play videos with mpv.
config.bind(
    ',m',
    'spawn umpv {url}'
)

config.bind(
    ',M',
    'hint links spawn umpv {hint-url}'
)
