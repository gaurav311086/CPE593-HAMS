/*
 * Michael Salek and Guarav Dubey
 * Mini Project Quick Sort (Original)
*/

#include <iostream>
#include <time.h>
using namespace std;

// function to swap values when needed
void swap(int* a, int* b){
    int temp = *a;
    *a = *b;
    *b = temp;
}

// function to set the partition of the array
int partition(int array[], int low, int high){
    int pivot = array[high];
    int i = low - 1;

    for (int j = low; j <= high - 1; j++){
        if(array[j] < pivot){
            i++;
            swap(&array[i], &array[j]);
        }
    }
    swap(&array[i + 1], &array[high]);
    return(i + 1);
}

// function to continually breaks down the arrays to perform the quicksort
void quicksort(int array[], int low, int high){
    if(low < high){
        int part_index = partition(array, low, high);
        quicksort(array, low, part_index - 1);
        quicksort(array, part_index + 1, high);
    }
}

// function to print the array
void printit(int array[], int size){
    for(int i = 0; i < size; i++){
        std::cout << array[i] << " ";
    }
}

// runs through each of the cases and sees how long each runs
int main(){
    clock_t t1;
    clock_t t2;
    double t;
    int array_ordered[] = {10, 11, 12, 100, 1000, 1000000, 10000000, 100000000};
    int array_reversed[] = {100000000, 10000000, 1000000, 1000, 1000, 12, 11, 10};
    int array_duplicate[] = {1, 3, 3, 2, 2, 2, 3, 2, 4, 4, 5, 4, 3, 2, 4, 5, 2, 3, 3, 3, 1};
    int array_FisherYates[] = {7, 6, 4, 3, 2, 5, 1};
    int size_ordered = sizeof(array_ordered)/sizeof(array_ordered[0]);
    int size_reversed = sizeof(array_reversed)/sizeof(array_reversed[0]);
    int size_duplicate = sizeof(array_duplicate)/sizeof(array_duplicate[0]);
    int size_FisherYates = sizeof(array_FisherYates)/sizeof(array_FisherYates[0]);
    t1 = clock();
    quicksort(array_ordered, 0, size_ordered - 1);
    t2 = clock();
    std::cout << "sorted array (already ordered): " << std::endl;
    std::cout << "n=" << size_ordered << "   time=" << (t2-t1) << std::endl;
    printit(array_ordered, size_ordered);
    quicksort(array_reversed, 0, size_reversed - 1);
    std::cout << std::endl << std::endl << "sorted array (reversed): " << std::endl;
    std::cout << "n=" << size_reversed << "   time=" << (t2-t1) << std::endl;
    printit(array_reversed, size_reversed);
    quicksort(array_duplicate, 0, size_duplicate - 1);
    std::cout << std::endl << std::endl << "sorted array (duplicate values): " << std::endl;
    std::cout << "n=" << size_duplicate << "   time=" << (t2-t1) << std::endl;
    printit(array_duplicate, size_duplicate);
    quicksort(array_FisherYates, 0, size_FisherYates - 1);
    std::cout << std::endl << std::endl << "sorted array (Fisher Yates): " << std::endl;
    std::cout << "n=" << size_FisherYates << "   time=" << (t2-t1) << std::endl;
    printit(array_FisherYates, size_FisherYates);
    return 0;
}