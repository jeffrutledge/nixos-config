{ newtabUrl }:
''
  set smoothscroll true

  " Use our custom start page instead of Tridactyl's own new tab page
  set newtab ${newtabUrl}

  " Tridactyl Solarized Theme
  colourscheme solarized

  " Completion navigation bindings
  bind --mode=ex <C-j> ex.next_completion
  bind --mode=ex <C-k> ex.prev_completion
  bind W tabdetach
''
