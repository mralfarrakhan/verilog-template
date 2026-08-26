{ pkgs, ... }:

{
  packages = with pkgs; [
    iverilog
    yosys
    gtkwave
    netlistsvg
    just
  ];
}
