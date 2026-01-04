{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";

    history = {
      size = 1000000;
      save = 1000000;
      path = "$HOME/.zsh_history";
      share = true;
      extended = true;
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MAKEFLAGS = "-j";
      CLICOLOR = "true";
    };

    syntaxHighlighting.enable = true;

    initContent = ''
      # Completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' insert-tab pending
      zstyle ':completion:*' menu select

      # Options
      setopt NO_BG_NICE
      setopt NO_LIST_BEEP
      setopt IGNORE_EOF
      setopt PROMPT_SUBST
      setopt LOCAL_OPTIONS
      setopt LOCAL_TRAPS
      setopt COMPLETE_IN_WORD
      setopt COMPLETE_ALIASES
      setopt HIST_VERIFY
      setopt APPEND_HISTORY
      setopt HIST_REDUCE_BLANKS
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
