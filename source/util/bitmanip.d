module util.bitmanip;

T get_nth_bits(T)(T value, uint low, uint high) {
    return (value >> start) & ((1 << (end - start)) - 1);
}

T get_nth_bit(T)(T value, uint n) {
    return (value >> n) & 1;
}