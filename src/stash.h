#include <Preferences.h>
#include <stdint.h>

#define STASH_PREFERENCE_NS "smp7c"
#define STASH_KEY_FRAME_IND "frameInd"

namespace Stash {

bool save(uint32_t frameInd);
bool restore(uint32_t &frameInd);

} // namespace Stash
