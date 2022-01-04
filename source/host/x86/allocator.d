module host.x86-64.allocator;

import core.memory;
import core.stdc.errno;
import core.stdc.string;
import core.sys.linux.sys.mman;

import std.conv;

import util;

// static this() {
//     auto PAGE_SIZE = pageSize;
// }

void SetupPage() {
    void* page = mmap(
        cast(void*) null, 
        pageSize, 
        PROT_EXEC | PROT_READ | PROT_WRITE,
        MAP_PRIVATE | MAP_ANON,
        -1,
        0
    );

    if (page == MAP_FAILED) {
        LogError(to!string(strerror(errno)));
    }
}