/*
 * Michael Salek and Guarav Dubey
 * Mini Project Quick Sort (Knuth Optimized)
*/

#include <bits/stdc++.h>
#include <stdlib.h>
#include <iostream>
#include <time.h>
using namespace std;

// function to swap values when needed
void swap(int* a, int* b){
    int temp = *a;
    *a = *b;
    *b = temp;
}

// randomizes the initial array to start
void randomize(int array[], int size)
{
    srand (time(NULL));

    for (int i = size - 1; i > 0; i--)
    {
        int j = rand() % (i + 1);

        swap(&array[i], &array[j]);
    }
}

// golden mean search function to find the minimum
int goldensearch(int array[], int size){
    int x1 = 0;
    int x4 = size - 1;
    double phi = 1.618;
    int s = (x4-x1)/phi;
    int x2 = x4 - s;
    int x3 = x1 + s;
    while(x4-x1 > 1){
        if(array[x2] < array[x3]){
            x4 = x3;
            x3 = x2;
            s = (x4-x1)/phi;
            x2 = x4 - s;
        }
        else {
            x1 = x2;
            x2 = x3;
            s = (x4 - x1) / phi;
            x3 = x1 + s;
        }
    }
    if(array[x2] > array[x3])
        return x3;
    else
        return x2;
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

// function to perform insertion sort
void insertionsort(int array[], int low, int high){
    int i, key, j;
    for (i = low + 1; i <= high; i++){
        key = array[i];
        j = i - 1;

        while (j >= 0 && array[j] > key)
        {
            array[j + 1] = array[j];
            j = j - 1;
        }
        array[j + 1] = key;
    }
}

// function to continually breaks down the arrays to perform the quicksort
void quicksort(int array[], int low, int high, int k){
    if(high - low < k)
        insertionsort(array, low, high);
    else{
        if(low < high) {
            int part_index = partition(array, low, high);
            quicksort(array, low, part_index - 1, k);
            quicksort(array, part_index + 1, high, k);
        }
    }
}

// function to print the array
void printit(int array[], int size){
    for(int i = 0; i < size; i++){
        std::cout << array[i] << " ";
    }
}

// runs through each of the values of k and decides the best value
int main(){
    // initializes variables
    clock_t t1;
    clock_t t2;
    double t;
    int size = 10000000; // sets the size of the array
    int* array = new int[size];
    int* origarray = new int[size];
    int* k_array = new int[100];

    // populate the array
    for(int i = 0; i < size; i++)
        array[i] = (i + 1)*(i + 1);
    randomize(array, size); // randomize the array
    // save the shuffled array
    for(int i = 0; i < size; i++){
        origarray[i] = array[i];
    }
    // highest value of k to test - used 100 due to other tests showing values over 100 performed worse
    int k_size = 100;

    // run through different values of k
    for(int k = 1; k <= k_size; k++){
        // reset back to the shuffled array for each value of k
        for(int i = 0; i < size; i++){
            array[i] = origarray[i];
        }
        t1 = clock();
        quicksort(array, 0, size -1, k);
        t2 = clock();
        std::cout << "n=" << size << "   time=" << (t2-t1) << "   k=" << k << std::endl;
        // printit(array, size);
        k_array[k-1] = t2-t1; // save the values of runtime for each k
    }

    int k_min = goldensearch(k_array, k_size);
    std::cout << std::endl << "best k value is " << k_min+1 << " with a time of " << k_array[k_min] << " ms";

    delete[] array;
    delete[] origarray;
    delete[] k_array;
    return 0;
}