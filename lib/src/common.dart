part of osx;

class Common {
  static bool areHiddenFilesShown() => Defaults.get(Domains.FINDER, "AppleShowAllFiles");
  static void setHiddenFilesShown(bool shown) => Defaults.set(Domains.FINDER, "AppleShowAllFiles", shown);
}

class Domains {
  static const String FINDER = "com.apple.finder";
}

class Volume {
  static int getVolume() {
    return int.parse(runAppleScriptSync("output volume of (get volume settings)"));
  }

  static bool isMuted() {
    return runAppleScriptSync("output of muted of (get volume settings)") == "true";
  }

  static void setVolume(int volume) {
    runAppleScriptSync("set volume output volume ${volume}");
  }

  static void setMuted(bool muted) {
    runAppleScriptSync("set volume ${muted ? 'with' : 'without'} output muted");
  }

  static void mute() => setMuted(true);
  static void unmute() => setMuted(false);
  static void toggleMuted() => setMuted(!isMuted());
}

class SystemInformation {
  static Map<String, dynamic> _info = parseAppleScriptRecord(runAppleScriptSync("system info"));

  static String getVersion() => _info["system version"];
  static String getUser() => _info["short user name"];
  static String getUserName() => _info["long user name"];
  static String getComputerName() => _info["computer name"];
  static String getHostName() => _info["host name"];
  static String getUserLocale() => _info["user locale"];
  static String getHomeDirectory() => _info["home directory"];
  static String getBootVolume() => _info["boot volume"];
  static String getAppleScriptVersion() => _info["AppleScript version"];
  static String getCpuType() => _info["CPU type"];
  static int getCpuSpeed() => _info["CPU speed"];
  static int getPhysicalMemory() => _info["physical memory"];
  static String getIPv4Address() => _info["IPv4 address"];
  static String getPrimaryEthernetAddress() => _info["primary Ethernet address"];
}

class Computer {
  static void sleep() {
    System.runShell("pmset displaysleepnow");
  }

  static void wake() {
    var n = now();
    Process.start("caffeinate", ["-u"]).then((proc) => proc.kill());
  }
}

class System {
  static void beep([int times = 1]) {
    runAppleScriptSync("beep ${times}");
  }

  static String runShell(String command) {
    return runAppleScriptSync('do shell script "${command}"');
  }

  static String runAdminShell(String command) {
    return runAppleScriptSync('do shell script "${command}" with administrator privileges');
  }
}

class Clipboard {
  static void set(String content) {
    var str = content.split("\n").map((it) => '"' + it + '"').join(",");

    runAppleScriptSync("set clipboard to (text of {${str}})");
  }

  static String get() {
    return parseAppleScriptRecord(runAppleScriptSync("paragraphs of (get the clipboard)")).join("\n").trim();
  }
}

class Battery {
  static num getLevel() {
    var info = _info();
    info = info.replaceAll("\t", "; ");
    var x = info.split("; ")[1];
    x = x.substring(0, x.indexOf("%"));
    return num.parse(x);
  }

  static bool isCharging() {
    return _info().contains("charging;");
  }

  static bool isPluggedIn() {
    var info = _info();
    return info.contains("charging;") || info.contains("charged;");
  }

  static String _info() {
    return Process.runSync("pmset", ["-g", "batt"]).stdout.split("\n")[1].trim();
  }
}
