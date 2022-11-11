#include <iostream>
#include <cstdlib>
#include <time.h>
#include <vector>
using namespace std;

#define DEBUG 1

uint32_t quicksort_lomuto_parition(vector <int> & a, uint32_t lo, uint32_t hi, bool descend= false);
void quicksort(vector <int> & a, uint32_t lo, uint32_t hi, bool descend= false);
void test_quicksort();

int main() {
  test_quicksort();
  return 0;
}


void quicksort(vector <int> &  a, uint32_t lo, uint32_t hi, bool descend) {
  if (!a.size() || !(lo < hi))
    return;
  #ifndef DEBUG
  srand(time(0));
  #endif
  uint32_t len = hi - lo + 1;
  uint32_t rand_pivot = lo + rand()%len;
  swap(a[rand_pivot],a[hi]);
  
  uint32_t pivot = quicksort_lomuto_parition(a,lo,hi,descend);
  if(!(pivot == lo))
    quicksort(a,lo,pivot-1,descend);
  if(!(pivot == hi))
    quicksort(a,pivot+1,hi,descend);
}
uint32_t quicksort_lomuto_parition(vector <int> & a, uint32_t lo, uint32_t hi, bool descend) {
  uint32_t pivot = hi;
  int & val_pivot = a[hi];  
  uint32_t i = lo - 1;  
  for(uint32_t j = lo; j <= hi -1; j++){
    int & a_j = a[j];
    if(a_j<= val_pivot && !descend ){
      i=i+1;
      if(i!=j)
        swap(a[i],a[j]);
    }
    if(a_j>= val_pivot && descend ){
      i=i+1;
      if(i!=j)
        swap(a[i],a[j]);
    }
  }
  i=i+1;
  swap(a[i],a[pivot]);
  return i;
}
void test_quicksort(){
  constexpr uint32_t n[11] = {10, 11, 12, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000};
  // constexpr uint32_t n[1] = {100000000};
  // constexpr uint32_t n[1] = {10, 11, 12, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000};
  for (uint32_t run =0; run < 11; run++){
    vector<int> a(n[run]);
    if(false/*n[run] < 1000*/) {
      cout << "Logging for elements < 1000" << endl;
      cout << "unsort:{";
      for(uint32_t i =0;i<n[run]-1;i++){
        a[i]=i;
        cout << a[i] << ",";
      }
      a[n[run]-1]=n[run]-1;
      cout << a[n[run]-1] << "}" << endl;
    }
    clock_t start, end;
    start = clock();
    quicksort(a,0,n[run]-1);
    end = clock();
    double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    if(false/*n[run] < 1000*/) {
      cout << "sort:{";
      for(uint32_t i =0;i<n[run]-1;i++){
        cout<<a[i]<<",";
      }
      cout << a[n[run]-1] << "}" << endl;
    }
    // delete [] a;
    cout << "Sorted '" << n[run] <<"' elements!" << endl;
    cout << "CPU time used is: " <<cpu_time_used << " s." << endl;
  }
  for (uint32_t run =0; run < 11; run++){
    vector<int> a(n[run]);
    if(false/*n[run] < 1000*/) {
      cout << "Logging for elements < 1000" << endl;
      cout << "unsort:{";
      for(uint32_t i =n[run]-1;i>=1;i--){
        a[i]=i;
        cout << a[i] << ",";
      }
      a[n[run]-1]=0;
      cout << a[n[run]-1] << "}" << endl;
    }
    clock_t start, end;
    start = clock();
    quicksort(a,0,n[run]-1);
    end = clock();
    double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    if(false/*n[run] < 1000*/) {
      cout << "sort:{";
      for(uint32_t i =0;i<n[run]-1;i++){
        cout<<a[i]<<",";
      }
      cout << a[n[run]-1] << "}" << endl;
    }
    cout << "Sorted '" << n[run] <<"' elements!" << endl;
    cout << "CPU time used is: " <<cpu_time_used << " s." << endl;
  }
}
