#include <stdio.h>

int fibonacci(int n) {
    if (n == 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return fibonacci(n-1) + fibonacci(n-2);
    }
}

int main() {
    int n;
    printf("Please input a number: ");
    scanf("%d", &n);
    printf("The result of fibonacci(n) is %d\n", fibonacci(n));
    return 0;
}
