#include <stdio.h>

void main(){
    int sapid = 500119624;
    int val;
    while (1){
        printf("Enter SAP id: ");
        scanf("%d", &val);
        if (sapid == val) {
            printf("Matched\n");
        } else {
            printf("Not Matched\n");
        }
    }
}