class MyChecker {
  String checker(int width) {
    if (width >= 481 && width <= 1024) {
      return "tab";
    } else if (width < 481) {
      return "phone";
    }
    return "large";
  }
}
