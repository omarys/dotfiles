c.aliases = {
    "esc": "fake-key <Esc>",
    "git": "open -t github.com",
    "gmail": "open -t gmail.com",
    "hn": "open -t hckrnews.com",
    "o": "open -t",
    "p": "open -p",
    "q": "quit",
    "red": "open -t reddit.com",
    "so": "open -t stackoverflow.com",
    "tt": "open -t twitter.com",
    "w": "session-save",
    "wq": "quit --save",
    "yt": "open -t youtube.com",
}

config.set("content.javascript.enabled", True, "file://*")
config.set("content.javascript.enabled", True, "chrome://*/*")
config.set("content.javascript.enabled", True, "qute://*/*")

c.url.default_page = "https://google.com"
c.url.searchengines = {"DEFAULT": "https://google.com/search?q={}"}
c.url.start_pages = "https://google.com"

c.tabs.position = "left"
c.tabs.width = "8%"
c.tabs.background = True

config.load_autoconfig()
