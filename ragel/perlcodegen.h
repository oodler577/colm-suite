/* Experimental Perl target. This file is part of Ragel and is distributed
 * under the GNU General Public License, version 2 or (at your option) later. */
#ifndef RAGEL_PERLCODEGEN_H
#define RAGEL_PERLCODEGEN_H
#include "gendata.h"

class PerlCodeGen : public CodeGenData {
public:
    explicit PerlCodeGen(ostream &out) : CodeGenData(out) {}
    void finishRagelDef();
    void writeData();
    void writeInit();
    void writeExec();
    void writeExports();
    void writeStart();
    void writeFirstFinal();
    void writeError();
private:
    void action(RedAction *a);
    void condition(GenAction *a);
    void expression(GenInlineList *list);
    int firstFinal();
    int errorState();
};
#endif
