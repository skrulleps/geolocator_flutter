enum Flavor {
  dev,
  staging,
  production,
}

class F {
  static Flavor appFlavor = Flavor.dev;

  static bool get isProduction => appFlavor == Flavor.production;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'GPS Tracking Dev';
      case Flavor.staging:
        return 'GPS Tracking Staging';
      case Flavor.production:
        return 'GPS Tracking';
    }
  }
}
