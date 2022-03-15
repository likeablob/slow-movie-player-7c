#include "stash.h"

Preferences preferences;

namespace Stash {

bool save(uint32_t frameInd) {
    if(!preferences.begin(STASH_PREFERENCE_NS, false)) {
        return false;
    }

    preferences.putUInt(STASH_KEY_FRAME_IND, frameInd);

    preferences.end();
}

bool restore(uint32_t &frameInd) {
    if(!preferences.begin(STASH_PREFERENCE_NS, true)) {
        return false;
    }

    frameInd = preferences.getUInt(STASH_KEY_FRAME_IND, 0);

    preferences.end();
}

} // namespace Stash
