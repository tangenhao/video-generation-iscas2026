#include "common/insn.h"

int main(int argc, const char** argv)
{

  common::insn::load_iteration_4  load_insn(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x8000, 0);
  common::insn::store_iteration_4 store_insn(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x8000, 1);
  common::insn::synchronize_indie sync_insn(2, 0, 0, 0, 0, 2, 1, 0, 0);

  sync_insn.print();
  load_insn.print();
  store_insn.print();

  return 0;
}
