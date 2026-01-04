{ colors }:
''
  :set smoothscroll true
  " Tridactyl Solarized Theme
  :colors dark
  :set bg ${colors.base03}
  :set fg ${colors.base0}

  " Custom CSS for Tridactyl UI elements
  :set customcss :root { \
    --tridactyl-bg: ${colors.base03}; \
    --tridactyl-fg: ${colors.base0}; \
    --tridactyl-url-fg: ${colors.blue}; \
    --tridactyl-url-bg: ${colors.base02}; \
    --tridactyl-highlight-box-bg: ${colors.yellow}; \
    --tridactyl-highlight-box-fg: ${colors.base03};
  }
''
