/* Experimental Perl target. This file is part of Ragel and is distributed
 * under the GNU General Public License, version 2 or (at your option) later. */
#include <cstdlib>
#include <iostream>
#include "perlcodegen.h"
#include "ragel.h"

extern CodeStyle codeStyle;

static void unsupported(const char *what)
{
    std::cerr << "Perl backend: unsupported " << what << "\n";
    std::exit(1);
}

int PerlCodeGen::errorState() { return redFsm->errState ? redFsm->errState->id : -1; }
int PerlCodeGen::firstFinal() { return redFsm->firstFinState ? redFsm->firstFinState->id : redFsm->nextStateId; }

void PerlCodeGen::finishRagelDef()
{
    if (codeStyle != GenTables) unsupported("code style (only -T0 is available)");
    redFsm->sortByStateId();
    analyzeMachine();
    if (hasLongestMatch) unsupported("scanner/longest match");
    if (getKeyExpr || accessExpr || pExpr || peExpr || eofExpr || csExpr || dataExpr ||
        prePushExpr || postPopExpr || topExpr || stackExpr || actExpr || tokstartExpr || tokendExpr) unsupported("variable or access overrides");
    for (RedStateList::Iter st = redFsm->stateList; st.lte(); st++) {
        if (st->stateCondList.length()) unsupported("semantic conditions");
        if (st->eofTrans) unsupported("EOF transitions");
        if (st->eofAction) {
            for (GenActionTable::Iter a = st->eofAction->key; a.lte(); a++)
                for (GenInlineList::Iter i = *a->value->inlineList; i.lte(); i++)
                    if (i->type == GenInlineItem::Char) unsupported("fc in EOF actions");
        }
    }
    for (GenActionList::Iter a = actionList; a.lte(); a++) {
        if (!a->numRefs()) continue;
        if (a->numFromStateRefs) {
            for (GenInlineList::Iter i = *a->inlineList; i.lte(); i++)
                if (i->type == GenInlineItem::Goto || i->type == GenInlineItem::Call || i->type == GenInlineItem::Ret)
                    unsupported("goto/call/return in from-state actions");
        }
        if (a->numEofRefs) {
            for (GenInlineList::Iter i = *a->inlineList; i.lte(); i++)
                if (i->type == GenInlineItem::Break || i->type == GenInlineItem::Hold || i->type == GenInlineItem::Next || i->type == GenInlineItem::Goto || i->type == GenInlineItem::Call || i->type == GenInlineItem::Ret)
                    unsupported("control statements in EOF actions");
        }
        for (GenInlineList::Iter i = *a->inlineList; i.lte(); i++) {
            if (i->type != GenInlineItem::Text && i->type != GenInlineItem::Char &&
                i->type != GenInlineItem::PChar && i->type != GenInlineItem::Hold &&
                i->type != GenInlineItem::Next && i->type != GenInlineItem::Break &&
                i->type != GenInlineItem::Goto && i->type != GenInlineItem::Call &&
                i->type != GenInlineItem::Ret)
                unsupported("Ragel control statements in actions");
        }
    }
}

void PerlCodeGen::writeData()
{
    if (noPrefix || noEntry || noFinal || noError) unsupported("write data options");
    out << "my $" << fsmName << "_start = " << redFsm->startState->id << ";\n";
    out << "my $" << fsmName << "_first_final = " << firstFinal() << ";\n";
    out << "my $" << fsmName << "_error = " << errorState() << ";\n";
}
void PerlCodeGen::writeExports() { unsupported("write exports"); }
void PerlCodeGen::writeInit() {
    if (!noCS) out << "$cs = " << redFsm->startState->id << ";\n";
    if (redFsm->anyActionCalls() || redFsm->anyActionRets()) out << "$top = 0;\n";
}
void PerlCodeGen::writeStart() { out << redFsm->startState->id; }
void PerlCodeGen::writeFirstFinal() { out << firstFinal(); }
void PerlCodeGen::writeError() { out << errorState(); }
void PerlCodeGen::action(RedAction *a)
{
    if (!a) return;
    for (GenActionTable::Iter item = a->key; item.lte(); item++) {
        for (GenInlineList::Iter i = *item->value->inlineList; i.lte(); i++) {
            if (i->type == GenInlineItem::Text) out << i->data;
            else if (i->type == GenInlineItem::Char) out << "ord(substr($data, $p, 1))";
            else if (i->type == GenInlineItem::PChar) out << "$p";
            else if (i->type == GenInlineItem::Hold) out << "--$p;";
            else if (i->type == GenInlineItem::Next) out << "$cs = " << i->targState->id << ";";
            else if (i->type == GenInlineItem::Break) out << "++$p; goto RAGEL_PERL_OUT;";
            else if (i->type == GenInlineItem::Goto) out << "$cs = " << i->targState->id << "; goto RAGEL_PERL_AGAIN;";
            else if (i->type == GenInlineItem::Call) out << "$stack[$top++] = $cs; $cs = " << i->targState->id << "; goto RAGEL_PERL_AGAIN;";
            else if (i->type == GenInlineItem::Ret) out << "$cs = $stack[--$top]; goto RAGEL_PERL_AGAIN;";
            else unsupported("action item");
        }
        out << "\n";
    }
}
void PerlCodeGen::writeExec()
{
    if (noEnd) unsupported("write exec noend");
    out << "{\n use bytes;\n while ($p < $pe && $cs != " << errorState() << ") {\n";
    if (redFsm->anyFromStateActions()) {
        out << "  my $_ragel_from = $cs;\n";
        for (RedStateList::Iter st = redFsm->stateList; st.lte(); st++) {
            if (st->fromStateAction) {
                out << "  if ($_ragel_from == " << st->id << ") {\n";
                action(st->fromStateAction);
                out << "  }\n";
            }
        }
    }
    out << "  my $_ragel_key = ord(substr($data, $p, 1));\n";
    bool firstState = true;
    for (RedStateList::Iter st = redFsm->stateList; st.lte(); st++) {
        if (st->id == errorState()) continue;
        out << (firstState ? "  if" : "  elsif") << " ($cs == " << st->id << ") {\n";
        firstState = false;
        bool firstTrans = true;
        for (RedTransList::Iter tr = st->outRange; tr.lte(); tr++) {
            out << (firstTrans ? "   if" : "   elsif") << " ($_ragel_key >= " << tr->lowKey.getLongLong()
                << " && $_ragel_key <= " << tr->highKey.getLongLong() << ") {\n";
            firstTrans = false;
            out << "    $cs = " << (tr->value->targ ? tr->value->targ->id : errorState()) << ";\n";
            action(tr->value->action);
            out << "   }\n";
        }
        if (firstTrans) out << "   $cs = " << errorState() << ";\n";
        else out << "   else { $cs = " << errorState() << "; }\n";
        out << "  }\n";
    }
    if (firstState) out << "  $cs = " << errorState() << ";\n";
    else out << "  else { $cs = " << errorState() << "; }\n";
    if (redFsm->anyActionGotos() || redFsm->anyActionCalls() || redFsm->anyActionRets())
        out << "  RAGEL_PERL_AGAIN: ;\n";
    if (redFsm->anyToStateActions()) {
        out << "  my $_ragel_to = $cs;\n";
        for (RedStateList::Iter st = redFsm->stateList; st.lte(); st++) {
            if (st->toStateAction) {
                out << "  if ($_ragel_to == " << st->id << ") {\n";
                action(st->toStateAction);
                out << "  }\n";
            }
        }
    }
    out << "  last if $cs == " << errorState() << ";\n  ++$p;\n }\n";
    if (redFsm->anyEofActions()) {
        out << " if ($p == $pe && defined($eof) && $p == $eof) {\n";
        for (RedStateList::Iter st = redFsm->stateList; st.lte(); st++) {
            if (st->eofAction) {
                out << "  if ($cs == " << st->id << ") {\n";
                action(st->eofAction);
                out << "  }\n";
            }
        }
        out << " }\n";
    }
    out << " RAGEL_PERL_OUT: ;\n}\n";
}
