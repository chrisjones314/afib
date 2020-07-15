

class AFTestStats {
  int pass = 0;
  int fail = 0;

  void addPasses(int p) { pass += p; }
  void addErrors(int f) { fail += f; }

  bool get hasErrors { return fail > 0; }
  int get totalPasses => pass;
  int get totalErrors => fail;



}