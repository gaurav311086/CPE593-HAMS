#include <iostream>
#include <cstdlib>
#include <time.h>
#include <vector>
using namespace std;

#define PATTERN_INCR  0
#define PATTERN_DECR  1
#define PATTERN_RAND1 2
#define PATTERN_RAND2 3
#define PATTERN_RAND3 4

  
class algo {
  private:
    void  exchange(int * arr, int a, int b) {
      if(!arr || a==b)
        return;
      int temp  = arr[a];
      arr[a]    = arr[b];
      arr[b]    = temp;
    }
    int   lomuto_parition(int * a, int lo, int hi/*, bool descend= false*/){
      int len = hi - lo + 1;
      int rand_pivot = lo + rand()%len;
      exchange(a,rand_pivot,hi);
      
      int pivot = hi;
      int v_pivot = a[pivot];  
      int i = lo - 1;
      for(int j = lo; j <= hi -1; j++){
        if(a[j]<= v_pivot /*&& !descend*/ ){
          i=i+1;
          exchange(a,i,j);
        }
        /*if(a[j]>= v_pivot && descend ){
          i=i+1;
          exchange(a[i],a[j]);
        }*/
      }
      i=i+1;
      exchange(a,i,pivot);
      return i;
    }
  public:
    void  quicksort_lomuto(int * a, int lo, int hi, int ins_sort_max_lvl=8/*, bool descend= false*/){
      if (lo >= hi)
        return;
      int start = lo;
      int end = hi;
      if((end - start) >= ins_sort_max_lvl){
        // lomuto partition    
        int pivot = lomuto_parition(a,start,end/*,descend*/);
        quicksort_lomuto(a,start,pivot-1/*,descend*/);
        quicksort_lomuto(a,pivot+1,end/*,descend*/);
      } else {
        insertionsort(a,start,end/*,descend*/);
      }
    }
    void  fischeryates_shuffle(int * a, int lo, int hi){
      int len = hi - lo + 1;
      for(int i =len-1; i >= lo+1; i--){
        int r = lo + rand()%len;
        exchange(a,r,i);
      }
    }
    void  insertionsort(int * a, int lo, int hi/*, bool descend= false*/){
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
};

void  fill_array(int *a,uint32_t n, uint32_t pattern=PATTERN_RAND3);
void  justheadtail(int *a,uint32_t size, uint32_t amount=10);
void  test_quicksort(int * a, uint32_t n, uint32_t k);


int main() {
  uint32_t n      = 100000000;
  // uint32_t n      = 8;
  int experiments = 10;
  int k[10]       = {4, 8, 10, 50, 100, 125, 150, 175, 200, 250};
  int *arr        = new int[n];
  fill_array(arr,n,PATTERN_INCR);
  // cout<<"Initial array:";
  // justheadtail(arr,n);
  for(int run = 0; run < experiments; run++){
    test_quicksort(arr,n,k[run]);
  }
  delete [] arr;
  arr=nullptr;
  return 0;
}

void test_quicksort(int *a, uint32_t n, uint32_t k){
  algo algo;
  // algo.fischeryates_shuffle(a,0,n-1);
  clock_t start, end;
  // cout<<"Shuffle array:";
  // justheadtail(a,n);
  start = clock();
  algo.quicksort_lomuto(a,0,n-1,k);
  // algo.insertionsort(a,0,n-1);
  end = clock();
  // cout<<"Qsorted array:";
  // justheadtail(a,n);
  double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
  cout  << "n=" << n <<" time = " <<cpu_time_used << " seconds. k = " << k << endl;
}
void fill_array(int *arr, uint32_t n, uint32_t pattern){
  for (uint32_t i = 0; i < n; i++) {
    switch(pattern){
      case PATTERN_INCR:
        arr[i]=i;
        break;
      case PATTERN_DECR:
        arr[i]=n-1-i;
        break;
      case PATTERN_RAND1:
        arr[i]=rand()%n;
        break;
      case PATTERN_RAND2:
        arr[i]=rand()%256;
        break;
      case PATTERN_RAND3:
        arr[i]=rand()%i;
        break;
      default:
        arr[i]=rand()%i;
        break;
    }
  }
}
void  justheadtail(int *a,uint32_t size, uint32_t amount){
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