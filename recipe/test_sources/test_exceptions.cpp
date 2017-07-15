#include <stdexcept>
#include <iostream>

int main() {
    try {
        throw std::runtime_error("hello");
    } catch (std::runtime_error &e) {
        std::cout << "hello" << std::endl;
    }
    return 0;
}
