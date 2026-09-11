{ pkgs, ... }:

{
  packages = with pkgs; [
    iverilog
    yosys
    just
    openfpgaloader
  ];
}
