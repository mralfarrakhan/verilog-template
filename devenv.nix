{ pkgs, ... }:

{
  packages = with pkgs; [
    just
    iverilog
    yosys
    gtkwave
    netlistsvg
  ];
}
