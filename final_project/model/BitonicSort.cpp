//
// Created by Michael Salek on 12/3/2022.
//

#include <iostream>
#include <fstream>
#include <iomanip>
#include <chrono>
using namespace std;


// puts the pair of values in the requested order from bitonicSort (ascending or descending)
void orderPair(uint32_t array[], uint32_t i, uint32_t j, uint32_t order){
    if (order == (array[i] > array[j])){
        uint32_t tmp = array[i];
        array[i] = array[j];
        array[j] = tmp;
    }
}

// Merges in the sorted values back into the array
void bitonicMerge(uint32_t array[], uint32_t low, uint32_t size, uint32_t order){
    if (size > 1){
        uint32_t k = size/2;
        for (uint32_t i = low; i < low + k; i++)
            orderPair(array, i, i+k, order);
        bitonicMerge(array, low, k, order);
        bitonicMerge(array, low + k, k, order);
    }
}

// initializes the sorting of the pairs in the array and then sorting pairs of those pairs, etc.
void bitonicSort(uint32_t array[], uint32_t low, uint32_t size, uint32_t order){
    if (size > 1){
        uint32_t k = size/2;
        // order is set to 1 to sort the first half in ascending order
        bitonicSort(array, low, k, 1);
        // order is set to 0 to sort the second half in descending order
        bitonicSort(array, low+k, k, 0);
        // Merges the whole sequence together in the order declared (1 for ascending)
        bitonicMerge(array, low, size, order);
    }
}

// begins the bitonicSort
void sort(uint32_t array[], uint32_t size, uint32_t order){
    bitonicSort(array, 0, size, order);
}

// exchanges two values, utilized for the shuffle
void exchange(uint32_t array[], uint32_t l, uint32_t r) {
    if(!array || (l==r))
        return;
    uint32_t tmp= array[l];
    array[l]=array[r];
    array[r]=tmp;
}

// shuffles random values into the array
void  fischeryates_shuffle(uint32_t array[], uint32_t lo, uint32_t hi){
    uint32_t len = hi - lo + 1;
    for(uint32_t i =len-1; i >= lo+1; i--){
        uint32_t random_i = ((uint32_t) random())%(hi-lo+1);
        uint32_t r = lo + random_i;
        exchange(array,r,i);
    }
}

// prints the array
void printit(uint32_t array[], uint32_t size){
    for(int i = 0; i < size; i++){
        std::cout << array[i] << std::endl;
    }
}

// main function
int main(){
    using std::chrono::high_resolution_clock;
    uint32_t size = 1024; // set size of the array
    uint32_t dir = 1; // 1 for ascending 0 for descending

    // initialize the array
    uint32_t array[size];

    // shuffles random values into the array
    fischeryates_shuffle(array,0,size-1);

    /* // saves an original version of the array for use multiple times
    uinit32_t array_orig[size];
    for(uint32_t i = 0; i < size; i++)
        array_orig[i] = array[i];
    */

    ofstream data;
    data.open("C++_BitonicSort_data.txt");
    // puts the unsorted array into the output text file
    data << "The unsorted array is: " << std::endl;
    for(uint32_t i = 0; i < size; i++)
        data << array[i] << std::endl;

    // sorts the array and calculates the time to sort it
    auto t1 = high_resolution_clock::now();
    sort(array, size, dir);
    auto t2 = high_resolution_clock::now();
    std::chrono::duration<double, std::milli> ms_double = t2 - t1;

    // puts the sorted array into the output text file
    data << std::endl << "The sorted array is: " << std::endl;
    for(uint32_t i = 0; i < size; i++)
        data << array[i] << std::endl;

    data.close();

    // outputs the time to sort the array
    std::cout << "Total cycles used for sorting "<< size <<" elememts :" << ms_double.count() << "ms" << std::endl;

    // printit(array, size);

    return 0;
}