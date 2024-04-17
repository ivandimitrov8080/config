{ pkgs, ... }: {
  home.packages = with pkgs; [
    goaccess
    ollama
    openssh
    procs
    ripgrep
    scripts
    shell_gpt
    tor-browser-bundle-bin
    woeusb
  ];
}
