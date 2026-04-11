{ ... }:
{
  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
    };
    extraConfig = ''
      set show-mode-in-prompt on
    '';
  };

  home.sessionVariables = {
    # python >=3.13 uses native repl without vi mode
    PYTHON_BASIC_REPL = "1";
  };
}
