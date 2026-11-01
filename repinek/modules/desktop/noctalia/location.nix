_: {
  programs.noctalia.settings = {
    location = {
      auto_locate = false; # A VPN makes automatic location unreliable

      # Used for weather and night light
      address = "Moscow, Russia";
      latitude = 55.7558;
      longitude = 37.6173;
    };
  };
}
