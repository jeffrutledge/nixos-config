{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aider-chat
    opencode
  ];

  home.sessionVariables = {
    OLLAMA_API_BASE = "http://localhost:11434";
  };

  home.file.".aider.conf.yml".text = ''
    model: ollama_chat/qwen2.5-coder:32b
  '';
}
