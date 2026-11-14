{ pkgs, ... }:
{
  home.packages = with pkgs; [
    opencode
  ];

  home.sessionVariables = {
    OLLAMA_API_BASE = "http://localhost:11434";
  };
}
