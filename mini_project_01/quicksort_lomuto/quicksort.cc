
/*
 * Michael Salek & Guarav Dubey
 * Mini Project Quick Sort (Knuth Optimized)
*/


/*
Hoare partition reference

//https://iq.opengenus.org/hoare-partition/#:~:text=Hoare%20partition%20is%20an%20algorithm%20that%20is%20used,algorithm%20uses%20hoare%20paritition%20to%20partition%20the%20array.

*/


#include <iostream>
#include <time.h>
#include <stdlib.h>
#include <random>
using namespace std;
random_device rd;
mt19937 gen(rd());

#define PATTERN_INCR  0
#define PATTERN_DECR  1
#define PATTERN_REPP  2
#define PATTERN_RAND  3
#define PATTERN_RAND3 4

#undef DEBUG
// #define DEBUG 1

void  exchange(int * arr, int a, int b);
int   partition_hoare(int *array, int low, int high);
void  quicksort_hoare(int *array, int low, int high, int k=0);
int   lomuto_parition(int * a, int lo, int hi);
void  quicksort_lomuto(int * a, int lo, int hi, int ins_sort_max_lvl=0);
void  insertionsort(int * a, int lo, int hi);
void  fischeryates_shuffle(int * a, int lo, int hi);
void  fill_array(int *a,uint32_t n, uint32_t pattern=PATTERN_RAND3);
void  printHeadnTail(int *a,uint32_t size, uint32_t amount=10);
void  test_quicksort_lomuto(int * a, uint32_t n, uint32_t experiments,  uint32_t k=0);
void  test_quicksort_hoare(int * a, uint32_t n, uint32_t experiments, uint32_t k=0);
int   goldensearch(const float *array, const int size);
int   random(int low, int high);
void  extra_credit_knuth_optimized_qsort_hoare(const int n);
void  extra_credit_knuth_optimized_qsort_lomuto(const int n);

int main() {
  // uint32_t n      = 100000000;
  uint32_t n      = 1000000;
  int patterns [4] = {PATTERN_INCR, PATTERN_DECR, PATTERN_REPP, PATTERN_INCR};
  int experiments = 15;
  // int k[15]       = {4, 8, 16, 32, 64 ,128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536};
  int *arr        = new int[n];
  
  
  test_quicksort_hoare(arr,n,experiments);
  test_quicksort_lomuto(arr,n,experiments);
  
  extra_credit_knuth_optimized_qsort_hoare(n);
  extra_credit_knuth_optimized_qsort_lomuto(n);
  
  delete [] arr;
  arr=nullptr; 
  return 0;
}
void  exchange(int * arr, int a, int b) {
  if(!arr || a==b || a <0 || b < 0)
    return;
  int temp  = arr[a];
  arr[a]    = arr[b];
  arr[b]    = temp;
}
int lomuto_parition(int * a, int lo, int hi){
  // int random_i = abs((  int) random(low,high))%(hi-lo+1);
  int random_i = random(lo,hi);
  int rand_pivot = lo + (random_i%(hi-lo+1));
  exchange(a,rand_pivot,hi);
  
  int pivot = hi;
  int v_pivot = a[pivot];  
  int i = lo - 1;
  for(int j = lo; j <= hi -1; j++){
    if(a[j]<= v_pivot){
      i=i+1;
      exchange(a,i,j);
    }
  }
  i=i+1;
  exchange(a,i,pivot);
  return i;
}
void  quicksort_lomuto(int * a, int lo, int hi, int ins_sort_max_lvl){
  if (lo >= hi)
    return;
  int start = lo;
  int end = hi;
  if((ins_sort_max_lvl <=0 ) || ((end - start) >= ins_sort_max_lvl)){
    // lomuto partition    
    int pivot = lomuto_parition(a,start,end);
    quicksort_lomuto(a,start,pivot-1);
    quicksort_lomuto(a,pivot+1,end);
  } else {
    insertionsort(a,start,end);
  }
}

int partition_hoare(int *array, int low, int high){
  //pick a random index in array and swap it with low
  int len = (high-low+1);
  int random_i = random(low,high);
  int rand_index = (random_i%len) + low;
  exchange(array,rand_index,low);

  int pivot = array[low];
  int i = low - 1;
  int j = high + 1;
  while(true){
    do {
      i++;
    }
    while(array[i] < pivot && (i<high));
      
    do {
      j--;
    }
    while(array[j] >= pivot && (j>low));
      
    if(i >= j)
      return j;
    exchange(array,j,i);
  }
  return -1;
}

// function to continually breaks down the arrays to perform the quicksort
void quicksort_hoare(int* array, int low, int high, int k){
  if (low >= high)
    return;
  if(k>0 && ((high - low) < k))
      insertionsort(array, low, high);
  else{
    if(low < high){
        int part_index = partition_hoare(array, low, high);
        quicksort_hoare(array, low, part_index-1,k);
        quicksort_hoare(array, part_index + 1, high,k);
    }
  }
}
void  insertionsort(int * a, int lo, int hi){
  if (!(lo < hi))
    return;
  int start = lo;
  int end = hi;
  int key, i, j;
  for(i = start + 1; i <= end; i++){
    j = i-1;
    key = a[i];
    while(key < a[j] && j >= start){
      a[j+1] = a[j];
      j=j-1;
    }
    a[j+1] = key;
  }
}
void  fischeryates_shuffle(int * a, int lo, int hi){
  int len = hi - lo + 1;
  for(int i =len-1; i >= lo+1; i--){
    // int random_i = (abs((  int) random(low,high)))%(hi-lo+1);
    int random_i = random(lo,hi);
    int r = lo + (random_i%(hi-lo+1));
    exchange(a,r,i);
  }
}
void test_quicksort_lomuto(int *a, uint32_t n, uint32_t experiments, uint32_t k){
  int patterns [4] = {PATTERN_INCR, PATTERN_DECR, PATTERN_REPP, PATTERN_INCR};
  cout <<endl <<  "Testing Quicksort (Lomuto) " <<endl <<  endl;
  for(int tst =0; tst < 4; tst++){
    if(tst==0)
    cout << "Test with array already sorted--ascending!"<<endl;
    if(tst==1)
    cout << "Test with array already sorted--descending!"<<endl;
    if(tst==2)
    cout << "Test with array--with some number repeated!"<<endl;
    if(tst==3)
    cout << "Test with array--with unique but random data!"<<endl;
    for(int run = 0; run < experiments; run++){
      fill_array(a,n,patterns[tst]);
      if(tst==3 || tst==2) fischeryates_shuffle(a,0,n-1);
      clock_t start, end;
      #ifdef DEBUG
      cout<<"Unsorted array:";
      printHeadnTail(a,n);
      #endif
      start = clock();
      quicksort_lomuto(a,0,n-1,k);
      end = clock();
      #ifdef DEBUG
      cout<<"Qsorted array:";
      printHeadnTail(a,n);
      #endif
      double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
      cout  << "n=" << n <<" time = " <<cpu_time_used << " seconds. k = " << k << endl;
    }
  }
}
void test_quicksort_hoare(int *a, uint32_t n, uint32_t experiments, uint32_t k){
  int patterns [4] = {PATTERN_INCR, PATTERN_DECR, PATTERN_REPP, PATTERN_INCR};
  cout << endl << "Testing Original Quicksort (Hoare) " << endl << endl;
  for(int tst =0; tst < 4; tst++){
    if(tst==0)
    cout << "Test with array already sorted--ascending!"<<endl;
    if(tst==1)
    cout << "Test with array already sorted--descending!"<<endl;
    if(tst==2)
    cout << "Test with array--with some number repeated!"<<endl;
    if(tst==3)
    cout << "Test with array--with unique but random data!"<<endl;
    for(int run = 0; run < experiments; run++){
      fill_array(a,n,patterns[tst]);
      if(tst==3 || tst==2) fischeryates_shuffle(a,0,n-1);
      clock_t start, end;
      #ifdef DEBUG
      cout<<"Unsorted array:";
      printHeadnTail(a,n);
      #endif
      start = clock();
      quicksort_hoare(a,0,n-1,k);
      end = clock();
      #ifdef DEBUG
      cout<<"Qsorted array:";
      printHeadnTail(a,n);
      #endif
      double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
      cout  << "n=" << n <<" time = " <<cpu_time_used << " seconds. k = " << k << endl;
    }
  }

}
void fill_array(int *arr, uint32_t n, uint32_t pattern){
  // int random_i = abs((  int) random(low,high));
  int random_i = random(0,n-1);
  int rp_this = (n/16);
  for (uint32_t i = 0; i < n; i++) {
    switch(pattern){
      case PATTERN_INCR:
        arr[i]=i;
        break;
      case PATTERN_DECR:
        arr[i]=n-1-i;
        break;
      case PATTERN_REPP:
        arr[i]=(i%rp_this == 0)? rp_this : i;
        break;
      case PATTERN_RAND:
        // random_i = abs((  int) random(low,high));
        arr[i]=random(0,n-1);
        break;
      case PATTERN_RAND3:
        random_i = random(0,n-1);
        arr[i]=random_i%i;
        break;
      default:
        random_i = random(0,n-1);
        // arr[i]=distribution(generator)%i;
        arr[i]=random_i%i;
        break;
    }
  }
}
void  printHeadnTail(int *a,uint32_t size, uint32_t amount){
  uint32_t  amt = (amount > size )? size : amount;
  cout << "{";
  for(int i =0; i < amt-1; i++)
    cout << a[i] << ",";
  if(amt < size){
    cout<<"??,";
    if((size -1 - amt) > 0) {
      for(int i = size -1 - amt; i <size-1; i++)
        cout << a[i] << ",";
    }
  }
  cout << a[size-1] << "}" <<endl;  
}

// golden mean search function to find the minimum
int goldensearch(const float *array, const int size){
    int x1 = 0;
    int x4 = size - 1;
    double phi = 1.618;
    int s = (((x4-x1)/phi)+0.5); //round
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
            s = (((x4 - x1) / phi)+0.5);//round
            x3 = x1 + s;
        }
    }
    if(array[x2] > array[x3])
        return x3;
    else
        return x2;
}
int random(int low, int high){
    uniform_int_distribution<> dist(low, high);
    return dist(gen);
}
void extra_credit_knuth_optimized_qsort_hoare(const int n) {
  cout << endl << "Knuth optimized qsort hoare " << endl << endl;
  //Knuth Optimized quicksort
  
  // initializes variables
  clock_t t1;
  clock_t t2;
  double t;
  int size = n; // sets the size of the array
  int* array = new int[size];
  int* origarray = new int[size];
  constexpr int k_size = 21;
  float* k_array = new float[k_size];

  // populate the array
  for(int i = 0; i < size; i++)
      array[i] = (i + 1)*(i + 1);
  fischeryates_shuffle(array,0, size-1); // randomize the array
  // save the shuffled array
  for(int i = 0; i < size; i++){
      origarray[i] = array[i];
  }

  // run through different values of k
  int kparam;
  for(int k = 0; k < k_size; k++){
     kparam = (k > 0)?((k/10)*1000+k*100):((k/10)*1000+k*100+4);
      // reset back to the shuffled array for each value of k
      for(int i = 0; i < size; i++){
          array[i] = origarray[i];
      }
      t1 = clock();
      quicksort_hoare(array, 0, size -1, kparam);
      t2 = clock();
      std::cout << "n=" << size << "   time=" << ((double) (t2 - t1)) / CLOCKS_PER_SEC << "   k=" << kparam << endl;
      // printit(array, size);
      k_array[k] = ((double) (t2 - t1)) / CLOCKS_PER_SEC; // save the values of runtime for each k
  }

  int k_min = goldensearch(k_array, k_size);
  kparam = (k_min > 0)?((k_min/10)*1000+k_min*100):((k_min/10)*1000+k_min*100+4);
  cout << endl << "best k value is " << kparam << " with a time of " <<  k_array[k_min] << " ms."<<endl;

  delete[] array;
  delete[] origarray;
  delete[] k_array;
  array=nullptr;
  origarray=nullptr;
  k_array=nullptr;
}
void extra_credit_knuth_optimized_qsort_lomuto(const int n) {
  cout << endl << "Knuth optimized qsort lomuto " << endl << endl;
  
  //Knuth Optimized quicksort
  
  // initializes variables
  clock_t t1;
  clock_t t2;
  double t;
  int size = n; // sets the size of the array
  int* array = new int[size];
  int* origarray = new int[size];
  constexpr int k_size = 21;
  float* k_array = new float[k_size];

  // populate the array
  for(int i = 0; i < size; i++)
      array[i] = (i + 1)*(i + 1);
  fischeryates_shuffle(array,0, size-1); // randomize the array
  // save the shuffled array
  for(int i = 0; i < size; i++){
      origarray[i] = array[i];
  }

  // run through different values of k
  int kparam;
  for(int k = 0; k < k_size; k++){
     kparam = (k > 0)?((k/10)*1000+k*100):((k/10)*1000+k*100+4);
      // reset back to the shuffled array for each value of k
      for(int i = 0; i < size; i++){
          array[i] = origarray[i];
      }
      t1 = clock();
      quicksort_lomuto(array, 0, size -1, kparam);
      t2 = clock();
      std::cout << "n=" << size << "   time=" << ((double) (t2 - t1)) / CLOCKS_PER_SEC<< "   k=" << kparam << endl;
      // printit(array, size);
      k_array[k] = ((double) (t2 - t1)) / CLOCKS_PER_SEC; // save the values of runtime for each k
  }

  int k_min = goldensearch(k_array, k_size);
  kparam = (k_min > 0)?((k_min/10)*1000+k_min*100):((k_min/10)*1000+k_min*100+4);
  cout << endl << "best k value is " << kparam << " with a time of " <<  k_array[k_min] << " ms."<<endl;

  delete[] array;
  delete[] origarray;
  delete[] k_array;
  array=nullptr;
  origarray=nullptr;
  k_array=nullptr;
}