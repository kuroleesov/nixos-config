# Звук: PipeWire
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # качество: PipeWire сам переключает частоту под трек (без ресемплинга),
    # а когда ресемплинг неизбежен — лучший алгоритм
    extraConfig.pipewire."10-quality" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
        ];
      };
    };
    extraConfig.pipewire-pulse."10-quality" = {
      "stream.properties"."resample.quality" = 10;
    };
    extraConfig.client."10-quality" = {
      "stream.properties"."resample.quality" = 10;
    };
  };
}
