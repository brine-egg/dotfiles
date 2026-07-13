{ ... }:
{
  determinateNix = {
    enable = true;
    determinateNixd.garbageCollector.strategy = "automatic";
  };
}
