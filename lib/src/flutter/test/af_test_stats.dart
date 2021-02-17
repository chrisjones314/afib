

class AFTestStats {
  int pass = 0;
  int fail = 0;
  int disabled = 0;

  void addPasses(int p) { pass += p; }
  void addErrors(int f) { fail += f; }
  void addDisabled(int d) { disabled += d; }

  bool get hasErrors { return fail > 0; }
  int get totalPasses => pass;
  int get totalErrors => fail;
  int get totalDisabled => disabled;
  bool get isEmpty { return pass == 0 && fail == 0 && disabled == 0; }
  void mergeIn(AFTestStats other) {
    pass += other.pass;
    fail += other.fail;
    disabled += other.disabled;
  }



}