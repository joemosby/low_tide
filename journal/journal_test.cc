#include "journal/journal.h"

#include <string_view>

int main() {
  if (low_tide::Journal::note_count() != 1) {
    return 1;
  }

  const std::string_view note = low_tide::Journal::note();
  if (note.empty()) {
    return 1;
  }

  // Stores a question, not a conclusion. No grade API exists to call.
  if (note.back() != '?') {
    return 1;
  }

  // No next-objective line: one question, one line.
  if (note.find('\n') != std::string_view::npos) {
    return 1;
  }

  return 0;
}
